defmodule Mix.Tasks.Incendium.Assets do
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    _dir =
      case args do
        [dir] -> dir
        _ -> raise "Task requires a directory name as a single argument"
      end
  end
end
