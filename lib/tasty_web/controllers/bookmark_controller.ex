defmodule TastyWeb.BookmarkController do
  use TastyWeb, :controller

  alias Tasty.Bookmarks
  alias Tasty.Bookmarks.Bookmark

  action_fallback TastyWeb.FallbackController

  def index(conn, params) do
    bookmarks = Bookmarks.list_bookmarks(params)
    render(conn, :index, bookmarks: bookmarks)
  end

  def create(conn, %{"bookmark" => bookmark_params}) do
    # For now, we'll handle bookmarks without authentication
    # TODO: Add authentication and set user_id from authenticated user
    bookmark_params = Map.put(bookmark_params, "user_id", 1)
    
    with {:ok, %Bookmark{} = bookmark} <- Bookmarks.create_bookmark(bookmark_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/bookmarks/#{bookmark}")
      |> render(:show, bookmark: bookmark)
    end
  end

  def show(conn, %{"id" => id}) do
    bookmark = Bookmarks.get_bookmark!(id)
    render(conn, :show, bookmark: bookmark)
  end

  def update(conn, %{"id" => id, "bookmark" => bookmark_params}) do
    bookmark = Bookmarks.get_bookmark!(id)
    # TODO: Add authorization check to ensure user owns bookmark

    with {:ok, %Bookmark{} = bookmark} <- Bookmarks.update_bookmark(bookmark, bookmark_params) do
      render(conn, :show, bookmark: bookmark)
    end
  end

  def delete(conn, %{"id" => id}) do
    bookmark = Bookmarks.get_bookmark!(id)
    # TODO: Add authorization check to ensure user owns bookmark

    with {:ok, %Bookmark{}} <- Bookmarks.delete_bookmark(bookmark) do
      send_resp(conn, :no_content, "")
    end
  end
end
