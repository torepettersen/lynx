defmodule FoxWeb.ButtonGroup do
  use Phoenix.Component
  import Tails, only: [classes: 1]
  import FoxWeb.Button

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def button_group(assigns) do
    ~H"""
    <div class="flex space-x-0 rounded-lg shadow">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(variant type size disabled form name value)

  slot :inner_block, required: true

  def group_button(assigns) do
    ~H"""
    <.button class={classes([group_button_variants(@rest), @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </.button>
    """
  end

  def group_button_variants(props \\ %{}) do
    classes([
      button_variants(props),
      "rounded-none shadow-none first:rounded-l-lg last:rounded-r-lg"
    ])
  end
end
