defmodule SeedsApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :seeds_app,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      releases: releases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SeedsApp.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:faker, "~> 0.18"},
      {:dialyxir, "1.4.7", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7.17", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.8", only: :test},
      {:mimic, "~> 2.3", only: :test},
      {:phoenix, "~> 1.8.0"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_ecto, "~> 4.7"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:plug_cowboy, "~> 2.8"},
      {:jason, "~> 1.4"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end

  defp releases do
    [
      seeds_app: [
        include_executables_for: [:unix],
        applications: [
          {:seeds_app, :permanent}
        ],
        strip_beams: [keep: ["Docs"]]
      ]
    ]
  end
end
