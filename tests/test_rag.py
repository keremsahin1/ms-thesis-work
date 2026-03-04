import numpy as np
import pytest
from watershed_seg.rag import build_rag, merging_cost, merged_region_stats, merge_regions


def test_build_rag_nodes(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    assert set(rag["regions"].keys()) == {1, 2, 3, 4}


def test_build_rag_edges(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    edges = rag["edges"]
    # Regions 1-2 (top), 1-3 (left), 2-4 (right), 3-4 (bottom) are adjacent
    assert (1, 2) in edges
    assert (1, 3) in edges
    assert (2, 4) in edges
    assert (3, 4) in edges
    # Diagonal regions 1-4 and 2-3 are NOT adjacent in 4-connectivity
    assert (1, 4) not in edges
    assert (2, 3) not in edges


def test_merging_cost_nonnegative(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    cost = merging_cost(rag["regions"][1], rag["regions"][2], n_bands=3)
    assert cost >= 0.0


def test_merged_region_stats_area():
    r1 = {"n": 10, "mean": np.array([100.0, 50.0, 25.0]),
          "std": np.array([5.0, 3.0, 2.0])}
    r2 = {"n": 10, "mean": np.array([200.0, 100.0, 50.0]),
          "std": np.array([10.0, 6.0, 4.0])}
    merged = merged_region_stats(r1, r2)
    assert merged["n"] == 20
    np.testing.assert_allclose(merged["mean"], np.array([150.0, 75.0, 37.5]))


def test_merged_region_stats_std_nonnegative():
    r1 = {"n": 5, "mean": np.array([100.0]), "std": np.array([5.0])}
    r2 = {"n": 5, "mean": np.array([100.0]), "std": np.array([5.0])}
    merged = merged_region_stats(r1, r2)
    assert (merged["std"] >= 0).all()


def test_merge_regions_removes_source(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    labels, rag2 = merge_regions(tiny_label_map.copy(), rag, 1, 2)
    assert 2 not in rag2["regions"]
    assert 1 in rag2["regions"]
    assert not np.any(labels == 2)


def test_merge_regions_label_map_updated(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    labels, _ = merge_regions(tiny_label_map.copy(), rag, 1, 2)
    # All previously-2 pixels should now be 1
    assert np.all(labels[tiny_label_map == 2] == 1)
    # Previously-1 pixels still 1
    assert np.all(labels[tiny_label_map == 1] == 1)


def test_merge_regions_area_updated(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    expected_n = rag["regions"][1]["n"] + rag["regions"][2]["n"]
    labels, rag2 = merge_regions(tiny_label_map.copy(), rag, 1, 2)
    # Merged region should have sum of original areas
    assert rag2["regions"][1]["n"] == expected_n
