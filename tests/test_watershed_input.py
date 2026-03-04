import numpy as np
import pytest
from watershed_seg.watershed_input import h_image, msgm


def test_h_image_shape(tiny_rgb):
    out = h_image(tiny_rgb, w=3)
    assert out.shape == tiny_rgb.shape[:2]


def test_h_image_dtype(tiny_rgb):
    out = h_image(tiny_rgb, w=3)
    assert out.dtype == np.float64


def test_h_image_nonnegative(tiny_rgb):
    out = h_image(tiny_rgb, w=3)
    assert (out >= 0).all()


def test_h_image_uniform_is_zero():
    """Uniform image has no spectral change → H-image should be 0."""
    img = np.full((10, 10, 3), 100.0)
    out = h_image(img, w=5)
    np.testing.assert_allclose(out, 0.0, atol=1e-10)


def test_h_image_single_band():
    img = np.random.rand(8, 8, 1) * 255
    out = h_image(img, w=3)
    assert out.shape == (8, 8)


def test_msgm_shape(tiny_rgb):
    out = msgm(tiny_rgb)
    assert out.shape == tiny_rgb.shape[:2]


def test_msgm_nonnegative(tiny_rgb):
    out = msgm(tiny_rgb)
    assert (out >= 0).all()
