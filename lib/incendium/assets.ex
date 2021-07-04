defmodule Incendium.Assets do
  @moduledoc false

  @d3_js_url "https://d3js.org/d3.v4.min.js"
  @d3_tip_js_url "https://cdnjs.cloudflare.com/ajax/libs/d3-tip/0.9.1/d3-tip.min.js"
  @d3_flamegraph_js_url "https://cdn.jsdelivr.net/gh/spiermar/d3-flame-graph@2.0.3/dist/d3-flamegraph.min.js"

  @d3_flamegraph_css_url "https://cdn.jsdelivr.net/gh/spiermar/d3-flame-graph@2.0.3/dist/d3-flamegraph.css"

  extra_css_path = "lib/incendium/assets/extra.css"
  extra_js_path = "lib/incendium/assets/extra.js"

  # Recompile this module if we rebuild the assets
  @external_resource "priv/assets/incendium.css"
  @external_resource "priv/assets/incendium.js"

  @external_resource extra_css_path
  @external_resource extra_js_path

  @extra_css File.read!(extra_css_path)
  @extra_js File.read!(extra_js_path)

  def css_path(), do: Path.join([:code.priv_dir(:incendium), "assets", "incendium.css"])

  def js_path(), do: Path.join([:code.priv_dir(:incendium), "assets", "incendium.js"])

  def extra_css() do
    @extra_css
  end

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

    File.write(js_path(), all_js)
  end

  def build_css() do
    {:ok, {_, _, d3_flamegraph_css}} = :httpc.request(@d3_flamegraph_css_url)

    File.write!(css_path(), d3_flamegraph_css)
  end

  def build_assets() do
    build_css()
    build_js()
  end
end
