defmodule SeedsAppWeb.RouterTest do
  use SeedsAppWeb.ConnCase

  alias SeedsApp.AsyncSeeds

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

  test "POST /api/seeds routes to seeds controller create action", %{conn: conn} do
    conn = post(conn, "/api/seeds")
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "DELETE /api/seeds routes to seeds controller clear action", %{conn: conn} do
    conn = delete(conn, "/api/seeds")
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "GET /api/stats routes to seeds controller stats action", %{conn: conn} do
    conn = get(conn, "/api/stats")
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "non-existent API routes return 404", %{conn: conn} do
    conn = get(conn, "/api/nonexistent")
    assert conn.status == 404
  end
end
