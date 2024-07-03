defmodule Lynx.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication],
    # authorizers: [Ash.Policy.Authorizer],
    domain: Lynx.Accounts

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true

    timestamps()
  end

  actions do
    defaults [:read]
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
      end

      tokens do
        enabled? true
        token_resource Lynx.Accounts.Token
        signing_secret Lynx.Accounts.Secrets
      end
    end
  end

  postgres do
    table "users"
    repo Lynx.Repo
  end

  identities do
    identity :unique_email, [:email]
  end

  # You can customize this if you wish, but this is a safe default that
  # only allows user data to be interacted with via AshAuthentication.
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  #
  #   policy always() do
  #     forbid_if always()
  #   end
  # end
end
