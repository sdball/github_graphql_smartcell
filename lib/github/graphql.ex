defmodule GitHub.GraphQL do
  def query(query, config) do
    query
    |> request(config)
    |> case do
      {:ok, %Neuron.Response{status_code: 200, body: %{"errors" => errors}}} ->
        {:error, errors}
      {:ok, %Neuron.Response{status_code: 200, body: %{"data" => data}}} ->
        {:ok, data}
      {:error, %Neuron.Response{body: body}} ->
        {:error, body}
      error ->
        error
    end
  end

  def request(query, config) do
    Neuron.query(query, %{},
      url: config[:endpoint],
      headers: [authorization: "Bearer #{config[:token]}"]
    )
  end
end
