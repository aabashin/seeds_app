defmodule GenerateParamsTest do
  use SeedsApp.DataCase

  alias SeedsApp.GenerateParams

  test "account/1" do
    %{id: user_id} = Factory.insert(:user)

    assert %{balance: _balance, login: _login, user_id: ^user_id} =
             GenerateParams.account(user_id)
  end

  test "user/0" do
    assert %{name: _name, email: _email, age: _age} = GenerateParams.user()
  end

  test "room/0" do
    assert %{title: _title} = GenerateParams.room()
  end

  test "meeting/2" do
    %{id: user_id} = Factory.insert(:user)
    %{id: room_id} = Factory.insert(:room)

    assert %{theme: _theme, user_id: ^user_id, room_id: ^room_id} =
             GenerateParams.meeting(user_id, room_id)
  end
end
