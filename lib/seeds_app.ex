defmodule SeedsApp do
  @moduledoc """
  Module for seeds DB randomize records
  """

  alias SeedsApp.Contexts.Meetings
  alias SeedsApp.Contexts.Rooms
  alias SeedsApp.Contexts.UsersAccounts
  alias SeedsApp.Types

  @doc """
  Seeds DB random records

  users_accounts_count :: integer (default 10)
  rooms_count :: integer (default 10)
  meetings_count :: integer (default 10)

    ## Examples

      iex> SeedsApp.seeds()
      {:ok, %{message: "Created 10 Users & Accounts, 10 Rooms and 10 Meetings...."}}

      iex> SeedsApp.seeds("some")
      {:error, "Some attrs is incorrect. See the help on /api/help"}
  """
  @spec seeds(
          users_accounts_count :: pos_integer(),
          rooms_count :: pos_integer(),
          meetings_count :: pos_integer()
        ) :: {:ok, %{message: String.t()}} | {:error, any()}
  def seeds(users_accounts_count \\ 10, rooms_count \\ 10, meetings_count \\ 10)

  def seeds(users_accounts_count, rooms_count, meetings_count)
      when is_integer(users_accounts_count) and users_accounts_count > 0 and
             is_integer(rooms_count) and rooms_count > 0 and is_integer(meetings_count) and
             meetings_count > 0 do
    start_time = DateTime.utc_now()

    # Используем батчевое создание для повышения производительности
    with {:ok, users_result} <- UsersAccounts.create_batch(users_accounts_count),
         {:ok, rooms_result} <- Rooms.create_batch(rooms_count),
         {:ok, meetings_result} <- Meetings.create_batch(
           meetings_count,
           users_result.ids,
           rooms_result.ids
         ) do
      response(%{
        users_result: users_result,
        rooms_result: rooms_result,
        meetings_result: meetings_result
      }, start_time)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def seeds(_users_accounts_count, _rooms_count, _meetings_count) do
    {:error, "Some attrs is incorrect. See the help on /api/help"}
  end

  def clear_all do
    {deleted_meetings_count, _} = Meetings.delete_all()
    {deleted_rooms_count, _} = Rooms.delete_all()
    {deleted_users_accounts_count, _} = UsersAccounts.delete_all()

    %{
      deleted_meetings_count: deleted_meetings_count,
      deleted_rooms_count: deleted_rooms_count,
      deleted_users_accounts_count: deleted_users_accounts_count
    }
  end

  @spec response(
          %{
            users_result: Types.create_context_result(),
            rooms_result: Types.create_context_result(),
            meetings_result: Types.create_context_result()
          },
          DateTime.t()
        ) :: {:ok, %{message: String.t()}} | {:error, any()}
  defp response(
         %{
           users_result: %{created: created_users, all_count: users_in_db},
           rooms_result: %{created: created_rooms, all_count: rooms_in_db},
           meetings_result: %{created: created_meetings, all_count: meetings_in_db}
         },
         start_time
       ) do
    %{minutes: minutes, seconds: seconds} = time_calculate(start_time)

    message =
      "Created #{created_users} Users & Accounts, #{created_rooms} Rooms and #{created_meetings} Meetings.
        Now in DB #{users_in_db} Users & Accounts, #{rooms_in_db} Rooms and #{meetings_in_db} Meetings.
          Elapsed time: #{minutes} min #{seconds} sec"

    {:ok, %{message: message}}
  end

  defp time_calculate(start_time) do
    finish_time = DateTime.utc_now()
    elapsed_time = DateTime.diff(finish_time, start_time)

    minutes = div(elapsed_time, 60)
    seconds = rem(elapsed_time, 60)

    %{minutes: minutes, seconds: seconds}
  end
end
