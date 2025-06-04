defmodule Tasty.Repo.Migrations.AddUserProfileFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string, null: false
      add :avatar_url, :string
      add :bio, :text
    end

    create unique_index(:users, [:username])
  end
end
