defmodule LynxWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  use LynxWeb, :verified_routes
  import Phoenix.Component
  import Phoenix.LiveView
  alias Lynx.Accounts.User

  def on_mount(:user_optional, _params, _session, socket) do
    {:cont, assign_new(socket, :current_user, fn -> nil end)}
  end

  def on_mount(:user_required, _params, _session, socket) do
    case socket.assigns[:current_user] do
      %User{} -> {:cont, socket}
      nil -> {:halt, redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:no_user, _params, _session, socket) do
    case socket.assigns[:current_user] do
      %User{} -> {:halt, redirect(socket, to: ~p"/")}
      nil -> {:cont, assign(socket, :current_user, nil)}
    end
  end
end
