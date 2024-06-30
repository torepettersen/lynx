defmodule LynxWeb.InputWithButton do
  use Phoenix.Component
  import Tails, only: [classes: 1]
  import LynxWeb.Button
  import LynxWeb.CoreComponents, only: [translate_error: 1]

  attr :id, :any, default: nil
  attr :class, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :rest, :global
  slot :inner_block

  def input_with_button(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns =
      assigns
      |> assign(field: nil, id: assigns.id || field.id)
      |> assign(:errors, Enum.map(errors, &translate_error(&1)))
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value end)

    ~H"""
    <div class={classes(["flex rounded-lg shadow", @class])}>
      <input
        type="text"
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value("text", @value)}
        class={
          classes([
            "block w-full rounded-l-lg border-r-0 text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
            @errors == [] && "border-zinc-300 focus:border-zinc-400",
            @errors != [] && "border-rose-400 focus:border-rose-400"
          ])
        }
        {@rest}
      />
      <.button class="h-auto rounded-r-lg">
        <%= render_slot(@inner_block) %>
      </.button>
    </div>
    """
  end
end
