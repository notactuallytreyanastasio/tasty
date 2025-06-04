defmodule Tasty.BookmarksTest do
  use Tasty.DataCase

  alias Tasty.Bookmarks

  describe "bookmarks" do
    alias Tasty.Bookmarks.Bookmark

    import Tasty.BookmarksFixtures

    @invalid_attrs %{description: nil, title: nil, url: nil, favicon_url: nil, screenshot_url: nil, is_public: nil, view_count: nil}

    test "list_bookmarks/0 returns all bookmarks" do
      bookmark = bookmark_fixture()
      assert Bookmarks.list_bookmarks() == [bookmark]
    end

    test "get_bookmark!/1 returns the bookmark with given id" do
      bookmark = bookmark_fixture()
      assert Bookmarks.get_bookmark!(bookmark.id) == bookmark
    end

    test "create_bookmark/1 with valid data creates a bookmark" do
      valid_attrs = %{description: "some description", title: "some title", url: "some url", favicon_url: "some favicon_url", screenshot_url: "some screenshot_url", is_public: true, view_count: 42}

      assert {:ok, %Bookmark{} = bookmark} = Bookmarks.create_bookmark(valid_attrs)
      assert bookmark.description == "some description"
      assert bookmark.title == "some title"
      assert bookmark.url == "some url"
      assert bookmark.favicon_url == "some favicon_url"
      assert bookmark.screenshot_url == "some screenshot_url"
      assert bookmark.is_public == true
      assert bookmark.view_count == 42
    end

    test "create_bookmark/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bookmarks.create_bookmark(@invalid_attrs)
    end

    test "update_bookmark/2 with valid data updates the bookmark" do
      bookmark = bookmark_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", url: "some updated url", favicon_url: "some updated favicon_url", screenshot_url: "some updated screenshot_url", is_public: false, view_count: 43}

      assert {:ok, %Bookmark{} = bookmark} = Bookmarks.update_bookmark(bookmark, update_attrs)
      assert bookmark.description == "some updated description"
      assert bookmark.title == "some updated title"
      assert bookmark.url == "some updated url"
      assert bookmark.favicon_url == "some updated favicon_url"
      assert bookmark.screenshot_url == "some updated screenshot_url"
      assert bookmark.is_public == false
      assert bookmark.view_count == 43
    end

    test "update_bookmark/2 with invalid data returns error changeset" do
      bookmark = bookmark_fixture()
      assert {:error, %Ecto.Changeset{}} = Bookmarks.update_bookmark(bookmark, @invalid_attrs)
      assert bookmark == Bookmarks.get_bookmark!(bookmark.id)
    end

    test "delete_bookmark/1 deletes the bookmark" do
      bookmark = bookmark_fixture()
      assert {:ok, %Bookmark{}} = Bookmarks.delete_bookmark(bookmark)
      assert_raise Ecto.NoResultsError, fn -> Bookmarks.get_bookmark!(bookmark.id) end
    end

    test "change_bookmark/1 returns a bookmark changeset" do
      bookmark = bookmark_fixture()
      assert %Ecto.Changeset{} = Bookmarks.change_bookmark(bookmark)
    end
  end

  describe "tags" do
    alias Tasty.Bookmarks.Tag

    import Tasty.BookmarksFixtures

    @invalid_attrs %{name: nil, color: nil, slug: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Bookmarks.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Bookmarks.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{name: "some name", color: "some color", slug: "some slug"}

      assert {:ok, %Tag{} = tag} = Bookmarks.create_tag(valid_attrs)
      assert tag.name == "some name"
      assert tag.color == "some color"
      assert tag.slug == "some slug"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bookmarks.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      update_attrs = %{name: "some updated name", color: "some updated color", slug: "some updated slug"}

      assert {:ok, %Tag{} = tag} = Bookmarks.update_tag(tag, update_attrs)
      assert tag.name == "some updated name"
      assert tag.color == "some updated color"
      assert tag.slug == "some updated slug"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Bookmarks.update_tag(tag, @invalid_attrs)
      assert tag == Bookmarks.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Bookmarks.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Bookmarks.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Bookmarks.change_tag(tag)
    end
  end
end
