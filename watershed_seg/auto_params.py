"""Automatic parameter selection using the G2 metric.

Port of fAutomaticSelectRM1ScaleThreshold.m,
fAutomaticSelectRM2ScaleThreshold.m,
fAutomaticSelectEPSFWindowSize.m,
fAutomaticSelectH_ImageWindowSize.m.

Each function sweeps a parameter range, evaluates G2 (normalised
Moran's I + normalised variance) at each step, and returns the value
that minimises G2.

Key detail from MATLAB: the merging sweep uses the *filtered* image
(for computing merging costs), while G2 evaluation uses the *original*
image (for measuring segmentation quality). See OOLCC.m lines 357-361.
"""
from __future__ import annotations

from typing import Iterable, Optional

import numpy as np

from .evaluation import morans_i, intra_variance, goodness2
from .merging import rm1, rm2
from .filters import epsf
from .watershed_input import h_image
from .watershed import vincent_soille


def _sweep(
    labels_fn,
    eval_img: np.ndarray,
    search_range: list,
) -> object:
    """Evaluate G2 for each parameter value; return the minimiser.

    Args:
        labels_fn: Callable(param_value) → label map.
        eval_img: Image used for G2 evaluation (original, unfiltered).
        search_range: Parameter values to sweep.
    """
    eval_img = np.asarray(eval_img, dtype=np.float64)
    all_mi, all_var = [], []

    for val in search_range:
        labels = labels_fn(val)
        mi = morans_i(labels, eval_img)
        var = intra_variance(labels, eval_img)
        all_mi.append(mi)
        all_var.append(var)

    mi_arr = np.array(all_mi).T    # C×S
    var_arr = np.array(all_var).T  # C×S
    g2 = goodness2(mi_arr, var_arr)

    best_idx = int(np.argmin(g2))
    return search_range[best_idx]


def auto_select_rm1_threshold(
    init_labels: np.ndarray,
    original_img: np.ndarray,
    filtered_img: Optional[np.ndarray] = None,
    search_range: Iterable[int] = range(1, 101),
) -> int:
    """Auto-select RM1 size threshold via G2 sweep.

    Port of fAutomaticSelectRM1ScaleThreshold.m.

    Args:
        init_labels: H×W int32 watershed label map.
        original_img: H×W×C float64 original image (used for G2 eval).
        filtered_img: H×W×C float64 filtered image (used for merging costs).
            If None, falls back to original_img.
        search_range: Range of threshold values to try.

    Returns:
        Optimal size threshold (int).
    """
    merge_img = filtered_img if filtered_img is not None else original_img
    search = list(search_range)
    return _sweep(
        lambda t: rm1(init_labels, merge_img, size_threshold=t),
        original_img,
        search,
    )


def auto_select_rm2_threshold(
    init_labels: np.ndarray,
    original_img: np.ndarray,
    filtered_img: Optional[np.ndarray] = None,
    search_range: Iterable[float] = range(50, 5001, 50),
) -> float:
    """Auto-select RM2 cost threshold via G2 sweep.

    Port of fAutomaticSelectRM2ScaleThreshold.m.

    IMPORTANT: init_labels should be the labels *after* RM1 merging,
    not the raw watershed labels. See OOLCC.m line 360.

    Args:
        init_labels: H×W int32 label map (post-RM1 for RM3 cascade).
        original_img: H×W×C float64 original image (used for G2 eval).
        filtered_img: H×W×C float64 filtered image (used for merging costs).
            If None, falls back to original_img.
        search_range: Range of cost threshold values to try (MATLAB: 50..5000 step 50).

    Returns:
        Optimal cost threshold (float).
    """
    merge_img = filtered_img if filtered_img is not None else original_img
    search = list(search_range)
    return _sweep(
        lambda t: rm2(init_labels, merge_img, cost_threshold=float(t)),
        original_img,
        search,
    )


def auto_select_epsf_window(
    img: np.ndarray,
    search_range: Iterable[int] = range(3, 16, 2),
) -> int:
    """Auto-select EPSF window size via G2 sweep.

    Port of fAutomaticSelectEPSFWindowSize.m.
    Applies EPSF + H-image + Vincent-Soille for each window candidate.

    Args:
        img: H×W×C float64 image.
        search_range: Odd window sizes to try.

    Returns:
        Optimal window size (int).
    """
    search = list(search_range)

    def _run(w):
        filtered = epsf(img, w=w)
        grad = h_image(filtered)
        return vincent_soille(grad)

    return _sweep(_run, img, search)


def auto_select_h_image_window(
    filtered_img: np.ndarray,
    search_range: Iterable[int] = range(3, 16, 2),
) -> int:
    """Auto-select H-image window size via G2 sweep.

    Port of fAutomaticSelectH_ImageWindowSize.m.
    Applies H-image + Vincent-Soille for each window candidate.

    Args:
        filtered_img: H×W×C float64 pre-filtered image.
        search_range: Odd window sizes to try.

    Returns:
        Optimal window size (int).
    """
    search = list(search_range)

    def _run(w):
        grad = h_image(filtered_img, w=w)
        return vincent_soille(grad)

    return _sweep(_run, filtered_img, search)
