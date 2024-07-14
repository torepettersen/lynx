defmodule Lynx.ShortLinks.ShortLink do
  use Ash.Resource,
    domain: Lynx.ShortLinks,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshOban]

  import Lynx.Validations
  alias Lynx.Accounts.AnonymousUser
  alias Lynx.Accounts.User
  alias Lynx.ShortLinks.Changes.GenerateCode
  alias Lynx.ShortLinks.Changes.GetRiskScore
  alias Lynx.ShortLinks.Changes.MaybeBlock
  alias Lynx.ShortLinks.Changes.SetOwner

  @host Application.compile_env!(:lynx, :host)
  @host_scheme Application.compile_env!(:lynx, :host_scheme)

  code_interface do
    define :read, action: :read
    define :by_code, action: :by_code, get_by: :code
    define :create, action: :create
  end

  actions do
    default_accept [:target_url]
    defaults [:update, :destroy]

    read :read do
      primary? true

      prepare build(sort: [inserted_at: :desc])

      pagination keyset?: true, required?: false
    end

    read :by_code

    create :create do
      primary? true

      change SetOwner
      change GenerateCode

      validate is_url?(:target_url)
    end

    update :check_link do
      require_atomic? false
      change GetRiskScore
      change MaybeBlock
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :state, :atom do
      constraints one_of: [:active, :inactive, :blocked]
    end

    attribute :code, :string, allow_nil?: false
    attribute :target_url, :string, allow_nil?: false
    attribute :last_used, :date
    attribute :risk_score, :integer

    attribute :tags, {:array, :atom} do
      constraints items: [
                    one_of: [
                      :phishing,
                      :malware,
                      :suspicious,
                      :parking,
                      :spamming,
                      :adult,
                      :risky_tld,
                      :short_link_redirect
                    ]
                  ]
    end

    attribute :session_id, :uuid

    timestamps()
  end

  relationships do
    belongs_to :user, User

    belongs_to :anonymous_user, AnonymousUser do
      source_attribute :session_id
    end
  end

  calculations do
    calculate :full_url, :string, expr("#{@host_scheme}://#{@host}/" <> code)
    calculate :display_url, :string, expr("#{@host}/" <> code)
  end

  identities do
    identity :unique_code, [:code]
  end

  oban do
    triggers do
      trigger :check_link do
        queue(:default)
        action :check_link
        where expr(is_nil(risk_score))
        scheduler_cron("* * * * *")
      end
    end
  end

  policies do
    bypass AshOban.Checks.AshObanInteraction do
      authorize_if always()
    end

    bypass action(:by_code) do
      authorize_if always()
    end

    policy action_type([:read, :update, :destroy]) do
      authorize_if relates_to_actor_via(:user)
      authorize_if expr(session_id == ^actor(:id))
    end

    policy action_type(:create) do
      authorize_if always()
    end
  end

  field_policies do
    field_policy_bypass [:state, :code, :target_url] do
      authorize_if always()
    end

    field_policy [
      :user_id,
      :session_id,
      :last_used,
      :tags,
      :risk_score,
      :inserted_at,
      :updated_at,
      :full_url,
      :display_url
    ] do
      authorize_if relates_to_actor_via(:user)
      authorize_if expr(session_id == ^actor(:id))
      authorize_if AshOban.Checks.AshObanInteraction
    end
  end

  postgres do
    table "short_links"
    repo Lynx.Repo
  end
end
