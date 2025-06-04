defmodule Tasty.Bookmarks.BookmarkTest do
  use Tasty.DataCase, async: true

  alias Tasty.Bookmarks.Bookmark
  import Tasty.AccountsFixtures

  describe "changeset/2" do
    setup do
      user = user_fixture()
      {:ok, user: user}
    end

    test "validates required fields", %{user: _user} do
      changeset = Bookmark.changeset(%Bookmark{}, %{})
      
      assert %{
        url: ["can't be blank"],
        title: ["can't be blank"],
        user_id: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "validates URL format", %{user: user} do
      # Test invalid URL format
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "not-a-url",
        title: "Test",
        user_id: user.id
      })
      
      assert %{url: ["must be a valid URL"]} = errors_on(changeset)

      # Test URLs without http/https
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "example.com",
        title: "Test",
        user_id: user.id
      })
      
      assert %{url: ["must be a valid URL"]} = errors_on(changeset)
    end

    test "accepts valid http and https URLs", %{user: user} do
      # Test HTTP URL
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "http://example.com",
        title: "Test",
        user_id: user.id
      })
      
      assert changeset.valid?

      # Test HTTPS URL
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test",
        user_id: user.id
      })
      
      assert changeset.valid?
    end

    test "validates title length", %{user: user} do
      long_title = String.duplicate("a", 256)
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: long_title,
        user_id: user.id
      })
      
      assert %{title: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end

    test "accepts valid bookmark data", %{user: user} do
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test Bookmark",
        description: "A test bookmark",
        favicon_url: "https://example.com/favicon.ico",
        screenshot_url: "https://example.com/screenshot.png",
        is_public: true,
        view_count: 5,
        user_id: user.id
      })
      
      assert changeset.valid?
      assert get_change(changeset, :url) == "https://example.com"
      assert get_change(changeset, :title) == "Test Bookmark"
      assert get_change(changeset, :description) == "A test bookmark"
      assert get_change(changeset, :favicon_url) == "https://example.com/favicon.ico"
      assert get_change(changeset, :screenshot_url) == "https://example.com/screenshot.png"
      assert get_change(changeset, :is_public) == true
      assert get_change(changeset, :view_count) == 5
      assert get_change(changeset, :user_id) == user.id
    end

    test "sets default values", %{user: user} do
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test",
        user_id: user.id
      })
      
      assert changeset.valid?
      # Test that defaults are applied in the schema, not changeset
      bookmark = apply_changes(changeset)
      assert bookmark.is_public == true
      assert bookmark.view_count == 0
    end

    test "accepts optional fields as nil", %{user: user} do
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test",
        description: nil,
        favicon_url: nil,
        screenshot_url: nil,
        user_id: user.id
      })
      
      assert changeset.valid?
    end

    test "validates foreign key constraint", %{user: user} do
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test",
        user_id: user.id
      })
      
      # The foreign key constraint is validated at the database level
      # This test ensures the changeset includes the constraint
      assert length(changeset.constraints) == 1
      constraint = hd(changeset.constraints)
      assert constraint.field == :user_id
      assert constraint.type == :foreign_key
    end

    test "handles boolean fields correctly", %{user: user} do
      # Test explicit false
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test",
        is_public: false,
        user_id: user.id
      })
      
      assert changeset.valid?
      assert get_change(changeset, :is_public) == false

      # Test string "false"
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test",
        is_public: "false",
        user_id: user.id
      })
      
      assert changeset.valid?
      assert get_change(changeset, :is_public) == false
    end

    test "handles integer fields correctly", %{user: user} do
      # Test string integer
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test",
        view_count: "42",
        user_id: user.id
      })
      
      assert changeset.valid?
      assert get_change(changeset, :view_count) == 42

      # Test negative integer
      changeset = Bookmark.changeset(%Bookmark{}, %{
        url: "https://example.com",
        title: "Test",
        view_count: -1,
        user_id: user.id
      })
      
      assert changeset.valid?
      assert get_change(changeset, :view_count) == -1
    end
  end
end