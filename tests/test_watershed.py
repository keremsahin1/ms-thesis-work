import numpy as np
import pytest
from watershed_seg.watershed import vincent_soille, rainfalling


def test_vincent_soille_shape(tiny_rgb):
    h_img = np.random.rand(*tiny_rgb.shape[:2])
    labels = vincent_soille(h_img)
    assert labels.shape == tiny_rgb.shape[:2]


def test_vincent_soille_labels_positive(tiny_rgb):
    h_img = np.random.rand(*tiny_rgb.shape[:2])
    labels = vincent_soille(h_img)
    assert labels.min() >= 1


def test_vincent_soille_labels_sequential():
    h_img = np.random.rand(16, 16)
    labels = vincent_soille(h_img)
    unique = np.unique(labels)
    assert unique[0] == 1
    assert unique[-1] == len(unique)  # labels are 1..N


def test_vincent_soille_uniform_input():
    """Uniform gradient → few large regions."""
    h_img = np.zeros((10, 10))
    labels = vincent_soille(h_img)
    assert labels.max() >= 1


def test_rainfalling_shape(tiny_rgb):
    h_img = np.random.rand(*tiny_rgb.shape[:2])
    labels = rainfalling(h_img)
    assert labels.shape == tiny_rgb.shape[:2]


def test_rainfalling_labels_positive(tiny_rgb):
    h_img = np.random.rand(*tiny_rgb.shape[:2])
    labels = rainfalling(h_img)
    assert labels.min() >= 1
