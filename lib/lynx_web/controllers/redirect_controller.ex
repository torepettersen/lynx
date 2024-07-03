defmodule LynxWeb.RedirectController do
  use LynxWeb, :controller

  alias Lynx.ShortLinks.ShortLink

  @host Application.compile_env!(:lynx, :host)
  @host_scheme Application.compile_env!(:lynx, :host_scheme)

  def index(conn, %{"code" => code}) do
    case ShortLink.by_code(code) do
      {:ok, short_link} -> redirect(conn, external: short_link.target_url)
      _ -> redirect(conn, external: app_url())
    end
  end

  def index(conn, _params) do
    redirect(conn, external: app_url())
  end

  defp app_url do
    "#{@host_scheme}://app.#{@host}"
  end
end
