import Config

config :seeds_app, ecto_repos: [SeedsApp.Repo]

unless Mix.env() == :default, do: import_config("#{Mix.env()}.exs")
