defmodule Lynx.Validations do
  alias Lynx.Validations.IsUrl

  def is_url?(attribute) do
    {IsUrl, attribute: attribute}
  end
end
