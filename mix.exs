defmodule Diagramx.MixProject do
  use Mix.Project

  def project do
    [
      app: :diagramx,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:logger, :postgrex]
    ]
  end

  defp escript do
    [main_module: Diagramx.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:graphvix, "~> 1.0.0"}, {:postgrex, "~> 0.6"}]
  end
end
