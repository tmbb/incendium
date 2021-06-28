defmodule Incendium.Storage do
  @moduledoc false

  # TODO: maybe expand this into a real solution which stores
  # profile data in a persistent backend such as ETS tables.

  def latest_stacks_path() do
    Path.join("incendium", "stacks.out")
  end
end
