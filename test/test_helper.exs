{:ok, _} = Application.ensure_all_started(:seeds_app)
{:ok, _} = Application.ensure_all_started(:mimic)

[
  SeedsApp,
  SeedsApp.AsyncSeeds,
  SeedsApp.Contexts.Meetings,
  SeedsApp.Contexts.Rooms,
  SeedsApp.Contexts.UsersAccounts
]
|> Enum.each(&Mimic.copy/1)

ExUnit.start()
Faker.start()

Ecto.Adapters.SQL.Sandbox.mode(SeedsApp.Repo, {:shared, self()})
