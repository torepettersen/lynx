defmodule LynxWeb.ShortLinksLive do
  use LynxWeb, :live_view

  alias Lynx.ShortLinks.ShortLink
  alias AshPhoenix.Form

  @impl true
  def mount(_params, _session, socket) do
    short_links = ShortLink.read!(actor: actor(socket))

    form = Form.for_create(ShortLink, :create, actor: actor(socket)) |> to_form()

    socket
    |> assign(short_links: short_links)
    |> assign(form: form)
    |> ok()
  end

  @impl true
  def handle_event("shorten_url", %{"form" => params}, socket) do
    dbg(params)

    case Form.submit(socket.assigns.form, params: params) do
      {:ok, short_link} ->
        socket
        |> push_navigate(to: ~p"/short-link/#{short_link}")
        |> noreply()

      {:error, form} ->
        socket
        |> assign(form: form)
        |> noreply()
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket.assigns.short_links
    |> Enum.find(&(&1.id == id))
    |> Ash.destroy!()

    short_links = ShortLink.read!(actor: actor(socket))

    socket
    |> assign(short_links: short_links)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.form for={@form} phx-submit="shorten_url">
      <.input_with_button class="max-w-lg" placeholder="URL" field={@form[:target_url]}>
        Shorten
      </.input_with_button>
    </.form>
    <.card class="mt-4">
      <.table>
        <.table_header>
          <.table_row>
            <.table_head class="min-w-56">Short link</.table_head>
            <.table_head>Status</.table_head>
            <.table_head>Target link</.table_head>
            <.table_head class="text-right min-w-36">Action</.table_head>
          </.table_row>
        </.table_header>
        <.table_body>
          <.table_row :for={short_link <- @short_links}>
            <.table_cell>
              <.link href={short_link.full_url}><%= short_link.display_url %></.link>
            </.table_cell>
            <.table_cell>
              <div class="flex">
                <%= short_link.state %>
                <.tooltip :if={short_link.state == :blocked} class="ml-1 flex items-center">
                  <.icon name="hero-information-circle-micro" />
                  <.tooltip_content class="bg-black text-white">
                    <.unsafe_messages short_link={short_link} />
                  </.tooltip_content>
                </.tooltip>
              </div>
            </.table_cell>
            <.table_cell class="truncate max-w-md">
              <.link href={short_link.target_url}><%= short_link.target_url %></.link>
            </.table_cell>
            <.table_cell>
              <div class="relative float-right inline-block">
                <.button_group>
                  <.link class={group_button_variants()} navigate={~p"/short-link/#{short_link.id}"}>
                    View
                  </.link>
                  <.group_button
                    class="px-2"
                    variant="outline"
                    phx-click={toggle(short_link.id)}
                    phx-click-away={hide(short_link.id)}
                  >
                    <.icon name="hero-ellipsis-vertical-micro" />
                  </.group_button>
                </.button_group>
                <.menu
                  id={"dropdown-#{short_link.id}"}
                  data-state="closed"
                  class="absolute right-0 w-56 mt-1 z-50 data-[state=closed]:hidden"
                >
                  <.copy_to_clipboard class={menu_item_variants()} value={short_link.display_url}>
                    <.icon name="hero-document-duplicate" class="mr-2 h-4 w-4" />
                    <:copy>Copy to clipboard</:copy>
                    <:copied>Copied!</:copied>
                  </.copy_to_clipboard>
                  <.link class={menu_item_variants()} href={~p"/qr-code/#{short_link.id}"}>
                    <.icon name="hero-qr-code" class="mr-2 h-4 w-4" />Download QR code
                  </.link>
                  <.menu_item
                    phx-click={JS.push("delete", value: %{id: short_link.id})}
                    data-confirm="Are you sure?"
                  >
                    <.icon name="hero-trash" class="mr-2 h-4 w-4" />Delete
                  </.menu_item>
                </.menu>
              </div>
            </.table_cell>
          </.table_row>
        </.table_body>
      </.table>
    </.card>
    """
  end

  defp unsafe_messages(%{short_link: %{tags: tags}} = assigns) do
    case unsafe_message(tags) do
      [_ | _] = messages ->
        assigns = assign(assigns, :messages, messages)

        ~H"""
        <ul>
          <li :for={message <- @messages}><%= message %></li>
        </ul>
        """

      _ ->
        ~H"This link has be flagged as unsafe"
    end
  end

  defp unsafe_message(tags) when is_list(tags),
    do: Enum.map(tags, &unsafe_message/1) |> Enum.reject(&is_nil/1)

  defp unsafe_message(:adult), do: "- This link has been flagged as adult content"
  defp unsafe_message(:malware), do: "- This link has been flagged as malware"
  defp unsafe_message(:phishing), do: "- This link has been flagged as phishing"
  defp unsafe_message(_), do: nil

  defp toggle(js \\ %JS{}, id) do
    JS.toggle_attribute(js, {"data-state", "open", "closed"}, to: "#dropdown-#{id}")
  end

  defp hide(js \\ %JS{}, id) do
    JS.set_attribute(js, {"data-state", "closed"}, to: "#dropdown-#{id}")
  end
end
