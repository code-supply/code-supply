defmodule Hosting.MixProject do
  use Mix.Project

  def project do
    [
      app: :hosting,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Hosting.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, "~> 4.4.0"},
      {:ecto_sql, "~> 3.9.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.19.2"},
      {:phoenix_view, "~> 2.0"},
      {:gcs_signed_url, "~> 0.4.5"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.4.1", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.22"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.5"},
      {:httpoison, "~> 1.7"},
      {:hashids, "~> 2.1.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:libcluster, "~> 3.3.0"},
      {:goth, "~> 1.3"},
      {:hackney, "~> 1.17"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.15"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:k8s, "~> 1.1"},
      {:hammox, "~> 0.6", only: :test},
      {:floki, "~> 0.33.0"},
      {:size, "~> 0.1.0"},
      {:google_api_storage, "~> 0.34.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets:copy": [
        "cmd cp -a assets/static/* priv/static/"
      ],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify",
        "cmd cp -a assets/static/* priv/static/",
        "phx.digest"
      ]
    ]
  end
end
