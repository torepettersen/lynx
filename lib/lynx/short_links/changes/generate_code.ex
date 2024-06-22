defmodule Lynx.ShortLinks.Changes.GenerateCode do
  use Ash.Resource.Change
  alias Ash.Changeset

  @charset Enum.concat([?0..?9, ?A..?Z, ?a..?z]) |> Enum.map(&<<&1>>)

  @impl true
  def change(changeset, _opts, _context) do
    case Changeset.get_attribute(changeset, :code) do
      nil ->
        Changeset.change_attribute(changeset, :code, generate_code())

      _ ->
        changeset
    end
  end

  defp generate_code do
    1..8
    |> Enum.map(fn _ -> Enum.random(@charset) end)
    |> Enum.join()
  end
end
