defmodule Mix.Tasks.ProductHuntUsers do
  use Mix.Task

  @client Req.new(base_url: "https://www.producthunt.com/frontend/graphql")

  def run([slug]) do
    Mix.Task.run("app.start")

    users =
      case File.read("priv/outreach/#{slug}.json") do
        {:ok, content} ->
          Jason.decode!(content, keys: :atoms)

        {:error, :enoent} ->
          post_id = get_post_id(slug)
          users = list_users(post_id)
          content = Jason.encode!(users)
          File.write!("priv/outreach/#{slug}.json", content)

          users
      end

    {twitter, users} = split_by_kind(users, "twitter")
  end

  defp split_by_kind(users, kind) do
    Enum.split_with(users, fn user ->
      Enum.any?(user.links, fn link -> link.kind == kind end)
    end)
  end

  defp get_post_id(slug) do
    @client
    |> Req.post!(
      json: %{
        operationName: "PostPageComments",
        variables: %{
          commentsListSubjectThreadsCursor: "",
          commentsThreadRepliesCursor: "",
          order: "SCORE",
          slug: slug,
          includeThreadForCommentId: nil,
          commentsListSubjectThreadsLimit: 4
        },
        extensions: %{
          persistedQuery: %{
            version: 1,
            sha256Hash: "99da1bd22a8294ac584535f929092afa915940406e2594ef0ed43839ead1909c"
          }
        }
      }
    )
    |> get_in([Access.key(:body), "data", "post", "id"])
  end

  defp list_users(post_id) do
    @client
    |> Req.post!(
      json: %{
        operationName: "PostPageSocialProof",
        variables: %{
          postId: post_id,
          limit: 500
        },
        extensions: %{
          persistedQuery: %{
            version: 1,
            sha256Hash: "155abe7b651255e2bbbab76906b40bf3ae80ef4d99b78d4a9597685d8e1f9e58"
          }
        }
      }
    )
    |> get_in([Access.key(:body), "data", "post", "contributors"])
    |> Enum.map(fn %{"user" => user, "role" => role} ->
      Map.merge(
        %{
          name: user["name"],
          username: user["username"],
          role: role
        },
        get_user(user["username"])
      )
    end)
  end

  defp get_user(username) do
    user =
      @client
      |> Req.post!(
        json: %{
          operationName: "ProfileAboutPage",
          variables: %{
            username: username,
            newProductsCursor: nil
          },
          extensions: %{
            persistedQuery: %{
              version: 1,
              sha256Hash: "568ab27efbe48ab0e61095eca22570e2d28c38d5c3e29bd8322d70c0852ec9df"
            }
          }
        }
      )
      |> get_in([Access.key(:body), "data", "profile"])

    links =
      Enum.map(user["links"], fn link ->
        %{
          kind: link["kind"],
          name: link["name"],
          url: link["encodedUrl"] |> String.replace("\n", "") |> Base.decode64!()
        }
      end)

    %{
      about: user["about"],
      votes_count: user["votesCount"],
      links: links
    }
  end
end
