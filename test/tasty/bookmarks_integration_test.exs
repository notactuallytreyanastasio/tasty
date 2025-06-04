defmodule Tasty.BookmarksIntegrationTest do
  use Tasty.DataCase, async: true

  alias Tasty.Bookmarks
  alias Tasty.Repo
  import Tasty.AccountsFixtures
  import Tasty.BookmarksFixtures

  describe "bookmark-tag associations" do
    setup do
      user = user_fixture()
      {:ok, user: user}
    end

    test "creating bookmark and associating with tags", %{user: user} do
      # Create tags first
      {:ok, tag1} = Bookmarks.create_tag(%{name: "JavaScript", slug: "javascript"})
      {:ok, tag2} = Bookmarks.create_tag(%{name: "Web Development", slug: "web-dev"})
      
      # Create bookmark
      {:ok, bookmark} = Bookmarks.create_bookmark(%{
        title: "JS Tutorial",
        url: "https://example.com/js",
        user_id: user.id
      })
      
      # Associate tags with bookmark
      bookmark = bookmark |> Repo.preload(:tags)
      changeset = bookmark |> Ecto.Changeset.change()
      changeset = changeset |> Ecto.Changeset.put_assoc(:tags, [tag1, tag2])
      {:ok, updated_bookmark} = Repo.update(changeset)
      
      # Verify associations
      updated_bookmark = updated_bookmark |> Repo.preload(:tags)
      assert length(updated_bookmark.tags) == 2
      
      tag_names = Enum.map(updated_bookmark.tags, & &1.name)
      assert "JavaScript" in tag_names
      assert "Web Development" in tag_names
    end

    test "bookmark can be retrieved with its tags", %{user: user} do
      # Create tags and bookmark with associations
      {:ok, tag1} = Bookmarks.create_tag(%{name: "React", slug: "react"})
      {:ok, tag2} = Bookmarks.create_tag(%{name: "Frontend", slug: "frontend"})
      
      {:ok, bookmark} = Bookmarks.create_bookmark(%{
        title: "React Guide",
        url: "https://example.com/react",
        user_id: user.id
      })
      
      # Associate tags
      bookmark = bookmark |> Repo.preload(:tags)
      changeset = bookmark |> Ecto.Changeset.change()
      changeset = changeset |> Ecto.Changeset.put_assoc(:tags, [tag1, tag2])
      {:ok, _} = Repo.update(changeset)
      
      # Test list_bookmarks preloads tags
      bookmarks = Bookmarks.list_bookmarks()
      assert length(bookmarks) == 1
      
      bookmark = hd(bookmarks)
      assert Ecto.assoc_loaded?(bookmark.tags)
      assert length(bookmark.tags) == 2
    end

    test "tag can have multiple bookmarks", %{user: user} do
      # Create a tag
      {:ok, tag} = Bookmarks.create_tag(%{name: "Python", slug: "python"})
      
      # Create multiple bookmarks
      {:ok, bookmark1} = Bookmarks.create_bookmark(%{
        title: "Python Tutorial",
        url: "https://example.com/python1",
        user_id: user.id
      })
      
      {:ok, bookmark2} = Bookmarks.create_bookmark(%{
        title: "Advanced Python",
        url: "https://example.com/python2", 
        user_id: user.id
      })
      
      # Associate same tag with both bookmarks
      for bookmark <- [bookmark1, bookmark2] do
        bookmark = bookmark |> Repo.preload(:tags)
        changeset = bookmark |> Ecto.Changeset.change()
        changeset = changeset |> Ecto.Changeset.put_assoc(:tags, [tag])
        {:ok, _} = Repo.update(changeset)
      end
      
      # Verify tag has multiple bookmarks
      tag = tag |> Repo.preload(:bookmarks)
      assert length(tag.bookmarks) == 2
      
      bookmark_titles = Enum.map(tag.bookmarks, & &1.title)
      assert "Python Tutorial" in bookmark_titles
      assert "Advanced Python" in bookmark_titles
    end

    test "removing tag association from bookmark", %{user: user} do
      # Create tag and bookmark with association
      {:ok, tag1} = Bookmarks.create_tag(%{name: "Node.js", slug: "nodejs"})
      {:ok, tag2} = Bookmarks.create_tag(%{name: "Backend", slug: "backend"})
      
      {:ok, bookmark} = Bookmarks.create_bookmark(%{
        title: "Node Guide",
        url: "https://example.com/node",
        user_id: user.id
      })
      
      # Associate both tags
      bookmark = bookmark |> Repo.preload(:tags)
      changeset = bookmark |> Ecto.Changeset.change()
      changeset = changeset |> Ecto.Changeset.put_assoc(:tags, [tag1, tag2])
      {:ok, bookmark} = Repo.update(changeset)
      
      # Remove one tag
      changeset = bookmark |> Ecto.Changeset.change()
      changeset = changeset |> Ecto.Changeset.put_assoc(:tags, [tag1])
      {:ok, updated_bookmark} = Repo.update(changeset)
      
      # Verify only one tag remains
      updated_bookmark = updated_bookmark |> Repo.preload(:tags)
      assert length(updated_bookmark.tags) == 1
      assert hd(updated_bookmark.tags).name == "Node.js"
    end

    test "deleting bookmark removes tag associations but not tags", %{user: user} do
      # Create tag and bookmark with association
      {:ok, tag} = Bookmarks.create_tag(%{name: "Vue.js", slug: "vuejs"})
      
      {:ok, bookmark} = Bookmarks.create_bookmark(%{
        title: "Vue Guide",
        url: "https://example.com/vue",
        user_id: user.id
      })
      
      # Associate tag
      bookmark = bookmark |> Repo.preload(:tags)
      changeset = bookmark |> Ecto.Changeset.change()
      changeset = changeset |> Ecto.Changeset.put_assoc(:tags, [tag])
      {:ok, bookmark} = Repo.update(changeset)
      
      # Delete bookmark
      {:ok, _} = Bookmarks.delete_bookmark(bookmark)
      
      # Verify tag still exists
      assert Bookmarks.get_tag!(tag.id)
      
      # Verify association is removed
      tag = tag |> Repo.preload(:bookmarks)
      assert length(tag.bookmarks) == 0
    end

    test "deleting tag removes associations but not bookmarks", %{user: user} do
      # Create tag and bookmark with association
      {:ok, tag} = Bookmarks.create_tag(%{name: "Angular", slug: "angular"})
      
      {:ok, bookmark} = Bookmarks.create_bookmark(%{
        title: "Angular Guide",
        url: "https://example.com/angular",
        user_id: user.id
      })
      
      # Associate tag
      bookmark = bookmark |> Repo.preload(:tags)
      changeset = bookmark |> Ecto.Changeset.change()
      changeset = changeset |> Ecto.Changeset.put_assoc(:tags, [tag])
      {:ok, bookmark} = Repo.update(changeset)
      
      # Delete tag
      {:ok, _} = Bookmarks.delete_tag(tag)
      
      # Verify bookmark still exists
      assert Bookmarks.get_bookmark!(bookmark.id)
      
      # Verify association is removed
      bookmark = bookmark |> Repo.preload(:tags, force: true)
      assert length(bookmark.tags) == 0
    end

    test "duplicate tag associations are handled gracefully", %{user: user} do
      # Create tag and bookmark
      {:ok, tag} = Bookmarks.create_tag(%{name: "CSS", slug: "css"})
      
      {:ok, bookmark} = Bookmarks.create_bookmark(%{
        title: "CSS Guide",
        url: "https://example.com/css",
        user_id: user.id
      })
      
      # Try to associate same tag multiple times
      bookmark = bookmark |> Repo.preload(:tags)
      changeset = bookmark |> Ecto.Changeset.change()
      changeset = changeset |> Ecto.Changeset.put_assoc(:tags, [tag, tag])
      {:ok, updated_bookmark} = Repo.update(changeset)
      
      # Verify only one association exists
      updated_bookmark = updated_bookmark |> Repo.preload(:tags)
      assert length(updated_bookmark.tags) == 1
    end

    test "large number of tag associations", %{user: user} do
      # Create many tags
      tags = for i <- 1..10 do
        {:ok, tag} = Bookmarks.create_tag(%{
          name: "Tag #{i}",
          slug: "tag-#{i}"
        })
        tag
      end
      
      # Create bookmark
      {:ok, bookmark} = Bookmarks.create_bookmark(%{
        title: "Multi-tag Bookmark",
        url: "https://example.com/multi",
        user_id: user.id
      })
      
      # Associate all tags
      bookmark = bookmark |> Repo.preload(:tags)
      changeset = bookmark |> Ecto.Changeset.change()
      changeset = changeset |> Ecto.Changeset.put_assoc(:tags, tags)
      {:ok, updated_bookmark} = Repo.update(changeset)
      
      # Verify all associations
      updated_bookmark = updated_bookmark |> Repo.preload(:tags)
      assert length(updated_bookmark.tags) == 10
    end
  end
end