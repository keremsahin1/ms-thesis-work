import numpy as np
import pytest
from watershed_seg.evaluation import (
    supervised_eval, morans_i, intra_variance,
    goodness2, simplified_image, psnr,
)
from watershed_seg.ground_truth import class_labels_to_seg_labels


# --- Ground truth ---

def test_seg_labels_sequential():
    class_map = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    seg = class_labels_to_seg_labels(class_map)
    unique = np.unique(seg)
    assert unique[0] == 1
    assert len(unique) == unique[-1]


def test_seg_labels_disconnected_class():
    class_map = np.array([
        [1, 0, 1],
        [0, 0, 0],
        [0, 0, 0],
    ], dtype=np.int32)
    seg = class_labels_to_seg_labels(class_map)
    assert len(np.unique(seg[seg > 0])) == 2


# --- Supervised eval ---

def test_perfect_segmentation_gives_zero_error():
    gt = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    found = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    e1, e2 = supervised_eval(gt, found)
    assert e1 == pytest.approx(0.0, abs=1e-6)
    assert e2 == pytest.approx(0.0, abs=1e-6)


def test_eval_returns_percentages():
    gt = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    found = np.array([[1, 1, 1, 2], [1, 1, 2, 2]], dtype=np.int32)
    e1, e2 = supervised_eval(gt, found)
    assert 0.0 <= e1 <= 100.0
    assert 0.0 <= e2 <= 100.0


# --- Moran's I ---

def test_morans_i_shape(tiny_label_map, tiny_rgb):
    mi = morans_i(tiny_label_map, tiny_rgb)
    assert mi.shape == (tiny_rgb.shape[2],)


def test_morans_i_single_region():
    labels = np.ones((8, 8), dtype=np.int32)
    img = np.random.rand(8, 8, 3) * 255
    mi = morans_i(labels, img)
    # No edges between distinct segments → result should be 0
    np.testing.assert_allclose(mi, 0.0, atol=1e-10)


# --- Intra variance ---

def test_intra_variance_shape(tiny_label_map, tiny_rgb):
    v = intra_variance(tiny_label_map, tiny_rgb)
    assert v.shape == (tiny_rgb.shape[2],)


def test_intra_variance_uniform_is_zero():
    img = np.full((8, 8, 3), 100.0)
    labels = np.ones((8, 8), dtype=np.int32)
    v = intra_variance(labels, img)
    np.testing.assert_allclose(v, 0.0, atol=1e-10)


# --- G2 ---

def test_goodness2_shape():
    morans = np.array([[0.1, 0.5, 0.9]])  # 1 band, 3 sweep values
    variances = np.array([[0.9, 0.5, 0.1]])
    g2 = goodness2(morans, variances)
    assert g2.shape == (3,)


def test_goodness2_multiband():
    morans = np.random.rand(3, 5)
    variances = np.random.rand(3, 5)
    g2 = goodness2(morans, variances)
    assert g2.shape == (5,)


# --- PSNR ---

def test_psnr_perfect_reconstruction():
    img = np.random.rand(8, 8, 3) * 255
    score = psnr(img, img)
    assert score == float("inf") or score > 100.0


def test_psnr_noisy_lower():
    img = np.full((8, 8, 3), 128.0)
    noisy = img + 10.0
    score = psnr(img, noisy)
    assert score < 100.0


# --- Simplified image ---

def test_simplified_image_shape(tiny_label_map, tiny_rgb):
    out = simplified_image(tiny_label_map, tiny_rgb)
    assert out.shape == tiny_rgb.shape


def test_simplified_image_uniform_regions():
    labels = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    img = np.stack([labels.astype(float) * 50] * 3, axis=-1)
    out = simplified_image(labels, img)
    np.testing.assert_allclose(out[0, 0], [50., 50., 50.])
    np.testing.assert_allclose(out[0, 2], [100., 100., 100.])
