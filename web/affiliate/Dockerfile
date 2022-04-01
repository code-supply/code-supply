FROM elixir:1.13.1-alpine@sha256:139a9d96206904a337c08d1c4889b596587c93422050d13bb8d77a773a7450ce AS build

RUN apk add --no-cache build-base npm git python2

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get --only-prod, deps.compile

COPY priv priv
COPY assets assets

# Must copy source code before asset build.
# PurgeCSS needs to scan the source for e.g. Tailwind classes.
COPY lib lib
RUN mix do assets.deploy, compile, release

FROM alpine@sha256:a15790640a6690aa1730c38cf0a440e2aa44aaca9b0e8931a9f2b0d7cc90fd65 AS app
RUN apk add --no-cache openssl ncurses-libs lsof

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/affiliate ./

ENV HOME=/app

CMD ["bin/affiliate", "start"]
