#!/bin/bash

# Comprehensive script to automatically fix git history issues
set -e

echo "🔧 Auto-fixing git history issues..."

# Function to fix a specific commit
fix_commit() {
    local commit_sha=$1
    local commit_msg=$(git log --format=%B -n 1 "$commit_sha")
    
    echo "🔧 Fixing commit: $commit_sha"
    echo "📝 Message: $commit_msg"
    
    # Check out the commit
    git checkout "$commit_sha" 2>/dev/null
    
    # Apply fixes based on the issues we know about
    local changes_made=false
    
    # Fix 1: Username field missing in user fixtures
    if [ -f "test/support/fixtures/accounts_fixtures.ex" ]; then
        if grep -q "email: unique_user_email()" test/support/fixtures/accounts_fixtures.ex && ! grep -q "username:" test/support/fixtures/accounts_fixtures.ex; then
            echo "  🔧 Adding username field to user fixtures..."
            
            # Add username field to the fixture
            sed -i '' 's/email: unique_user_email(),/email: unique_user_email(),\n      username: unique_user_username(),/' test/support/fixtures/accounts_fixtures.ex
            
            # Add the username helper function if missing
            if ! grep -q "unique_user_username" test/support/fixtures/accounts_fixtures.ex; then
                sed -i '' '/def valid_user_password/a\
  def unique_user_username, do: "user#{System.unique_integer()}"
' test/support/fixtures/accounts_fixtures.ex
            fi
            
            changes_made=true
        fi
    fi
    
    # Fix 2: Unused variable warnings in tests
    if [ -f "test/tasty/bookmarks_test.exs" ]; then
        if grep -q "bookmark = bookmark_fixture(user: user)" test/tasty/bookmarks_test.exs; then
            echo "  🔧 Fixing unused variable warning in bookmarks_test.exs..."
            sed -i '' 's/bookmark = bookmark_fixture(user: user)/_created_bookmark = bookmark_fixture(user: user)/' test/tasty/bookmarks_test.exs
            changes_made=true
        fi
    fi
    
    if [ -f "test/tasty/bookmarks/bookmark_test.exs" ]; then
        if grep -q 'test "validates required fields", %{user: user} do' test/tasty/bookmarks/bookmark_test.exs; then
            echo "  🔧 Fixing unused variable warning in bookmark_test.exs..."
            sed -i '' 's/test "validates required fields", %{user: user} do/test "validates required fields", %{user: _user} do/' test/tasty/bookmarks/bookmark_test.exs
            changes_made=true
        fi
    fi
    
    # Fix 3: Missing imports
    if [ -f "test/tasty_web/controllers/tag_controller_test.exs" ]; then
        if grep -q "import Tasty.BookmarksFixtures" test/tasty_web/controllers/tag_controller_test.exs && grep -q "unused import" <(mix compile 2>&1 || true); then
            echo "  🔧 Removing unused import in tag_controller_test.exs..."
            sed -i '' '/import Tasty.BookmarksFixtures/d' test/tasty_web/controllers/tag_controller_test.exs
            changes_made=true
        fi
    fi
    
    # Fix 4: Test implementation issues
    if [ -f "test/tasty/bookmarks/tag_test.exs" ]; then
        # Check if there are test failures related to tag tests
        if mix test test/tasty/bookmarks/tag_test.exs >/dev/null 2>&1; then
            : # Tests pass, no fix needed
        else
            echo "  🔧 Applying tag test fixes..."
            # Apply our known fixes to tag slug generation
            if [ -f "lib/tasty/bookmarks/tag.ex" ]; then
                # Update the slugify function to handle special characters properly
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
                changes_made=true
            fi
        fi
    fi
    
    # If we made changes, commit them
    if [ "$changes_made" = true ]; then
        echo "  💾 Committing fixes..."
        git add .
        git commit --amend --no-edit
        echo "  ✅ Fixes applied to commit $commit_sha"
        return 0
    else
        echo "  ⚠️  No automatic fixes available for this commit"
        return 1
    fi
}

# Get the problematic commits from our previous analysis
problematic_commits=("5a71444" "ccd60e3" "89d8fbb" "73c9c81" "b734d20" "cc11eb7")

original_branch=$(git branch --show-current)
echo "📍 Starting from: $original_branch"

# Fix each problematic commit
for commit in "${problematic_commits[@]}"; do
    echo ""
    echo "🔧 Processing commit: $commit"
    
    if fix_commit "$commit"; then
        echo "✅ Successfully fixed commit $commit"
    else
        echo "❌ Could not automatically fix commit $commit"
    fi
done

# Return to original branch
git checkout "$original_branch" >/dev/null 2>&1

echo ""
echo "🏁 Auto-fix complete!"
echo "📍 Returned to: $original_branch"
echo ""
echo "🧪 Running full test suite to verify fixes..."
if mix test; then
    echo "✅ All tests pass!"
else
    echo "❌ Some tests still failing - manual intervention may be needed"
fi