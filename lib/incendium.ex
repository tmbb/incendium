defmodule Incendium do
  @moduledoc """
  Incendium is a way of ...
  """

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
