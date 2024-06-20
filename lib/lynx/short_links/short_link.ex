defmodule Lynx.ShortLinks.ShortLink do
  use Ash.Resource,
    domain: Lynx.ShortLinks,
    data_layer: AshPostgres.DataLayer

  alias Uniq.UUID

  attributes do
    uuid_primary_key :id, default: &UUID.uuid7/0

    attribute :code, :string, allow_nil?: false
    attribute :url, :string, allow_nil?: false

    attribute :last_used, :date

    timestamps()
  end

  identities do
    identity :unique_code, [:code]
  end

  postgres do
    table "short_links"
    repo Lynx.Repo
  end
end
