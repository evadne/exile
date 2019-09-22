defmodule ExileAuth.AccountsTest do
  use Exile.DataCase

  alias ExileAuth.Accounts

  describe "users" do
    alias ExileAuth.Accounts.User

    @valid_attrs %{password: "some password", permissions: %{}, username: "some username"}
    @update_attrs %{password: "some updated password", permissions: %{}, username: "some updated username"}
    @invalid_attrs %{password: nil, permissions: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      # Verify password is not set and the hash is correct
      assert user.password == nil
      assert Bcrypt.verify_pass("some password", user.password_hash)
      assert user.permissions == %{}
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      # Verify password is not set and the hash is correct
      assert user.password == nil
      assert Bcrypt.verify_pass("some updated password", user.password_hash)
      assert user.permissions == %{}
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_user/2 returns a user when credentials are correct" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert {:ok, ^user} =
        Accounts.authenticate_user("some username", "some password")
    end

    test "authenticate_user/2 returns an error when the user does not exist" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert {:error, :invalid_credentials} =
        Accounts.authenticate_user("wrong username", "some password")
    end

    test "authenticate_user/2 returns an error the credentials are incorrect" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert {:error, :invalid_credentials} =
        Accounts.authenticate_user("some username", "wrong password")
    end
  end
end
