FROM elixir:1.12.3-alpine@sha256:138f5642181e758028de51143d969af64feaceb01375dd6516d56aa562152aea AS build

RUN apk add --no-cache build-base npm git python2

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get --only-prod, deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets

# Must copy source code before asset build.
# PurgeCSS needs to scan the source for e.g. Tailwind classes.
COPY lib lib
ENV NODE_ENV=production
RUN mix do assets.deploy, compile, release

FROM alpine:3.13.6@sha256:e15947432b813e8ffa90165da919953e2ce850bef511a0ad1287d7cb86de84b5 AS app
RUN apk add --no-cache openssl ncurses-libs libstdc++ lsof

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/affable ./

ENV HOME=/app

CMD ["bin/affable", "start"]
