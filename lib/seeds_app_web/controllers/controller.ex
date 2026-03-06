defmodule SeedsAppWeb.SeedsController do
  use Phoenix.Controller

  alias SeedsApp
  alias SeedsApp.AsyncSeeds

  plug(:put_layout, false)

  def create(conn, params) do
    users_count = parse_integer(params["users_count"], 10)
    rooms_count = parse_integer(params["rooms_count"], 10)
    meetings_count = parse_integer(params["meetings_count"], 10)

    case AsyncSeeds.enqueue(users_count, rooms_count, meetings_count) do
      {:ok, task_id} ->
        json(conn, %{status: "success", message: "Task enqueued", task_id: task_id})

      {:error, :queue_full} ->
        json(conn, %{status: "error", message: "Queue is full, try again later"})
    end
  end

  def status(conn, params) do
    task_id = params["task_id"]

    if task_id do
      case AsyncSeeds.get_status(task_id) do
        nil ->
          json(conn, %{status: "error", message: "Task not found"})

        task_status ->
          json(conn, %{
            status: "success",
            data: %{
              task_id: task_status.task_id,
              status: task_status.status,
              users_count: task_status.users_count,
              rooms_count: task_status.rooms_count,
              meetings_count: task_status.meetings_count,
              error: task_status.error
            }
          })
      end
    else
      json(conn, %{status: "error", message: "task_id is required"})
    end
  end

  def clear(conn, _params) do
    %{
      deleted_meetings_count: deleted_meetings_count,
      deleted_rooms_count: deleted_rooms_count,
      deleted_users_accounts_count: deleted_users_accounts_count
    } = SeedsApp.clear_all()

    json(conn, %{
      status: "success",
      message:
        "Database cleared successfully. Deleted: #{deleted_meetings_count} Meetings, #{deleted_rooms_count} Rooms, #{deleted_users_accounts_count} Users/Accounts"
    })
  end

  def stats(conn, _params) do
    alias SeedsApp.Contexts.{Meetings, Rooms, UsersAccounts}

    stats = %{
      users: UsersAccounts.count(),
      rooms: Rooms.count(),
      meetings: Meetings.count()
    }

    json(conn, %{status: "success", data: stats})
  end

  def help(conn, _params) do
    conn
    |> put_view(SeedsAppWeb.SeedsView)
    |> put_format(:html)
    |> render("help.html")
  end

  defp parse_integer(nil, default), do: default

  defp parse_integer(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {number, _} -> number
      :error -> default
    end
  end

  defp parse_integer(_, default), do: default
end
