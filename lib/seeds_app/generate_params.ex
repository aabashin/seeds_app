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

  @spec generate_boolean() :: boolean()
  defp generate_boolean, do: :rand.uniform(2) == 1
end
