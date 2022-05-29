defmodule Incendium.BencheeServer do
  use Agent

  @moduledoc false

  # Public API

  def start_link(suite_name) do
    # The state is basically a map from filenames to scenarios, so that we
    # can aggregate the stack frames from multiple executions.
    initial_state = %{
      suite: suite_name,
      filenames: %{}
    }

    # We've setup a registry when we started out Incendium application
    name = registered_name_for(suite_name)

    Agent.start_link(fn -> initial_state end, name: name)
  end

  def get_new_filename_for_scenario(suite_name, scenario_name) do
    filename = get_tmp_file()

    name = registered_name_for(suite_name)
    # Update the map to tell the agent which scenario the filename corresponds to.
    Agent.update(name, fn state ->
      update_filenames(state, filename, scenario_name)
    end)

    # Return the filename to be used later
    filename
  end

  def get_filenames_by_scenario(suite_name) do
    state = get_state_from_suite_name(suite_name)
    group_filenames_by_scenario(state.filenames)
  end

  # Helpers:

  defp get_state_from_suite_name(suite_name) do
    name = registered_name_for(suite_name)
    Agent.get(name, & &1)
  end

  defp registered_name_for(suite_name) do
    {:via, Registry, {Incendium.BencheeServer.Registry, suite_name}}
  end

  defp random_char() do
    [?a..?z, ?A..?Z] |> Enum.random() |> Enum.random()
  end

  defp random_filename() do
    suffix = Enum.map(1..32, fn _ -> random_char() end)
    to_string(["incendium_call_stack_", suffix])
  end

  defp get_tmp_file() do
    dir = System.tmp_dir!()
    filename = random_filename()
    Path.join(dir, filename)
  end

  def update_filenames(state, filename, scenario_name) do
    %{state | filenames: Map.put(state.filenames, filename, scenario_name)}
  end

  defp group_filenames_by_scenario(filenames) do
    get_scenario = fn {_filename, scenario_name} -> scenario_name end
    get_filename = fn {filename, _scenario_name} -> filename end

    # Walk the filename/scenario pairs, grouping them according to the scenario.
    # Keep the filename as a value (the scenario will be the key)
    Enum.group_by(filenames, get_scenario, get_filename)
  end
end
