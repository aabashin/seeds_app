import Config

config :seeds_app, SeedsApp.Repo,
  database: "seeds_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10,
  timeout: 120_000,
  queue_target: 5000,
  queue_interval: 100_000,
  ownership_timeout: 120_000,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false
