import Config

config :seeds_app, SeedsApp.Repo,
  database: "seeds_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5433,
  pool_size: 20,
  timeout: 120_000,
  queue_target: 5000,
  queue_interval: 100_000,
  ownership_timeout: 120_000,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false

config :seeds_app, SeedsAppWeb.Endpoint,
  http: [port: 4002],
  server: true,
  secret_key_base: "test_secret_key_base_very_long_string_required_here_for_phoenix",
  live_view: [signing_salt: "test_signing_salt"]

config :seeds_app, :max_async_queue_size, 30

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
