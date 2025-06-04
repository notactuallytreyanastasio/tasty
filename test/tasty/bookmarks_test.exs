defmodule Tasty.BookmarksTest do
  use Tasty.DataCase

  alias Tasty.Bookmarks

  describe "bookmarks" do
    alias Tasty.Bookmarks.Bookmark

    import Tasty.BookmarksFixtures

    @invalid_attrs %{description: nil, title: nil, url: nil, favicon_url: nil, screenshot_url: nil, is_public: nil, view_count: nil}

    test "list_bookmarks/0 returns all bookmarks" do
      bookmark = bookmark_fixture()
      bookmarks = Bookmarks.list_bookmarks()
      assert length(bookmarks) == 1
      assert hd(bookmarks).id == bookmark.id
    end

    test "list_bookmarks/1 filters by user_id" do
      user1 = Tasty.AccountsFixtures.user_fixture()
      user2 = Tasty.AccountsFixtures.user_fixture()
      
      bookmark1 = bookmark_fixture(user: user1)
      bookmark2 = bookmark_fixture(user: user2)
      
      user1_bookmarks = Bookmarks.list_bookmarks(%{"user_id" => user1.id})
      user2_bookmarks = Bookmarks.list_bookmarks(%{"user_id" => user2.id})
      
      assert length(user1_bookmarks) == 1
      assert hd(user1_bookmarks).id == bookmark1.id
      
      assert length(user2_bookmarks) == 1
      assert hd(user2_bookmarks).id == bookmark2.id
    end

    test "list_bookmarks/1 filters public bookmarks only" do
      user = Tasty.AccountsFixtures.user_fixture()
      
      public_bookmark = bookmark_fixture(user: user, is_public: true)
      _private_bookmark = bookmark_fixture(user: user, is_public: false)
      
      public_bookmarks = Bookmarks.list_bookmarks(%{"public_only" => "true"})
      
      assert length(public_bookmarks) == 1
      assert hd(public_bookmarks).id == public_bookmark.id
    end

    test "list_bookmarks/1 combines filters" do
      user1 = Tasty.AccountsFixtures.user_fixture()
      user2 = Tasty.AccountsFixtures.user_fixture()
      
      _user1_public = bookmark_fixture(user: user1, is_public: true)
      _user1_private = bookmark_fixture(user: user1, is_public: false)
      user2_public = bookmark_fixture(user: user2, is_public: true)
      _user2_private = bookmark_fixture(user: user2, is_public: false)
      
      filtered_bookmarks = Bookmarks.list_bookmarks(%{
        "user_id" => user2.id,
        "public_only" => "true"
      })
      
      assert length(filtered_bookmarks) == 1
      assert hd(filtered_bookmarks).id == user2_public.id
    end

    test "list_bookmarks/1 preloads associations" do
      user = Tasty.AccountsFixtures.user_fixture()
      bookmark = bookmark_fixture(user: user)
      
      bookmarks = Bookmarks.list_bookmarks()
      bookmark = hd(bookmarks)
      
      assert Ecto.assoc_loaded?(bookmark.user)
      assert Ecto.assoc_loaded?(bookmark.tags)
      assert bookmark.user.id == user.id
    end

    test "get_bookmark!/1 returns the bookmark with given id" do
      bookmark = bookmark_fixture()
      assert Bookmarks.get_bookmark!(bookmark.id) == bookmark
    end

    test "create_bookmark/1 with valid data creates a bookmark" do
      user = Tasty.AccountsFixtures.user_fixture()
      valid_attrs = %{
        description: "some description", 
        title: "some title", 
        url: "https://example.com", 
        favicon_url: "https://example.com/favicon.ico", 
        screenshot_url: "https://example.com/screenshot.png", 
        is_public: true, 
        view_count: 42,
        user_id: user.id
      }

      assert {:ok, %Bookmark{} = bookmark} = Bookmarks.create_bookmark(valid_attrs)
      assert bookmark.description == "some description"
      assert bookmark.title == "some title"
      assert bookmark.url == "https://example.com"
      assert bookmark.favicon_url == "https://example.com/favicon.ico"
      assert bookmark.screenshot_url == "https://example.com/screenshot.png"
      assert bookmark.is_public == true
      assert bookmark.view_count == 42
      assert bookmark.user_id == user.id
    end

    test "create_bookmark/1 with invalid URL returns error changeset" do
      user = Tasty.AccountsFixtures.user_fixture()
      invalid_attrs = %{
        title: "Test", 
        url: "not-a-url",
        user_id: user.id
      }

      assert {:error, %Ecto.Changeset{}} = Bookmarks.create_bookmark(invalid_attrs)
    end

    test "create_bookmark/1 without user_id returns error changeset" do
      attrs = %{
        title: "Test", 
        url: "https://example.com"
      }

      assert {:error, %Ecto.Changeset{}} = Bookmarks.create_bookmark(attrs)
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
