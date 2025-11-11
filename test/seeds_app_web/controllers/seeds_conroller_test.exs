defmodule SeedsAppWeb.SeedsControllerTest do
  use SeedsAppWeb.ConnCase

  alias SeedsApp
  alias SeedsApp.Contexts.{UsersAccounts, Rooms, Meetings}

  describe "create/2" do
    test "creates seeds with default parameters", %{conn: conn} do
      conn = post(conn, "/api/seeds")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["message"] == "Database seeded successfully"

      # Проверяем, что данные создались
      assert UsersAccounts.count() > 0
      assert Rooms.count() > 0
      assert Meetings.count() > 0
    end

    test "creates seeds with custom parameters", %{conn: conn} do
      conn = post(conn, "/api/seeds?users_count=5&rooms_count=3&meetings_count=7")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["message"] == "Database seeded successfully"

      # Проверяем, что создалось нужное количество записей
      assert UsersAccounts.count() >= 5
      assert Rooms.count() >= 3
      assert Meetings.count() >= 7
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
      assert response["message"] == "Database cleared successfully"

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
end
