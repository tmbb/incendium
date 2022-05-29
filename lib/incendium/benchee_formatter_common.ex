defmodule Incendium.BencheeFormatterCommon do
  alias Incendium.BencheeServer
  alias Incendium.Flamegraph
  alias Incendium.BencheeFormatterData

  @moduledoc false

  def format(incendium_suite, original_suite, _options) do
    suite_name =  incendium_suite.configuration.title
    # To draw the flamegraphs we only care about the incendium_suite
    scenarios = incendium_suite.scenarios
    groups = BencheeServer.get_filenames_by_scenario(suite_name)
    data_size = get_humanized_data_size(groups)

    medians = Enum.map(scenarios, fn scenario -> scenario.run_time_data.statistics.median end)
    max_median = Enum.max(medians)
    flamegraph_multipliers = Enum.map(medians, fn median -> median / max_median end)

    scenarios_data =
      for {scenario, multiplier} <- List.zip([scenarios, flamegraph_multipliers]) do
        filenames = Map.fetch!(groups, scenario.name)
        hierarchy = Flamegraph.files_to_hierarchy(filenames)
        json_hieararchy = Jason.encode!(hierarchy)

        data = %{
          id: unique_id(),
          name: scenario.name,
          hierarchy: json_hieararchy,
          flamegraph_width_multiplier: multiplier,
          slug: Slug.slugify(scenario.name)
        }

        data
      end

    # We've already extracted data from the files
    # We can delete them now
    delete_tmp_files(groups)

    %BencheeFormatterData{
      incendium_suite: incendium_suite,
      incendium_scenarios_data: scenarios_data,
      original_suite: original_suite,
      disk_space_usage: data_size
    }
  end

  defp delete_tmp_files(groups) do
    groups
    # lists of files
    |> Map.values()
    # Concat them all into a big list of files
    |> Enum.concat()
    # Delete them all
    |> Enum.map(&File.rm!/1)
  end

  defp get_humanized_data_size(groups) do
    data_size = get_data_size(groups)

    data_size
    |> Enum.map(fn {k, v} -> {k, Size.humanize!(v)} end)
    |> Enum.into(%{})
  end

  defp get_data_size(groups) do
    groups
    |> Enum.map(&data_size_in_bytes_for_group/1)
    |> Enum.into(%{})
  end

  defp data_size_in_bytes_for_group({scenario, filenames} = _group) do
    size =
      filenames
      |> Enum.map(&File.stat!/1)
      |> Enum.map(fn stat -> stat.size end)
      |> Enum.sum()

    {scenario, size}
  end

  defp unique_id() do
    suffix = Enum.map(1..32, fn _ -> random_char() end)
    to_string(["incendium_", suffix])
  end

  defp random_char() do
    [?a..?z, ?A..?Z] |> Enum.random() |> Enum.random()
  end
end
