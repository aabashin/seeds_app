import Config

config :seeds_app, ecto_repos: [SeedsApp.Repo]

config :seeds_app, SeedsAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "your_secret_key_base_here_replace_in_production",
  render_errors: [view: SeedsAppWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: SeedsApp.PubSub,
  live_view: [signing_salt: "your_signing_salt_here"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

unless Mix.env() == :default, do: import_config("#{Mix.env()}.exs")
