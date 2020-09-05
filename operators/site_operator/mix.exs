defmodule SiteOperator.MixProject do
  use Mix.Project

  def project do
    [
      app: :site_operator,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:jason, :logger_json]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bonny, "~> 0.4.0"},
      {:httpoison, "~> 1.7.0"},
      {:poison, "~> 4.0.1"},
      {:hammox, "~> 0.2", only: [:test]},
      {:logger_json, github: "portal-labs/logger_json", ref: "17aa009"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
