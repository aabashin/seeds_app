defmodule AsyncSeedsApplicationTest do
  use ExUnit.Case, async: false

  alias SeedsApp.AsyncSeeds

  # Тест проверяет, что AsyncSeeds запущен в приложении
  # Этот тест падает без запуска GenServer в application.ex

  test "AsyncSeeds GenServer should be started with application" do
    # Проверяем, что процесс зарегистрирован
    assert Process.whereis(AsyncSeeds) != nil, "AsyncSeeds should be started with application"

    # Проверяем, что можем вызвать функции GenServer без ошибки
    assert is_integer(AsyncSeeds.queue_size())
    assert AsyncSeeds.max_queue_size() > 0
  end

  test "TaskSupervisor should be started with application" do
    # Проверяем, что TaskSupervisor запущен
    assert Process.whereis(SeedsApp.TaskSupervisor) != nil,
           "TaskSupervisor should be started with application"
  end
end
