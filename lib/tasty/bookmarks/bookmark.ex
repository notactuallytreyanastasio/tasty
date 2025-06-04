defmodule Tasty.Bookmarks.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :favicon_url, :string
    field :screenshot_url, :string
    field :is_public, :boolean, default: true
    field :view_count, :integer, default: 0

    belongs_to :user, Tasty.Accounts.User
    many_to_many :tags, Tasty.Bookmarks.Tag, join_through: "bookmark_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:url, :title, :description, :favicon_url, :screenshot_url, :is_public, :view_count, :user_id])
    |> validate_required([:url, :title, :user_id])
    |> validate_format(:url, ~r/^https?:\/\//, message: "must be a valid URL")
    |> validate_length(:title, max: 255)
    |> foreign_key_constraint(:user_id)
  end
end
