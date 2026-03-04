import numpy as np
import pytest


@pytest.fixture
def tiny_rgb():
    """8x8 3-band float64 image, values in [0, 255]."""
    rng = np.random.default_rng(42)
    return rng.uniform(0, 255, (8, 8, 3))


@pytest.fixture
def tiny_label_map():
    """8x8 label map with 4 regions (1..4)."""
    m = np.array([
        [1, 1, 1, 1, 2, 2, 2, 2],
        [1, 1, 1, 1, 2, 2, 2, 2],
        [1, 1, 1, 1, 2, 2, 2, 2],
        [1, 1, 1, 1, 2, 2, 2, 2],
        [3, 3, 3, 3, 4, 4, 4, 4],
        [3, 3, 3, 3, 4, 4, 4, 4],
        [3, 3, 3, 3, 4, 4, 4, 4],
        [3, 3, 3, 3, 4, 4, 4, 4],
    ], dtype=np.int32)
    return m
