defmodule Lynx.ShortLinks do
  use Ash.Domain

  resources do
    resource Lynx.ShortLinks.ShortLink
  end
end
