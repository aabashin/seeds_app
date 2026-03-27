defmodule SeedsAppWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest

      # The default endpoint for testing
      @endpoint SeedsAppWeb.Endpoint
    end
  end

  setup tags do
    Mimic.set_mimic_from_context(tags)
    Mimic.verify_on_exit!()

    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(SeedsApp.Repo, shared: not tags[:async])

    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SeedsApp.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SeedsApp.Repo, {:shared, self()})
    end

    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
