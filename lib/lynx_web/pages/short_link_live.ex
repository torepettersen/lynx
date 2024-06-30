defmodule LynxWeb.ShortLinkLive do
  use LynxWeb, :live_view

  alias Lynx.ShortLinks.ShortLink

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    short_link = Ash.get!(ShortLink, id) |> Ash.load!([:display_url, :full_url])

    qr_code =
      short_link.full_url
      |> QRCodeEx.encode()
      |> QRCodeEx.svg(width: 100)

    socket
    |> assign(short_link: short_link)
    |> assign(qr_code: qr_code)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.card class="max-w-lg">
      <.card_header class="flex flex-row justify-between pb-0 space-y-0">
        <div class="space-y-1.5">
          <.card_title class="text-lg text-primary hover:text-primary/80">
            <.link href={@short_link.full_url}><%= @short_link.display_url %></.link>
          </.card_title>
          <.card_description><%= @short_link.target_url %></.card_description>
        </div>
        <div class="">
          <%= raw(@qr_code) %>
        </div>
      </.card_header>
      <.card_content></.card_content>
      <.card_footer class="flex justify-start space-x-4">
        <.copy_to_clipboard class={button_variants()} value={@short_link.display_url} />
        <.link class={button_variants(%{variant: "outline"})} href={~p"/qr-code/#{@short_link.id}"}>
          Download QR Code
        </.link>
      </.card_footer>
    </.card>
    """
  end
end
