defmodule Incendium.Controller do
  alias Incendium.{
    Flamegraph,
    Assets,
    Storage
  }

  @doc """
  Turn the current module into an Icendium controller.

  Options:

    * `routes_module` (required) - The module that contains the routes
      in your application (it should be something like `YourApp.Router.Helpers`)

    * `:otp_app` (required) - The main OTP application

  ## Examples

      defmodule MyApp.IncendiumController do
        use Incendium.Controller,
          routes_module: MyApp.Router.Helpers,
          otp_app: :my_app
      end
  """
  defmacro __using__(opts) do
    routes_module = Keyword.fetch!(opts, :routes_module)
    otp_app = Keyword.fetch!(opts, :otp_app)

    app_priv = :code.priv_dir(otp_app)

    static_js_dest = Path.join([app_priv, "static", "js", "incendium.js"])
    static_css_dest = Path.join([app_priv, "static", "css", "incendium.css"])

    File.cp!(Assets.css_path(), static_css_dest)
    File.cp!(Assets.js_path(), static_js_dest)

    quote do
      use Phoenix.Controller

      def latest_flamegraph(conn, params) do
        Incendium.Controller.latest_flamegraph(conn, params, unquote(routes_module))
      end
    end
  end

  @doc false
  def latest_flamegraph(conn, _params, routes_module) do
    latest_hierarchy =
      Storage.latest_stacks_path()
      |> Flamegraph.file_to_hierarchy()
      |> Jason.encode!()

    body =
      Incendium.View.render("latest-flamegraph.html",
        conn: conn,
        routes_module: routes_module,
        latest_hierarchy: latest_hierarchy
      )
      |> Phoenix.HTML.Safe.to_iodata()

    Plug.Conn.send_resp(conn, 200, body)
  end
end
