defmodule Incendium.View do
  @moduledoc false

  # Helpers to render pages in the IncendiumController.

  alias Incendium.Assets

  @external_resource "#{__DIR__}/templates/view/latest-flamegraph.html.eex"
  @external_resource "#{__DIR__}/templates/view/flamegraph.js.eex"

  use Phoenix.View,
    root: "#{__DIR__}/templates/view",
    path: ""

  def extra_css() do
    Assets.extra_css()
  end
end
