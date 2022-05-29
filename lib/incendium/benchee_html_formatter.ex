defmodule Incendium.BencheeHtmlFormatter do
  alias Incendium.BencheeFormatterData
  alias Incendium.BencheeFormatterCommon
  # this module will be used in the templates to embed the static assets
  alias Incendium.Assets

  alias Benchee.Conversion
  alias Benchee.Conversion.{DeviationPercent, Format, Scale}

  require EEx

  @moduledoc false

  @behaviour Benchee.Formatter

  function_from_eex_file =
    fn kind, name, path ->
      @external_resource path

      EEx.function_from_file(
        kind,
        name,
        path,
        [:assigns],
        # Use the Phoenix engine to handle escaping automatically
        engine: Phoenix.HTML.Engine
      )
    end

  @impl true
  def format(incendium_suite, options) do
    original_suite = Map.fetch!(options, :original_suite)
    BencheeFormatterCommon.format(incendium_suite, original_suite, options)
  end

  @impl true
  def write(formatter_data = %BencheeFormatterData{}, options) do
    %{incendium_suite: incendium_suite,
      incendium_scenarios_data: incendium_scenarios_data,
      original_suite: original_suite,
      disk_space_usage: disk_space_usage
      } = formatter_data

    incendium_config = incendium_suite.configuration
    incendium_scaling_strategy = incendium_config.unit_scaling
    incendium_units = Conversion.units(incendium_suite.scenarios, incendium_scaling_strategy)

    original_config = original_suite.configuration
    original_scaling_strategy = original_config.unit_scaling
    original_units = Conversion.units(original_suite.scenarios, original_scaling_strategy)

    default_file = Path.join("incendium", incendium_suite.configuration.title <> ".html")
    file = Map.get(options, :incendium_file, default_file)
    _embed = Map.get(options, :embed, true)
    flamegraph_widths_to_scale = Map.get(options, :incendium_flamegraph_widths_to_scale, true)

    html =
      suite_html(
        flamegraph_widths_to_scale: flamegraph_widths_to_scale,
        original_suite: original_suite,
        original_units: original_units,
        incendium_suite: incendium_suite,
        incendium_scenarios_data: incendium_scenarios_data,
        incendium_units: incendium_units,
        disk_space_usage: disk_space_usage,
        # Always embed the JS and CSS to make it easier to share benchmarks
        embed: true
      )

    # Create the directory if it doesn't exist already
    file |> Path.dirname() |> File.mkdir_p!()
    # Save the HTMl as a file
    File.write!(file, html)
  end

  # Helpers

  flamegraph_template_path = "lib/incendium/templates/partials/flamegraph.html.eex"
  data_table_template_path = "lib/incendium/templates/partials/data_table.html.eex"
  disk_space_usage_template_path = "lib/incendium/templates/partials/disk_space_usage.html.eex"
  system_info_template_path = "lib/incendium/templates/partials/system_info.html.eex"
  flamegraph_js_template = "lib/incendium/templates/flamegraph.js.eex"
  suite_template = "lib/incendium/templates/suite.html.eex"

  @external_resource flamegraph_template_path
  @external_resource data_table_template_path
  @external_resource disk_space_usage_template_path
  @external_resource system_info_template_path
  @external_resource flamegraph_js_template
  @external_resource suite_template


  function_from_eex_file.(
    :defp,
    :flamegraph_html,
    flamegraph_template_path
  )

  function_from_eex_file.(
    :defp,
    :data_table_html,
    data_table_template_path
  )

  function_from_eex_file.(
    :defp,
    :disk_space_usage_html,
    disk_space_usage_template_path
  )

  function_from_eex_file.(
    :defp,
    :system_info_html,
    system_info_template_path
  )

  function_from_eex_file.(
    :defp,
    :flamegraph_js,
    flamegraph_js_template
  )

  function_from_eex_file.(
    :defp,
    :suite_html_raw,
    suite_template
  )

  @doc false
  def suite_html(assigns) do
    suite_html_raw(assigns) |> Phoenix.HTML.safe_to_string()
  end

  # Stuff literally stolen from Benchee

  defp format_mode(nil, _unit) do
    "none"
  end

  defp format_mode(modes = [_ | _], unit) do
    modes
    |> Enum.map(fn mode -> format_property(mode, unit) end)
    |> Enum.join(", ")
  end

  defp format_mode(value, unit) do
    format_property(value, unit)
  end

  defp format_property(value, unit) do
    Format.format({Scale.scale(value, unit), unit})
  end

  defp format_percent(deviation_percent) do
    DeviationPercent.format(deviation_percent)
  end
end
