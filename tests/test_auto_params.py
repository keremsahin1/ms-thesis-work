import numpy as np
import pytest
from watershed_seg.auto_params import auto_select_rm1_threshold, auto_select_rm2_threshold
from watershed_seg.filters import epsf
from watershed_seg.merging import rm1


def test_auto_select_rm1_returns_int(tiny_label_map, tiny_rgb):
    thresh = auto_select_rm1_threshold(
        tiny_label_map, tiny_rgb,
        search_range=range(1, 5),
    )
    assert isinstance(thresh, int)


def test_auto_select_rm1_within_range(tiny_label_map, tiny_rgb):
    search = range(1, 5)
    thresh = auto_select_rm1_threshold(
        tiny_label_map, tiny_rgb,
        search_range=search,
    )
    assert thresh in search


def test_auto_select_rm2_returns_numeric(tiny_label_map, tiny_rgb):
    thresh = auto_select_rm2_threshold(
        tiny_label_map, tiny_rgb,
        search_range=range(10, 50, 10),
    )
    assert thresh in range(10, 50, 10)


# --- Regression tests for bugs fixed in 2026-03-07 ---


def test_auto_select_rm1_accepts_filtered_img(tiny_label_map, tiny_rgb):
    """Regression: auto_select_rm1_threshold must accept filtered_img kwarg.

    Bug: the function used the same image for merging and G2 evaluation.
    MATLAB uses filtered image for merging, original for evaluation.
    """
    filtered = epsf(tiny_rgb, w=3)
    thresh = auto_select_rm1_threshold(
        tiny_label_map, tiny_rgb,
        filtered_img=filtered,
        search_range=range(1, 5),
    )
    assert isinstance(thresh, int)
    assert thresh in range(1, 5)


def test_auto_select_rm2_accepts_filtered_img(tiny_label_map, tiny_rgb):
    """Regression: auto_select_rm2_threshold must accept filtered_img kwarg."""
    filtered = epsf(tiny_rgb, w=3)
    thresh = auto_select_rm2_threshold(
        tiny_label_map, tiny_rgb,
        filtered_img=filtered,
        search_range=range(10, 50, 10),
    )
    assert thresh in range(10, 50, 10)


def test_auto_select_rm2_on_post_rm1_labels(tiny_label_map, tiny_rgb):
    """Regression: RM2 auto-selection should use post-RM1 labels.

    Bug: pipeline was passing raw watershed labels to auto_select_rm2_threshold.
    MATLAB (OOLCC.m line 360) passes dRM1Labels (after RM1), not dWSLabels.
    This test verifies the function works correctly on post-RM1 input.
    """
    # Simulate the correct pipeline: RM1 first, then auto-select RM2
    rm1_labels = rm1(tiny_label_map, tiny_rgb, size_threshold=5)
    thresh = auto_select_rm2_threshold(
        rm1_labels, tiny_rgb,
        search_range=range(10, 50, 10),
    )
    assert thresh in range(10, 50, 10)


def test_auto_select_rm2_default_range_matches_matlab():
    """Regression: RM2 default search range must be 50..5000 step 50.

    Bug: was range(100, 10001, 100). MATLAB uses 50:50:5000.
    """
    import inspect
    sig = inspect.signature(auto_select_rm2_threshold)
    default_range = sig.parameters["search_range"].default
    assert list(default_range) == list(range(50, 5001, 50))
