
use pyo3::prelude::*;

fn diff_as_string(a: i64, b: i64) -> String {
    (a - b).to_string()
}

/// Formats the sum of two numbers as string.
#[pyfunction]
fn sum_as_string(a: usize, b: usize) -> PyResult<String> {
    Ok((a + b).to_string())
}

/// A Python module implemented in Rust.
#[pymodule]
fn foobar(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(sum_as_string, m)?)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_diff_as_string() {
        assert_eq!(diff_as_string(2, 1), "1");
        assert_eq!(diff_as_string(1, 2), "-1");
    }
}
