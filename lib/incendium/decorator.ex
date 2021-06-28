defmodule Incendium.Decorator do
  @moduledoc """
  Defines decorators to profile function calls.
  """

  use Decorator.Define, [
    incendium_profile_with_tracing: 0
  ]

  alias Incendium.Storage

  @doc """
  *Decorator*. When the decorated function is invoked,
  it will bd profiled using tracing.

  Stack data will be written to #{Storage.latest_stacks_path()}.

  **Note**: profiling will be disabled if `Mix.env() == :prod`.
  This means it's safe(ish) to leave these decorators in a production
  environment.
  It's never a good idea to profile in prod using the `:eflame`
  library, as it makes your code run ~10x slower.


  ## Example

      defmodule MyApp.UserController do
        # ...
        use Incendium.Decorator

        @decorate incendium_profile_with_tracing()
        def index(conn, params) do
          # ...
        end
      end
  """
  def incendium_profile_with_tracing(body, _context) do
    # If we're not in prod, it's safe to profile
    if Mix.env() in [:dev, :test] do
      Storage.latest_stacks_path()
      |> Path.dirname()
      |> File.mkdir_p!()

      quote do
        Incendium.profile_with_tracing(fn -> unquote(body) end)
      end
    # It's never a good idea to profile in prod
    # (your functions will run ~10x slower)
    else
      body
    end
  end
end
