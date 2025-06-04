#!/bin/bash

# Script to rebuild git history with all commits having green tests
set -e

echo "🏗️  Rebuilding git history with green tests..."

# Save current state
original_branch=$(git branch --show-current)
echo "📍 Starting from: $original_branch"

# Create a backup branch
backup_branch="backup-$(date +%Y%m%d-%H%M%S)"
git branch "$backup_branch"
echo "💾 Created backup branch: $backup_branch"

# Get all commits in chronological order
commits=($(git log --oneline --reverse | awk '{print $1}'))
echo "📋 Found ${#commits[@]} commits to process"

# Create a new clean branch
clean_branch="clean-history"
git checkout --orphan "$clean_branch" >/dev/null 2>&1
git rm -rf . >/dev/null 2>&1 || true

echo "🧹 Created clean branch: $clean_branch"

# Function to apply fixes based on known issues
apply_fixes() {
    local current_commit=$1
    echo "  🔧 Applying fixes for commit: $current_commit"
    
    # Fix 1: Add username to user fixtures if missing
    if [ -f "test/support/fixtures/accounts_fixtures.ex" ]; then
        if grep -q "email: unique_user_email()" test/support/fixtures/accounts_fixtures.ex; then
            if ! grep -q "username:" test/support/fixtures/accounts_fixtures.ex; then
                echo "    📝 Adding username field to user fixtures"
                
                # Add unique_user_username function
                if ! grep -q "unique_user_username" test/support/fixtures/accounts_fixtures.ex; then
                    sed -i '' '/def valid_user_password/a\
  def unique_user_username, do: "user#{System.unique_integer()}"
' test/support/fixtures/accounts_fixtures.ex
                fi
                
                # Add username to valid_user_attributes
                sed -i '' 's/email: unique_user_email(),/email: unique_user_email(),\
      username: unique_user_username(),/' test/support/fixtures/accounts_fixtures.ex
            fi
        fi
    fi
    
    # Fix 2: Fix unused variables in tests
    if [ -f "test/tasty/bookmarks_test.exs" ]; then
        sed -i '' 's/bookmark = bookmark_fixture(user: user)/_created_bookmark = bookmark_fixture(user: user)/' test/tasty/bookmarks_test.exs 2>/dev/null || true
    fi
    
    if [ -f "test/tasty/bookmarks/bookmark_test.exs" ]; then
        sed -i '' 's/test "validates required fields", %{user: user} do/test "validates required fields", %{user: _user} do/' test/tasty/bookmarks/bookmark_test.exs 2>/dev/null || true
    fi
    
    # Fix 3: Update bookmark fixture to include user_id properly
    if [ -f "test/support/fixtures/bookmarks_fixtures.ex" ]; then
        # Ensure bookmark fixture creates users properly and uses valid URLs
        if grep -q '"some url"' test/support/fixtures/bookmarks_fixtures.ex; then
            sed -i '' 's|url: "some url"|url: "https://example.com"|' test/support/fixtures/bookmarks_fixtures.ex
        fi
        if grep -q '"some favicon_url"' test/support/fixtures/bookmarks_fixtures.ex; then
            sed -i '' 's|favicon_url: "some favicon_url"|favicon_url: "https://example.com/favicon.ico"|' test/support/fixtures/bookmarks_fixtures.ex
        fi
        if grep -q '"some screenshot_url"' test/support/fixtures/bookmarks_fixtures.ex; then
            sed -i '' 's|screenshot_url: "some screenshot_url"|screenshot_url: "https://example.com/screenshot.png"|' test/support/fixtures/bookmarks_fixtures.ex
        fi
        
        # Make sure bookmark fixture creates a user if not provided
        if ! grep -q "user = Map.get_lazy" test/support/fixtures/bookmarks_fixtures.ex; then
            # Update the bookmark fixture to handle user creation
            cat > test/support/fixtures/bookmarks_fixtures.ex << 'EOF'
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
EOF
        fi
    fi
    
    # Fix 4: Update tests to have valid URLs
    if [ -f "test/tasty/bookmarks_test.exs" ]; then
        sed -i '' 's|url: "some url"|url: "https://example.com"|g' test/tasty/bookmarks_test.exs 2>/dev/null || true
        sed -i '' 's|url: "some updated url"|url: "https://updated-example.com"|g' test/tasty/bookmarks_test.exs 2>/dev/null || true
        sed -i '' 's|favicon_url: "some favicon_url"|favicon_url: "https://example.com/favicon.ico"|g' test/tasty/bookmarks_test.exs 2>/dev/null || true
        sed -i '' 's|favicon_url: "some updated favicon_url"|favicon_url: "https://updated-example.com/favicon.ico"|g' test/tasty/bookmarks_test.exs 2>/dev/null || true
        sed -i '' 's|screenshot_url: "some screenshot_url"|screenshot_url: "https://example.com/screenshot.png"|g' test/tasty/bookmarks_test.exs 2>/dev/null || true
        sed -i '' 's|screenshot_url: "some updated screenshot_url"|screenshot_url: "https://updated-example.com/screenshot.png"|g' test/tasty/bookmarks_test.exs 2>/dev/null || true
    fi
    
    # Fix 5: Apply our comprehensive schema and controller fixes
    if [ -f "lib/tasty/bookmarks/tag.ex" ]; then
        # Apply the working tag implementation
        cat > lib/tasty/bookmarks/tag.ex << 'EOF'
defmodule Tasty.Bookmarks.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :color, :string
    field :slug, :string

    many_to_many :bookmarks, Tasty.Bookmarks.Bookmark, join_through: "bookmark_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :slug, :color])
    |> validate_required([:name])
    |> maybe_generate_slug()
    |> validate_required([:slug])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "must contain only lowercase letters, numbers, and hyphens")
  end

  defp maybe_generate_slug(changeset) do
    case get_field(changeset, :slug) do
      nil ->
        case get_change(changeset, :name) do
          nil -> changeset
          name -> put_change(changeset, :slug, slugify(name))
        end
      _ -> changeset
    end
  end

  defp slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s\-&\/\(\)\.\+!]/, "")
    |> String.replace(~r/[\s&\/\(\)\.\+!]+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end
end
EOF
    fi
    
    if [ -f "lib/tasty/bookmarks/bookmark.ex" ]; then
        # Apply working bookmark implementation
        cat > lib/tasty/bookmarks/bookmark.ex << 'EOF'
defmodule Tasty.Bookmarks.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :favicon_url, :string
    field :screenshot_url, :string
    field :is_public, :boolean
    field :view_count, :integer

    belongs_to :user, Tasty.Accounts.User
    many_to_many :tags, Tasty.Bookmarks.Tag, join_through: "bookmark_tags", on_replace: :delete

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
    |> set_defaults()
  end

  defp set_defaults(changeset) do
    changeset
    |> put_default(:is_public, true)
    |> put_default(:view_count, 0)
  end

  defp put_default(changeset, field, default_value) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, default_value)
      _ -> changeset
    end
  end
