# Исходный образ Elixir
FROM elixir:1.18-alpine AS builder

# Установка Node.js и npm для Phoenix
RUN apk add --no-cache nodejs npm

# Установка PostgreSQL клиента
RUN apk add --no-cache postgresql-client

# Создание пользователя app
RUN addgroup -g 1000 app && adduser -u 1000 -G app -s /bin/sh -D app

WORKDIR /app

# Копируем зависимости и mix-файлы
COPY mix.exs mix.lock ./

# Установка зависимостей Elixir
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod

# Копируем исходный код
COPY config config/
COPY lib lib/
COPY priv priv/

# Компиляция приложения
ENV MIX_ENV=prod
RUN mix phx.digest && \
    mix release

# Финальный образ
FROM alpine:3.19

# Установка необходимых пакетов
RUN apk add --no-cache openssl postgresql-client

# Создание пользователя app
RUN addgroup -g 1000 app && adduser -u 1000 -G app -s /bin/sh -D app

WORKDIR /app

# Копируем релиз из builder
COPY --from=builder --chown=app:app /app/_build/prod/rel/seeds_app ./

# Права на директорию
RUN chown -R app:app /app

# Переключаемся на пользователя app
USER app

# Запуск приложения
ENV MIX_ENV=prod
EXPOSE 4000

CMD ["bin/seeds_app", "start"]