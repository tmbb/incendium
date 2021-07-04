defmodule Incendium.Flamegraph do
  @moduledoc false

  def file_to_hierarchy(path) do
    path
    |> file_to_stacks()
    |> stacks_to_hierarchy()
    |> maybe_wrap_in_root()
  end

  def file_to_stacks(path) do
    # A stack file consists of a number of sampled stack frames.
    # Each stack frame is separated from the following one by a newline.
    # Function calls in the stack frame are separated by semicolons.
    File.read!(path)
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, ";") end)
  end

  def stacks_to_hierarchy(stacks) do
    # d3-flamegraph expects a pretty specific format for the data.
    level =
      Enum.reduce(stacks, %{}, fn
        [], acc ->
          acc


        [frame | stack], acc ->
          case acc do
            %{^frame => stacks_for_frame} ->
              %{acc | frame => [stack | stacks_for_frame]}

            _acc ->
              Map.put(acc, frame, [stack])
          end
      end)

    handle_level(level)
  end

  defp handle_level(level) do
    for {frame, stacks} <- level do
      levels = stacks_to_hierarchy(stacks)
      %{name: frame, value: length(stacks), children: levels}
    end
  end

  defp maybe_wrap_in_root(hierarchy) when is_map(hierarchy), do: hierarchy

  defp maybe_wrap_in_root(hierarchy) when is_list(hierarchy) do
    value =
      hierarchy
      |> Enum.map(fn node -> node.value end)
      |> Enum.sum()

    %{name: "root", value: value, children: hierarchy}
  end
end
