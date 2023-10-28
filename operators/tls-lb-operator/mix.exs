defmodule TlsLbOperator.MixProject do
  use Mix.Project

  def project do
    [
      app: :tls_lb_operator,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        tls_lb_operator: [
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:k8s, "~> 1.1"}
    ]
  end
end
