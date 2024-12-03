# Seeds_App

Simple elixir application with Ecto lib and Posgrex adapter for demonstrate Elixir works with DB

Need installed and setuped PostgreSQL, Erlang and Elixir

## Run app

```bash
git clone https://github.com/aabashin/seeds_app.git
cd seeds_app
```

Write ip, port, username, password to `config.exs`, `dev.exs`, `test.exs`

```bash
$ mix deps.get
$ mix ecto.setup
$ mix test
$ iex -S mix
iex> SeedsApp.seeds()
```

DB seeds random records

To see help run

```bash
h SeedsApp.seeds()
```

## Clear DB

To delete all records run

```bash
iex> SeedsApp.clear_all()
```

## Delete & create new db

```bash
$ mix ecto.reset
```

## DB structure

Tables:

* Accounts
* Users
* Rooms
* Meetings

Referenses:

* User has one Account
* Rooms has many Meetings
* Users has many Meetings
