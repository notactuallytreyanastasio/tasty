defmodule Tasty.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :color, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tags, [:name])
    create unique_index(:tags, [:slug])
  end
end
