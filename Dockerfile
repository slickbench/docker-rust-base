# syntax=docker/dockerfile:experimental

FROM rustlang/rust:nightly as odyssey_builder

RUN rustup default nightly-2021-07-05 && rustup component add clippy && rustup toolchain uninstall nightly

# Install tools
RUN cargo install sccache
RUN cargo install cargo-sweep
RUN cargo install cargo-tarpaulin
RUN cargo install diesel_cli --no-default-features --features "postgres"

# Cleanup
RUN rm -rf $HOME/.cargo/registry/
