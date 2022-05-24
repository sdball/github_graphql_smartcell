defmodule GithubGraphQLSmartcell.MixProject do
  use Mix.Project

  @github "https://github.com/sdball/github_graphql_smartcell"
  @version "0.1.0"

  def project do
    [
      name: "GitHub GraphQL Smart Cell",
      description: description(),
      app: :github_graphql_smartcell,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      source_url: @github
    ]
  end

  def application do
    [
      mod: {GithubGraphQLSmartcell.Application, []}
    ]
  end

  defp description do
    "GitHub GraphQL integration with Livebook"
  end

  defp deps do
    [
      {:kino, "~> 0.6.1"},
      {:neuron, "~> 5.0"},
      {:jason, "~> 1.3"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "components",
      source_url: @github,
      source_ref: "v#{@version}",
      extras: ["guides/components.livemd", "guides/pagination.livemd"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github
      }
    ]
  end
end
