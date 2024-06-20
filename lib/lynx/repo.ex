defmodule Lynx.Repo do
  use Ecto.Repo,
    otp_app: :lynx,
    adapter: Ecto.Adapters.Postgres
end
