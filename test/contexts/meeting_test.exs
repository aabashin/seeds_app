defmodule Contexts.MeetingTest do
  use SeedsApp.DataCase

  alias SeedsApp.Contexts.Models.Meeting
  alias SeedsApp.Contexts.Meetings
  alias SeedsApp.Repo

  test "create/2" do
    %{id: user_id} = Factory.insert(:user)
    %{id: room_id} = Factory.insert(:room)

    assert {:ok, %Meeting{user_id: ^user_id, room_id: ^room_id}} =
             Meetings.create(user_id, room_id)
  end

  test "delete/0" do
    Factory.insert(:meeting)
    assert {1, nil} = Meetings.delete_all()
    assert [] = Repo.all(Meeting)
  end
end
