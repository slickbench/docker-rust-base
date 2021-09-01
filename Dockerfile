# syntax=docker/dockerfile:experimental

FROM debian:bullseye-slim
WORKDIR app
ENV PATH="/usr/local/cargo/bin:${PATH}"
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup

RUN apt-get update && apt-get install -y \
  ca-certificates \
  libpq-dev libssl-dev \
  curl file git ssh capnproto \
  build-essential clang lld pkg-config cmake \
  zlib1g-dev libxxhash-dev libstdc++-10-dev \
  autoconf automake autotools-dev libtool xutils-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
  
RUN git clone https://github.com/rui314/mold.git /tmp/mold \
  && cd /tmp/mold && make && make install \
  && rm -rf /tmp/mold

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain nightly -y

COPY cargo.toml $CARGO_HOME/config

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN rustup default nightly && rustup update && rustup component add clippy llvm-tools-preview

# Install tools
RUN cargo install sccache

ENV RUSTC_WRAPPER=sccache SCCACHE_DIR=/tmp/sccache

RUN cargo install diesel_cli --no-default-features --features postgres \
	&& cargo install sqlx-cli --no-default-features --features postgres \
	&& cargo install cargo-llvm-cov cargo-chef cargo-hack \
	&& rm -rf /usr/local/cargo/registry \
	&& sccache -s && rm -r $SCCACHE_DIR

