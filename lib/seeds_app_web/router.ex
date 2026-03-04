defmodule SeedsAppWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", SeedsAppWeb do
    pipe_through(:api)

    post("/seeds", SeedsController, :create)
    get("/seeds/status", SeedsController, :status)
    delete("/seeds", SeedsController, :clear)
    get("/stats", SeedsController, :stats)
    get("/help", SeedsController, :help)
  end

  match(:*, "/*path", SeedsAppWeb.ErrorController, :not_found)
end
