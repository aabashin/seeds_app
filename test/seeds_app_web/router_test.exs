defmodule SeedsAppWeb.RouterTest do
  use SeedsAppWeb.ConnCase

  test "POST /api/seeds routes to seeds controller create action", %{conn: conn} do
    Mimic.stub(SeedsApp.AsyncSeeds, :enqueue, fn _, _, _ -> {:ok, :rand.uniform(10)} end)

    conn = post(conn, "/api/seeds")
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "DELETE /api/seeds routes to seeds controller clear action", %{conn: conn} do
    Mimic.stub(SeedsApp, :clear_all, fn ->
      %{deleted_meetings_count: 0, deleted_rooms_count: 0, deleted_users_accounts_count: 0}
    end)

    conn = delete(conn, "/api/seeds")
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "GET /api/stats routes to seeds controller stats action", %{conn: conn} do
    Mimic.stub(SeedsApp.AsyncSeeds, :get_status, fn _ ->
      {:ok,
       %{
         status: :pending,
         users_count: :rand.uniform(10),
         rooms_count: :rand.uniform(10),
         meetings_count: :rand.uniform(10),
         inserted_at: DateTime.utc_now()
       }}
    end)

    conn = get(conn, "/api/stats")
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "non-existent API routes return 404", %{conn: conn} do
    conn = get(conn, "/api/nonexistent")
    assert conn.status == 404
  end
end
