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
$ mix phx.server
```

Routes accessed for you

```bash
# seeds db
$ curl -X POST http://localhost:4000/api/seeds
# or with count of records
$ curl -X POST http://localhost:4000/api/seeds?users_count=5&rooms_count=5&meetings_count=5
# clear db
$ curl -X DELETE http://localhost:4000/api/seeds
# view satistics
$ curl http://localhost:4000/api/stats
```

You can open url http://localhost:4000/api/stats in your browser for see statistics

To see help run

TODO create API

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
