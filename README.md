# rust-python-coverage
Example PyO3 project with automated test coverage for Rust and Python

[![CI](https://github.com/cjermain/rust-python-coverage/actions/workflows/CI.yml/badge.svg)](https://github.com/cjermain/rust-python-coverage/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/cjermain/rust-python-coverage/branch/main/graph/badge.svg?token=NWHDJ22L8I)](https://codecov.io/gh/cjermain/rust-python-coverage)

This repository shows how to set up a continuous-integration job for measuring
coverage over a project using [PyO3](https://github.com/PyO3/pyo3). Based on
the [CI for PyO3's own tests](https://github.com/PyO3/pyo3/blob/main/.github/workflows/ci.yml#L306),
this example provides a simpler starting point for new projects. Coverage is
computed using [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov). The
coverage is measured over both the Python and Rust sections by taking advantage
of the ability of `cargo-llvm-cov` to measure coverage on any binary.

# How does it work?

The repository contains 3 areas: (1) Rust only, (2) Rust with PyO3 bindings, and
(3) Python only.

```
├── python
│   └── foobar
│       └── __init__.py  # Python code
├── src
│   └── lib.rs           # Rust code, PyO3 bindings, Rust tests
└── tests
    └── test_foobar.py   # Python tests, also covering PyO3/Rust
```

Each area defines a simple function for adding two numbers:

* `rust_sum` - Rust only
* `pyo3_sum` - Rust with PyO3 bindings
* `py_sum` - Python only

In order to get full test coverage of all of the functions, both the Python
and Rust tests need to be run. We'll show the process step by step.

Before getting started, install `cargo-llvm-cov`:

```
rustup component add llvm-tools-preview
cargo install cargo-llvm-cov
```

The Python tests require a virtual environment to isolate the packages from the
system. This installs `pytest`, which is able to measure the coverage of the
Python only sections and also exercise the PyO3 bound Rust code.

```
uv sync
```

The Rust tests use `cargo test`. To measure the full Rust coverage from Python
tests, `cargo-llvm-cov` provides a set of environment variables that cause the
Rust binaries to include [instrumentation coverage](https://doc.rust-lang.org/stable/rustc/instrument-coverage.html)
that will save profile files when they are used. This means that any program
that exercises the binaries can be measured for the effect it has on coverage.

```
$ cargo llvm-cov show-env --export-prefix
export RUSTFLAGS=" -C instrument-coverage --cfg coverage --cfg trybuild_no_target"
export LLVM_PROFILE_FILE="/home/.../rust-python-coverage/target/rust-python-coverage-%m.profraw"
export CARGO_INCREMENTAL="0"
export CARGO_LLVM_COV_TARGET_DIR="/home/.../rust-python-coverage/target"
```

The profile files generated can be inspected in `CARGO_LLVM_COV_TARGET_DIR`.

In addition to these environment variables, it can be helpful to use incremental
compilation. For larger projects with nested directories and multiple Cargo.toml
files, it is necessary to centralize the `CARGO_TARGET_DIR` by setting it to the
`CARGO_LLVM_COV_TARGET_DIR` that is generated.

```
source <(cargo llvm-cov show-env --export-prefix)
export CARGO_TARGET_DIR=$CARGO_LLVM_COV_TARGET_DIR
export CARGO_INCREMENTAL=1
```

With these environment variables set up, we are ready to run the coverage
measurements.

```
cargo llvm-cov clean --workspace
cargo test
uv run -- maturin develop --uv
uv run -- pytest tests --cov=foobar --cov-report xml
cargo llvm-cov report --lcov --output-path coverage.lcov
```

First the `cargo llvm-cov clean` command removes any previous profiling
information. We then run the regular tests, which builds the Rust version
of the library. We use `maturin develop` to build and install the Python
wheel for the project. Then the `pytest` command is used to exercise the
Python tests, while also generating a coverage report for the Python code.

The last step of this process happens in the CI, where we upload both coverage
files to CodeCov. [Merging reports](https://docs.codecov.com/docs/merging-reports)
is an automatic feature of CodeCov, so the final view shows the combined view.

https://codecov.io/gh/cjermain/rust-python-coverage
