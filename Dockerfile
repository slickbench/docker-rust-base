# syntax=docker/dockerfile:experimental

FROM rustlang/rust:nightly as odyssey_builder
RUN echo "[net]\ngit-fetch-with-cli = true" > $CARGO_HOME/config
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN rustup update && rustup component add clippy

# Install tools
RUN cargo install diesel_cli --no-default-features --features postgres
RUN cargo install sqlx-cli --no-default-features --features postgres
RUN cargo install cargo-sweep cargo-tarpaulin cargo-chef cargo-hack

# Cleanup
RUN rm -rf /usr/local/cargo/registry

WORKDIR app
