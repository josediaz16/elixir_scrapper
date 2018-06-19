FROM elixir:1.6.5

RUN apt-get update
RUN apt-get install -y inotify-tools

RUN mix local.hex --force

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force
RUN mix deps.get
RUN mix local.rebar --force
RUN mix deps.compile
CMD mix test
