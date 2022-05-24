defmodule GraphQL do
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
