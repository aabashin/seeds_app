defmodule SeedsAppWeb.SeedsControllerTest do
  use SeedsAppWeb.ConnCase

  # Отключаем параллельное выполнение из-за асинхронных задач
  use ExUnit.Case, async: false

  alias SeedsApp
  alias SeedsApp.AsyncSeeds
  alias SeedsApp.Contexts.{UsersAccounts, Rooms, Meetings}

  describe "create/2" do
    setup do
      Mimic.stub(SeedsApp.AsyncSeeds, :enqueue, fn _, _, _ -> {:ok, "#{:rand.uniform(10)}"} end)

      :ok
    end

    test "creates seeds with default parameters", %{conn: conn} do
      conn = post(conn, "/api/seeds")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["message"] == "Task enqueued"
      assert is_binary(response["task_id"])
    end

    test "creates seeds with custom parameters", %{conn: conn} do
      conn = post(conn, "/api/seeds?users_count=1&rooms_count=1&meetings_count=1")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["message"] == "Task enqueued"
      assert is_binary(response["task_id"])
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
      {:ok, task_id} = AsyncSeeds.enqueue(100, 100, 100)

      conn = get(conn, "/api/seeds/status?task_id=#{task_id}")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["data"]["task_id"] == task_id
      assert response["data"]["status"] == "running"
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
    setup do
      # Очищаем базу перед тестом
      SeedsApp.clear_all()

      :ok
    end

    test "returns statistics when database is empty", %{conn: conn} do
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
