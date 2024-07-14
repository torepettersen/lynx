defmodule Lynx.Repo.Migrations.CreateShortLinks do
  use Ecto.Migration

  def change do
    create table(:short_links) do
      add :state, :text, null: false, default: "active"
      add :code, :text, null: false
      add :target_url, :text, null: false
      add :last_used, :date
      add :risk_score, :integer
      add :tags, {:array, :text}

      add :user_id, references(:users, on_delete: :delete_all)
      add :session_id, :uuid

      timestamps()
    end

    create unique_index(:short_links, [:code], name: "short_links_unique_code_index")

    create constraint(:short_links, :one_of_user_id_or_session_id,
             check:
               "(user_id IS NOT NULL AND session_id IS NULL) OR (user_id IS NULL AND session_id IS NOT NULL)"
           )
  end
end
