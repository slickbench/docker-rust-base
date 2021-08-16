# syntax=docker/dockerfile:experimental

FROM debian:bullseye-slim

ENV PATH="/usr/local/cargo/bin:${PATH}"
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup

RUN apt-get update && apt-get install -y \
  ca-certificates \
  libpq-dev libssl-dev \
  curl file git ssh \
  build-essential clang lld pkg-config \
  autoconf automake autotools-dev libtool xutils-dev \
  && rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain nightly -y

RUN echo $PATH
RUN ls $CARGO_HOME

COPY cargo.toml $CARGO_HOME/config

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN rustup default nightly && rustup update && rustup component add clippy

# Install tools
RUN cargo install diesel_cli --no-default-features --features postgres
RUN cargo install sqlx-cli --locked --no-default-features --features postgres
RUN cargo install cargo-sweep cargo-tarpaulin cargo-chef cargo-hack

# Cleanup
RUN rm -rf /usr/local/cargo/registry

WORKDIR app
