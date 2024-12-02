defmodule SeedsApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import SeedsApp.DataCase
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias SeedsApp.Factory
      alias SeedsApp.Repo
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(SeedsApp.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
