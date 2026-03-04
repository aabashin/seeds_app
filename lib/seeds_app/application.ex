defmodule SeedsApp.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SeedsApp.Repo,
      {Phoenix.PubSub, name: SeedsApp.PubSub},
      {Task.Supervisor, name: SeedsApp.TaskSupervisor},
      SeedsApp.AsyncSeeds,
      SeedsAppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: SeedsApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
