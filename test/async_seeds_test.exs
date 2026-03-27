defmodule AsyncSeedsTest do
  use ExUnit.Case, async: false

  alias SeedsApp.AsyncSeeds

  describe "queue management" do
    test "max_queue_size/0 returns configured limit" do
      assert AsyncSeeds.max_queue_size() > 0
    end

    test "queue_size/0 returns current queue size" do
      size = AsyncSeeds.queue_size()
      assert is_integer(size)
      assert size >= 0
    end
  end

  describe "enqueue/3" do
    test "returns {:ok, task_id} when queue is not full" do
      result = AsyncSeeds.enqueue(10, 10, 10)
      assert {:ok, _task_id} = result
    end

    test "returns {:error, :queue_full} when queue is full" do
      # Заполняем очередь до максимума
      max_size = AsyncSeeds.max_queue_size()

      for _ <- 1..max_size do
        AsyncSeeds.enqueue(1, 1, 1)
      end

      # Следующая попытка должна вернуть ошибку
      result = AsyncSeeds.enqueue(1, 1, 1)
      assert {:error, :queue_full} = result
    end

    test "task_id is unique" do
      AsyncSeeds.clear_queue()

      {:ok, task_id1} = AsyncSeeds.enqueue(1, 1, 1)
      {:ok, task_id2} = AsyncSeeds.enqueue(1, 1, 1)

      refute task_id1 == task_id2
    end
  end

  describe "get_status/1" do
    test "returns status for valid task_id" do
      AsyncSeeds.clear_queue()
      {:ok, task_id} = AsyncSeeds.enqueue(10, 10, 10)

      status = AsyncSeeds.get_status(task_id)
      assert is_map(status)
      assert status.task_id == task_id
      assert status.users_count == 10
      assert status.rooms_count == 10
      assert status.meetings_count == 10
    end

    test "returns nil for invalid task_id" do
      status = AsyncSeeds.get_status("invalid_id")
      assert status == nil
    end
  end

  describe "clear_queue/0" do
    test "clears all pending tasks" do
      AsyncSeeds.clear_queue()
      assert AsyncSeeds.queue_size() == 0
    end
  end
end
