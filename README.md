# Incendium


Easy profiling for your Phoenix controller actions (and other functions) using [flamegraphs](http://www.brendangregg.com/flamegraphs.html).

#### Example flamegraph

<link rel="stylesheet" href="doc_extra/assets/incendium.css" />
<script src="doc_extra/assets/incendium.js" charset="utf-8"></script>

<script type="text/javascript" src="doc_extra/assets/incendium_flamegraph_hkctthqlqhcubcsgrazymmvaldzllxbq.js"></script>

## Installation

The package can be installed
by adding `incendium` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:incendium, "~> x.y.z"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/incendium](https://hexdocs.pm/incendium).

<!-- ex_doc -->
## Rationale

Profiling Elixir code is easy using the default Erlang tools, such as `fprof`.
These tools produce a lot of potentially useful data, but visualizing and interpreting all that data is not easy.
The erlang tool [`eflame`](https://github.com/proger/eflame) contains some utilities to generate flamegraphs from the results of profiling your code

But... `eflame` expects you to manually run a bash script, which according to my reading seems to call a perl (!) script that generates an interactive SVG.
And although the generated SVGs support some minimal interaction, it's possible to do better.

When developping a web application, one can take advantage of the web browser as a highly dynamic tool for visualization using SVG, HTML and Javascript.
Fortunately there is a very good javascrtip library to generate flamegraphs: [d3-flame-graph](https://github.com/spiermar/d3-flame-graph).

By reading `:eflame` stacktrace samples and converting them into a format that `d3-flame-graph` can understand, we can render the flamegraph in a webpage.
That way, instead of the manual steps above you can just visit an URL in your web application.

## Batch usage (usage with benchmarks)

Incendium can be used to run benchmarks with integrated profiling data (in the form of flamegraphs).
It uses [Benchee]() under the hood, and the API is actually quite similar to Benchee's.

It provides a single function, namely `Incendium.run/2`, which takes the same arguments as `Benchee.run/2`, plus some incendium-specific ones. The main difference is that the suite title is a required keyword argument instead of an optional one.

An example:

```elixir
defmodule Incendium.Benchmarks.Example do
  defp map_fun(i) do
    [i, i * i]
  end

  def run() do
    list = Enum.to_list(1..10_000)

    Incendium.run(%{
      "flat_map" => fn -> Enum.flat_map(list, &map_fun/1) end,
      "map.flatten" => fn -> list |> Enum.map(&map_fun/1) |> List.flatten() end
      },
      title: "Example",
      incendium_flamegraph_widths_to_scale: true
    )
  end
end

Incendium.Benchmarks.Example.run()
```

The output of the script above can be found [here](https://hexdocs.pm/incendium/0.3.0/assets/Example.html).

## Interactive Usage (intgrated with a Phoenix web application)

To use `incendium` in your web application, you need to follow these steps:

### 1. Add Incendium as a dependency

```elixir
def deps do
  [
    {:incendium, "~> 0.2.0"}
  ]
end
```

You can make it a `:dev` only dependency if you wish, but Incendium will only decorate your functions if you're in `:dev` mode.
Incendium decorators *won't* decorate your functions in `:prod` (profilers such as `eflame` should never be used in `:prod` because they add a very significant overhead; your code will be ~10-12 times slower)

### 2. Create an Incendium Controller for your application

```elixir
# lib/my_app_web/controllers/incencdium_controller.ex

defmodule MyApp.IncendiumController do
  use Incendium.Controller,
    routes_module: MyAppWeb.Router.Helpers,
    otp_app: :my_app
end
```

There is no need to define an accompanying view.
Currently the controller is not extensible (and there aren't many natural extension points anyway).

Upon compilation, the controller will automcatically add the files `incendium.js` and `incendium.css` to your `priv/static` directory so that those static files will be served using the normal Phoenix mechanisms.
On unusual Phoenix apps which have static files in other places, this might not work as expected.
Currently there isn't a way to override the place where the static files should be added.

### 3. Add the controller to your Router

```elixir
# lib/my_app_web/controllers/router.ex

  require Incendium

  scope "/incendium", MyAppWeb do
    Incendium.routes(IncendiumController)
  end

```

### 4. Decorate the functions you want to profile

Incendium decorators depend on the [decorator](https://hex.pm/packages/decorator) package.

```elixir
defmodule MyAppWeb.MyContext.ExampleController do
  use MyAppWeb.Mandarin, :controller

  # Activate the incendium decorators
  use Incendium.Decorator

  # Each invocation of the `index/2` function will be traced and profiled.
  @decorate incendium_profile_with_tracing()
  def index(conn, params) do
    resources = MyContext.list_resources(params)
    render(conn, "index.html", resources: resources)
  end
end
```

Currently incendium only supports tracing profilers
(which are very slow and not practical in production).
In the future we may support better options such as sampling profilers.

### 5. Visit the `/incendium` route to see the generated flamegraph

Each time you run a profiled function, a new stacktrace will be generated.
Stacktraces are not currently saves, you can only access the latest one.
In the future we might add a persistence layer that stores a number of stacktraces instead of keeping just the last one.

[Here](https://hexdocs.pm/incendium/example-flamegraph.html) you can find an example flamegraph with explanations about how to interact with it .