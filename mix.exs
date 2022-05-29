defmodule Incendium.MixProject do
  use Mix.Project

  @version "0.3.1"
  @url "https://github.com/tmbb/incendium"

  def project do
    [
      app: :incendium,
      name: "Incendium",
      description: "Easy flamegraphs for your application or benchmarks",
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
        main: "Incendium",
        extras: [
          # Don't add a README; add usage instructions to the main module instead
          "doc_extra/pages/Example flamegraph.md"
        ],
        assets: "doc_extra/assets/"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets],
      mod: {Incendium.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:eflame, "~> 1.0"},

      # Dependencies required to integrate with Phoenix applications:
      {:phoenix, "~> 1.6"},
      {:decorator, "~> 1.4"},

      # Dependencies required for benchmarks:
      {:size, "~> 0.1"},
      {:benchee, "~> 1.0"},
      # TODO: do we really need slugify?
      {:slugify, "~> 1.3"},

      # Dependencies required for both Phoenix applications and benchmarks:
      # NOTE: `phoenix_html` is NOT phoenix-specific.
      # It merely provides utilities to work with HTML templates
      {:phoenix_html, "~> 3.0"},
      {:jason, "~> 1.2"},

      # Documentation
      {:ex_doc, "~> 0.23", only: :dev}
    ]
  end

  defp aliases() do
    [
      publish: "run scripts/release.exs"
    ]
  end
end
