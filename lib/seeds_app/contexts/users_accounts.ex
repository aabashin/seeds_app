defmodule SeedsApp.Contexts.UsersAccounts do
  @moduledoc """
  Users & Accounts context functions
  """

  import Ecto.Query

  alias Ecto.Multi

  alias SeedsApp.Contexts.Models.Account
  alias SeedsApp.Contexts.Models.User
  alias SeedsApp.GenerateParams
  alias SeedsApp.Repo

  @doc """
  Get User by params
  """
  @spec get_by(params :: map()) :: User.t() | nil
  def get_by(params), do: Repo.get_by(User, params)

  @doc """
  Get Users records count
  """
  @spec count() :: pos_integer()
  def count do
    Repo.aggregate(User, :count)
  end

  @doc """
  Get ids
  """
  @spec get_ids() :: [pos_integer(), ...] | []
  def get_ids do
    User
    |> select([u], u.id)
    |> Repo.all()
  end

  @doc """
  Creates account and user in trasaction
  """
  @spec create() :: {:ok, any()} | {:error, any()}
  def create do
    id = get_max_user_id() + 1
    params = GenerateParams.user(id)

    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, params))
    |> Multi.insert(:account, fn %{user: user} ->
      Account.changeset(%Account{}, GenerateParams.account(user.id))
    end)
    |> Repo.transaction()
  end

    @doc """
  Get max id
  """
  @spec get_max_user_id() :: pos_integer()
  def get_max_user_id do
    id =
      User
      |> select([u], max(u.id))
      |> Repo.one()

    case id do
      nil -> 0
      id -> id
    end
  end

  @doc """
  Deletes all Accounts and Users records
  Anough to delete Users, because in account reference on_delete: :delete_all
  """
  @spec delete_all() :: {:ok, any()} | {:error, any()}
  def delete_all, do: Repo.delete_all(User)
end
