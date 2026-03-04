import numpy as np
import pytest
from watershed_seg.auto_params import auto_select_rm1_threshold, auto_select_rm2_threshold


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