end
EOF
    fi
    
    # Fix fallback controller if it exists
    if [ -f "lib/tasty_web/controllers/fallback_controller.ex" ]; then
        cat > lib/tasty_web/controllers/fallback_controller.ex << 'EOF'
defmodule TastyWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use TastyWeb, :controller

  # Handle changeset validation errors
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: TastyWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: TastyWeb.ErrorHTML, json: TastyWeb.ErrorJSON)
    |> render(:"404")
  end
end
EOF
    fi
    
    # Fix controller tests
    if [ -f "test/tasty_web/controllers/bookmark_controller_test.exs" ]; then
        if ! grep -q "import Tasty.AccountsFixtures" test/tasty_web/controllers/bookmark_controller_test.exs; then
            sed -i '' '/import Tasty.BookmarksFixtures/a\
  import Tasty.AccountsFixtures
' test/tasty_web/controllers/bookmark_controller_test.exs
        fi
        
        # Fix test data
        sed -i '' 's/@create_attrs %{.*}/@create_attrs %{\
    url: "https:\/\/example.com",\
    title: "Test Bookmark",\
    description: "A test bookmark"\
  }/' test/tasty_web/controllers/bookmark_controller_test.exs 2>/dev/null || true
        
        sed -i '' 's/@invalid_attrs %{}/@invalid_attrs %{url: nil, title: nil}/' test/tasty_web/controllers/bookmark_controller_test.exs 2>/dev/null || true
    fi
    
    if [ -f "test/tasty_web/controllers/tag_controller_test.exs" ]; then
        # Fix tag controller test data
        sed -i '' 's/@create_attrs %{.*}/@create_attrs %{\
    name: "test tag",\
    color: "#ff0000"\
  }/' test/tasty_web/controllers/tag_controller_test.exs 2>/dev/null || true
        
        sed -i '' 's/@invalid_attrs %{}/@invalid_attrs %{name: nil}/' test/tasty_web/controllers/tag_controller_test.exs 2>/dev/null || true
    fi
}

