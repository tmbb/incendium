defmodule Incendium.Assets do
  @moduledoc false

  @d3_js_url "https://d3js.org/d3.v4.min.js"
  @d3_tip_js_url "https://cdnjs.cloudflare.com/ajax/libs/d3-tip/0.9.1/d3-tip.min.js"
  @d3_flamegraph_js_url "https://cdn.jsdelivr.net/gh/spiermar/d3-flame-graph@2.0.3/dist/d3-flamegraph.min.js"
  @jquery_js_url "https://code.jquery.com/jquery-3.4.1.slim.min.js"
  @bootstrap_js_url "https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"

  @d3_flamegraph_css_url "https://cdn.jsdelivr.net/gh/spiermar/d3-flame-graph@2.0.3/dist/d3-flamegraph.css"
  @bootstrap_css_url "https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"

  extra_css_path = "lib/incendium/assets/extra.css"
  extra_js_path = "lib/incendium/assets/extra.js"

  # Recompile this module if we rebuild the assets
  @external_resource "priv/assets/incendium.css"
  @external_resource "priv/assets/incendium.js"

  @external_resource extra_css_path
  @external_resource extra_js_path

  @extra_css File.read!(extra_css_path)
  @extra_js File.read!(extra_js_path)

  def css_path() do
    Path.join([:code.priv_dir(:incendium), "assets", "incendium.css"])
  end

  def js_path() do
    Path.join([:code.priv_dir(:incendium), "assets", "incendium.js"])
  end

  def benchee_css_path() do
    Path.join([:code.priv_dir(:incendium), "assets", "benchee-incendium.css"])
  end

  def benchee_js_path() do
    Path.join([:code.priv_dir(:incendium), "assets", "benchee-incendium.js"])
  end

  def extra_css() do
    @extra_css
  end

  def all_js() do
    File.read!(js_path())
  end

  def all_css() do
    File.read!(css_path())
  end

  def all_benchee_js() do
    File.read!(benchee_js_path())
  end

  def all_benchee_css() do
    File.read!(benchee_css_path())
  end

  # Build online
  # ------------

  def build_js() do
    {:ok, {_, _, d3_js}} = :httpc.request(@d3_js_url)
    {:ok, {_, _, d3_tip_js}} = :httpc.request(@d3_tip_js_url)
    {:ok, {_, _, d3_flamegraph_js}} = :httpc.request(@d3_flamegraph_js_url)

    all_js = [
      d3_js,
      d3_tip_js,
      d3_flamegraph_js,
      @extra_js
    ]
    |> Enum.intersperse("\n")
    |> remove_js_source_map()

    save_to_local_cache("d3.js", d3_js)
    save_to_local_cache("d3-tip.js", d3_tip_js)
    save_to_local_cache("d3-flame-graph", d3_flamegraph_js)

    File.write(js_path(), all_js)
  end

  def build_benchee_js() do
    {:ok, {_, _, d3_js}} = :httpc.request(@d3_js_url)
    {:ok, {_, _, d3_tip_js}} = :httpc.request(@d3_tip_js_url)
    {:ok, {_, _, d3_flamegraph_js}} = :httpc.request(@d3_flamegraph_js_url)
    {:ok, {_, _, jquery_js}} = :httpc.request(@jquery_js_url)
    {:ok, {_, _, bootstrap_js}} = :httpc.request(@bootstrap_js_url)

    all_js = [
      d3_js,
      d3_tip_js,
      d3_flamegraph_js,
      jquery_js,
      bootstrap_js,
      @extra_js
    ]
    |> Enum.intersperse("\n")
    |> remove_js_source_map()

    save_to_local_cache("d3.js", d3_js)
    save_to_local_cache("d3-tip.js", d3_tip_js)
    save_to_local_cache("d3-flame-graph.js", d3_flamegraph_js)
    save_to_local_cache("jquery.js", jquery_js)
    save_to_local_cache("bootstrap.js", bootstrap_js)

    File.write(benchee_js_path(), all_js)
  end

  def build_css() do
    {:ok, {_, _, d3_flamegraph_css}} = :httpc.request(@d3_flamegraph_css_url)

    save_to_local_cache("flamegraph.css", d3_flamegraph_css)

    File.write!(css_path(), remove_css_source_map(d3_flamegraph_css))
  end

  def build_benchee_css() do
    {:ok, {_, _, d3_flamegraph_css}} = :httpc.request(@d3_flamegraph_css_url)
    {:ok, {_, _, bootstrap_css}} = :httpc.request(@bootstrap_css_url)

    save_to_local_cache("flamegraph.css", d3_flamegraph_css)
    save_to_local_cache("bootstrap.css", bootstrap_css)

    all_css = [
      d3_flamegraph_css,
      bootstrap_css
    ]
    |> Enum.intersperse("\n")
    |> remove_css_source_map()

    File.write!(benchee_css_path(), all_css)
  end

  def build_assets() do
    build_css()
    build_js()
    build_benchee_css()
    build_benchee_js()
  end

  # Build offline:
  # --------------

  def build_js_offline() do
    d3_js = read_from_local_cache("d3.js")
    d3_tip_js = read_from_local_cache("d3-tip.js")
    d3_flamegraph_js = read_from_local_cache("d3-flame-graph.js")
    jquery_js = read_from_local_cache("jquery.js")
    bootstrap_js = read_from_local_cache("bootstrap.js")

    all_js = [
      d3_js,
      d3_tip_js,
      d3_flamegraph_js,
      jquery_js,
      bootstrap_js,
      @extra_js
    ]
    |> Enum.intersperse("\n")
    |> remove_js_source_map()

    File.write(js_path(), all_js)
  end

  def build_benchee_js_offline() do
    d3_js = read_from_local_cache("d3.js")
    d3_tip_js = read_from_local_cache("d3-tip.js")
    d3_flamegraph_js = read_from_local_cache("d3-flame-graph.js")

    all_js = [
      d3_js,
      d3_tip_js,
      d3_flamegraph_js,
      @extra_js
    ]
    |> Enum.intersperse("\n")
    |> remove_js_source_map()

    File.write(benchee_js_path(), all_js)
  end

  def build_css_offline() do
    d3_flamegraph_css = read_from_local_cache("flamegraph.css")

    File.write!(css_path(), d3_flamegraph_css |> remove_css_source_map)
  end

  def build_benchee_css_offline() do
    d3_flamegraph_css = read_from_local_cache("flamegraph.css")
    bootstrap_css = read_from_local_cache("bootstrap.css")

    all_css = [
      d3_flamegraph_css,
      bootstrap_css
    ]
    |> Enum.intersperse("\n")
    |> remove_css_source_map()

    File.write!(benchee_css_path(), all_css)
  end

  def build_assets_offline() do
    build_css_offline()
    build_js_offline()
    build_benchee_css_offline()
    build_benchee_js_offline()
  end

  # Helpers

  defp save_to_local_cache(filename, data) do
    path = Path.join("lib/incendium/assets/vendor", filename)
    File.write!(path, data)
  end

  defp read_from_local_cache(filename) do
    path = Path.join("lib/incendium/assets/vendor", filename)
    File.read!(path)
  end

  defp remove_js_source_map(iolist) do
    binary = to_string(iolist)
    String.replace(binary, ~r'^\s*//#\s*sourceMappingURL=[^\n]+', "\n")
  end

  defp remove_css_source_map(iolist) do
    binary = to_string(iolist)
    # Not semantically correct but the correct regex is way too complex
    String.replace(binary, ~r'^\s*/\*#\s*sourceMappingURL=[^\n]+', "\n")
  end
end
