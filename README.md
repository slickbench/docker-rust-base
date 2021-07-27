# Docker Rust Builder

A base docker image for building and testing the odyssey backend. Based on rustlang/nightly

## Features

Pre-installs the following utilities, useful for rust CI builds:
 - cargo-chef
 - cargo-sweep
 - cargo-tarpaulin
 - diesel_cli w/ postgres support
