# rust-python-coverage
Example PyO3 project with automated test coverage for Rust and Python

## Setup

```
cd rust-python-coverage
maturin init -b pyo3 --name foobar .
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

