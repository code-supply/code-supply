defmodule TlsLbOperator.MixProject do
  use Mix.Project

  def project do
    [
      app: :tls_lb_operator,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
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
      {:jason, "~> 1.3"}
    ]
  end

  defp escript do
    [main_module: TlsLbOperator]
  end
end
