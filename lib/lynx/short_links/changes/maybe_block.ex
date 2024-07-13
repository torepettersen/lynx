defmodule Lynx.ShortLinks.Changes.MaybeBlock do
  use Ash.Resource.Change

  @blocking_tags MapSet.new([:unsafe, :phishing, :malware, :adult])

  @impl true
  def change(changeset, _opts, _context) do
    blocking_tags =
      Ash.Changeset.get_attribute(changeset, :tags)
      |> MapSet.new()
      |> MapSet.intersection(@blocking_tags)
      |> Enum.to_list()

    case blocking_tags do
      [_ | _] -> Ash.Changeset.change_attribute(changeset, :state, :blocked)
      [] -> changeset
    end
  end
end
