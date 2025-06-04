defmodule Tasty.Accounts.UserTest do
  use Tasty.DataCase, async: true

  alias Tasty.Accounts.User

  describe "registration_changeset/3" do
    test "validates required fields" do
      changeset = User.registration_changeset(%User{}, %{})
      
      assert %{
        email: ["can't be blank"],
        username: ["can't be blank"],
        password: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "validates email format" do
      attrs = %{email: "invalid", username: "testuser", password: "validpassword123"}
      changeset = User.registration_changeset(%User{}, attrs)
      
      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates email length" do
      long_email = String.duplicate("a", 150) <> "@example.com"
      attrs = %{email: long_email, username: "testuser", password: "validpassword123"}
      changeset = User.registration_changeset(%User{}, attrs)
      
      assert %{email: ["should be at most 160 character(s)"]} = errors_on(changeset)
    end

    test "validates username requirements" do
      # Test minimum length
      attrs = %{email: "test@example.com", username: "ab", password: "validpassword123"}
      changeset = User.registration_changeset(%User{}, attrs)
      assert %{username: ["should be at least 3 character(s)"]} = errors_on(changeset)

      # Test maximum length
      long_username = String.duplicate("a", 31)
      attrs = %{email: "test@example.com", username: long_username, password: "validpassword123"}
      changeset = User.registration_changeset(%User{}, attrs)
      assert %{username: ["should be at most 30 character(s)"]} = errors_on(changeset)

      # Test invalid characters
      attrs = %{email: "test@example.com", username: "test@user", password: "validpassword123"}
      changeset = User.registration_changeset(%User{}, attrs)
      assert %{username: ["can only contain letters, numbers, underscore and hyphen"]} = errors_on(changeset)
    end

    test "validates password length" do
      # Test minimum length
      attrs = %{email: "test@example.com", username: "testuser", password: "short"}
      changeset = User.registration_changeset(%User{}, attrs)
      assert %{password: ["should be at least 12 character(s)"]} = errors_on(changeset)

      # Test maximum length
      long_password = String.duplicate("a", 73)
      attrs = %{email: "test@example.com", username: "testuser", password: long_password}
      changeset = User.registration_changeset(%User{}, attrs)
      assert %{password: ["should be at most 72 character(s)"]} = errors_on(changeset)
    end

    test "hashes password when valid" do
      attrs = %{
        email: "test@example.com", 
        username: "testuser", 
        password: "validpassword123"
      }
      changeset = User.registration_changeset(%User{}, attrs)
      
      assert changeset.valid?
      assert get_change(changeset, :hashed_password)
      refute get_change(changeset, :password)
    end

    test "accepts optional bio and avatar_url" do
      attrs = %{
        email: "test@example.com", 
        username: "testuser", 
        password: "validpassword123",
        bio: "Test bio",
        avatar_url: "https://example.com/avatar.jpg"
      }
      changeset = User.registration_changeset(%User{}, attrs)
      
      assert changeset.valid?
      assert get_change(changeset, :bio) == "Test bio"
      assert get_change(changeset, :avatar_url) == "https://example.com/avatar.jpg"
    end

    test "does not hash password when hash_password: false" do
      attrs = %{
        email: "test@example.com", 
        username: "testuser", 
        password: "validpassword123"
      }
      changeset = User.registration_changeset(%User{}, attrs, hash_password: false)
      
      assert changeset.valid?
      assert get_change(changeset, :password) == "validpassword123"
      refute get_change(changeset, :hashed_password)
    end
  end

  describe "email_changeset/3" do
    test "requires email to change" do
      user = %User{email: "current@example.com"}
      changeset = User.email_changeset(user, %{})
      
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates new email format" do
      user = %User{email: "current@example.com"}
      changeset = User.email_changeset(user, %{email: "invalid"})
      
      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "accepts valid email change" do
      user = %User{email: "current@example.com"}
      changeset = User.email_changeset(user, %{email: "new@example.com"})
      
      assert changeset.valid?
      assert get_change(changeset, :email) == "new@example.com"
    end
  end

  describe "password_changeset/3" do
    test "validates password and password_confirmation match" do
      changeset = User.password_changeset(%User{}, %{
        password: "validpassword123",
        password_confirmation: "different"
      })
      
      assert %{password_confirmation: ["does not match password"]} = errors_on(changeset)
    end

    test "validates password requirements" do
      changeset = User.password_changeset(%User{}, %{password: "short"})
      
      assert %{password: ["should be at least 12 character(s)"]} = errors_on(changeset)
    end

    test "hashes password when valid" do
      changeset = User.password_changeset(%User{}, %{
        password: "validpassword123",
        password_confirmation: "validpassword123"
      })
      
      assert changeset.valid?
      assert get_change(changeset, :hashed_password)
      refute get_change(changeset, :password)
    end
  end

  describe "confirm_changeset/1" do
    test "sets confirmed_at to current time" do
      user = %User{}
      changeset = User.confirm_changeset(user)
      
      assert get_change(changeset, :confirmed_at)
      assert changeset.valid?
    end
  end

  describe "valid_password?/2" do
    test "returns true for valid password" do
      password = "validpassword123"
      hashed_password = Bcrypt.hash_pwd_salt(password)
      user = %User{hashed_password: hashed_password}
      
      assert User.valid_password?(user, password)
    end

    test "returns false for invalid password" do
      hashed_password = Bcrypt.hash_pwd_salt("validpassword123")
      user = %User{hashed_password: hashed_password}
      
      refute User.valid_password?(user, "wrongpassword")
    end

    test "returns false when user has no hashed_password" do
      user = %User{hashed_password: nil}
      
      refute User.valid_password?(user, "anypassword")
    end

    test "returns false when password is empty" do
      hashed_password = Bcrypt.hash_pwd_salt("validpassword123")
      user = %User{hashed_password: hashed_password}
      
      refute User.valid_password?(user, "")
    end
  end

  describe "validate_current_password/2" do
    test "validates current password correctly" do
      password = "validpassword123"
      hashed_password = Bcrypt.hash_pwd_salt(password)
      user = %User{hashed_password: hashed_password}
      changeset = Ecto.Changeset.change(user)
      
      result = User.validate_current_password(changeset, password)
      
      assert result.valid?
    end

    test "adds error for invalid current password" do
      hashed_password = Bcrypt.hash_pwd_salt("validpassword123")
      user = %User{hashed_password: hashed_password}
      changeset = Ecto.Changeset.change(user)
      
      result = User.validate_current_password(changeset, "wrongpassword")
      
      assert %{current_password: ["is not valid"]} = errors_on(result)
    end
  end
end