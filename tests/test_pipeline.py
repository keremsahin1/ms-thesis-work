import numpy as np
import pytest
from watershed_seg import Pipeline, segment, evaluate


def test_pipeline_run_returns_label_map(tiny_rgb):
    p = Pipeline(rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    assert result.labels.shape == tiny_rgb.shape[:2]
    assert result.labels.dtype == np.int32


def test_pipeline_run_labels_positive(tiny_rgb):
    p = Pipeline(rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    assert result.labels.min() >= 1


def test_segment_shortcut(tiny_rgb):
    result = segment(tiny_rgb, auto_params=False)
    assert result.labels.shape == tiny_rgb.shape[:2]


def test_pipeline_n_segments(tiny_rgb):
    p = Pipeline(rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    assert result.n_segments == int(result.labels.max())


def test_pipeline_intermediates(tiny_rgb):
    p = Pipeline(rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    assert result.filtered_img is not None
    assert result.gradient_img is not None
    assert result.watershed_labels is not None


def test_pipeline_prefilter_none(tiny_rgb):
    p = Pipeline(prefilter=None, rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    assert result.labels.shape == tiny_rgb.shape[:2]


def test_evaluate_unsupervised(tiny_rgb):
    p = Pipeline(rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    metrics = evaluate(result)
    assert "morans_i" in metrics
    assert "psnr" in metrics


def test_evaluate_supervised(tiny_rgb, tiny_label_map):
    p = Pipeline(rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    metrics = evaluate(result, ground_truth=tiny_label_map)
    assert "E1" in metrics
    assert "E2" in metrics
    assert 0.0 <= metrics["E1"] <= 100.0


def test_pipeline_auto_params_passes_filtered_img(tiny_rgb):
    """Regression: auto_params must pass filtered_img to auto-select functions
    and use post-RM1 labels for RM2 threshold selection."""
    p = Pipeline()
    result = p.run(tiny_rgb, auto_params=True)
    assert result.labels.shape == tiny_rgb.shape[:2]
    assert result.labels.min() >= 1
    # Verify auto-selected thresholds are stored in params
    assert "rm1_threshold" in result.params
    assert "rm2_threshold" in result.params
