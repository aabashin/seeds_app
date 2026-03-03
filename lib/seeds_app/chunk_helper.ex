defmodule SeedsApp.ChunkHelper do
  @moduledoc """
  Утилита для разбиения данных на чанки с учётом лимита параметров PostgreSQL.
  """

  @default_max_params 65_535

  @doc """
  Рассчитывает оптимальный размер чанка на основе количества колонок.

  ## Параметры
    - columns_count: количество колонок в таблице
    - max_params: максимальное количество параметров (по умолчанию 65_535)

  ## Пример
      iex> SeedsApp.ChunkHelper.chunk_size(6)
      10000
  """
  @spec chunk_size(columns :: pos_integer(), max_params :: pos_integer()) :: pos_integer()
  def chunk_size(columns, max_params \\ @default_max_params) do
    safe_max = max_params - 100
    floor(safe_max / columns)
  end

  @doc """
  Разбивает список на чанки указанного размера.

  ## Параметры
    - list: список для разбиения
    - chunk_size: размер чанка

  ## Пример
      iex> SeedsApp.ChunkHelper.chunk_list([1,2,3,4,5], 2)
      [[1,2], [3,4], [5]]
  """
  @spec chunk_list(list :: list(), chunk_size :: pos_integer()) :: [list()]
  def chunk_list(list, chunk_size) do
    Enum.chunk_every(list, chunk_size)
  end

  @doc """
  Применяет функцию вставки к каждому чанку списка.
  Возвращает общее количество обработанных записей.

  ## Параметры
    - list: данные для вставки
    - columns_count: количество колонок
    - insert_fn: функция вставки, принимающая список и возвращающая {count, result}
    - max_params: максимальное количество параметров

  ## Пример
      data = [%{name: "A"}, %{name: "B"}, ...]
      SeedsApp.chunk_insert(data, 4, fn chunk -> Repo.insert_all(Model, chunk) end)
  """
  @spec chunk_insert(
          list :: list(),
          columns_count :: pos_integer(),
          insert_fn :: (list() -> {non_neg_integer(), any()}),
          max_params :: pos_integer()
        ) :: {:ok, %{total: non_neg_integer(), chunks: non_neg_integer()}} | {:error, String.t()}
  def chunk_insert(list, columns_count, insert_fn, max_params \\ @default_max_params)

  def chunk_insert([], _columns, _insert_fn, _max_params) do
    {:ok, %{total: 0, chunks: 0}}
  end

  def chunk_insert(list, columns_count, insert_fn, max_params) when is_list(list) do
    size = chunk_size(columns_count, max_params)
    chunks = chunk_list(list, size)

    results =
      Enum.map(chunks, fn chunk ->
        insert_fn.(chunk)
      end)

    total = Enum.reduce(results, 0, fn {count, _}, acc -> acc + count end)

    {:ok, %{total: total, chunks: length(chunks)}}
  end
end
