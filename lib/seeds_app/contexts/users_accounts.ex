defmodule SeedsApp.Contexts.UsersAccounts do
  @moduledoc """
  Users & Accounts context functions
  """

  import Ecto.Query

  alias Ecto.Multi

  alias SeedsApp.ChunkHelper
  alias SeedsApp.Contexts.Models.Account
  alias SeedsApp.Contexts.Models.User
  alias SeedsApp.GenerateParams
  alias SeedsApp.Repo
  alias SeedsApp.Types

  # Кол-во колонок для расчёта чанка (name, age, email, inserted_at, updated_at)
  @columns_count 5

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

  @doc """
  Creates batch of users with accounts using insert_all with chunking
  """
  @spec create_batch(count :: pos_integer()) :: {:ok, Types.create_context_result()} | {:error, String.t()}
  def create_batch(count) when is_integer(count) and count > 0 do
    start_id = get_max_user_id() + 1
    user_params_list = GenerateParams.users_list(start_id, count)

    # Добавляем timestamps для батчевой вставки
    now = NaiveDateTime.utc_now()

    # Вставляем пользователей чанками
    user_params_with_timestamps = Enum.map(user_params_list, fn params ->
      Map.merge(params, %{inserted_at: now, updated_at: now})
    end)

    {:ok, users_result} = ChunkHelper.chunk_insert(
      user_params_with_timestamps,
      @columns_count,
      fn chunk -> Repo.insert_all(User, chunk, returning: [:id]) end
    )

    # Получаем только id вставленных пользователей (те, которые >= start_id)
    user_ids = User
      |> where([u], u.id >= ^start_id)
      |> select([u], u.id)
      |> Repo.all()

    # Генерируем и вставляем аккаунты чанками
    account_params_list = GenerateParams.accounts_list(user_ids)
    account_params_with_timestamps = Enum.map(account_params_list, fn params ->
      Map.merge(params, %{inserted_at: now, updated_at: now})
    end)

    # Для accounts тоже 5 колонок (balance, login, user_id, inserted_at, updated_at)
    ChunkHelper.chunk_insert(
      account_params_with_timestamps,
      @columns_count,
      fn chunk -> Repo.insert_all(Account, chunk) end
    )

    {:ok, %{created: users_result.total, all_count: count(), ids: user_ids}}
  end

  def create_batch(_count), do: {:error, "Count must be a positive integer"}
end
