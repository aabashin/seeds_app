defmodule SeedsApp.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :seeds_app,
    adapter: Ecto.Adapters.Postgres
end
