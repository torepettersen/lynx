defmodule Lynx.ShortLinks.Changes.SetOwner do
  use Ash.Resource.Change
  import Ash.Changeset
  alias Lynx.Accounts.AnonymousUser
  alias Lynx.Accounts.User

  @impl true
  def change(changeset, _opts, %{actor: actor}) do
    case actor do
      %User{} = actor ->
        manage_relationship(changeset, :user, actor, type: :append_and_remove)

      %AnonymousUser{} = actor ->
        manage_relationship(changeset, :anonymous_user, actor, type: :append_and_remove)
    end
  end
end
