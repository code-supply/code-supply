defmodule SiteOperator.MixProject do
  use Mix.Project

  def project do
    [
      app: :site_operator,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:logger_json, "~> 4.0"}
    ]
  end
end
