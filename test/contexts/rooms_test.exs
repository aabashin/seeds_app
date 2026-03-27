defmodule Contexts.RoomsTest do
  use SeedsApp.DataCase
  use ExUnit.Case, async: false

  alias SeedsApp.Contexts.Models.Meeting
  alias SeedsApp.Contexts.Models.Room
  alias SeedsApp.Contexts.Meetings
  alias SeedsApp.Contexts.Rooms
  alias SeedsApp.Repo

  describe "single record operations" do
    test "create/0" do
      assert {:ok, %Room{}} = Rooms.create()
    end

    test "delete_all/0" do
      Factory.insert(:room)
      Meetings.delete_all()
      assert {_, nil} = Rooms.delete_all()
      assert [] = Repo.all(Room)
    end

    test "get_ids/0" do
      %{id: room_id} = Factory.insert(:room)
      room_ids = Rooms.get_ids()

      assert is_list(room_ids)
      assert room_id in room_ids
    end

    test "get_max_id/0" do
      Factory.insert(:room)

      expected_id =
        Room
        |> select([r], max(r.id))
        |> Repo.one()

      assert ^expected_id = Rooms.get_max_id()
    end
  end

  describe "batch operations" do
    test "create_batch/1 creates correct count" do
      Repo.delete_all(Meeting)
      Repo.delete_all(Room)
      count = 5

      assert {:ok, _result} = Rooms.create_batch(count)
    end

    test "create_batch/1 returns correct structure" do
      Meetings.delete_all()
      Repo.delete_all(Room)
      count = 3

      assert {:ok, result} = Rooms.create_batch(count)

      assert is_map(result)
      assert Map.has_key?(result, :created)
      assert Map.has_key?(result, :all_count)
      assert Map.has_key?(result, :ids)
      assert is_list(result.ids)
      assert length(result.ids) == count
    end

    test "create_batch/1 creates rooms in DB" do
      Meetings.delete_all()
      Repo.delete_all(Room)
      count = 10

      {:ok, _result} = Rooms.create_batch(count)
    end

    test "create_batch/1 returns error when count is invalid" do
      assert {:error, _} = Rooms.create_batch(0)
      assert {:error, _} = Rooms.create_batch(-1)
      assert {:error, _} = Rooms.create_batch("invalid")
    end

    test "create_batch/1 with starting id offset" do
      Meetings.delete_all()
      Repo.delete_all(Room)
      # First batch
      {:ok, result1} = Rooms.create_batch(3)
      first_ids = result1.ids

      # Second batch should have different ids (continuing)
      {:ok, result2} = Rooms.create_batch(2)
      second_ids = result2.ids

      # All ids should be unique
      all_ids = first_ids ++ second_ids
      assert length(Enum.uniq(all_ids)) == length(all_ids)
    end
  end
end
