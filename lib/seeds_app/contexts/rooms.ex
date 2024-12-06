defmodule SeedsApp.Contexts.Rooms do
  @moduledoc """
  Rooms context functions
  """

  import Ecto.Query

  alias SeedsApp.Contexts.Models.Room
  alias SeedsApp.GenerateParams
  alias SeedsApp.Repo

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
end
