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
        ) :: {:ok, String.t()} | {:error, any()}
  def seeds(users_accounts_count \\ 10, rooms_count \\ 10, meetings_count \\ 10)

  def seeds(users_accounts_count, rooms_count, meetings_count)
      when is_integer(users_accounts_count) and users_accounts_count > 0 and
             is_integer(rooms_count) and rooms_count > 0 and is_integer(meetings_count) and
             meetings_count > 0 do
    start_time = DateTime.utc_now()

    UsersAccounts
    |> create_context(users_accounts_count)
    |> create_rooms(rooms_count)
    |> create_meetings(meetings_count)
    |> response(start_time)
  end

  def seeds(_users_accounts_count, _rooms_count, _meetings_count) do
    {:error, "Some attrs is incorrect. See the help on /api/help"}
  end

  def clear_all do
    Meetings.delete_all()
    Rooms.delete_all()
    UsersAccounts.delete_all()
  end

  @spec create_rooms({:ok, Types.create_context_result()} | {:error, any()}, non_neg_integer()) ::
          {:ok,
           %{
             users_create_response: Types.create_context_result(),
             rooms_create_response: Types.create_context_result()
           }}
          | {:error, any()}
  defp create_rooms({:ok, users_create_response}, rooms_count) do
    case create_context(Rooms, rooms_count) do
      {:ok, rooms_create_response} ->
        {:ok,
         %{
           users_create_response: users_create_response,
           rooms_create_response: rooms_create_response
         }}

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp create_rooms({:error, errors}, _rooms_count) do
    {:error, errors}
  end

  @spec create_meetings(
          {:ok,
           users_create_response: Types.create_context_result(),
           rooms_create_response: Types.create_context_result()}
          | {:error, any()},
          non_neg_integer()
        ) ::
          {:ok,
           %{
             users_create_response: Types.create_context_result(),
             rooms_create_response: Types.create_context_result(),
             meetings_create_response: Types.create_context_result()
           }}
          | {:error, any()}
  defp create_meetings(
         {:ok,
          %{
            users_create_response: %{
              created: _created_users,
              all_count: users_in_db,
              ids: users_ids
            },
            rooms_create_response: %{
              created: _created_rooms,
              all_count: rooms_in_db,
              ids: rooms_ids
            }
          } = response},
         meetings_count
       ) do
    created_meetings =
      Enum.reduce(1..meetings_count, 0, fn _, count ->
        user_id = get_rand_id(users_ids, users_in_db)
        room_id = get_rand_id(rooms_ids, rooms_in_db)

        case Meetings.create(user_id, room_id) do
          {:ok, _meeting} -> count + 1
          {:error, _} -> count
        end
      end)

    meetings_in_db = Meetings.count()

    {:ok,
     Map.put(response, :meetings_create_response, %{
       created: created_meetings,
       all_count: meetings_in_db
     })}
  end

  defp create_meetings({:error, errors}, _rooms_count) do
    {:error, errors}
  end

  @spec response(
          {:ok,
           users_create_response: Types.create_context_result(),
           rooms_create_response: Types.create_context_result(),
           meetings_create_response: Types.create_context_result()}
          | {:error, any()},
          non_neg_integer()
        ) ::
          {:ok, %{message: String.t()}} | {:error, any()}
  defp response(
         {:ok,
          %{
            users_create_response: %{
              created: created_users,
              all_count: users_in_db,
              ids: _users_ids
            },
            rooms_create_response: %{
              created: created_rooms,
              all_count: rooms_in_db,
              ids: _rooms_ids
            },
            meetings_create_response: %{
              created: created_meetings,
              all_count: meetings_in_db
            }
          }},
         start_time
       ) do
    %{minutes: minutes, seconds: seconds} = time_calculate(start_time)

    message =
      "Created #{created_users} Users & Accounts, #{created_rooms} Rooms and #{created_meetings} Meetings.
        Now in DB #{users_in_db} Users & Accounts, #{rooms_in_db} Rooms and #{meetings_in_db} Meetings.
          Elapsed time: #{minutes} min #{seconds} sec"

    {:ok, %{message: message}}
  end

  defp response({:error, errors}, _rooms_count) do
    {:error, errors}
  end

  defp time_calculate(start_time) do
    finish_time = DateTime.utc_now()
    elapsed_time = DateTime.diff(finish_time, start_time)

    minutes = div(elapsed_time, 60)
    seconds = rem(elapsed_time, 60)

    %{minutes: minutes, seconds: seconds}
  end

  @spec create_context(module(), non_neg_integer()) ::
          {:ok, Types.create_context_result()} | {:error, any()}
  defp create_context(context, count) do
    %{count: count, errors: errors} =
      Enum.reduce(1..count, %{count: 0, errors: []}, fn _, %{count: count, errors: errors} ->
        case context.create() do
          {:ok, _transaction} -> %{count: count + 1, errors: errors}
          {:error, error} -> %{count: count, errors: [error | errors]}
          {:error, _context, error, _so_far} -> %{count: count, errors: [error | errors]}
        end
      end)

    if count == 0 do
      {:error, errors}
    else
      all_count = context.count()
      ids = context.get_ids()

      {:ok, %{created: count, all_count: all_count, ids: ids}}
    end
  end

  @spec get_rand_id(list(), pos_integer()) :: pos_integer()
  defp get_rand_id(ids, count) do
    Enum.at(ids, :rand.uniform(count) - 1)
  end
end