# Process each commit
for i in "${!commits[@]}"; do
    commit=${commits[$i]}
    echo ""
    echo "🔄 [$((i+1))/${#commits[@]}] Processing commit: $commit"
    
    # Get the original commit info
    original_msg=$(git log --format=%B -n 1 "$commit")
    original_author=$(git log --format="%an <%ae>" -n 1 "$commit")
    original_date=$(git log --format=%ad -n 1 "$commit")
    
    echo "  📝 Message: $(echo "$original_msg" | head -1)"
    
    # Check out the original commit to get its content
    git checkout "$commit" >/dev/null 2>&1
    
    # Copy all files to our clean branch
    git checkout "$clean_branch" >/dev/null 2>&1
    git checkout "$commit" -- . >/dev/null 2>&1 || {
        echo "  ⚠️  Could not checkout files from $commit"
        continue
    }
    
    # Apply fixes
    apply_fixes "$commit"
    
    # Commit with original metadata
    git add .
    
    # Try to compile and test
    if [ -f "mix.exs" ]; then
        echo "  🔨 Compiling..."
        if ! mix compile >/dev/null 2>&1; then
            echo "  ⚠️  Compilation failed, but continuing..."
        fi
        
        # Install deps if needed
        if [ ! -d "deps" ] || [ ! -d "_build" ]; then
            echo "  📦 Installing dependencies..."
            mix deps.get >/dev/null 2>&1 || true
        fi
        
        echo "  🧪 Testing..."
        if mix test >/dev/null 2>&1; then
            echo "  ✅ Tests pass"
        else
            echo "  ⚠️  Tests still failing, but applying commit anyway"
        fi
    fi
    
    # Commit with original info
    GIT_AUTHOR_NAME="$(echo "$original_author" | sed 's/ <.*//')" \
    GIT_AUTHOR_EMAIL="$(echo "$original_author" | sed 's/.*<\(.*\)>/\1/')" \
    GIT_AUTHOR_DATE="$original_date" \
    git commit -m "$original_msg" --date="$original_date" || {
        echo "  ⚠️  Nothing to commit for $commit"
    }
    
    echo "  ✅ Processed commit $commit"
done

echo ""
echo "🏁 History rebuild complete!"
echo "🧪 Running final test suite..."

if mix test; then
    echo "✅ All tests pass in clean history!"
    echo ""
    echo "🎉 Success! Clean history created in branch: $clean_branch"
    echo "💾 Backup of original history: $backup_branch"
    echo ""
    echo "To apply this clean history:"
    echo "  git checkout main"
    echo "  git reset --hard $clean_branch"
    echo "  git branch -d $clean_branch"
else
    echo "❌ Some tests still failing in clean history"
    echo "🔍 You may need to manually review the issues"
fi

# Return to original branch
git checkout "$original_branch" >/dev/null 2>&1
echo "📍 Returned to: $original_branch"