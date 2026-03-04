defmodule SeedsAppWeb.SeedsControllerTest do
  use SeedsAppWeb.ConnCase

  alias SeedsApp
  alias SeedsApp.AsyncSeeds
  alias SeedsApp.Contexts.{UsersAccounts, Rooms, Meetings}

  setup do
    # Запускаем TaskSupervisor и AsyncSeeds для тестов
    case Process.whereis(SeedsApp.TaskSupervisor) do
      nil ->
        start_supervised!({Task.Supervisor, name: SeedsApp.TaskSupervisor})

      _ ->
        :ok
    end

    case Process.whereis(AsyncSeeds) do
      nil ->
        start_supervised!(AsyncSeeds)

      _ ->
        AsyncSeeds.clear_queue()
    end

    :ok
  end

  describe "create/2" do
    test "creates seeds with default parameters", %{conn: conn} do
      conn = post(conn, "/api/seeds")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["message"] == "Task enqueued"
      assert is_binary(response["task_id"])

      # Ждём завершения задачи
      Process.sleep(1000)

      # Проверяем, что данные создались
      assert UsersAccounts.count() > 0
      assert Rooms.count() > 0
      assert Meetings.count() > 0
    end

    test "creates seeds with custom parameters", %{conn: conn} do
      conn = post(conn, "/api/seeds?users_count=5&rooms_count=3&meetings_count=7")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["message"] == "Task enqueued"
      assert is_binary(response["task_id"])

      # Ждём завершения задачи
      Process.sleep(1000)

      # Проверяем, что создалось нужное количество записей
      assert UsersAccounts.count() >= 5
      assert Rooms.count() >= 3
      assert Meetings.count() >= 7
    end
  end

  describe "status/2" do
    test "returns error when task_id is not provided", %{conn: conn} do
      conn = get(conn, "/api/seeds/status")
      response = json_response(conn, 200)

      assert response["status"] == "error"
      assert response["message"] == "task_id is required"
    end

    test "returns error for invalid task_id", %{conn: conn} do
      conn = get(conn, "/api/seeds/status?task_id=invalid_id")
      response = json_response(conn, 200)

      assert response["status"] == "error"
      assert response["message"] == "Task not found"
    end

    test "returns success for valid task_id", %{conn: conn} do
      # Создаём задачу
      {:ok, task_id} = AsyncSeeds.enqueue(10, 10, 10)

      # Ждём завершения задачи
      Process.sleep(1500)

      conn = get(conn, "/api/seeds/status?task_id=#{task_id}")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["data"]["task_id"] == task_id
      assert response["data"]["status"] == "completed"
      assert response["data"]["users_count"] == 10
      assert response["data"]["rooms_count"] == 10
      assert response["data"]["meetings_count"] == 10
    end
  end

  describe "clear/2" do
    setup do
      # Сначала создаем тестовые данные
      SeedsApp.seeds(5, 5, 5)
      :ok
    end

    test "clears all data from database", %{conn: conn} do
      # Проверяем, что данные есть
      assert UsersAccounts.count() > 0
      assert Rooms.count() > 0
      assert Meetings.count() > 0

      conn = delete(conn, "/api/seeds")
      response = json_response(conn, 200)

      assert response["status"] == "success"

      assert response["message"] ==
               "Database cleared successfully. Deleted: 5 Meetings, 5 Rooms, 5 Users/Accounts"

      # Проверяем, что данные очищены
      assert UsersAccounts.count() == 0
      assert Rooms.count() == 0
      assert Meetings.count() == 0
    end
  end

  describe "stats/2" do
    test "returns statistics when database is empty", %{conn: conn} do
      # Очищаем базу перед тестом
      SeedsApp.clear_all()

      conn = get(conn, "/api/stats")
      response = json_response(conn, 200)

      assert response["status"] == "success"

      assert response["data"] == %{
               "users" => 0,
               "rooms" => 0,
               "meetings" => 0
             }
    end

    test "returns correct statistics with data", %{conn: conn} do
      # Создаем тестовые данные
      SeedsApp.seeds(3, 2, 4)

      conn = get(conn, "/api/stats")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["data"]["users"] == 3
      assert response["data"]["rooms"] == 2
      assert response["data"]["meetings"] == 4
    end
  end

  describe "/help" do
    test "success", %{conn: conn} do
      assert conn = %Plug.Conn{} = get(conn, "/api/help")

      assert conn.status == 200
      assert conn.path_info == ["api", "help"]
      assert conn.request_path == "/api/help"
    end
  end
end
