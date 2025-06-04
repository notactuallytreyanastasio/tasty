defmodule Tasty.Repo.Migrations.CreateBookmarks do
  use Ecto.Migration

  def change do
    create table(:bookmarks) do
      add :url, :string, null: false
      add :title, :string, null: false
      add :description, :text
      add :favicon_url, :string
      add :screenshot_url, :string
      add :is_public, :boolean, default: true, null: false
      add :view_count, :integer, default: 0
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:bookmarks, [:user_id])
    create index(:bookmarks, [:url])
    create index(:bookmarks, [:is_public])
  end
end
