FROM elixir:1.13.1-alpine@sha256:139a9d96206904a337c08d1c4889b596587c93422050d13bb8d77a773a7450ce AS build
RUN apk add --update-cache \
      elixir

WORKDIR /app

RUN mix local.hex --force && \
      mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
# COPY config config
RUN mix do deps.get --only-prod, deps.compile

COPY lib lib
RUN mix escript.build

FROM flant/shell-operator:latest@sha256:d1fe58aec7d9b5ddbbc619831274dd634c7e6c8a4ed3e8ac06291521372d1b51 AS app
RUN apk add --no-cache erlang

WORKDIR /app

COPY --from=build /app/tls_lb_operator hooks/
