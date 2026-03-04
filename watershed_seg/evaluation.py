"""Segmentation evaluation metrics.

Supervised:   E1 (global pixel error), E2 (per-segment error)
Unsupervised: Moran's I, intra-segment variance, G2 goodness, PSNR

Port of fSegDiscrepEval.m, fFindVariance_MoransI_New.m,
fGetGoodness2.m, fFindSegmentationAccuracy.m.
"""
import numpy as np
from skimage.measure import regionprops

from .ground_truth import class_labels_to_seg_labels


# ---------------------------------------------------------------------------
# Supervised
# ---------------------------------------------------------------------------

def supervised_eval(
    gt_class_map: np.ndarray, found_labels: np.ndarray
) -> tuple:
    """Compute E1 (global pixel error %) and E2 (per-segment error %).

    Port of fSegDiscrepEval.m.

    Each found segment is assigned to the modal GT segment label. Then
    E1 = off-diagonal / total confusion matrix entries.
    E2 = mean of per-GT-segment wrong-pixel fractions.

    Args:
        gt_class_map: H×W int32 class label map (ground truth classes).
        found_labels: H×W int32 segmentation label map.

    Returns:
        (E1, E2) as percentages in [0, 100].
    """
    gt_class_map = np.asarray(gt_class_map, dtype=np.int32)
    found_labels = np.asarray(found_labels, dtype=np.int32)

    gt_seg = class_labels_to_seg_labels(gt_class_map)
    n_gt_segs = int(gt_seg.max())

    # Assign each found segment to its modal GT segment
    updated_found = np.zeros_like(found_labels)
    for prop in regionprops(found_labels):
        idx = prop.coords
        gt_vals = gt_seg[idx[:, 0], idx[:, 1]]
        gt_vals = gt_vals[gt_vals > 0]
        if len(gt_vals) == 0:
            continue
        modal_gt = int(np.bincount(gt_vals).argmax())
        updated_found[idx[:, 0], idx[:, 1]] = modal_gt

    # Confusion matrix: conf[found_id-1, gt_id-1]
    conf = np.zeros((n_gt_segs, n_gt_segs), dtype=np.int64)
    for gt_seg_id in range(1, n_gt_segs + 1):
        gt_mask = gt_seg == gt_seg_id
        found_in_gt = updated_found[gt_mask]
        for found_id in range(1, n_gt_segs + 1):
            conf[found_id - 1, gt_seg_id - 1] = int(
                np.sum(found_in_gt == found_id)
            )

    total = int(conf.sum())
    diag = int(np.trace(conf))
    e1 = float((total - diag) / total * 100) if total > 0 else 0.0

    e2_sum = 0.0
    for gt_seg_id in range(1, n_gt_segs + 1):
        col = conf[:, gt_seg_id - 1]
        ref_area = int(col.sum())
        if ref_area > 0:
            wrong = ref_area - int(conf[gt_seg_id - 1, gt_seg_id - 1])
            e2_sum += wrong * 100.0 / ref_area
    e2 = e2_sum / n_gt_segs if n_gt_segs > 0 else 0.0

    return e1, e2


# ---------------------------------------------------------------------------
# Unsupervised
# ---------------------------------------------------------------------------

