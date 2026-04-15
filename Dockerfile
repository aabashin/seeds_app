# Мультистейдж сборка для оптимизации размера финального образа

# --- Стадия 1: Сборка зависимостей ---
FROM elixir:1.19-alpine AS deps

# Установка необходимых пакетов для сборки нативных зависимостей
RUN apk add --no-cache \
    build-base \
    git

WORKDIR /build

# Копирование файлов манифеста зависимостей
COPY mix.exs mix.lock ./

# Установка зависимостей
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

# --- Стадия 2: Сборка приложения ---
FROM deps AS build

WORKDIR /build

# Копирование исходного кода
COPY lib ./lib
COPY priv ./priv
COPY config ./config
COPY rel ./rel

# Компиляция приложения в продакшен-режиме с созданием релиза
RUN MIX_ENV=prod mix compile && \
    MIX_ENV=prod mix release

# --- Стадия 3: Финальный образ для запуска ---
FROM elixir:1.19-alpine AS final

# Установка необходимых пакетов для runtime
RUN apk add --no-cache \
    libstdc++ \
    ncurses \
    openssl \
    gcompat

WORKDIR /app

# Создание нефпривилегированного пользователя для безопасности
RUN addgroup -g 1000 app && \
    adduser -u 1000 -G app -h /app -D app

# Копирование релиза из стадии build
COPY --from=build --chown=app:app /build/_build/prod/rel/seeds_app ./

# Переключение на нефривилегированного пользователя
USER app

# Переменные окружения по умолчанию
ENV PHX_HOST=localhost \
    PHX_PORT=4000 \
    DB_HOST=postgres \
    DB_PORT=5432 \
    DB_USER=postgres \
    DB_PASS=postgres \
    DB=seeds_dev \
    SECRET_KEY_BASE=your_secret_key_base_here_replace_in_production

# Экспонирование порта Phoenix приложения
EXPOSE 4000

# Команда запуска приложения
CMD ["bin/seeds_app", "start"]