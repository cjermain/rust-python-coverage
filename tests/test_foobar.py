import pytest

import foobar

@pytest.mark.parametrize(
    "a, b, expected",
    [
        (1, 2, '3'), 
    ]
)
def test_sum_as_string(a, b, expected):
    assert foobar.sum_as_string(a, b) == expected
