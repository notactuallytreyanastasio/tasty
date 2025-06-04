#!/bin/bash

# Script to fix git history by ensuring every commit has green tests
# This will manually fix commits one by one using git filter-branch

set -e

echo "🧹 Fixing git history to ensure all commits have green tests..."

# Get all commit SHAs in chronological order (oldest first)
echo "📋 Analyzing commit history..."
git log --oneline --reverse

# Manual approach: Check each commit and fix if needed
check_commit() {
    local commit_sha=$1
    echo ""
    echo "🔍 Checking commit: $commit_sha"
    
    # Check out the commit
    git checkout "$commit_sha" 2>/dev/null || {
        echo "❌ Failed to checkout $commit_sha"
        return 1
    }
    
    # Check if this is an Elixir project commit
    if [ ! -f "mix.exs" ]; then
        echo "⏭️  Not an Elixir commit, skipping"
        return 0
    fi
    
    # Try to compile
    echo "  🔨 Compiling..."
    if ! mix compile >/dev/null 2>&1; then
        echo "  ❌ Compilation failed"
        return 1
    fi
    
    # Install deps if needed
    if [ ! -d "deps" ] || [ ! -d "_build" ]; then
        echo "  📦 Installing dependencies..."
        mix deps.get >/dev/null 2>&1 || true
    fi
    
    # Run tests
    echo "  🧪 Running tests..."
    local test_output
    test_output=$(mix test 2>&1)
    local test_exit_code=$?
    
    if [ $test_exit_code -eq 0 ]; then
        echo "  ✅ Tests pass"
        return 0
    else
        echo "  ❌ Tests fail"
        echo "  📋 Test output:"
        echo "$test_output" | head -20
        return 1
    fi
}

# Check if we need to create a clean branch
original_branch=$(git branch --show-current)
if [ -z "$original_branch" ]; then
    original_branch="main"
fi

echo "📍 Starting from: $original_branch"

# List all commits to check
commits=($(git log --oneline --reverse | awk '{print $1}'))
echo "📋 Found ${#commits[@]} commits to check"

# Check each commit
failed_commits=()
for i in "${!commits[@]}"; do
    commit=${commits[$i]}
    echo ""
    echo "🔍 [$((i+1))/${#commits[@]}] Checking: $commit"
    
    if ! check_commit "$commit"; then
        failed_commits+=("$commit")
        echo "  ❌ Commit $commit has issues"
    else
        echo "  ✅ Commit $commit is clean"
    fi
done

# Return to original branch
git checkout "$original_branch" >/dev/null 2>&1

echo ""
echo "🏁 Analysis complete!"

if [ ${#failed_commits[@]} -eq 0 ]; then
    echo "✅ All commits have green tests!"
    exit 0
else
    echo "❌ The following commits have failing tests:"
    for commit in "${failed_commits[@]}"; do
        echo "  - $commit"
    done
    echo ""
    echo "💡 Manual intervention needed. The script found issues but didn't automatically fix them."
    echo "   You may need to use git rebase -i to edit these commits."
    exit 1
fi