defmodule Lynx.ShortLinks.ShortLink do
  use Ash.Resource,
    domain: Lynx.ShortLinks,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  alias Lynx.Accounts.User
  alias Lynx.ShortLinks.Changes.GenerateCode
  alias Uniq.UUID

  @host Application.compile_env!(:lynx, :host)
  @host_scheme Application.compile_env!(:lynx, :host_scheme)

  code_interface do
    define :read, action: :read
    define :by_code, action: :by_code, get_by: :code
    define :create, action: :create
  end

  actions do
    default_accept [:target_url, :code]
    defaults [:update, :destroy]

    read :read do
      primary? true

      prepare build(sort: [inserted_at: :desc])
      prepare build(load: [:display_url, :full_url])
    end

    read :by_code

    create :create do
      primary? true

      change relate_actor(:owner, allow_nil?: true)
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

  relationships do
    belongs_to :owner, User
  end

  calculations do
    calculate :full_url, :string, expr("#{@host_scheme}://#{@host}/" <> code)
    calculate :display_url, :string, expr("#{@host}/" <> code)
  end

  identities do
    identity :unique_code, [:code]
  end

  policies do
    policy action_type([:read, :update, :destroy]) do
      authorize_if relates_to_actor_via(:owner)
    end

    policy action_type([:create]) do
      authorize_if always()
    end

    bypass action(:by_code) do
      authorize_if always()
    end
  end

  postgres do
    table "short_links"
    repo Lynx.Repo
  end
end
