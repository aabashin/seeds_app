defmodule SeedsAppWeb.SeedsController do
  use Phoenix.Controller

  alias SeedsApp

  plug :put_layout, false

  def create(conn, params) do
    users_count = parse_integer(params["users_count"], 10)
    rooms_count = parse_integer(params["rooms_count"], 10)
    meetings_count = parse_integer(params["meetings_count"], 10)

    case SeedsApp.seeds(users_count, rooms_count, meetings_count) do
      {:ok, message} ->
        json(conn, %{status: "success", message: message})

      {:error, errors} ->
        json(conn, %{status: "error", message: errors})
    end
  end

  def clear(conn, _params) do
    SeedsApp.clear_all()
    json(conn, %{status: "success", message: "Database cleared successfully"})
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
