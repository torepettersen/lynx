defmodule Lynx.ShortLinks.Changes.GetRiskScore do
  use Ash.Resource.Change

  alias Ash.Changeset

  @tags [
    "unsafe",
    "phishing",
    "malware",
    "suspicious",
    "parking",
    "spamming",
    "adult",
    "risky_tld",
    "short_link_redirect"
  ]

  @impl true
  def change(changeset, _opts, _context) do
    changeset
    |> Changeset.get_attribute(:target_url)
    |> url_safe()
    |> then(&Changeset.change_attributes(changeset, &1))
  end

  defp url_safe(url) do
    case Req.get(client(), url: URI.encode_www_form(url)) do
      {:ok, %{body: body, status: 200}} ->
        tags =
          body
          |> Map.take(@tags)
          |> Map.filter(fn {_key, value} -> value end)
          |> Map.keys()
          |> Enum.map(&String.to_existing_atom/1)

        %{
          risk_score: body["risk_score"],
          tags: tags
        }
    end
  end

  defp client do
    Req.new(base_url: "https://www.ipqualityscore.com/api/json/url/#{api_key()}/")
  end

  defp api_key do
    Application.fetch_env!(:lynx, :ipqs_api_key)
  end
end
