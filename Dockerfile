FROM elixir:1.6.5

RUN apt-get update
RUN apt-get install -y inotify-tools
RUN apt-get install unzip

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN mix local.hex --force

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force
RUN mix deps.get

WORKDIR /app/deps/html5ever/native/html5ever_nif/
RUN cargo update
WORKDIR /app

RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile
CMD mix test
