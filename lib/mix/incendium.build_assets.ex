defmodule Mix.Tasks.Incendium.BuildAssets do
  use Mix.Task
  alias Incendium.Assets

  @impl Mix.Task
  def run(args) do
    case "--offline" in args do
      true -> Assets.build_assets_offline()
      false -> Assets.build_assets()
    end
  end
end
