defmodule Lynx.Validations.IsUrl do
  use Ash.Resource.Validation

  @impl true
  def init(opts) do
    case is_atom(opts[:attribute]) do
      true -> {:ok, opts}
      false -> {:error, "attribute must be an atom!"}
    end
  end

  @impl true
  def validate(changeset, opts, _context) do
    value = Ash.Changeset.get_attribute(changeset, opts[:attribute])

    case new_uri(value) do
      {:ok, %URI{scheme: nil}} ->
        {:error, field: opts[:attribute], message: "must be a valid url"}

      {:ok, %URI{host: nil}} ->
        {:error, field: opts[:attribute], message: "must be a valid url"}

      {:error, _} ->
        {:error, field: opts[:attribute], message: "must be a valid url"}

      {:ok, %URI{scheme: scheme}} when scheme not in ["http", "https"] ->
        {:error, field: opts[:attribute], message: "url must start with https:// or http://"}

      {:ok, %URI{}} ->
        :ok

      nil ->
        :ok
    end
  end

  defp new_uri(value) when is_binary(value), do: URI.new(value)
  defp new_uri(nil), do: nil
end
