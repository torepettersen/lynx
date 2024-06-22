defmodule LynxWeb.ShortLinkLive do
  use LynxWeb, :live_view

  alias Lynx.ShortLinks.ShortLink

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    short_link = Ash.get!(ShortLink, id)

    socket
    |> assign(short_link: short_link)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.button>Hei</.button>
    """
  end
end
