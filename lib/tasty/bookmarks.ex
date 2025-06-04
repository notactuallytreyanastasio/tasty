defmodule Tasty.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  import Ecto.Query, warn: false
  alias Tasty.Repo

  alias Tasty.Bookmarks.Bookmark

  @doc """
  Returns the list of bookmarks.

  ## Examples

      iex> list_bookmarks()
      [%Bookmark{}, ...]

  """
  def list_bookmarks(params \\ %{}) do
    from(b in Bookmark)
    |> filter_by_user_id(params)
    |> filter_by_is_public(params)
    |> filter_by_tag(params)
    |> apply_ordering(params)
    |> apply_limit(params)
    |> preload([:user, :tags])
    |> Repo.all()
  end

  @doc """
  Returns a random sampling of public bookmarks for the discovery feed.
  
  ## Options
  - limit: number of bookmarks to return (default: 20)
  - tag_id: filter by specific tag
  """
  def list_public_bookmarks(opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    tag_id = Keyword.get(opts, :tag_id, nil)
    
    from(b in Bookmark)
    |> where([b], b.is_public == true)
    |> maybe_filter_by_tag_id(tag_id)
    |> order_by([b], fragment("RANDOM()"))
    |> limit(^limit)
    |> preload([:user, :tags])
    |> Repo.all()
  end

  @doc """
  Returns tags ordered by bookmark count for popular tags display.
  """
  def list_popular_tags(limit \\ 20) do
    from(t in Tasty.Bookmarks.Tag)
    |> join(:left, [t], bt in "bookmark_tags", on: bt.tag_id == t.id)
    |> join(:left, [t, bt], b in Bookmark, on: b.id == bt.bookmark_id and b.is_public == true)
    |> group_by([t], t.id)
    |> order_by([t, bt, b], desc: count(b.id))
    |> limit(^limit)
    |> select([t, bt, b], {t, count(b.id)})
    |> Repo.all()
    |> Enum.map(fn {tag, _count} -> tag end)
  end

  @doc """
  Returns a map of tag_id => count for public bookmarks.
  """
  def get_tag_counts_for_public_bookmarks do
    from(t in Tasty.Bookmarks.Tag)
    |> join(:left, [t], bt in "bookmark_tags", on: bt.tag_id == t.id)
    |> join(:left, [t, bt], b in Bookmark, on: b.id == bt.bookmark_id and b.is_public == true)
    |> group_by([t], t.id)
    |> select([t, bt, b], {t.id, count(b.id)})
    |> Repo.all()
    |> Map.new()
  end

  defp filter_by_user_id(query, %{"user_id" => user_id}) when not is_nil(user_id) do
    from b in query, where: b.user_id == ^user_id
  end
  defp filter_by_user_id(query, _), do: query

  defp filter_by_is_public(query, %{"public_only" => "true"}) do
    from b in query, where: b.is_public == true
  end
  defp filter_by_is_public(query, _), do: query

  defp filter_by_tag(query, %{"tag_id" => tag_id}) when not is_nil(tag_id) do
    from b in query,
      join: bt in "bookmark_tags", on: bt.bookmark_id == b.id,
      where: bt.tag_id == ^tag_id
  end
  defp filter_by_tag(query, _), do: query

  defp maybe_filter_by_tag_id(query, nil), do: query
  defp maybe_filter_by_tag_id(query, tag_id) do
    from b in query,
      join: bt in "bookmark_tags", on: bt.bookmark_id == b.id,
      where: bt.tag_id == ^tag_id
  end

  defp apply_ordering(query, %{"order" => "recent"}) do
    from b in query, order_by: [desc: b.inserted_at]
  end
  defp apply_ordering(query, %{"order" => "popular"}) do
    from b in query, order_by: [desc: b.view_count]
  end
  defp apply_ordering(query, %{"order" => "random"}) do
    from b in query, order_by: fragment("RANDOM()")
  end
  defp apply_ordering(query, _) do
    from b in query, order_by: [desc: b.inserted_at]
  end

  defp apply_limit(query, %{"limit" => limit}) when is_binary(limit) do
    case Integer.parse(limit) do
      {limit_int, ""} -> limit(query, ^limit_int)
      _ -> query
    end
  end
  defp apply_limit(query, _), do: query

  @doc """
  Gets a single bookmark.

  Raises `Ecto.NoResultsError` if the Bookmark does not exist.

  ## Examples

      iex> get_bookmark!(123)
      %Bookmark{}

      iex> get_bookmark!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bookmark!(id), do: Repo.get!(Bookmark, id)

  @doc """
  Creates a bookmark.

  ## Examples

      iex> create_bookmark(%{field: value})
      {:ok, %Bookmark{}}

      iex> create_bookmark(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bookmark(attrs \\ %{}) do
    %Bookmark{}
    |> Bookmark.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bookmark.

  ## Examples

      iex> update_bookmark(bookmark, %{field: new_value})
      {:ok, %Bookmark{}}

      iex> update_bookmark(bookmark, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bookmark(%Bookmark{} = bookmark, attrs) do
    bookmark
    |> Bookmark.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bookmark.

  ## Examples

      iex> delete_bookmark(bookmark)
      {:ok, %Bookmark{}}

      iex> delete_bookmark(bookmark)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bookmark(%Bookmark{} = bookmark) do
    Repo.delete(bookmark)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bookmark changes.

  ## Examples

      iex> change_bookmark(bookmark)
      %Ecto.Changeset{data: %Bookmark{}}

  """
  def change_bookmark(%Bookmark{} = bookmark, attrs \\ %{}) do
    Bookmark.changeset(bookmark, attrs)
  end

  alias Tasty.Bookmarks.Tag

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end
end
