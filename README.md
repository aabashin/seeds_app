# Seeds_App

Простое Elixir-приложение с Ecto и Postgrex для демонстрации работы с базой данных PostgreSQL.

## Требования

### Для локальной разработки
- Erlang 28.3.2
- Elixir 1.19.5-otp-28
- PostgreSQL

---

## Запуск в Docker

### Быстрый старт

```bash
# Клонировать репозиторий
git clone https://github.com/aabashin/seeds_app.git
cd seeds_app

# Запустить все сервисы (PostgreSQL + приложение)
docker compose up -d

# Проверить статус
docker compose ps

# Просмотр логов
docker compose logs -f seeds_app
```

### Остановка сервисов

```bash
docker compose down
```

### Пересборка образа

```bash
docker compose build --no-cache
docker compose up -d
```

### Доступ к приложению

- Описание API: http://localhost:4000/api/help
- PostgreSQL (внешний доступ): localhost:5433

### Переменные окружения

| Переменная | Описание | Значение по умолчанию |
|------------|----------|----------------------|
| `PHX_HOST` | Хост приложения | `localhost` |
| `PHX_PORT` | Порт приложения | `4000` |
| `DB_HOST` | Хост базы данных | `postgres` |
| `DB_PORT` | Порт базы данных | `5432` |
| `DB_USER` | Пользователь БД | `postgres` |
| `DB_PASS` | Пароль БД | `postgres` |
| `DB` | Имя базы данных | `seeds_dev` |
| `SECRET_KEY_BASE` | Секрет для сессий | (заменить в production) |

### Пример запуска с кастомными настройками

```bash
docker compose up -d \
  -e PHX_PORT=4080 \
  -e DB_HOST=custom-db \
  -e DB_PASS=secret_password
```

---

---

## Запуск в режиме production (без Docker)

Установите переменные окружения:

- `PHX_HOST`
- `PHX_PORT`
- `DB`
- `DB_USER`
- `DB_PASS`
- `DB_HOST`

```bash
$ git clone https://github.com/aabashin/seeds_app.git
$ cd seeds_app
```

Настройте переменные в `config/runtime.exs`:

```bash
$ MIX_ENV=prod mix release
$ cd _build/prod/rel/seeds_app/bin
$ ./seeds_app start
```

## Запуск в режиме development
```

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

## API Endpoints

### Seeds (async)

```bash
# Create seeds (async) - returns task_id immediately
$ curl -X POST http://localhost:4000/api/seeds
# or with custom count
$ curl -X POST http://localhost:4000/api/seeds?users_count=5000&rooms_count=5000&meetings_count=5000

# Response:
# {"message":"Task enqueued","status":"success","task_id":"a1b2c3d4e5f6"}
```

### Status

```bash
# Check task status
$ curl http://localhost:4000/api/seeds/status?task_id=a1b2c3d4e5f6

# Response:
# {"data":{"meetings_count":5000,"rooms_count":5000,"status":"completed","task_id":"a1b2c3d4e5f6","users_count":5000},"status":"success"}

# Possible statuses: pending, running, completed, failed
```

### Clear & Stats

```bash
# Clear database
$ curl -X DELETE http://localhost:4000/api/seeds

# Example response:
# {
#    "message": "Database cleared successfully. Deleted: 100000 Meetings, 100000 Rooms, 100000 Users/Accounts",
#    "status": "success"
#}

# View statistics
$ curl http://localhost:4000/api/stats
```

### Help

```bash
# View help
$ curl http://localhost:4000/api/help
```

You can open url http://localhost:4000/api/stats in your browser for see statistics

## Features

- **Async processing** — tasks are queued and processed in background
- **Queue limit** — maximum 10 concurrent tasks (configurable)
- **Parallel insert** — uses TaskSupervisor for parallel data insertion
- **Dynamic chunking** — automatically splits large datasets to respect PostgreSQL limit (65,535 parameters)

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

References:

* User has one Account
* Rooms has many Meetings
* Users has many Meetings