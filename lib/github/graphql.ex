defmodule GitHub.GraphQL do
  def query(query, config, vars \\ %{first: 20}) do
    query
    |> call_graphql(config, vars)
    |> case do
      {:ok, %Neuron.Response{status_code: 200, body: %{"errors" => errors}}} ->
        {:error, errors}

      {:ok, %Neuron.Response{status_code: 200, body: %{"data" => data}}} ->
        {:ok, data}

      {:error, %Neuron.Response{body: body}} ->
        {:error, body}

      error ->
        {:error, error}
    end
  end

  def paginate(query, config, vars \\ %{first: 20}) do
    init = fn -> request(query, config, vars) end
    next = &next/1
    stop = &Function.identity/1

    Stream.resource(init, next, stop)
    |> Enum.into([])
    |> case do
      [] ->
        IO.puts("Empty results from pagination. Did your query have a `nodes` field?")
        pagination_usage()
        []
      nodes ->
        nodes
    end
  end

  defp request(query, config, vars) do
    query
    |> call_graphql(config, vars)
    |> case do
      {:ok, %Neuron.Response{status_code: 200, body: %{"errors" => errors}}} ->
        IO.inspect(errors)
        {[], nil, query, config, vars}

      {:ok, %Neuron.Response{status_code: 200, body: %{"data" => data}}} ->
        {GraphQL.find_nodes(data), GraphQL.find_pageinfo(data), query, config, vars}

      {:error, %Neuron.Response{body: body}} ->
        IO.inspect(body)
        {[], nil, query, config, vars}

      error ->
        IO.inspect(error)
        {[], nil, query, config, vars}
    end
  end

  defp next({nil, _query, _config, _vars} = acc), do: {:halt, acc}
  defp next({%{"hasNextPage" => false}, _query, _config, _vars} = acc), do: {:halt, acc}

  defp next({%{"endCursor" => endCursor}, query, config, vars} = acc) do
    results = request(query, config, Map.put(vars, :after, endCursor))

    case results do
      {_data, %{"endCursor" => ^endCursor}, _query, _config, _vars} ->
        IO.puts("endCursor is not advancing: halting queries")
        pagination_usage()
        {:halt, acc}

      _ ->
        next(results)
    end
  end

  defp next({data, page, query, config, args}) do
    {data, {page, query, config, args}}
  end

  defp call_graphql(query, config, vars) do
    Neuron.query(query, vars,
      url: config[:endpoint],
      headers: [authorization: "Bearer #{config[:token]}"]
    )
  end

  defp pagination_usage() do
    IO.puts("For pagination to work your query must meet the requirements")
    IO.puts("""
    query($first: Int, $after: String) {
      viewer {
        followers(first: $first, after: $after) {
          pageInfo {
            endCursor
            hasNextPage
          }
          nodes {
            databaseId
          }
        }
      }
    }
    """)
  end
end
