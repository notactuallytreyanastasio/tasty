defmodule Tasty.Repo.Migrations.CreateBookmarkTags do
  use Ecto.Migration

  def change do
    create table(:bookmark_tags, primary_key: false) do
      add :bookmark_id, references(:bookmarks, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
    end

    create index(:bookmark_tags, [:bookmark_id])
    create index(:bookmark_tags, [:tag_id])
    create unique_index(:bookmark_tags, [:bookmark_id, :tag_id])
  end
end
