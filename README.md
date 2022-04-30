# rust-python-coverage
Example PyO3 project with automated test coverage for Rust and Python

[![CI](https://github.com/cjermain/rust-python-coverage/actions/workflows/CI.yml/badge.svg)](https://github.com/cjermain/rust-python-coverage/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/cjermain/rust-python-coverage/branch/main/graph/badge.svg?token=NWHDJ22L8I)](https://codecov.io/gh/cjermain/rust-python-coverage)

This repository shows how to set up continuous-integration job for measuring
coverage over a project using [PyO3](https://github.com/PyO3/pyo3). Based on
the [CI for PyO3's own tests](https://github.com/PyO3/pyo3/blob/main/.github/workflows/ci.yml#L306),
this example provides a simpler starting point for new projects. Coverage is
computed using [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov). The
coverge is measured over both the Python and Rust sections by taking advantage
of the ability of `cargo-llvm-cov` to measure coverge on any binary.

## Setup

Install `cargo-llvm-cov`:
```
rustup component add llvm-tools-preview
cargo install cargo-llvm-cov
```

Create the project:
```
cd rust-python-coverage
maturin init -b pyo3 --name foobar .
```

Setup the virtual environment:
```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Testing

Rust
```
cargo test
```

Python
```
maturin develop
pytest
```

## Coverage

By sourcing the relevant environment variables, multiple test binaries can be
called, including `pytest`.

```
source venv/bin/activate
source <(cargo llvm-cov show-env --export-prefix)
cargo llvm-cov --package=foobar clean --workspace
cargo test --package=foobar
maturin develop
pytest tests
cargo llvm-cov --package=foobar --no-run --lcov --output-path coverage.lcov
```
