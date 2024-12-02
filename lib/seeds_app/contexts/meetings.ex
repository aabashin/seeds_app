defmodule SeedsApp.Contexts.Meetings do
  @moduledoc """
  Meeting context functions
  """

  alias SeedsApp.Contexts.Models.Meeting
  alias SeedsApp.GenerateParams
  alias SeedsApp.Repo

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
  @spec count() :: Integer.t()
  def count do
    Repo.aggregate(Meeting, :count)
  end

  @doc """
  Delete all
  """
  @spec delete_all() :: {Integer.t(), nil}
  def delete_all do
    Repo.delete_all(Meeting)
  end
end
