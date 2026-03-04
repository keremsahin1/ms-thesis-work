import numpy as np
import pytest
from watershed_seg.filters import epsf


def test_epsf_output_shape(tiny_rgb):
    out = epsf(tiny_rgb, w=3)
    assert out.shape == tiny_rgb.shape


def test_epsf_output_dtype(tiny_rgb):
    out = epsf(tiny_rgb, w=3)
    assert out.dtype == np.float64


def test_epsf_uniform_image_unchanged():
    img = np.full((10, 10, 3), 128.0)
    out = epsf(img, w=5)
    np.testing.assert_allclose(out, img, atol=1e-10)


def test_epsf_output_in_range(tiny_rgb):
    out = epsf(tiny_rgb, w=3)
    assert out.min() >= 0.0
    assert out.max() <= 255.0


def test_epsf_smoothing_reduces_variance(tiny_rgb):
    out = epsf(tiny_rgb, w=5)
    assert out.std() <= tiny_rgb.std()
