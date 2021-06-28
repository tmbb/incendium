defmodule Incendium.Assets do
  @moduledoc false

  @d3_js_url "https://d3js.org/d3.v4.min.js"
  @d3_tip_js_url "https://cdnjs.cloudflare.com/ajax/libs/d3-tip/0.9.1/d3-tip.min.js"
  @d3_flamegraph_js_url "https://cdn.jsdelivr.net/gh/spiermar/d3-flame-graph@2.0.3/dist/d3-flamegraph.min.js"

  @bootstrap_css_url "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
  @d3_flamegraph_css_url "https://cdn.jsdelivr.net/gh/spiermar/d3-flame-graph@2.0.3/dist/d3-flamegraph.css"
  @extra_css File.read!("lib/incendium/assets/extra.css")

  def css_path(), do: Path.join([:code.priv_dir(:incendium), "assets", "incendium.css"])

  def js_path(), do: Path.join([:code.priv_dir(:incendium), "assets", "incendium.js"])

  def build_js() do
    {:ok, {_, _, d3_js}} = :httpc.request(@d3_js_url)
    {:ok, {_, _, d3_tip_js}} = :httpc.request(@d3_tip_js_url)
    {:ok, {_, _, d3_flamegraph_js}} = :httpc.request(@d3_flamegraph_js_url)

    all_js = [
      d3_js,
      d3_tip_js,
      d3_flamegraph_js
    ]

    File.write(js_path(), all_js)
  end

  def build_css() do
    {:ok, {_, _, bootstrap_css}} = :httpc.request(@bootstrap_css_url)
    {:ok, {_, _, d3_flamegraph_css}} = :httpc.request(@d3_flamegraph_css_url)

    all_css = [
      bootstrap_css,
      d3_flamegraph_css,
      @extra_css
    ]

    File.write!(css_path(), all_css)
  end

  def build_assets() do
    build_css()
    build_js()
  end
end
