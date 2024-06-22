defmodule Lynx.Repo.Migrations.CreateShortLinks do
  use Ecto.Migration

  def up do
    create table(:short_links) do
      add :active, :boolean, null: false, default: true
      add :code, :text, null: false
      add :target_url, :text, null: false
      add :last_used, :date

      timestamps()
    end

    create unique_index(:short_links, [:code], name: "short_links_unique_code_index")
  end

  def down do
    drop_if_exists unique_index(:short_links, [:code], name: "short_links_unique_code_index")

    drop table(:short_links)
  end
end
