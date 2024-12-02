# Seeds_App

Simple elixir application with Ecto lib and Posgrex adapter for demonstrate Elixir works with DB

Need installed and setuped PostgreSQL, Erlang and Elixir

## Run app

Write ip, port, username, password to `config.exs`

```bash
$ mix deps.get
$ mix ecto.create
$ mix ecto.migrate
$ iex -S mix
iex> SeedsApp.seeds()
```

DB seeds random records

To see help run

```bash
h SeedsApp.seeds()
```

## DB structure

Tables:

* Accounts
* Users
* Rooms
* Meetings

Referenses:

* User has one Account
* Meetings has many Rooms
* Meetings has many Users
