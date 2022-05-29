defmodule Incendium do
  @external_resource "README.md"

  readme_part =
    "README.md"
    |> File.read!()
    |> String.split("<!-- ex_doc -->")
    |> Enum.at(1)

  @moduledoc """
  Easy flamegraphs to profile for your web applications.

  #{readme_part}
  """

  @doc """
  Runs benchmarks using `Benchee` and render the scenarios as flamegraphs.

  Takes the same parameters as `Benchee.run/2`.
  Takes the following `Incendium`-specific options:

    - `:incendium_flamegraph_widths_to_scale` (default `true`) -
      sets the width of the flamegraphs according to the scenario runtime.
      Scenarios that take a longer time to run will generate wider flamegraphs.

    - `:incendium_file` (default `"incendium/\#{suite.title}`) -
      the path to the HTML file were Incendium saves the benchmark results
      (in Benchee, this is specified by a Formatter, bue Incendium unfortunatelly
      can't reuse the normal Benchee formatting infrastructure)

  All other options are passed into `Benchee.run/2`
  """
  def run(benchmarks, options) do
    Incendium.Benchee.run(benchmarks, options)
  end


  alias Incendium.Storage

  @doc """
  Adds routes for an Incendium controller.
  """
  defmacro routes(controller) do
    require Phoenix.Router
    quote do
      Phoenix.Router.get "/", unquote(controller), :latest_flamegraph
    end
  end

  @doc """
  Profiles a function call using tracing (as opposed to sampling).

  This profiler uses [`:eflame`](https://github.com/proger/eflame) under the hood.
  Profiled code will be very slow. Never use this in production.
  Stack data will be written to #{Storage.latest_stacks_path()}.
  """
  def profile_with_tracing(fun) do
    output_file = Storage.latest_stacks_path() |> to_charlist()
    :eflame.apply(:normal_with_children, output_file, fun, [])
  end
end
