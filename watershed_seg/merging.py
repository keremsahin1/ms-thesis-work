"""Multi-scale region merging: RM1, RM2, RM3 (proposed cascade).

Port of fRegionMerge1.m, fRegionMerge2.m, fRegionMerge_Proposed.m.
"""
import numpy as np
from .rag import build_rag, merge_regions


def _renumber_labels(labels: np.ndarray) -> np.ndarray:
    """Renumber labels to sequential 1..N. Port of fRenumberLabels.m."""
    out = np.zeros_like(labels)
    for new_lbl, old_lbl in enumerate(np.unique(labels[labels > 0]), start=1):
        out[labels == old_lbl] = new_lbl
    return out


def _find_smallest_merge(rag: dict) -> tuple:
    """Find the smallest region and its cheapest adjacent edge.

    Returns (r1_survivor, r2_absorbed) or (None, None) if nothing to merge.
    r1 is the neighbour (survivor), r2 is the smallest region (absorbed).
    """
    regions = rag["regions"]
    adj = rag["adj"]
    edges = rag["edges"]

    sizes = {lbl: r["n"] for lbl, r in regions.items()}
    min_size = min(sizes.values())
    candidates = [lbl for lbl, n in sizes.items() if n == min_size]

    best_r1, best_r2, best_cost = None, None, float("inf")
    for lbl in candidates:
        neighbors = adj.get(lbl, set())
        for nb in neighbors:
            key = (min(lbl, nb), max(lbl, nb))
            cost = edges.get(key, float("inf"))
            if cost < best_cost:
                best_cost = cost
                best_r1, best_r2 = nb, lbl  # nb survives, lbl is absorbed

    if best_r1 is None and candidates:
        # Isolated region — force-merge with spatially nearest label
        best_r2 = candidates[0]
        # Just pick any region that isn't best_r2
        others = [l for l in regions if l != best_r2]
        if others:
            best_r1 = others[0]

    return best_r1, best_r2


def rm1(
    labels: np.ndarray,
    img: np.ndarray,
    size_threshold: int = 100,
) -> np.ndarray:
    """RM1: Size-based region merging.

    Port of fRegionMerge1.m.

    Repeatedly merges the smallest region into its cheapest adjacent
    neighbour until all regions exceed size_threshold.

    Args:
        labels: H×W int32 label map (1-based, sequential).
        img: H×W×C float64 image.
        size_threshold: Stop when all regions have area > this value.

    Returns:
        H×W int32 renumbered label map.
    """
    labels = labels.copy().astype(np.int32)
    img = np.asarray(img, dtype=np.float64)
    rag = build_rag(labels, img)

    while True:
        sizes = {lbl: r["n"] for lbl, r in rag["regions"].items()}
        if not sizes or min(sizes.values()) > size_threshold:
            break

        r1, r2 = _find_smallest_merge(rag)
        if r1 is None:
            break

        labels, rag = merge_regions(labels, rag, r1, r2)

    return _renumber_labels(labels)


def rm2(
    labels: np.ndarray,
    img: np.ndarray,
    cost_threshold: float = 3000.0,
) -> np.ndarray:
    """RM2: Heterogeneity-based region merging.

    Port of fRegionMerge2.m.

    Repeatedly merges the globally cheapest edge until the minimum cost
    exceeds cost_threshold.

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.
        cost_threshold: Stop when min edge cost exceeds this value.

    Returns:
        H×W int32 renumbered label map.
    """
    labels = labels.copy().astype(np.int32)
    img = np.asarray(img, dtype=np.float64)
    rag = build_rag(labels, img)

    while rag["edges"]:
        min_key = min(rag["edges"], key=rag["edges"].__getitem__)
        min_cost = rag["edges"][min_key]
        if min_cost > cost_threshold:
            break
        r1, r2 = min_key
        labels, rag = merge_regions(labels, rag, r1, r2)

    return _renumber_labels(labels)


def rm3(
    labels: np.ndarray,
    img: np.ndarray,
    size_threshold: int = 100,
    cost_threshold: float = 3000.0,
) -> np.ndarray:
    """RM3: Proposed cascaded region merging (thesis novel contribution).

    Port of fRegionMerge_Proposed.m.

    Stage 1 (size-based, like RM1): Eliminates micro-segments.
    Stage 2 (cost-based, like RM2): Merges perceptually similar regions.

    Both stages share a single RAG built once — more efficient than
    running RM1 followed by a fresh RM2.

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.
        size_threshold: RM1 stopping criterion (pixels).
        cost_threshold: RM2 stopping criterion (merging cost).

    Returns:
        H×W int32 renumbered label map.
    """
    labels = labels.copy().astype(np.int32)
    img = np.asarray(img, dtype=np.float64)
    rag = build_rag(labels, img)

    # --- Stage 1: size-based (RM1 logic) ---
    while True:
        sizes = {lbl: r["n"] for lbl, r in rag["regions"].items()}
        if not sizes or min(sizes.values()) > size_threshold:
            break
        r1, r2 = _find_smallest_merge(rag)
        if r1 is None:
            break
        labels, rag = merge_regions(labels, rag, r1, r2)

    # --- Stage 2: cost-based (RM2 logic) ---
    while rag["edges"]:
        min_key = min(rag["edges"], key=rag["edges"].__getitem__)
        min_cost = rag["edges"][min_key]
        if min_cost > cost_threshold:
            break
        r1, r2 = min_key
        labels, rag = merge_regions(labels, rag, r1, r2)

    return _renumber_labels(labels)
