defmodule GithubGraphqlSmartcell.MixProject do
  use Mix.Project

  def project do
    [
      app: :github_graphql_smartcell,
      version: "0.0.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {GithubGraphqlSmartcell.Application, []}
    ]
  end

  defp deps do
    [
      {:kino, "~> 0.6.1"},
      {:neuron, "~> 5.0"},
      {:jason, "~> 1.3"}
    ]
  end
end
