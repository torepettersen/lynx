defmodule Lynx.ShortLinks.ShortLink do
  use Ash.Resource,
    domain: Lynx.ShortLinks,
    data_layer: AshPostgres.DataLayer

  alias Lynx.ShortLinks.Changes.GenerateCode
  alias Uniq.UUID

  @host Application.compile_env!(:lynx, :host)
  @host_scheme Application.compile_env!(:lynx, :host_scheme)

  actions do
    default_accept [:target_url, :code]
    defaults [:update, :destroy]

    read :read do
      primary? true
      prepare build(sort: [inserted_at: :desc])
    end

    create :create do
      primary? true

      change GenerateCode
    end
  end

  attributes do
    uuid_primary_key :id, default: &UUID.uuid7/0

    attribute :active, :boolean, allow_nil?: false, default: true
    attribute :code, :string, allow_nil?: false
    attribute :target_url, :string, allow_nil?: false

    attribute :last_used, :date

    timestamps()
  end

  calculations do
    calculate :full_url, :string, expr("#{@host_scheme}://#{@host}/" <> code)
    calculate :display_url, :string, expr("#{@host}/" <> code)
  end

  identities do
    identity :unique_code, [:code]
  end

  postgres do
    table "short_links"
    repo Lynx.Repo
  end
end
