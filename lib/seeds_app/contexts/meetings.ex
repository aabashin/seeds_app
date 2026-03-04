defmodule SeedsApp.Contexts.Meetings do
  @moduledoc """
  Meeting context functions
  """

  alias SeedsApp.ChunkHelper
  alias SeedsApp.Contexts.Models.Meeting
  alias SeedsApp.GenerateParams
  alias SeedsApp.Repo
  alias SeedsApp.Types

  # Кол-во колонок для расчёта чанка (theme, user_id, room_id, inserted_at, updated_at)
  @columns_count 5

  @doc """
  Create Meeting
  """
  @spec create(user_id :: pos_integer(), room_id :: pos_integer()) ::
          {:ok, Meeting.t()} | {:error, Ecto.Changeset.t()}
  def create(user_id, room_id) do
    params = GenerateParams.meeting(user_id, room_id)

    %Meeting{}
    |> Meeting.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Calculate Meetings count
  """
  @spec count() :: pos_integer()
  def count do
    Repo.aggregate(Meeting, :count)
  end

  @doc """
  Delete all
  """
  @spec delete_all() :: {pos_integer(), nil}
  def delete_all do
    Repo.delete_all(Meeting)
  end

  @doc """
  Creates batch of meetings using insert_all with chunking
  """
  @spec create_batch(
          count :: pos_integer(),
          user_ids :: [pos_integer()],
          room_ids :: [pos_integer()]
        ) :: {:ok, Types.create_context_result()} | {:error, String.t()}
  def create_batch(count, user_ids, room_ids)
      when is_integer(count) and count > 0 and is_list(user_ids) and user_ids != [] and is_list(room_ids) and room_ids != [] do
    meeting_params_list = GenerateParams.meetings_list(user_ids, room_ids, count)

    now = NaiveDateTime.utc_now()
    meeting_params_with_timestamps = Enum.map(meeting_params_list, fn params ->
      Map.merge(params, %{inserted_at: now, updated_at: now})
    end)

    {:ok, meetings_result} = ChunkHelper.chunk_insert(
      meeting_params_with_timestamps,
      @columns_count,
      fn chunk -> Repo.insert_all(Meeting, chunk) end
    )

    {:ok, %{created: meetings_result.total, all_count: count()}}
  end

  def create_batch(_count, _user_ids, _room_ids), do: {:error, "Invalid parameters"}
end
