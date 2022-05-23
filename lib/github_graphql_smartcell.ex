defmodule GithubGraphqlSmartcell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/github_graphql_smartcell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "GitHub GraphQL Query"

  @impl true
  def init(attrs, ctx) do
    fields = %{
      "variable" => Kino.SmartCell.prefixed_var_name("results", attrs["variable"]),
      "endpoint" => attrs["endpoint"] || "https://api.github.com/graphql",
      "api_token" => attrs["api_token"] || "PASTE API TOKEN",
      "query" => attrs["query"] || "{ viewer { login } }",
    }

    {:ok, assign(ctx, fields: fields)}
  end

  @impl true
  def handle_connect(ctx) do
    payload = %{
      fields: ctx.assigns.fields
    }

    {:ok, payload, ctx}
  end

  @impl true
  def to_attrs(%{assigns: %{fields: fields}}) do
    Map.take(fields, ["variable", "endpoint", "api_token", "query"])
  end

  @impl true
  def to_source(attrs) do
    quote do
      {:ok, unquote(quoted_var(attrs["variable"]))} = GitHub.GraphQL.query(unquote(attrs["query"]), endpoint: unquote(attrs["endpoint"]), token: unquote(attrs["api_token"]))
    end
    |> Kino.SmartCell.quoted_to_string()
  end

  @impl true
  def handle_event("update_field", %{"field" => field, "value" => value}, ctx) do
    updated_fields = to_updates(ctx.assigns.fields, field, value)
    ctx = update(ctx, :fields, &Map.merge(&1, updated_fields))
    broadcast_event(ctx, "update", %{"fields" => updated_fields})
    {:noreply, ctx}
  end

  defp quoted_var(string), do: {String.to_atom(string), [], nil}

  defp to_updates(fields, "variable", value) do
    if Kino.SmartCell.valid_variable_name?(value) do
      %{"variable" => value}
    else
      %{"variable" => fields["variable"]}
    end
  end

  defp to_updates(_fields, field, value), do: %{field => value}
end
