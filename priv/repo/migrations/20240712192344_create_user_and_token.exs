defmodule Lynx.Repo.Migrations.CreateUserAndToken do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :citext, null: false
      add :hashed_password, :text, null: false

      timestamps()
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")

    create table(:tokens, primary_key: false) do
      add :jti, :text, null: false, primary_key: true
      add :extra_data, :map
      add :purpose, :text, null: false
      add :expires_at, :utc_datetime, null: false
      add :subject, :text, null: false

      timestamps(inserted_at: :created_at)
    end
  end
end
