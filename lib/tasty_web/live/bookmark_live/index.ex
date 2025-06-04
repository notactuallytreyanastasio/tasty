defmodule TastyWeb.BookmarkLive.Index do
  use TastyWeb, :live_view

  alias Tasty.Bookmarks

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to real-time bookmark updates
      Phoenix.PubSub.subscribe(Tasty.PubSub, "bookmarks")
    end

    # Load initial data
    bookmarks = Bookmarks.list_public_bookmarks(limit: 30)
    tags = Bookmarks.list_popular_tags(15)
    tag_counts = get_tag_counts()

    {:ok,
     socket
     |> assign(:bookmarks, bookmarks)
     |> assign(:tags, tags)
     |> assign(:tag_counts, tag_counts)
     |> assign(:selected_tag, nil)
     |> assign(:loading, false)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_filters(socket, params)}
  end

  @impl true
  def handle_event("select_tag", %{"tag_id" => tag_id}, socket) do
    # Navigate with tag filter
    {:noreply, push_patch(socket, to: ~p"/discover?tag_id=#{tag_id}")}
  end

  @impl true
  def handle_event("clear_tag", _params, socket) do
    # Navigate without tag filter
    {:noreply, push_patch(socket, to: ~p"/discover")}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    socket = 
      socket
      |> assign(:loading, true)
      |> load_bookmarks()

    {:noreply, assign(socket, :loading, false)}
  end

  @impl true
  def handle_info({:bookmark_created, _bookmark}, socket) do
    # Refresh feed when new public bookmarks are added
    {:noreply, load_bookmarks(socket)}
  end

  @impl true
  def handle_info({:bookmark_updated, _bookmark}, socket) do
    # Refresh feed when bookmarks are updated
    {:noreply, load_bookmarks(socket)}
  end

  defp apply_filters(socket, params) do
    tag_id = params["tag_id"]
    selected_tag = 
      if tag_id do
        Enum.find(socket.assigns.tags, &(&1.id == String.to_integer(tag_id)))
      else
        nil
      end

    socket
    |> assign(:selected_tag, selected_tag)
    |> load_bookmarks()
  end

  defp load_bookmarks(socket) do
    tag_id = if socket.assigns.selected_tag, do: socket.assigns.selected_tag.id, else: nil
    bookmarks = Bookmarks.list_public_bookmarks(limit: 30, tag_id: tag_id)
    assign(socket, :bookmarks, bookmarks)
  end

  defp get_tag_counts do
    Bookmarks.get_tag_counts_for_public_bookmarks()
  end

  defp format_time_ago(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 -> "#{diff}s ago"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      diff < 2592000 -> "#{div(diff, 86400)}d ago"
      true -> Calendar.strftime(datetime, "%b %d, %Y")
    end
  end

  defp truncate_description(description, length \\ 120) do
    if String.length(description) > length do
      String.slice(description, 0, length) <> "..."
    else
      description
    end
  end

end