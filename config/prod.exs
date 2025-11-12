import Config

config :seeds_app, SeedsAppWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  check_origin: false
