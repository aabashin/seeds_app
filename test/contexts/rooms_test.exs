defmodule Contexts.RoomsTest do
  use SeedsApp.DataCase

  alias SeedsApp.Contexts.Models.Room
  alias SeedsApp.Contexts.Rooms
  alias SeedsApp.Repo

  test "create/0" do
    assert {:ok, %Room{}} = Rooms.create()
  end

  test "delete_all/0" do
    Factory.insert(:room)
    assert {1, nil} = Rooms.delete_all()
    assert [] = Repo.all(Room)
  end

  test "get_ids/0" do
    %{id: room_id} = Factory.insert(:room)
    assert [^room_id] = Rooms.get_ids()
  end

  test "get_max_id/0" do
    Factory.insert_list(10, :room)
    expected_id =
      Room
      |> select([r], max(r.id))
      |> Repo.one()

    assert ^expected_id = Rooms.get_max_id()
  end

  test "get_max_id/0 return 0 if no Rooms in DB" do
    Repo.delete_all(Room)
    refute Room
            |> select([r], max(r.id))
            |> Repo.one()

    assert 0 = Rooms.get_max_id()
  end
end
