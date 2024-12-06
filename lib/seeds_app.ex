defmodule SeedsApp do
  @moduledoc """
  Module for seeds DB randomize records
  """

  alias SeedsApp.Contexts.Meetings
  alias SeedsApp.Contexts.Rooms
  alias SeedsApp.Contexts.UsersAccounts

  @doc """
  Seeds DB random records

  users_accounts_count :: integer (default 10)
  rooms_count :: integer (default 10)
  meetings_count :: integer (default 10)

    ## Examples

      iex> SeedsApp.seeds()
      :ok

      iex> SeedsApp.seeds("some")
      :ok
  """
  @spec seeds(
          users_accounts_count :: pos_integer(),
          rooms_count :: pos_integer(),
          meetings_count :: pos_integer()
        ) :: :ok
  def seeds(users_accounts_count \\ 10, rooms_count \\ 10, meetings_count \\ 10)

  def seeds(users_accounts_count, rooms_count, meetings_count)
      when is_integer(users_accounts_count) and users_accounts_count > 0 and
             is_integer(rooms_count) and rooms_count > 0 and is_integer(meetings_count) and
             meetings_count > 0 do
    start_time = DateTime.utc_now()

    %{created: created_users, all_count: users_in_db, ids: users_ids} =
      create_context(UsersAccounts, users_accounts_count)

    %{created: created_rooms, all_count: rooms_in_db, ids: rooms_ids} =
      create_context(Rooms, rooms_count)

    created_meetings =
      Enum.reduce(1..meetings_count, 0, fn _, count ->
        user_id = get_rand_id(users_ids, created_users)
        room_id = get_rand_id(rooms_ids, created_rooms)

        case Meetings.create(user_id, room_id) do
          {:ok, _meeting} -> count + 1
          {:error, _} -> count
        end
      end)

    meetings_in_db = Meetings.count()

    %{minutes: minutes, seconds: seconds} = time_calculate(start_time)

    IO.puts("Done\n
              Created #{created_users} Users & Accounts, #{created_rooms} Rooms and #{created_meetings} Meetings\n
              Now in DB #{users_in_db} Users & Accounts, #{rooms_in_db} Rooms and #{meetings_in_db} Meetings\n
              Elapsed time: #{minutes} min #{seconds} sec")
  end

  def seeds(_users_accounts_count, _rooms_count, _meetings_count) do
    IO.warn("Some attrs is incorrect. See the help: h SeedsApp.seeds")
  end

  def clear_all do
    Meetings.delete_all()
    Rooms.delete_all()
    UsersAccounts.delete_all()
  end

  defp time_calculate(start_time) do
    finish_time = DateTime.utc_now()
    elapsed_time = DateTime.diff(finish_time, start_time)

    minutes = div(elapsed_time, 60)
    seconds = rem(elapsed_time, 60)

    %{minutes: minutes, seconds: seconds}
  end

  defp create_context(context, count) do
    # Example for loop with reduce in elixir
    # for _ <- 1..users_accounts_count, reduce: 0 do
    #   acc ->
    #     case UsersAccounts.create() do
    #       {:ok, _transaction} -> acc + 1
    #       {:error, _error} -> acc
    #     end
    # end

    # Loop with Enum.reduce
    created =
      Enum.reduce(1..count, 0, fn _, acc ->
        case context.create() do
          {:ok, _transaction} -> acc + 1
          {:error, _error} -> acc
          {:error, _context, _error, _so_far} -> acc
        end
      end)

    all_count = context.count()
    ids = context.get_ids()

    %{created: created, all_count: all_count, ids: ids}
  end

  @spec get_rand_id(list(), pos_integer()) :: pos_integer()
  defp get_rand_id(ids, count) do
    Enum.at(ids, :rand.uniform(count) - 1)
  end
end
