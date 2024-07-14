defmodule LynxWeb.AuthController do
  use LynxWeb, :controller
  use AshAuthentication.Phoenix.Controller

  require Ash.Query

  alias Lynx.Accounts.AnonymousUser
  alias Lynx.ShortLinks.ShortLink

  def success(conn, _activity, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/short-links"

    move_links_to_user(conn, user)

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> redirect(to: return_to)
  end

  def failure(conn, _activity, _reason) do
    conn
    |> put_flash(:error, "Incorrect email or password")
    |> redirect(to: ~p"/sign-in")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session()
    |> redirect(to: return_to)
  end

  defp move_links_to_user(conn, user) do
    session_id = get_session(conn, :session_id)
    actor = AnonymousUser.create!(%{id: session_id})

    ShortLink
    |> Ash.Query.filter(session_id == ^session_id)
    |> Ash.bulk_update!(:move_to_user, %{user_id: user.id}, actor: actor)
  end
end
