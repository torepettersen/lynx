defmodule LynxWeb.CopyToClipboard do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :value, :string, required: true
  attr :rest, :global

  slot :inner_block
  slot :copy
  slot :copied

  def copy_to_clipboard(assigns) do
    ~H"""
    <button phx-click={JS.dispatch("phx:copy")} value={@value} {@rest}>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% end %>
      <span class="copy-text">
        <%= if @copy != [] do %>
          <%= render_slot(@copy) %>
        <% else %>
          Copy
        <% end %>
      </span>
      <span class="copied-text hidden">
        <%= if @copied != [] do %>
          <%= render_slot(@copied) %>
        <% else %>
          Copied!
        <% end %>
      </span>
    </button>
    """
  end
end
