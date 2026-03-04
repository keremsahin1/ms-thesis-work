"""Region Adjacency Graph for region merging.

Port of fGetRAG.m, fGetMergingCost.m, fUpdateEdges.m.

Internal representation:
  rag = {
      "regions": {label: {"n": int, "mean": C-array, "std": C-array}},
      "edges":   {(min_lbl, max_lbl): cost},
      "adj":     {label: set_of_neighbor_labels},
  }

Region stats are maintained analytically — no pixel re-scan on merge.
This is O(C) per merge vs. MATLAB's O(pixels).
"""
import numpy as np
from skimage.measure import regionprops


def _edge_key(a: int, b: int) -> tuple:
    return (min(a, b), max(a, b))


def merged_region_stats(r1: dict, r2: dict) -> dict:
    """Compute merged region stats analytically using the parallel algorithm.

    Exact (not approximate): uses the identity
        E[X²] = Var[X] + (E[X])²
    to combine two populations without accessing raw pixels.

    Args:
        r1, r2: Region dicts with keys 'n' (int), 'mean' (C-array), 'std' (C-array).

    Returns:
        New region dict with merged n, mean, std.
    """
    n1, n2 = r1["n"], r2["n"]
    n = n1 + n2
    mean = (n1 * r1["mean"] + n2 * r2["mean"]) / n
    # E[X²] for each region = var + mean²
    ex2 = (n1 * (r1["std"] ** 2 + r1["mean"] ** 2) +
           n2 * (r2["std"] ** 2 + r2["mean"] ** 2)) / n
    var = np.maximum(ex2 - mean ** 2, 0.0)  # clamp float errors
    return {"n": n, "mean": mean, "std": np.sqrt(var)}


def merging_cost(r1: dict, r2: dict, n_bands: int) -> float:
    """Spectral merging cost Q(r1, r2).

    Port of fGetMergingCost.m with w_spectral=1.0 (shape term dropped,
    as used in the thesis).

    Formula:
        Q = Σ_b { (1/n_bands) * (n_merged * σ_merged_b
                                  - n1 * σ1_b - n2 * σ2_b) }

    where σ is the standard deviation of pixel intensities per band.
    The formula measures the increase in total 'spread' when merging.

    Args:
        r1, r2: Region dicts.
        n_bands: Number of spectral bands.

    Returns:
        Scalar merging cost (non-negative for well-separated regions).
    """
    merged = merged_region_stats(r1, r2)
    band_weight = 1.0 / n_bands
    h_spec = float(np.sum(
        band_weight * (
            merged["n"] * merged["std"]
            - r1["n"] * r1["std"]
            - r2["n"] * r2["std"]
        )
    ))
    return h_spec


def build_rag(labels: np.ndarray, img: np.ndarray) -> dict:
    """Build Region Adjacency Graph from a label map and image.

    Port of fGetRAG.m + fGetAdjacentRegions.m.

    Finds 4-connected adjacent region pairs and computes merging costs.

    Args:
        labels: H×W int32 label map (1-based, sequential).
        img: H×W×C float64 image.

    Returns:
        RAG dict with keys:
            'regions': {label → {n, mean, std}}
            'edges':   {(lbl_a, lbl_b) → cost}  (lbl_a < lbl_b)
            'adj':     {label → set of neighbors}
    """
    img = np.asarray(img, dtype=np.float64)
    n_bands = img.shape[2]
    regions = {}

    for prop in regionprops(labels):
        lbl = prop.label
        idx = prop.coords  # N×2 [row, col]
        pixels = img[idx[:, 0], idx[:, 1]]  # N×C
        regions[lbl] = {
            "n": prop.area,
            "mean": pixels.mean(axis=0),
            "std": pixels.std(axis=0, ddof=0),
        }

    # Build adjacency by scanning 4-connectivity
    H, W = labels.shape
    adj: dict = {lbl: set() for lbl in regions}

    for r in range(H):
        for c in range(W):
            lbl = int(labels[r, c])
            if lbl == 0:
                continue
            for nr, nc in [(r, c + 1), (r + 1, c)]:
                if 0 <= nr < H and 0 <= nc < W:
                    nb = int(labels[nr, nc])
                    if nb != lbl and nb > 0:
                        adj[lbl].add(nb)
                        adj[nb].add(lbl)

    edges = {}
    for lbl, neighbors in adj.items():
        for nb in neighbors:
            key = _edge_key(lbl, nb)
            if key not in edges:
                edges[key] = merging_cost(regions[lbl], regions[nb], n_bands)

    return {"regions": regions, "edges": edges, "adj": adj}


def merge_regions(
    labels: np.ndarray, rag: dict, r1: int, r2: int
) -> tuple:
    """Merge region r2 into r1. r1 is the survivor.

    Port of the merge logic in fRegionMerge1.m / fUpdateEdges.m.

    Updates:
    - label map (all r2 pixels → r1)
    - r1 region stats (merged analytically)
    - adjacency (r2's neighbors become r1's neighbors)
    - edge costs (recomputed for all r1 edges after stats update)

    Args:
        labels: H×W int32 label map.
        rag: RAG dict (will be mutated — pass a copy if needed).
        r1: Survivor region label.
        r2: Absorbed region label.

    Returns:
        (updated_labels, updated_rag)
    """
    n_bands = rag["regions"][r1]["mean"].shape[0]
    regions = rag["regions"]
    adj = rag["adj"]
    edges = rag["edges"]

    # Update label map
    labels = labels.copy()
    labels[labels == r2] = r1

    # Update r1 stats using parallel formula
    regions[r1] = merged_region_stats(regions[r1], regions[r2])

    # Transfer r2's neighbors to r1 (skip r1 itself)
    for nb in list(adj.get(r2, [])):
        if nb == r1:
            continue
        adj[r1].add(nb)
        adj[nb].discard(r2)
        adj[nb].add(r1)

    # Remove r2's old edges
    for key in list(edges.keys()):
        if r2 in key:
            del edges[key]

    # Recompute all costs for r1's edges (stats changed)
    adj[r1].discard(r2)
    for nb in list(adj[r1]):
        key = _edge_key(r1, nb)
        edges[key] = merging_cost(regions[r1], regions[nb], n_bands)

    # Remove r2 from the graph
    del regions[r2]
    if r2 in adj:
        del adj[r2]

    return labels, {"regions": regions, "edges": edges, "adj": adj}
