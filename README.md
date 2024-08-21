
> [!NOTE]
> This is fork of [Colin Jermain's original](https://github.com/cjermain/rust-python-coverage) with the following changes:
> - Updated to latest `PyO3`, `maturin`, and `pytest-cov` dependencies
> - Updated the coverage output paths for clarity
> - Added a `run-cov.sh` script that also explains some detail on coverage data generation
> - Added a `nix` devshell for easy setup
> - Added a `clean.sh` script to clean up generated artificats

> [!NOTE]
> Try running `clean.sh` if you encounter any "weird" errors.
> If the error persists, blow out the `.venv` and `~/.cargo/bin` directories and try again.

-------
-------

# rust-python-coverage
Example PyO3 project with automated test coverage for Rust and Python

[![CI](https://github.com/Michael-J-Ward/rust-python-coverage/actions/workflows/CI.yml/badge.svg)](https://github.com/Michael-J-Ward/rust-python-coverage/actions/workflows/CI.yml)
[![codecov](https://codecov.io/github/Michael-J-Ward/rust-python-coverage/graph/badge.svg?token=K4T59SGTQX)](https://codecov.io/github/Michael-J-Ward/rust-python-coverage)

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

### Setup: Installing Dependencies

Before getting started, install `cargo-llvm-cov`:

> [!NOTE]
> If you use nix flakes, you can use the provided devshell to install the dependencies
> ```
> nix develop .
> ```
> If you are interested in `nix`, I recommend the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer).


```
rustup component add llvm-tools-preview
cargo install cargo-llvm-cov
```

The Python tests require a virtual environment to isolate the packages from the
system. This installs `pytest`, which is able to measure the coverage of the
Python only sections and also exercise the PyO3 bound Rust code.

```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Setup: Preparing `cargo-llvm-cov` environment variables

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
cargo llvm-cov clean --workspace -v
cargo test
maturin develop
pytest tests --cov=foobar --cov-report lcov:python-coverage.lcov
cargo llvm-cov --no-run --lcov --output-path rust-coverage.lcov
```

First the `cargo llvm-cov clean` command removes any previous profiling
information. We then run the regular tests, which builds the Rust version
of the library. We use `maturin develop` to build and install the Python
wheel for the project. Then the `pytest` command is used to exercise the
Python tests, while also generating a coverage report for the Python code.

The last step of this process happens in the CI, where we upload both coverage
files to CodeCov. [Merging reports](https://docs.codecov.com/docs/merging-reports)
is an automatic feature of CodeCov, so the final view shows the combined view.

https://codecov.io/github/Michael-J-Ward/rust-python-coverage

## Appendix

If you'd like to *save* the html report for the Rust code, you can run the following command:

```console
 cargo llvm-cov report --html --open --output-dir .
warning: 1 functions have mismatched data

    Finished report saved to ./html
     Opening ./html/index.html
```
