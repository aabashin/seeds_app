defmodule SeedsAppTest do
  use SeedsApp.DataCase

  alias SeedsApp.Contexts.Models.Account
  alias SeedsApp.Contexts.Models.Meeting
  alias SeedsApp.Contexts.Models.Room
  alias SeedsApp.Contexts.Models.User
  alias SeedsApp.Repo

  test "success seeds" do
    assert :ok = SeedsApp.seeds(1, 1, 1)

    assert [%{id: room_id, title: _title}] = Repo.all(Room)
    assert [%{id: user_id, name: _name, age: _age, email: _email}] = Repo.all(User)
    assert [%{user_id: ^user_id, balance: _balance, login: _login}] = Repo.all(Account)
    assert [%{room_id: ^room_id, user_id: ^user_id, theme: _theme}] = Repo.all(Meeting)
  end

  test "don't create records id db, if args is incorrect" do
    assert :ok = SeedsApp.seeds("some incorrect")

    assert [] = Repo.all(Room)
    assert [] = Repo.all(User)
    assert [] = Repo.all(Account)
    assert [] = Repo.all(Meeting)
  end

  test "clear_all/0" do
    Factory.insert(:room)
    Factory.insert(:user)
    Factory.insert(:meeting)

    assert {2, nil} = SeedsApp.clear_all()

    assert [] = Repo.all(Room)
    assert [] = Repo.all(User)
    assert [] = Repo.all(Account)
    assert [] = Repo.all(Meeting)
  end
end
