# rust-python-coverage
Example PyO3 project with automated test coverage for Rust and Python

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

By sourcing the relevant environment variables, multiple tests can be performed,
including those from `pytest`.

```
source venv/bin/activate
source <(cargo llvm-cov show-env --export-prefix)
cargo llvm-cov --package=foobar clean --workspace
cargo test --package=foobar
maturin develop
pytest tests
cargo llvm-cov --package=foobar --no-run --lcov --output-path coverage.lcov
```
