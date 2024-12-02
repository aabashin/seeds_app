defmodule SeedsApp.Factory do
  @moduledoc """
  Factories for tests
  """
  use ExMachina.Ecto, repo: SeedsApp.Repo

  use SeedsApp.Repo.AccountFactory
  use SeedsApp.Repo.MeetingFactory
  use SeedsApp.Repo.RoomFactory
  use SeedsApp.Repo.UserFactory
end
