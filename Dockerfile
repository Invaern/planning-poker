FROM elixir:1.11.2-alpine as build


RUN mix local.hex --force \
    && mix local.rebar \
    && mix archive.install hex phx_new 1.5.7 --force \
    && apk add --update npm

WORKDIR /opt/ppoker

ENV MIX_ENV=prod
ADD . . 

RUN mix deps.get --only prod \
    && mix compile \
    && npm install --prefix ./assets \
    && NODE_ENV=production npm run deploy --prefix ./assets \
    && mix phx.digest \
    && mix release

FROM alpine:3.12 as release

WORKDIR /opt/planning_poker/
COPY --from=build /opt/ppoker/_build/prod/rel/planning_poker/ .
RUN apk add --update ncurses

ENV MIX_ENV=prod \
    PORT=4000 \
    SECRET_KEY_BASE=LHgA0fW/XMKUc4sOhUPKcRakuARqb9bWzVi2yA10guuwalsiz4PoZ5NNl8gGhooC \
    AUTH_USERNAME=admin \
    AUTH_PASSWORD=nimda \
    URL_HOST=localhost \
    SCHEME=http \
    RELEASE_NODE="ppoker@127.0.0.1" \
    RELEASE_COOKIE=myverysecretcookie \
    RELEASE_DISTRIBUTION=name \
    BEAM_PORT=4001

EXPOSE 4000
EXPOSE 4001
EXPOSE 4369

CMD [ "bin/planning_poker", "start" ]


