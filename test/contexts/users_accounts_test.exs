defmodule Contexts.UsersAccountsTest do
  use SeedsApp.DataCase

  alias SeedsApp.Contexts.Models.Account
  alias SeedsApp.Contexts.Models.User
  alias SeedsApp.Contexts.UsersAccounts
  alias SeedsApp.Repo

  @count 10

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

  test "delete_all/0" do
    Factory.insert_list(@count, :account)

    assert {count, nil} = UsersAccounts.delete_all()
    assert count == @count

    assert [] = Repo.all(User)
    assert [] = Repo.all(Account)
  end
end
