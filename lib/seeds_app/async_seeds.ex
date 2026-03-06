defmodule SeedsApp.AsyncSeeds do
  @moduledoc """
  Асинхронная обработка задач seeds с ограничением очереди.
  """

  use GenServer

  alias SeedsApp, as: SeedsModule

  # Максимальный размер очереди
  @default_max_queue_size 10

  # === Публичный API ===

  @doc """
  Возвращает максимальный размер очереди.
  """
  @spec max_queue_size() :: pos_integer()
  def max_queue_size do
    Application.get_env(:seeds_app, :max_async_queue_size, @default_max_queue_size)
  end

  @doc """
  Возвращает текущий размер очереди (выполняемых задач).
  """
  @spec queue_size() :: non_neg_integer()
  def queue_size do
    GenServer.call(__MODULE__, :queue_size)
  end

  @doc """
  Добавляет задачу в очередь.
  Возвращает {:ok, task_id} или {:error, :queue_full}.
  """
  @spec enqueue(
          users_count :: pos_integer(),
          rooms_count :: pos_integer(),
          meetings_count :: pos_integer()
        ) ::
          {:ok, String.t()} | {:error, :queue_full}
  def enqueue(users_count, rooms_count, meetings_count) do
    GenServer.call(__MODULE__, {:enqueue, users_count, rooms_count, meetings_count})
  end

  @doc """
  Возвращает статус задачи по task_id.
  """
  @spec get_status(task_id :: String.t()) :: map() | nil
  def get_status(task_id) do
    GenServer.call(__MODULE__, {:get_status, task_id})
  end

  @doc """
  Очищает очередь задач.
  """
  @spec clear_queue() :: :ok
  def clear_queue do
    GenServer.call(__MODULE__, :clear_queue)
  end

  # === GenServer ===

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    state = %{
      tasks: %{},
      running_count: 0
    }

    {:ok, state}
  end

  # === Call handlers ===

  @impl true
  def handle_call(:queue_size, _from, state) do
    {:reply, state.running_count, state}
  end

  def handle_call(:clear_queue, _from, state) do
    state = %{state | tasks: %{}, running_count: 0}
    {:reply, :ok, state}
  end

  def handle_call({:enqueue, users_count, rooms_count, meetings_count}, _from, state) do
    max_size = max_queue_size()

    if state.running_count >= max_size do
      {:reply, {:error, :queue_full}, state}
    else
      task_id = generate_task_id()

      task = %{
        status: :pending,
        users_count: users_count,
        rooms_count: rooms_count,
        meetings_count: meetings_count,
        inserted_at: DateTime.utc_now()
      }

      task_ref =
        Task.Supervisor.async(SeedsApp.TaskSupervisor, fn ->
          execute_task(task_id, users_count, rooms_count, meetings_count)
        end)

      task_with_ref = Map.put(task, :task_ref, task_ref)

      new_state = %{
        state
        | tasks: Map.put(state.tasks, task_id, task_with_ref),
          running_count: state.running_count + 1
      }

      {:reply, {:ok, task_id}, new_state}
    end
  end

  def handle_call({:get_status, task_id}, _from, state) do
    case Map.get(state.tasks, task_id) do
      nil ->
        {:reply, nil, state}

      task ->
        status = Map.put(task, :task_id, task_id)
        {:reply, status, state}
    end
  end

  def handle_call(:task_completed, _from, state) do
    new_count = max(0, state.running_count - 1)
    {:reply, :ok, %{state | running_count: new_count}}
  end

  # === Info handlers ===

  @impl true
  def handle_info({_ref, _result}, state) do
    # Игнорируем результаты Task.async - статус обновляется через execute_task
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    # Игнорируем сообщения о завершении процессов
    {:noreply, state}
  end

  # === Cast handlers ===

  @impl true
  def handle_cast({:update_status, task_id, status, error}, state) do
    task = Map.get(state.tasks, task_id)

    if task do
      updated_task =
        Map.merge(task, %{
          status: status,
          error: error,
          completed_at: DateTime.utc_now()
        })

      new_state = %{
        state
        | tasks: Map.put(state.tasks, task_id, updated_task)
      }

      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  # === Приватные функции ===

  defp generate_task_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end

  defp execute_task(task_id, users_count, rooms_count, meetings_count) do
    update_task_status(task_id, :running)

    result = SeedsModule.seeds(users_count, rooms_count, meetings_count)

    case result do
      {:ok, _} ->
        update_task_status(task_id, :completed)

      {:error, reason} ->
        update_task_status(task_id, :failed, reason)
    end

    GenServer.call(__MODULE__, :task_completed)
  end

  defp update_task_status(task_id, status, error \\ nil) do
    GenServer.cast(__MODULE__, {:update_status, task_id, status, error})
  end
end
