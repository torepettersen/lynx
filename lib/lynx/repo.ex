defmodule Lynx.Repo do
  use AshPostgres.Repo, otp_app: :lynx

  def installed_extensions do
    # Ash installs some functions that it needs to run the
    # first time you generate migrations.
    ["ash-functions", "uuid-ossp", "citext", AshMoney.AshPostgresExtension]
  end
end
