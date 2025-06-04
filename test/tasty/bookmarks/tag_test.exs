defmodule Tasty.Bookmarks.TagTest do
  use Tasty.DataCase, async: true

  alias Tasty.Bookmarks.Tag

  describe "changeset/2" do
    test "validates required fields" do
      changeset = Tag.changeset(%Tag{}, %{})
      
      assert %{
        name: ["can't be blank"],
        slug: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "validates slug format" do
      changeset = Tag.changeset(%Tag{}, %{
        name: "Test Tag",
        slug: "Invalid Slug!"
      })
      
      assert %{slug: ["must contain only lowercase letters, numbers, and hyphens"]} = errors_on(changeset)
    end

    test "accepts valid slug formats" do
      valid_slugs = [
        "javascript",
        "web-development", 
        "html5",
        "css-3",
        "node-js",
        "react-native"
      ]

      for slug <- valid_slugs do
        changeset = Tag.changeset(%Tag{}, %{
          name: "Test",
          slug: slug
        })
        
        assert changeset.valid?, "Expected #{slug} to be valid"
      end
    end

    test "auto-generates slug from name when slug is not provided" do
      changeset = Tag.changeset(%Tag{}, %{
        name: "JavaScript Programming"
      })
      
      assert changeset.valid?
      assert get_change(changeset, :slug) == "javascript-programming"
    end

    test "slug generation handles special characters" do
      test_cases = [
        {"React.js & Vue.js", "react-js-vue-js"},
        {"C++ Programming!", "c-programming"},
        {"Node.js   Development", "node-js-development"},
        {"HTML/CSS", "html-css"},
        {"API Design & Development", "api-design-development"},
        {"Machine Learning (ML)", "machine-learning-ml"}
      ]

      for {name, expected_slug} <- test_cases do
        changeset = Tag.changeset(%Tag{}, %{name: name})
        
        assert changeset.valid?
        assert get_change(changeset, :slug) == expected_slug, 
               "Expected #{name} to generate slug #{expected_slug}, got #{get_change(changeset, :slug)}"
      end
    end

    test "does not override provided slug" do
      changeset = Tag.changeset(%Tag{}, %{
        name: "JavaScript",
        slug: "custom-js-slug"
      })
      
      assert changeset.valid?
      assert get_change(changeset, :slug) == "custom-js-slug"
    end

    test "handles empty slug generation gracefully" do
      changeset = Tag.changeset(%Tag{}, %{
        name: "!@#$%^&*()"
      })
      
      # Should generate empty slug and fail validation
      refute changeset.valid?
      assert %{slug: ["can't be blank"]} = errors_on(changeset)
    end

    test "accepts optional color field" do
      changeset = Tag.changeset(%Tag{}, %{
        name: "JavaScript",
        slug: "javascript",
        color: "#f7df1e"
      })
      
      assert changeset.valid?
      assert get_change(changeset, :color) == "#f7df1e"
    end

    test "handles color field as nil" do
      changeset = Tag.changeset(%Tag{}, %{
        name: "JavaScript",
        slug: "javascript",
        color: nil
      })
      
      assert changeset.valid?
    end

    test "validates uniqueness constraints" do
      changeset = Tag.changeset(%Tag{}, %{
        name: "JavaScript",
        slug: "javascript"
      })
      
      # The uniqueness constraint is validated at the database level
      # This test ensures the changeset includes the constraints
      constraints = changeset.constraints
      
      name_constraint = Enum.find(constraints, &(&1.field == :name))
      slug_constraint = Enum.find(constraints, &(&1.field == :slug))
      
      assert name_constraint.type == :unique
      assert slug_constraint.type == :unique
    end

    test "updates existing tag" do
      existing_tag = %Tag{
        name: "Old Name",
        slug: "old-slug",
        color: "#old"
      }
      
      changeset = Tag.changeset(existing_tag, %{
        name: "New Name",
        color: "#new"
      })
      
      assert changeset.valid?
      assert get_change(changeset, :name) == "New Name"
      assert get_change(changeset, :color) == "#new"
      # Existing slug is preserved when updating
      refute get_change(changeset, :slug)
    end

    test "preserves existing slug when updating without name change" do
      existing_tag = %Tag{
        name: "JavaScript",
        slug: "javascript",
        color: "#old"
      }
      
      changeset = Tag.changeset(existing_tag, %{
        color: "#new"
      })
      
      assert changeset.valid?
      assert get_change(changeset, :color) == "#new"
      refute get_change(changeset, :slug)  # No slug change
    end

    test "edge case: very long name generates valid slug" do
      long_name = String.duplicate("very-long-tag-name-", 10) <> "end"
      
      changeset = Tag.changeset(%Tag{}, %{
        name: long_name
      })
      
      assert changeset.valid?
      slug = get_change(changeset, :slug)
      assert is_binary(slug)
      assert String.length(slug) > 0
      # Verify the slug follows the expected pattern
      assert slug =~ ~r/^[a-z0-9-]+$/
    end

    test "preserves hyphen separators in slug generation" do
      changeset = Tag.changeset(%Tag{}, %{
        name: "Multi-Word Tag Name"
      })
      
      assert changeset.valid?
      assert get_change(changeset, :slug) == "multi-word-tag-name"
    end
  end
end