defmodule LynxWeb.Plugs.PutSessionId do
  import Plug.Conn
  alias Plug.Conn

  def init(default), do: default

  def call(%Conn{} = conn, _default) do
    case get_session(conn, :session_id) do
      nil -> put_session(conn, :session_id, Ash.UUIDv7.generate())
      _ -> conn
    end
  end
end
