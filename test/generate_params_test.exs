defmodule GenerateParamsTest do
  use SeedsApp.DataCase

  alias SeedsApp.GenerateParams

  describe "single params generation" do
    test "account/1" do
      %{id: user_id} = Factory.insert(:user)

      assert %{balance: _balance, login: _login, user_id: ^user_id} =
               GenerateParams.account(user_id)
    end

    test "user/0" do
      id = :rand.uniform(1_000)
      assert %{name: _name, email: _email, age: _age} = GenerateParams.user(id)
    end

    test "room/0" do
      id = :rand.uniform(1_000)
      assert %{title: _title} = GenerateParams.room(id)
    end

    test "meeting/2" do
      %{id: user_id} = Factory.insert(:user)
      %{id: room_id} = Factory.insert(:room)

      assert %{theme: _theme, user_id: ^user_id, room_id: ^room_id} =
               GenerateParams.meeting(user_id, room_id)
    end
  end

  describe "batch params generation" do
    test "users_list/1 generates correct count" do
      count = 5
      start_id = 1

      result = GenerateParams.users_list(start_id, count)

      assert is_list(result)
      assert length(result) == count
    end

    test "users_list/1 generates valid user params" do
      count = 10
      start_id = 100

      result = GenerateParams.users_list(start_id, count)

      Enum.each(result, fn user_params ->
        assert is_map(user_params)
        assert Map.has_key?(user_params, :name)
        assert Map.has_key?(user_params, :age)
        assert Map.has_key?(user_params, :email)
        assert is_binary(user_params.name)
        assert is_integer(user_params.age)
        assert is_binary(user_params.email)
      end)
    end

    test "rooms_list/1 generates correct count" do
      count = 5
      start_id = 1

      result = GenerateParams.rooms_list(start_id, count)

      assert is_list(result)
      assert length(result) == count
    end

    test "rooms_list/1 generates valid room params" do
      count = 10
      start_id = 1

      result = GenerateParams.rooms_list(start_id, count)

      Enum.each(result, fn room_params ->
        assert is_map(room_params)
        assert Map.has_key?(room_params, :title)
        assert is_binary(room_params.title)
      end)
    end

    test "accounts_list/1 generates correct count" do
      user_ids = [1, 2, 3, 4, 5]
      count = length(user_ids)

      result = GenerateParams.accounts_list(user_ids)

      assert is_list(result)
      assert length(result) == count
    end

    test "accounts_list/1 generates valid account params" do
      user_ids = [1, 2, 3]

      result = GenerateParams.accounts_list(user_ids)

      Enum.each(result, fn account_params ->
        assert is_map(account_params)
        assert Map.has_key?(account_params, :balance)
        assert Map.has_key?(account_params, :login)
        assert Map.has_key?(account_params, :user_id)
        assert is_float(account_params.balance)
        assert is_boolean(account_params.login)
        assert is_integer(account_params.user_id)
      end)
    end

    test "accounts_list/1 assigns correct user_ids" do
      user_ids = [10, 20, 30]

      result = GenerateParams.accounts_list(user_ids)
      result_user_ids = Enum.map(result, & &1.user_id)

      assert result_user_ids == user_ids
    end

    test "meetings_list/3 generates correct count" do
      user_ids = [1, 2, 3]
      room_ids = [10, 20]
      count = 4

      result = GenerateParams.meetings_list(user_ids, room_ids, count)

      assert is_list(result)
      assert length(result) == count
    end

    test "meetings_list/3 generates valid meeting params" do
      user_ids = [1, 2, 3]
      room_ids = [10, 20]
      count = 10

      result = GenerateParams.meetings_list(user_ids, room_ids, count)

      Enum.each(result, fn meeting_params ->
        assert is_map(meeting_params)
        assert Map.has_key?(meeting_params, :theme)
        assert Map.has_key?(meeting_params, :user_id)
        assert Map.has_key?(meeting_params, :room_id)
        assert is_binary(meeting_params.theme)
        assert meeting_params.user_id in user_ids
        assert meeting_params.room_id in room_ids
      end)
    end

    test "meetings_list/3 uses all available user_ids and room_ids" do
      user_ids = [1, 2]
      room_ids = [10, 20]
      count = 100

      result = GenerateParams.meetings_list(user_ids, room_ids, count)
      used_user_ids = Enum.uniq(Enum.map(result, & &1.user_id))
      used_room_ids = Enum.uniq(Enum.map(result, & &1.room_id))

      assert Enum.sort(used_user_ids) == Enum.sort(user_ids)
      assert Enum.sort(used_room_ids) == Enum.sort(room_ids)
    end
  end
end
