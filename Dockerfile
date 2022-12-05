# syntax=docker/dockerfile:1.3
FROM debian:bookworm-slim as base
WORKDIR app

ENV PATH="/usr/local/cargo/bin:${PATH}"
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup

RUN apt-get update \
	&& apt-get install -y \
		git curl ssh \
		build-essential clang \
		libssl-dev \
	&& apt-get clean

#
# Build the mold linker
#
FROM base as mold

RUN apt-get update \
	&& apt-get install -y \
		cmake \
		zlib1g-dev libxxhash-dev \
	&& apt-get clean

RUN git clone https://github.com/rui314/mold.git /tmp/mold \
  && cd /tmp/mold \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ .. \
  && cmake --build . -j $(nproc)


#
# Build the rust image
# 
FROM base as rust

RUN apt-get update \
	&& apt-get install -y \
		pkg-config \
	&& apt-get clean

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
RUN rustup default nightly && rustup update && rustup component add clippy llvm-tools-preview


#
# Build sccache
#
FROM rust as sccache

RUN cargo install sccache && rm -rf /usr/local/cargo/registry


#
# Build the final image
#
FROM rust

ENV RUSTC_WRAPPER=sccache SCCACHE_DIR=/tmp/sccache

RUN apt-get update && apt-get install -y \
	ca-certificates \
	libpq-dev libstdc++-10-dev \
	curl file \
	docker.io docker-compose \
	autoconf automake autotools-dev libtool xutils-dev \
	cmake \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=sccache $CARGO_HOME/bin/sccache $CARGO_HOME/bin/sccache

RUN cargo install diesel_cli --no-default-features --features postgres \
	&& cargo install sqlx-cli --no-default-features --features rustls,postgres \
	&& cargo install cargo-llvm-cov cargo-chef cargo-hack \
	&& rm -rf /usr/local/cargo/registry \
	&& sccache -s && rm -r $SCCACHE_DIR

RUN --mount=type=bind,from=mold,src=/tmp/mold,target=/tmp/mold cd /tmp/mold/build && cmake --install .
  
COPY cargo.toml $CARGO_HOME/config
