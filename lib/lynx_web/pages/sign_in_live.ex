defmodule LynxWeb.SignInLive do
  use LynxWeb, :live_view

  alias AshPhoenix.Form
  alias Lynx.Accounts
  alias Lynx.Accounts.User

  @impl true
  def mount(_params, _session, socket), do: ok(socket)

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> apply_action(socket.assigns.live_action)
    |> noreply()
  end

  def apply_action(socket, :sign_in) do
    form = Form.for_action(User, :sign_in_with_password, api: Accounts, as: "user")

    socket
    |> assign(:form, form)
    |> assign(:cta, "Sign in")
  end

  def apply_action(socket, :register) do
    form = Form.for_action(User, :register_with_password, api: Accounts, as: "user")

    socket
    |> assign(:form, form)
    |> assign(:cta, "Register")
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params, errors: false)

    socket
    |> assign(form: form)
    |> noreply()
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    result =
      Form.submit(socket.assigns.form,
        params: params,
        read_one?: true,
        before_submit: fn changeset ->
          Ash.Changeset.set_context(changeset, %{token_type: :sign_in})
        end
      )

    case result do
      {:ok, user} ->
        token = user.__metadata__.token

        socket
        |> redirect(to: ~p"/auth/user/password/sign_in_with_token?token=#{token}")
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-muted flex min-h-screen items-center justify-center">
      <.card class="w-96 px-4">
        <.card_header>
          <.card_title><%= @cta %></.card_title>
        </.card_header>
        <.form :let={f} for={@form} phx-change="validate" phx-submit="submit">
          <.card_content>
            <div class="space-y-4">
              <.input field={f[:email]} label="Email" />
              <.input field={f[:password]} type="password" label="Password" />
              <.input
                :if={@live_action == :register}
                field={f[:password_confirmation]}
                type="password"
                label="Password confirmation"
              />
            </div>
          </.card_content>
          <.card_footer>
            <.button><%= @cta %></.button>
          </.card_footer>
        </.form>
      </.card>
    </div>
    """
  end
end
