import numpy as np
import pytest
from watershed_seg.utils import mirror_pad, strip_pad


def test_mirror_pad_shape_2d():
    img = np.ones((10, 12))
    out = mirror_pad(img, 3)
    assert out.shape == (16, 18)


def test_mirror_pad_shape_3d():
    img = np.ones((10, 12, 3))
    out = mirror_pad(img, 3)
    assert out.shape == (16, 18, 3)


def test_strip_pad_is_inverse():
    img = np.random.rand(10, 12, 3)
    padded = mirror_pad(img, 2)
    recovered = strip_pad(padded, 2)
    np.testing.assert_array_equal(img, recovered)


def test_mirror_pad_values():
    img = np.arange(9, dtype=float).reshape(3, 3)
    out = mirror_pad(img, 1)
    # Center should be unchanged
    np.testing.assert_array_equal(out[1:4, 1:4], img)
