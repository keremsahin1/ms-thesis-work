"""End-to-end tests: full pipeline on synthetic images."""
import numpy as np
import pytest
from watershed_seg import Pipeline, segment, evaluate


def _synthetic_image(seed: int = 0) -> np.ndarray:
    """32×32 3-band image with 4 distinct quadrant regions."""
    rng = np.random.default_rng(seed)
    img = np.zeros((32, 32, 3), dtype=np.float64)
    img[:16, :16] = rng.uniform(200, 220, (16, 16, 3))  # bright top-left
    img[:16, 16:] = rng.uniform(50, 70, (16, 16, 3))    # dark top-right
    img[16:, :16] = rng.uniform(100, 120, (16, 16, 3))  # mid bottom-left
    img[16:, 16:] = rng.uniform(150, 170, (16, 16, 3))  # mid bottom-right
    return img


def test_full_pipeline_runs():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=10, rm2_threshold=500)
    result = p.run(img)
    assert result.labels.shape == (32, 32)
    assert result.n_segments >= 1


def test_full_pipeline_finds_regions():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=5, rm2_threshold=200)
    result = p.run(img)
    assert 1 <= result.n_segments <= 100


def test_evaluate_unsupervised_e2e():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=5, rm2_threshold=200)
    result = p.run(img)
    metrics = evaluate(result)
    assert "morans_i" in metrics
    assert "psnr" in metrics
    assert metrics["psnr"] > 0


def test_evaluate_supervised_e2e():
    img = _synthetic_image()
    gt = np.zeros((32, 32), dtype=np.int32)
    gt[:16, :16] = 1
    gt[:16, 16:] = 2
    gt[16:, :16] = 3
    gt[16:, 16:] = 4

    p = Pipeline(rm1_threshold=5, rm2_threshold=200)
    result = p.run(img)
    metrics = evaluate(result, ground_truth=gt)
    assert "E1" in metrics and "E2" in metrics
    assert 0.0 <= metrics["E1"] <= 100.0
    assert 0.0 <= metrics["E2"] <= 100.0


def test_all_merging_modes_run():
    img = _synthetic_image()
    for mode, kwargs in [
        ("rm1", {"rm1_threshold": 10}),
        ("rm2", {"rm2_threshold": 500}),
        ("rm3", {"rm1_threshold": 10, "rm2_threshold": 500}),
    ]:
        p = Pipeline(merging=mode, **kwargs)
        result = p.run(img)
        assert result.labels.shape == img.shape[:2], f"Failed for merging={mode}"


def test_all_prefilters_run():
    img = _synthetic_image()
    for mode in ["epsf", "pgf", "vectoral_median", None]:
        p = Pipeline(prefilter=mode, rm1_threshold=10, rm2_threshold=500)
        result = p.run(img)
        assert result.labels.shape == img.shape[:2], f"Failed for prefilter={mode}"


def test_all_watershed_inputs_run():
    img = _synthetic_image()
    for ws_input in ["h_image", "msgm"]:
        p = Pipeline(ws_input=ws_input, rm1_threshold=10, rm2_threshold=500)
        result = p.run(img)
        assert result.labels.shape == img.shape[:2]


def test_rm3_produces_fewer_segments_than_watershed():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=10, rm2_threshold=500)
    result = p.run(img)
    ws_count = int(result.watershed_labels.max())
    final_count = result.n_segments
    assert final_count <= ws_count


def test_labels_cover_all_pixels():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=5, rm2_threshold=200)
    result = p.run(img)
    assert (result.labels > 0).all()
    assert result.labels.shape == img.shape[:2]


def test_labels_sequential():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=5, rm2_threshold=200)
    result = p.run(img)
    unique = np.unique(result.labels)
    assert unique[0] == 1
    assert len(unique) == unique[-1]  # no gaps in label sequence
