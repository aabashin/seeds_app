defmodule SeedsApp.Contexts.Rooms do
  @moduledoc """
  Rooms context functions
  """

  import Ecto.Query

  alias SeedsApp.ChunkHelper
  alias SeedsApp.Contexts.Models.Room
  alias SeedsApp.GenerateParams
  alias SeedsApp.Repo
  alias SeedsApp.Types

  # Кол-во колонок для расчёта чанка (title, inserted_at, updated_at)
  @columns_count 3

  @doc """
  Insert Room to DB
  """
  @spec create() :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  def create do
    id = get_max_id() + 1
    params = GenerateParams.room(id)

    %Room{}
    |> Room.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Calculate Rooms count
  """
  @spec count() :: pos_integer()
  def count do
    Repo.aggregate(Room, :count)
  end

  @doc """
  Get ids
  """
  @spec get_ids() :: [pos_integer(), ...] | []
  def get_ids do
    # Example query
    # Repo.all(from(r in Room, select: r.id))

    Room
    |> select([r], r.id)
    |> Repo.all()
  end

  @doc """
  Get max id
  """
  @spec get_max_id() :: pos_integer()
  def get_max_id do
    id =
      Room
      |> select([r], max(r.id))
      |> Repo.one()

    case id do
      nil -> 0
      id -> id
    end
  end

  @doc """
  Deletes ell Rooms from DB
  """
  @spec delete_all() :: nil
  def delete_all do
    Repo.delete_all(Room)
  end

  @doc """
  Creates batch of rooms using insert_all with chunking
  """
  @spec create_batch(count :: pos_integer()) :: {:ok, Types.create_context_result()} | {:error, String.t()}
  def create_batch(count) when is_integer(count) and count > 0 do
    start_id = get_max_id() + 1
    room_params_list = GenerateParams.rooms_list(start_id, count)

    now = NaiveDateTime.utc_now()
    room_params_with_timestamps = Enum.map(room_params_list, fn params ->
      Map.merge(params, %{inserted_at: now, updated_at: now})
    end)

    {:ok, rooms_result} = ChunkHelper.chunk_insert(
      room_params_with_timestamps,
      @columns_count,
      fn chunk -> Repo.insert_all(Room, chunk, returning: [:id]) end
    )

    # Получаем только id вставленных записей (те, которые >= start_id)
    room_ids = Room
      |> where([r], r.id >= ^start_id)
      |> select([r], r.id)
      |> Repo.all()

    {:ok, %{created: rooms_result.total, all_count: count(), ids: room_ids}}
  end

  def create_batch(_count), do: {:error, "Count must be a positive integer"}
end
