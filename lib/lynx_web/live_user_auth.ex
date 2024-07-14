defmodule LynxWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  use LynxWeb, :verified_routes
  import Phoenix.Component
  import Phoenix.LiveView
  alias Lynx.Accounts.User
  alias Lynx.Accounts.AnonymousUser

  def on_mount(:user_optional, _params, %{"session_id" => session_id}, socket) do
    case socket.assigns[:current_user] do
      %User{} -> {:cont, socket}
      nil -> {:cont, assign(socket, :current_user, AnonymousUser.create!(%{id: session_id}))}
    end
  end

  def on_mount(:user_required, _params, _session, socket) do
    case socket.assigns[:current_user] do
      %User{} -> {:cont, socket}
      nil -> {:halt, redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:no_user, _params, %{"session_id" => session_id}, socket) do
    case socket.assigns[:current_user] do
      %User{} -> {:halt, redirect(socket, to: ~p"/")}
      nil -> {:cont, assign(socket, :current_user, AnonymousUser.create!(%{id: session_id}))}
    end
  end
end
