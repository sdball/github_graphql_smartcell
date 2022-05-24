defmodule GraphQLTest do
  use ExUnit.Case
  doctest GraphQL

  describe "find_pageinfo" do
    test "finds pageInfo at an arbitrary depth in a map" do
      map = %{
        "a" => %{
          "b" => %{
            "pageInfo" => %{
              "hasNextPage" => true,
              "endCursor" => "abc123"
            },
            "nodes" => [:one, :two, :three, :etc]
          }
        }
      }

      assert(
        GraphQL.find_pageinfo(map) == %{
          "hasNextPage" => true,
          "endCursor" => "abc123"
        }
      )
    end

    test "returns nil if pageInfo is not present" do
      map = %{
        "a" => %{
          "b" => %{
            "nodes" => [:one, :two, :three, :etc]
          }
        }
      }

      assert(GraphQL.find_pageinfo(map) |> is_nil)
    end
  end

  describe "find_nodes" do
    test "finds nodes at an arbitrary depth in a map" do
      map = %{
        "a" => %{
          "b" => %{
            "pageInfo" => %{
              "hasNextPage" => true,
              "endCursor" => "abc123"
            },
            "nodes" => [:one, :two, :three, :etc]
          }
        }
      }

      assert(GraphQL.find_nodes(map) == [:one, :two, :three, :etc])
    end

    test "returns empty list if nodes is not present" do
      map = %{
        "a" => %{
          "b" => %{
            "pageInfo" => %{
              "hasNextPage" => true,
              "endCursor" => "abc123"
            }
          }
        }
      }

      assert(GraphQL.find_nodes(map) == [])
    end
  end
end
