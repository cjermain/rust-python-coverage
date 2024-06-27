#!/usr/bin/env bash
set -euxo pipefail

source <(cargo llvm-cov show-env --export-prefix)
export CARGO_TARGET_DIR=$CARGO_LLVM_COV_TARGET_DIR
export CARGO_INCREMENTAL=1

# clean the workspace
cargo clean
cargo llvm-cov clean --workspace -v

# test the rust library
cargo test

# build the python library
maturin develop

# run the python tests
pytest tests --cov=foobar --cov-report xml

# generate the coverage report
cargo llvm-cov report -v --html --open

# cargo llvm-cov --open
