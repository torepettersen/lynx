defmodule Lynx.Repo.Migrations.CreateShortLinks do
  use Ecto.Migration

  def change do
    create table(:short_links) do
      add :active, :boolean, null: false, default: true
      add :code, :text, null: false
      add :target_url, :text, null: false
      add :last_used, :date

      timestamps()
    end

    create unique_index(:short_links, [:code], name: "short_links_unique_code_index")
  end
end
