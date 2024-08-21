#!/usr/bin/env bash
set -euxo pipefail

# set up the environment so `pytest` runs also provide coverage data
source <(cargo llvm-cov show-env --export-prefix)
export CARGO_TARGET_DIR=$CARGO_LLVM_COV_TARGET_DIR
export CARGO_INCREMENTAL=1

# clean the workspace
cargo clean
cargo llvm-cov clean --workspace -v

# test the rust library
# this will generate `target/rust-python-*.profraw` files
cargo test

# build the python library
maturin develop

# run the python tests
# this will generate additional `target/rust-python-*.profraw` files
# and write a coverage report for `*.py` files to `pytest-coverage.lcov`
pytest tests --cov=foobar --cov-report lcov:pytest-coverage.lcov --cov-report term

# merge the `*.profraw` files into a single  `rust-coverage.lcov` report
cargo llvm-cov report --lcov --output-path rust-coverage.lcov

# print the `rust` coverage report to the command line
cargo llvm-cov report

# or open the `rust` coverage report in the browser
# cargo llvm-cov report -v --html --open

# CAVEAT - only `codecov.io` provides a unified view of `python` and `rust` coverage