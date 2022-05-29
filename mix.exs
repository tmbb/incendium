defmodule Incendium.MixProject do
  use Mix.Project

  @version "0.2.0"
  @url "https://github.com/tmbb/incendium"

  def project do
    [
      app: :incendium,
      description: "Easy flamegraphs for your web application",
      version: @version,
      source_url: @url,
      homepage: @url,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      package: [
        licenses: ["MIT"],
        links: %{
          "GitHub" => @url
        }
      ],
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
      {:phoenix_html, "~> 3.0"},
      {:phoenix, "~> 1.6"},
      {:decorator, "~> 1.4"},
      {:jason, "~> 1.2"},
      {:eflame, "~> 1.0"},
      {:ex_doc, "~> 0.23", only: :dev}
    ]
  end

  defp aliases() do
    [
      publish: "run scripts/release.exs"
    ]
  end
end
