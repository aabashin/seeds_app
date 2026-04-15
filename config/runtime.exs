import Config

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      "sX+01us8enwOjI2sF7xiDmakd28fMwOZn/VbNwa56K06EDuLlGoAdEnVl+npBk6Y"

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("PHX_PORT") || "4000")

  config :seeds_app, SeedsAppWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    server: true,
    check_origin: false

  database = System.get_env("DB") || "seeds_dev"
  db_username = System.get_env("DB_USER") || "postgres"
  db_password = System.get_env("DB_PASS") || "postgres"
  db_host = System.get_env("DB_HOST") || "localhost"
  db_port = System.get_env("DB_PORT") || 5433

  config :seeds_app, SeedsApp.Repo,
    database: database,
    username: db_username,
    password: db_password,
    hostname: db_host,
    port: String.to_integer(db_port),
    pool_size: 10,
    timeout: 120_000,
    queue_target: 5000,
    queue_interval: 100_000,
    ownership_timeout: 15_000_000,
    log: :debug
end
