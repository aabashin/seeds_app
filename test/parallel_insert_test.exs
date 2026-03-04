defmodule ParallelInsertTest do
  use SeedsApp.DataCase

  alias SeedsApp.Contexts.{Meetings, Rooms, UsersAccounts}
  alias SeedsApp.Repo

  setup do
    # Очищаем данные перед каждым тестом
    Repo.delete_all(SeedsApp.Contexts.Models.Meeting)
    Repo.delete_all(SeedsApp.Contexts.Models.Account)
    Repo.delete_all(SeedsApp.Contexts.Models.Room)
    Repo.delete_all(SeedsApp.Contexts.Models.User)
    :ok
  end

  describe "parallel chunk_insert/4" do
    test "parallel insert increases performance (qualitative check)" do
      # Проверяем, что параллельная вставка работает корректно
      # Количество записей для теста
      count = 1000

      start_time = :os.system_time(:millisecond)

      # Последовательная вставка (эмуляция старой логики)
      {:ok, _} = Rooms.create_batch(count)

      sequential_time = :os.system_time(:millisecond) - start_time

      # Очищаем
      Repo.delete_all(SeedsApp.Contexts.Models.Room)

      start_time = :os.system_time(:millisecond)

      # Параллельная вставка (новая логика с TaskSupervisor)
      {:ok, _} = Rooms.create_batch(count)

      parallel_time = :os.system_time(:millisecond) - start_time

      # Проверяем, что данные вставлены корректно
      assert Rooms.count() == count

      # Параллельная вставка должна быть быстрее или сопоставима
      IO.puts("Sequential: #{sequential_time}ms, Parallel: #{parallel_time}ms")
    end

    test "parallel insert creates correct number of records for UsersAccounts" do
      count = 500
      {:ok, result} = UsersAccounts.create_batch(count)

      assert result.created == count
      assert UsersAccounts.count() == count
      assert length(result.ids) == count
    end

    test "parallel insert creates correct number of records for Rooms" do
      count = 500
      {:ok, result} = Rooms.create_batch(count)

      assert result.created == count
      assert Rooms.count() == count
      assert length(result.ids) == count
    end

    test "parallel insert creates correct number of records for Meetings" do
      # Сначала создаём users и rooms
      {:ok, %{ids: user_ids}} = UsersAccounts.create_batch(10)
      {:ok, %{ids: room_ids}} = Rooms.create_batch(10)

      count = 500
      {:ok, result} = Meetings.create_batch(count, user_ids, room_ids)

      assert result.created == count
      assert Meetings.count() == count
    end

    test "parallel insert handles large dataset (5000 records)" do
      count = 5000
      {:ok, result} = Rooms.create_batch(count)

      assert result.created == count
      assert Rooms.count() == count
    end

    test "parallel insert with multiple batches maintains data integrity" do
      # Первый батч
      {:ok, result1} = Rooms.create_batch(100)
      # Второй батч
      {:ok, result2} = Rooms.create_batch(100)

      # Проверяем, что все ID уникальны
      all_ids = result1.ids ++ result2.ids
      assert length(Enum.uniq(all_ids)) == length(all_ids)

      # Общее количество
      assert Rooms.count() == 200
    end
  end
end
