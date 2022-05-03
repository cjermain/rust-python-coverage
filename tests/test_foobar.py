import pytest

import foobar

VALUES = [
    (1, 2, 3),
    (2, 1, 3),
]


@pytest.mark.parametrize("a, b, expected", VALUES)
def test_pyo3_sum(a, b, expected):
    assert foobar.pyo3_sum(a, b) == expected


@pytest.mark.parametrize("a, b, expected", VALUES)
def test_py_sum(a, b, expected):
    assert foobar.py_sum(a, b) == expected
