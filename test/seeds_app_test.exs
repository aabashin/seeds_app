defmodule SeedsAppTest do
  use SeedsApp.DataCase

  use ExUnit.Case, async: false

  alias SeedsApp.Contexts.Meetings
  alias SeedsApp.Contexts.Rooms
  alias SeedsApp.Contexts.UsersAccounts

  alias SeedsApp.Contexts.Models.Account
  alias SeedsApp.Contexts.Models.Meeting
  alias SeedsApp.Contexts.Models.Room
  alias SeedsApp.Contexts.Models.User

  alias SeedsApp.Repo

  setup do
    # Очищаем очередь задач перед тестом
    case Process.whereis(SeedsApp.AsyncSeeds) do
      nil ->
        :ok

      _ ->
        SeedsApp.AsyncSeeds.clear_queue()
    end
  end

  test "success seeds" do
    Repo.delete_all(Meeting)
    Repo.delete_all(Room)
    Repo.delete_all(Account)
    Repo.delete_all(User)

    assert {:ok, %{message: message}} = SeedsApp.seeds(1, 1, 1)
    assert message =~ "Created 1 Users & Accounts, 1 Rooms and 1 Meetings."

    assert [%{id: room_id, title: _title}] = Repo.all(Room)
    assert [%{id: user_id, name: _name, age: _age, email: _email}] = Repo.all(User)
    assert [%{user_id: ^user_id, balance: _balance, login: _login}] = Repo.all(Account)
    assert [%{room_id: ^room_id, user_id: ^user_id, theme: _theme}] = Repo.all(Meeting)
  end

  test "don't create records id db, if args is incorrect" do
    assert {:error, "Some attrs is incorrect. See the help on /api/help"} =
             SeedsApp.seeds("some incorrect")
  end

  test "clear_all/0" do
    for module <- [Meetings, Rooms, UsersAccounts] do
      Mimic.stub(module, :delete_all, fn -> {:rand.uniform(10), nil} end)
    end

    assert %{deleted_meetings_count: _, deleted_rooms_count: _, deleted_users_accounts_count: _} =
             SeedsApp.clear_all()
  end
end
