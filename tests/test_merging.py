import numpy as np
import pytest
from watershed_seg.merging import rm1, rm2, rm3


def test_rm1_reduces_segment_count(tiny_label_map, tiny_rgb):
    # With threshold > 16 pixels per region, all 4 should merge
    out = rm1(tiny_label_map, tiny_rgb, size_threshold=20)
    n_before = len(np.unique(tiny_label_map))
    n_after = len(np.unique(out))
    assert n_after < n_before


def test_rm1_no_merge_below_threshold(tiny_label_map, tiny_rgb):
    # Each region is 16 pixels; threshold=1 → nothing merged
    out = rm1(tiny_label_map, tiny_rgb, size_threshold=1)
    assert len(np.unique(out)) == len(np.unique(tiny_label_map))


def test_rm1_labels_sequential(tiny_label_map, tiny_rgb):
    out = rm1(tiny_label_map, tiny_rgb, size_threshold=20)
    unique = np.unique(out)
    assert unique[0] == 1
    assert len(unique) == unique[-1]  # no gaps


def test_rm1_covers_all_pixels(tiny_label_map, tiny_rgb):
    out = rm1(tiny_label_map, tiny_rgb, size_threshold=20)
    assert out.shape == tiny_label_map.shape
    assert (out > 0).all()


def test_rm2_reduces_segment_count(tiny_label_map, tiny_rgb):
    out = rm2(tiny_label_map, tiny_rgb, cost_threshold=1e9)
    assert len(np.unique(out)) < len(np.unique(tiny_label_map))


def test_rm2_no_merge_at_negative_threshold(tiny_label_map, tiny_rgb):
    # Cost is always non-negative, so threshold < 0 means no merges
    out = rm2(tiny_label_map, tiny_rgb, cost_threshold=-1.0)
    assert len(np.unique(out)) == len(np.unique(tiny_label_map))


def test_rm3_two_stage(tiny_label_map, tiny_rgb):
    out = rm3(tiny_label_map, tiny_rgb, size_threshold=1, cost_threshold=1e9)
    # With very high cost threshold, should merge down to 1 segment
    assert len(np.unique(out)) == 1


def test_rm3_labels_sequential(tiny_label_map, tiny_rgb):
    out = rm3(tiny_label_map, tiny_rgb, size_threshold=20, cost_threshold=100.0)
    unique = np.unique(out)
    if len(unique) > 1:
        assert unique[0] == 1
        assert len(unique) == unique[-1]


def test_rm3_produces_fewer_segments_than_rm1_alone(tiny_label_map, tiny_rgb):
    rm1_out = rm1(tiny_label_map, tiny_rgb, size_threshold=5)
    rm3_out = rm3(tiny_label_map, tiny_rgb, size_threshold=5, cost_threshold=1000.0)
    assert len(np.unique(rm3_out)) <= len(np.unique(rm1_out))
