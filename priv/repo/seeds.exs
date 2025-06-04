# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tasty.Repo.insert!(%Tasty.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Tasty.Accounts
alias Tasty.Bookmarks

# Create a test user
{:ok, user} = Accounts.register_user(%{
  email: "test@example.com",
  username: "testuser",
  password: "testpassword123",
  bio: "Test user for development"
})

# Create some test tags
{:ok, tech_tag} = Bookmarks.create_tag(%{name: "Technology", slug: "technology", color: "#3B82F6"})
{:ok, web_tag} = Bookmarks.create_tag(%{name: "Web Development", slug: "web-development", color: "#10B981"})
{:ok, elixir_tag} = Bookmarks.create_tag(%{name: "Elixir", slug: "elixir", color: "#8B5CF6"})

# Create some test bookmarks
{:ok, bookmark1} = Bookmarks.create_bookmark(%{
  url: "https://elixir-lang.org",
  title: "Elixir Programming Language",
  description: "A dynamic, functional language designed for building maintainable applications.",
  user_id: user.id,
  is_public: true
})

{:ok, bookmark2} = Bookmarks.create_bookmark(%{
  url: "https://phoenixframework.org",
  title: "Phoenix Framework",
  description: "A productive web framework that does not compromise speed or maintainability.",
  user_id: user.id,
  is_public: true
})

IO.puts("Seeded database with test user and bookmarks!")
