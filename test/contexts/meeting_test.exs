defmodule Contexts.MeetingTest do
  use SeedsApp.DataCase

  alias SeedsApp.Contexts.Models.Meeting
  alias SeedsApp.Contexts.Meetings
  alias SeedsApp.Contexts.Rooms
  alias SeedsApp.Contexts.UsersAccounts
  alias SeedsApp.Repo

  describe "single record operations" do
    test "create/2" do
      %{id: user_id} = Factory.insert(:user)
      %{id: room_id} = Factory.insert(:room)

      assert {:ok, %Meeting{user_id: ^user_id, room_id: ^room_id}} =
               Meetings.create(user_id, room_id)
    end

    test "delete_all/0" do
      Factory.insert(:meeting)
      assert {1, nil} = Meetings.delete_all()
      assert [] = Repo.all(Meeting)
    end
  end

  describe "batch operations" do
    setup do
      # Create users and rooms for testing
      {:ok, users_result} = UsersAccounts.create_batch(5)
      {:ok, rooms_result} = Rooms.create_batch(3)

      %{
        user_ids: users_result.ids,
        room_ids: rooms_result.ids
      }
    end

    test "create_batch/3 creates correct count", %{user_ids: user_ids, room_ids: room_ids} do
      count = 10

      assert {:ok, result} = Meetings.create_batch(count, user_ids, room_ids)
      assert result.created == count
    end

    test "create_batch/3 returns correct structure", %{user_ids: user_ids, room_ids: room_ids} do
      count = 5

      assert {:ok, result} = Meetings.create_batch(count, user_ids, room_ids)

      assert is_map(result)
      assert Map.has_key?(result, :created)
      assert Map.has_key?(result, :all_count)
    end

    test "create_batch/3 creates meetings in DB", %{user_ids: user_ids, room_ids: room_ids} do
      count = 15

      {:ok, _result} = Meetings.create_batch(count, user_ids, room_ids)

      meetings = Repo.all(Meeting)
      assert length(meetings) == count
    end

    test "create_batch/3 uses only provided user_ids", %{user_ids: user_ids, room_ids: room_ids} do
      count = 20

      {:ok, _result} = Meetings.create_batch(count, user_ids, room_ids)

      meetings = Repo.all(Meeting)

      Enum.each(meetings, fn meeting ->
        assert meeting.user_id in user_ids
        assert meeting.room_id in room_ids
      end)
    end

    test "create_batch/3 returns error when count is invalid", %{user_ids: user_ids, room_ids: room_ids} do
      assert {:error, _} = Meetings.create_batch(0, user_ids, room_ids)
      assert {:error, _} = Meetings.create_batch(-1, user_ids, room_ids)
      assert {:error, _} = Meetings.create_batch("invalid", user_ids, room_ids)
    end

    test "create_batch/3 returns error when user_ids is empty", %{room_ids: room_ids} do
      assert {:error, _} = Meetings.create_batch(5, [], room_ids)
    end

    test "create_batch/3 returns error when room_ids is empty", %{user_ids: user_ids} do
      assert {:error, _} = Meetings.create_batch(5, user_ids, [])
    end
  end
end