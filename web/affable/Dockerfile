FROM elixir:1.14.3-alpine@sha256:533332aabb572cb902a47564f0c67b599ee6423e40796fb732e8992eb967e452 AS build

RUN apk add --no-cache build-base git

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get --only-prod, deps.compile

COPY assets assets

# Must copy source code before asset build.
# PurgeCSS needs to scan the source for e.g. Tailwind classes.
COPY lib lib
RUN mix do assets.deploy, compile, release

FROM alpine:3.17.2@sha256:e2e16842c9b54d985bf1ef9242a313f36b856181f188de21313820e177002501 AS app
RUN apk add --no-cache openssl ncurses-libs libstdc++ lsof

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/affable ./

ENV HOME=/app

CMD ["bin/affable", "start"]
