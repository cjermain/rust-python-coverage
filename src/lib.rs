
use pyo3::prelude::*;

/// Returns the sum of two numbers (only Rust)
fn rust_sum(a: i64, b: i64) -> i64 {
    a + b
}

/// Returns the sum of two numbers, wrapped by pyo3
#[pyfunction]
fn pyo3_sum(a: usize, b: usize) -> PyResult<usize> {
    Ok(a + b)
}

/// A Python module implemented in Rust.
// LCOV_EXCL_START - PyO3 module initialization cannot be directly tested (see rust-lang/rust#84605)
#[pymodule]
fn _foobar(_py: Python, m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(pyo3_sum, m)?)?;
    Ok(())
}
// LCOV_EXCL_STOP

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rust_sum() {
        assert_eq!(rust_sum(2, 1), 3);
        assert_eq!(rust_sum(1, 2), 3);
    }
}
