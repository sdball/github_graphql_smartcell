defmodule GithubGraphQLSmartcellTest do
  use ExUnit.Case, async: true

  import Kino.Test

  setup :configure_livebook_bridge

  test "initial source uses the defaults" do
    {_kino, source} = start_smart_cell!(GithubGraphQLSmartcell, %{})

    assert source ==
             """
             {:ok, results} =
               GitHub.GraphQL.query("{ viewer { login } }",
                 endpoint: "https://api.github.com/graphql",
                 token: ""
               )\
             """
  end

  test "pagination on calls GraphQL.paginate" do
    {_kino, source} = start_smart_cell!(GithubGraphQLSmartcell, %{"variable" => "paginated", "paginate" => true})

    assert source ==
             """
             paginated =
               GitHub.GraphQL.paginate("{ viewer { login } }",
                 endpoint: "https://api.github.com/graphql",
                 token: ""
               )\
             """
  end

  test "pagination off calls GraphQL.query" do
    {_kino, source} = start_smart_cell!(GithubGraphQLSmartcell, %{"variable" => "paginate_off", "paginate" => nil})

    assert source ==
             """
             {:ok, paginate_off} =
               GitHub.GraphQL.query("{ viewer { login } }",
                 endpoint: "https://api.github.com/graphql",
                 token: ""
               )\
             """
  end

  test "restores source code from attrs" do
    attrs = %{
      "variable" => "myvar",
      "endpoint" => "https://example.com/graphql",
      "api_token" => "configured-api-token",
      "query" => "{ your { awesome { query } } }"
    }

    {_kino, source} = start_smart_cell!(GithubGraphQLSmartcell, attrs)

    assert source ==
             """
             {:ok, myvar} =
               GitHub.GraphQL.query("{ your { awesome { query } } }",
                 endpoint: "https://example.com/graphql",
                 token: "configured-api-token"
               )\
             """
  end

  test "when a field changes, broadcasts the change and sends source update" do
    {kino, _source} = start_smart_cell!(GithubGraphQLSmartcell, %{"variable" => "res"})

    push_event(kino, "update_field", %{"field" => "api_token", "value" => "mytoken"})

    assert_broadcast_event(kino, "update", %{"fields" => %{"api_token" => "mytoken"}})

    assert_smart_cell_update(kino, %{"api_token" => "mytoken"}, """
    {:ok, res} =
      GitHub.GraphQL.query("{ viewer { login } }",
        endpoint: "https://api.github.com/graphql",
        token: "mytoken"
      )\
    """)
  end

  test "when an invalid variable name is set, restores the previous value" do
    {kino, _source} = start_smart_cell!(GithubGraphQLSmartcell, %{"variable" => "v"})
    push_event(kino, "update_field", %{"field" => "variable", "value" => "CONST"})
    assert_broadcast_event(kino, "update", %{"fields" => %{"variable" => "v"}})
  end
end
