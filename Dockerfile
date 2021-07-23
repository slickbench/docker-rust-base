# syntax=docker/dockerfile:experimental

FROM rustlang/rust:nightly as odyssey_builder

RUN rustup update && rustup component add clippy

# Install tools
RUN cargo install sccache
RUN cargo install cargo-sweep
RUN cargo install cargo-tarpaulin
RUN cargo install diesel_cli --no-default-features --features "postgres"

# Cleanup
RUN rm -rf /usr/local/cargo/registry
