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
  @spec count() :: Integer.t()
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
    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, GenerateParams.user()))
    |> Multi.insert(:account, fn %{user: user} ->
      Account.changeset(%Account{}, GenerateParams.account(user.id))
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes all Accounts and Users records
  Anough to delete Users, because in account reference on_delete: :delete_all
  """
  @spec delete_all() :: {:ok, any()} | {:error, any()}
  def delete_all, do: Repo.delete_all(User)
end
