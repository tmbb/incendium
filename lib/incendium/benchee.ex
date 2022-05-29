defmodule Incendium.Benchee do
  @moduledoc false

  alias Incendium.BencheeServer

  @doc """
  TODO:
  """
  def run(benchmarks, options) do
    suite_name = Keyword.fetch!(options, :title)
    {incendium_flamegraph_widths_to_scale, options} =
      Keyword.pop(options, :incendium_flamegraph_widths_to_scale, false)

    # Run the original suite so that we get runtimes not affected by the profiler.
    original_suite = Benchee.run(benchmarks, options)

    # After running the original suite, we'll run a suite in which all function
    # executions are wrapped by the profiler.
    # We can compare the runtime of the scenarios from both suites to see if
    # runtimes of different scenarios remain proportional.
    # This is a useful sanity check because tracing profilers may distort
    # the runtime of different functions in different ways.

    # Pass the original suite as an argument to the formatter so that we can access the
    # original runtime values (those not affected by the formatter) when formatting
    # our data
    incendium_formatter =
      {Incendium.BencheeHtmlFormatter, [
        original_suite: original_suite,
        flamegraph_scale_widths: incendium_flamegraph_widths_to_scale
      ]}

    # We don't want any of the default formatters here;
    # They'd be operating on wrong data (data "contaminated" by the profiler)
    options_for_profiling = Keyword.put(options, :formatters, [incendium_formatter])


    benchmarks_for_profiling = prepare_benchmarks_for_profiling(suite_name, benchmarks)
    # Start a server for this benchmarks suite
    BencheeServer.start_link(suite_name)
    # Now, run the new benchmarks
    Benchee.run(benchmarks_for_profiling, options_for_profiling)
    # The Incendium.BencheeFormatter will kill the BencheeServer
    # when it's done collecting the data
  end

  defp profiled_function(suite_name, scenario_name, fun) do
    case Function.info(fun, :arity) do
      # The function we're about to profile doesn't take an input
      {:arity, 0} ->
        # Return a function that doesn't take an input
        fn ->
          # We need a new filename for each function evocation
          filename = BencheeServer.get_new_filename_for_scenario(suite_name, scenario_name)
          :eflame.apply(:normal_with_children, filename, fun, [])
        end

      # The function we're about to profile expects an input.
      # The function wrapped in the profiler must receive an input too.
      {:arity, 1} ->
        fn input ->
          # We need a new filename for each function evocation
          filename = BencheeServer.get_new_filename_for_scenario(suite_name, scenario_name)
          :eflame.apply(:normal_with_children, filename, fn -> fun.(input) end, [])
        end

      {:arity, arity} -> raise "Invalid function arity #{arity}; function arity must be 0 or 1"
    end
  end

  defp prepare_benchmarks_for_profiling(suite_name, benchmarks) do
    for {scenario_name, args} <- benchmarks, into: %{} do
      # Args can either contain just a function or a pair
      # containing both a function and a hook
      case args do
        {fun, hooks} when is_function(fun) and is_list(hooks) ->
          new_fun = profiled_function(suite_name, scenario_name, fun)
          {scenario_name, {new_fun, hooks}}

        fun when is_function(fun) ->
          new_fun = profiled_function(suite_name, scenario_name, fun)
          {scenario_name, new_fun}
      end
    end
  end
end
