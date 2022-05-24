defmodule GraphQL do
  @moduledoc """
  Useful functions to parse data from GraphQL response data
  """

  @doc """
  Find the "pageInfo" data within a GraphQL response.

  ## Examples

      iex> %{
      ...>   "a" => %{
      ...>     "b" => %{
      ...>       "pageInfo" => %{
      ...>         "hasNextPage" => true,
      ...>         "endCursor" => "abc123"
      ...>       },
      ...>       "nodes" => [:one, :two, :three, :etc]
      ...>     }
      ...>   }
      ...> } |> GraphQL.find_pageinfo()
      %{
        "hasNextPage" => true,
        "endCursor" => "abc123"
      }

      iex> GraphQL.find_pageinfo(%{})
      nil
  """
  def find_pageinfo(data) when map_size(data) == 0, do: nil

  def find_pageinfo(data) when is_map(data) do
    data
    |> Enum.reduce(%{}, fn {key, nested_data}, _acc ->
      case key do
        "pageInfo" ->
          nested_data

        _ ->
          find_pageinfo(nested_data)
      end
    end)
  end

  def find_pageinfo(_) do
    nil
  end

  @doc """
  Find "nodes" within a GraphQL response.

  ## Examples

      iex> %{
      ...>   "a" => %{
      ...>     "b" => %{
      ...>       "pageInfo" => %{
      ...>         "hasNextPage" => true,
      ...>         "endCursor" => "abc123"
      ...>       },
      ...>       "nodes" => [:one, :two, :three, :etc]
      ...>     }
      ...>   }
      ...> } |> GraphQL.find_nodes()
      [:one, :two, :three, :etc]

      iex> GraphQL.find_nodes(%{})
      []
  """
  def find_nodes(%{"nodes" => nodes}) do
    nodes
  end

  def find_nodes(map) when is_map(map) do
    Enum.map(map, fn {_key, data} ->
      find_nodes(data)
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  def find_nodes(_) do
    nil
  end
end
