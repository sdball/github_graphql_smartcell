# GithubGraphQLSmartcell

This is an [Elixir LiveBook](https://livebook.dev) smart cell that allows
querying the GitHub GraphQL API.

## Installation

The package can be installed by adding `github_graphql_smartcell` to your list
of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:github_graphql_smartcell, "~> 0.1.0"}
  ]
end
```

In an Elixir LiveBook

```elixir
Mix.install([
  {:github_graphql_smartcell, "~> 0.1.0"},
])
```

## Usage

You will need

1. Elixir LiveBook
2. A GitHub personal access token
3. A GraphQL query you want to execute

In your Elixir LiveBook's setup cell either search for
`github_graphql_smartcell` or add the above `Mix.install` code.

Then click "+ Smart" and then select "GitHub GraphQL Query" to insert the smart cell.

In the smart cell itself, paste in your GitHub personal access token and GraphQL query. Then execute!

You should see your query results or a reasonably useful error display.

### Pagination

Pagination IS supported BUT currently your query must be paginating a query
with only a single `nodes` declaration in the query. I'm working on a
completely generic pagination approach so until then we have to make do.

To paginate you must declare `$first` and `$after` in your query, use `$first`
and `$after` in your query, and include `pageInfo { hasNextPage, endCursor }`
in the paginating section of your query.

It is weird and confusing. Let me walk you through the deal.

While GraphQL has a pretty good pagination story it is still GraphQL which
means **the query itself** needs to know about the pagination data and
variables.

Here's a query that will get the database IDs for your first 10 followers

```graphql
{
  viewer {
    followers(first: 10) {
      nodes {
        databaseId
      }
    }
  }
}
```

Great right? But how do you paginate? Well, you need to ask for `pageInfo` with `endCursor` and `hasNextPage`

```graphql
{
  viewer {
    followers(first: 10) {
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
```

But NO that's not enough of course. If you execute this query in your smart cell you should see a message

```
endCursor is not advancing: halting queries
```

That's because the GraphQL query depends on variables for pagination. And variables must be declared and known to both the querying code AND the query itself.

```graphql
{
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
```

Because the smart cell is the querying code we unfortunately have to simply agree to use well-known names for `$first` and `$after`. We could make the smart cell have extra inputs to declare the variables and then declare the names of the variables but that seems even more confusing.

Also that's STILL not enough to make GraphQL happy. You need to declare the names and types of the variables too!

That means you need to explicitly add the normally optional `query {}` wrapper and declare the variables.

```graphql
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
```

And, at last, if you execute that query you should see a list of all of your followers' databaseIds.

Please clap because pulling out the `pageInfo` and `nodes` in a mostly generic way was a pain.

But also watch out because I probably did not account for some shapes of query results and things will blow up.

But for at least the simple queries I've executed so far this smart cell

* Understands how to simply return results if the query does not declare pagination
* Understands how to recognize if there's pagination info but not usage in the query and return the results without endlessly querying the same cursor.
* Understands how to paginate nodes with pageInfo data into a combined list

