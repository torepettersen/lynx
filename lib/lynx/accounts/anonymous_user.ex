defmodule Lynx.Accounts.AnonymousUser do
  use Ash.Resource,
    domain: Lynx.Accounts

  code_interface do
    define :create
  end

  actions do
    default_accept [:id]
    defaults [:create, :read]
  end

  attributes do
    attribute :id, :uuid, primary_key?: true, allow_nil?: false
  end

  resource do
    require_primary_key? false
  end
end
