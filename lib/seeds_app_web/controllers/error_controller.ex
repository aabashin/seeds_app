defmodule SeedsAppWeb.ErrorController do
  use SeedsAppWeb, :controller

  plug(:put_layout, false)

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> put_view(SeedsAppWeb.ErrorView)
    |> render("404.html")
  end
end
