defmodule Affable.MixProject do
  use Mix.Project

  def project do
    [
      app: :affable,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
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
      mod: {Affable.Application, []},
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
      {:bcrypt_elixir, "~> 2.0"},
      {:phoenix, "~> 1.6.2", override: true},
      {:phoenix_ecto, "~> 4.4.0"},
      {:ecto_sql, "~> 3.8"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.17.0"},
      {:floki, ">= 0.31.0", only: :test},
      {:gcs_signed_url,
       github: "alexandrubagu/gcs_signed_url", ref: "56b3c0c531151c2b69ee54b3cc12957b6d7ab732"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.3",
       github: "phoenixframework/phoenix_live_reload", ref: "2f6e908", only: :dev},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phx_gen_auth, "~> 0.4.0", only: [:dev], runtime: false},
      {:httpoison, "~> 1.7"},
      {:bamboo, "~> 2.2.0"},
      {:bamboo_phoenix, "~> 1.0.0"},
      {:hashids, "~> 2.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:libcluster, "~> 3.2"},
      {:goth, "~> 1.3-rc"},
      {:hackney, "~> 1.17"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4.15"}
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
