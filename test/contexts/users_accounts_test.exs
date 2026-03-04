defmodule Contexts.UsersAccountsTest do
  use SeedsApp.DataCase

  alias SeedsApp.Contexts.Models.Account
  alias SeedsApp.Contexts.Models.User
  alias SeedsApp.Contexts.UsersAccounts
  alias SeedsApp.Repo

  @count 10

  describe "single record operations" do
    test "create/0" do
      assert {:ok, transaction_message} = UsersAccounts.create()
      assert %{user: %User{}, account: %Account{}} = transaction_message
    end

    test "User get_by/1 success" do
      %{id: user_id} = expected_user = Factory.insert(:user)
      user = UsersAccounts.get_by(%{id: user_id})
      assert %User{} = user
      assert user.id == expected_user.id
      assert user.name == expected_user.name
      assert user.age == expected_user.age
      assert user.email == expected_user.email
    end

    test "User get_by/1 if user not found" do
      refute UsersAccounts.get_by(%{id: -1})
    end

    test "count/0" do
      Factory.insert_list(@count, :user)
      assert @count == UsersAccounts.count()
    end

    test "get_max_user_id/0" do
      Factory.insert_list(@count, :user)

      expected_id =
        User
        |> select([u], max(u.id))
        |> Repo.one()

      assert ^expected_id = UsersAccounts.get_max_user_id()
    end

    test "get_max_user_id/0 return 0 if no Users in DB" do
      Repo.delete_all(User)

      refute User
             |> select([u], max(u.id))
             |> Repo.one()

      assert 0 = UsersAccounts.get_max_user_id()
    end

    test "delete_all/0" do
      Factory.insert_list(@count, :account)

      assert {count, nil} = UsersAccounts.delete_all()
      assert count == @count

      assert [] = Repo.all(User)
      assert [] = Repo.all(Account)
    end
  end

  describe "batch operations" do
    test "create_batch/1 creates correct count" do
      count = 5

      assert {:ok, result} = UsersAccounts.create_batch(count)
      assert result.created == count
      assert UsersAccounts.count() == count
    end

    test "create_batch/1 returns correct structure" do
      count = 3

      assert {:ok, result} = UsersAccounts.create_batch(count)

      assert is_map(result)
      assert Map.has_key?(result, :created)
      assert Map.has_key?(result, :all_count)
      assert Map.has_key?(result, :ids)
      assert is_list(result.ids)
      assert length(result.ids) == count
    end

    test "create_batch/1 creates users with accounts" do
      count = 10

      {:ok, _result} = UsersAccounts.create_batch(count)

      users = Repo.all(User)
      accounts = Repo.all(Account)

      assert length(users) == count
      assert length(accounts) == count
    end

    test "create_batch/1 returns error when count is invalid" do
      assert {:error, _} = UsersAccounts.create_batch(0)
      assert {:error, _} = UsersAccounts.create_batch(-1)
      assert {:error, _} = UsersAccounts.create_batch("invalid")
    end

    test "create_batch/1 with starting id offset" do
      # First batch
      {:ok, result1} = UsersAccounts.create_batch(3)
      first_ids = result1.ids

      # Second batch should have different ids (continuing)
      {:ok, result2} = UsersAccounts.create_batch(2)
      second_ids = result2.ids

      # All ids should be unique
      all_ids = first_ids ++ second_ids
      assert length(Enum.uniq(all_ids)) == length(all_ids)
    end
  end
end