def morans_i(labels: np.ndarray, img: np.ndarray) -> np.ndarray:
    """Moran's I spatial autocorrelation, one value per band.

    Port of fFindVariance_MoransI_New.m (Moran's I part).

    High I → adjacent segments have similar means (poor separation).
    Low I → adjacent segments are spectrally distinct (good separation).

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.

    Returns:
        C-element float64 array — one Moran's I value per band.
    """
    img = np.asarray(img, dtype=np.float64)
    n_bands = img.shape[2]
    n_segs = int(labels.max())

    if n_segs == 0:
        return np.zeros(n_bands)

    # Compute per-segment means
    seg_means = np.zeros((n_segs, n_bands))
    for prop in regionprops(labels):
        idx = prop.coords
        seg_means[prop.label - 1] = img[idx[:, 0], idx[:, 1]].mean(axis=0)

    # Find adjacent pairs (4-connectivity between segments)
    H, W = labels.shape
    adj_pairs: set = set()
    for r in range(H):
        for c in range(W):
            lbl = int(labels[r, c])
            for nr, nc in [(r, c + 1), (r + 1, c)]:
                if 0 <= nr < H and 0 <= nc < W:
                    nb = int(labels[nr, nc])
                    if nb != lbl and nb > 0 and lbl > 0:
                        adj_pairs.add((min(lbl - 1, nb - 1),
                                       max(lbl - 1, nb - 1)))

    results = np.zeros(n_bands)
    n = n_segs
    w_sum = len(adj_pairs) * 2  # symmetric pairs
    if w_sum == 0:
        return results

    for b in range(n_bands):
        x = seg_means[:, b]
        x_bar = x.mean()
        dev = x - x_bar
        dev_sq_sum = float(dev @ dev)
        if dev_sq_sum == 0.0:
            continue
        cross = sum(dev[i] * dev[j] for i, j in adj_pairs) * 2
        results[b] = (n * cross) / (w_sum * dev_sq_sum)

    return results


def intra_variance(labels: np.ndarray, img: np.ndarray) -> np.ndarray:
    """Area-weighted intra-segment variance, one value per band.

    Port of fFindVariance_MoransI_New.m (variance part).

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.

    Returns:
        C-element float64 array of variance values per band.
    """
    img = np.asarray(img, dtype=np.float64)
    n_bands = img.shape[2]
    total_pixels = labels.size
    var_sum = np.zeros(n_bands)

    for prop in regionprops(labels):
        idx = prop.coords
        pixels = img[idx[:, 0], idx[:, 1]]
        var_sum += prop.area * pixels.var(axis=0, ddof=0)

    return var_sum / total_pixels


def goodness2(
    all_morans_i: np.ndarray, all_variance: np.ndarray
) -> np.ndarray:
    """G2 goodness metric for automatic parameter selection.

    Port of fGetGoodness2.m.

    Normalises Moran's I and variance arrays each to [0,1] within the
    sweep, sums them per band, then averages across bands.
    Lower G2 = better segmentation balance.

    Args:
        all_morans_i: C×S array — Moran's I per band (C) per sweep step (S).
        all_variance: C×S array — intra-variance per band per sweep step.

    Returns:
        S-element float64 array of G2 values.
    """
    def _norm(arr):
        lo = arr.min(axis=1, keepdims=True)
        hi = arr.max(axis=1, keepdims=True)
        denom = np.where(hi - lo > 0, hi - lo, 1.0)
        return (arr - lo) / denom

    mi = np.asarray(all_morans_i, dtype=np.float64)
    var = np.asarray(all_variance, dtype=np.float64)
    g2 = (_norm(mi) + _norm(var)).mean(axis=0)
    return g2


# ---------------------------------------------------------------------------
# Image reconstruction metrics
# ---------------------------------------------------------------------------

def simplified_image(labels: np.ndarray, img: np.ndarray) -> np.ndarray:
    """Replace each region with its mean colour.

    Port of fSimplifyImage.m / fGetSegmentedImg.m.

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.

    Returns:
        H×W×C float64 image where every pixel has its region's mean.
    """
    img = np.asarray(img, dtype=np.float64)
    out = np.zeros_like(img)
    for prop in regionprops(labels):
        idx = prop.coords
        mean_colour = img[idx[:, 0], idx[:, 1]].mean(axis=0)
        out[idx[:, 0], idx[:, 1]] = mean_colour
    return out


def psnr(
    img: np.ndarray, reconstructed: np.ndarray, max_val: float = 255.0
) -> float:
    """Peak Signal-to-Noise Ratio in dB.

    Port of fFindSegmentationAccuracy.m (PSNR part).

    Args:
        img: H×W×C original image.
        reconstructed: H×W×C reconstructed (simplified) image.
        max_val: Maximum pixel value (default 255).

    Returns:
        PSNR in dB. Returns inf if images are identical.
    """
    mse = float(np.mean((img - reconstructed) ** 2))
    if mse == 0.0:
        return float("inf")
    return 10.0 * np.log10(max_val ** 2 / mse)
