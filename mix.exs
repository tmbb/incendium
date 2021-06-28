defmodule Incendium.MixProject do
  use Mix.Project

  def project do
    [
      app: :incendium,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        extras: ["doc_extra/pages/Example flamegraph.md"],
        assets: "doc_extra/assets/"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_html, "~> 2.0"},
      {:phoenix, "~> 1.4"},
      {:decorator, "~> 1.4"},
      {:jason, "~> 1.2"},
      {:eflame, "~> 1.0"},
      {:ex_doc, "~> 0.23", only: :dev}
    ]
  end
end
