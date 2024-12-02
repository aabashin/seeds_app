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
    %Room{}
    |> Room.changeset(GenerateParams.room())
    |> Repo.insert()
  end

  @doc """
  Calculate Rooms count
  """
  @spec count() :: Integer.t()
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
  Deletes ell Rooms from DB
  """
  @spec delete_all() :: nil
  def delete_all do
    Repo.delete_all(Room)
  end
end
