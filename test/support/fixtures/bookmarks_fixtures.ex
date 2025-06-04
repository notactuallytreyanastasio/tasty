defmodule Tasty.BookmarksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tasty.Bookmarks` context.
  """

  @doc """
  Generate a bookmark.
  """
  def bookmark_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{})
    user = Map.get_lazy(attrs, :user, fn -> Tasty.AccountsFixtures.user_fixture() end)
    
    attrs = Map.delete(attrs, :user)
    
    {:ok, bookmark} =
      attrs
      |> Enum.into(%{
        description: "some description",
        favicon_url: "https://example.com/favicon.ico",
        is_public: true,
        screenshot_url: "https://example.com/screenshot.png",
        title: "some title",
        url: "https://example.com",
        view_count: 42,
        user_id: user.id
      })
      |> Tasty.Bookmarks.create_bookmark()

    bookmark
  end

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        color: "#ffffff",
        name: "some name",
        slug: "some-name"
      })
      |> Tasty.Bookmarks.create_tag()

    tag
  end
end
