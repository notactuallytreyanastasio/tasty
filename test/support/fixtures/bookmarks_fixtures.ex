defmodule Tasty.BookmarksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tasty.Bookmarks` context.
  """

  @doc """
  Generate a bookmark.
  """
  def bookmark_fixture(attrs \\ %{}) do
    {:ok, bookmark} =
      attrs
      |> Enum.into(%{
        description: "some description",
        favicon_url: "some favicon_url",
        is_public: true,
        screenshot_url: "some screenshot_url",
        title: "some title",
        url: "some url",
        view_count: 42
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
        color: "some color",
        name: "some name",
        slug: "some slug"
      })
      |> Tasty.Bookmarks.create_tag()

    tag
  end
end
