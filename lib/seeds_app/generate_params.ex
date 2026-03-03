defmodule SeedsApp.GenerateParams do
  @moduledoc """
  Module for generation randomize data for DB
  """

  alias SeedsApp.Types

  @spec account(user_id :: pos_integer()) :: Types.account()
  def account(user_id) do
    %{balance: :rand.uniform(), login: generate_boolean(), user_id: user_id}
  end

  @spec user(id :: pos_integer()) :: Types.user()
  def user(id) do
    %{
      name: Faker.Person.first_name(),
      age: :rand.uniform(100),
      email: Faker.Lorem.word() <> "#{id}@mail.ru"
    }
  end

  @spec room(id :: pos_integer()) :: Types.room()
  def room(id) do
    %{title: Faker.Lorem.word() <> "#{id}"}
  end

  @spec meeting(user_id :: pos_integer(), room_id :: pos_integer()) :: Types.metting()
  def meeting(user_id, room_id) do
    %{theme: Faker.Lorem.sentence(), user_id: user_id, room_id: room_id}
  end

  # Batch functions

  @spec users_list(start_id :: pos_integer(), count :: pos_integer()) :: [Types.user()]
  def users_list(start_id, count) do
    start_id..(start_id + count - 1)
    |> Enum.map(&user/1)
  end

  @spec rooms_list(start_id :: pos_integer(), count :: pos_integer()) :: [Types.room()]
  def rooms_list(start_id, count) do
    start_id..(start_id + count - 1)
    |> Enum.map(&room/1)
  end

  @spec accounts_list(user_ids :: [pos_integer()]) :: [Types.account()]
  def accounts_list(user_ids) do
    Enum.map(user_ids, &account/1)
  end

  @spec meetings_list(
          user_ids :: [pos_integer()],
          room_ids :: [pos_integer()],
          count :: pos_integer()
        ) :: [Types.metting()]
  def meetings_list(user_ids, room_ids, count) do
    Enum.map(1..count, fn _ ->
      user_id = Enum.random(user_ids)
      room_id = Enum.random(room_ids)
      meeting(user_id, room_id)
    end)
  end

  @spec generate_boolean() :: boolean()
  defp generate_boolean, do: :rand.uniform(2) == 1
end
