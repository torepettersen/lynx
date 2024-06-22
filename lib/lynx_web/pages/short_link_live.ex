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
    <.card class="max-w-lg">
      <.card_header>
        <.card_title class="text-lg text-primary hover:text-primary/80">
          <.link href={"https://pnt.li/#{@short_link.code}"}>pnt.li/<%= @short_link.code %></.link>
        </.card_title>
        <.card_description><%= @short_link.url %></.card_description>
      </.card_header>
      <.card_footer class="flex justify-start space-x-4">
        <.button phx-click={JS.dispatch("phx:copy")} value={"pnt.li/#{@short_link.code}"}>
          Copy
        </.button>
      </.card_footer>
    </.card>
    """
  end
end
