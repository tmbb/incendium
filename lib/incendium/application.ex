defmodule Incendium.Application do
  use Application

  @moduledoc false

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Registry, keys: :unique, name: Incendium.BencheeServer.Registry}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
