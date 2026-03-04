"""Pre-filtering stage: EPSF, PGF, vectoral median.

Port of fEdgePreservedSmoothingFilter.m, fPeerGroupFiltering.m,
and fVectoralMedianFilter.m.
"""
import numpy as np
from .utils import mirror_pad


def epsf(
    img: np.ndarray,
    w: int = 5,
    p: float = 2.0,
    n_iter: int = 1,
) -> np.ndarray:
    """Edge-Preserved Smoothing Filter (EPSF).

    Port of fEdgePreservedSmoothingFilter.m.

    Uses Manhattan (L1) spectral distance between each window pixel and
    the center pixel. Weight c_i = (1 - d_i)^p where d_i = L1_dist /
    (n_bands * 255). Center pixel has c_i = 1 (thesis modification —
    original MATLAB comment says "center should be 0" but that line is
    commented out, so center is included with full weight).

    Args:
        img: H×W×C float64 array in [0, 255].
        w: Window size (odd integer).
        p: Power parameter controlling sharpness of the weight function.
        n_iter: Number of filter iterations.

    Returns:
        Filtered image, same shape and dtype as img.
    """
    img = np.asarray(img, dtype=np.float64)
    n_bands = img.shape[2]
    max_val = 255.0
    r = w // 2

    for _ in range(n_iter):
        padded = mirror_pad(img, r)
        H, W = img.shape[:2]
        weighted_sum = np.zeros_like(img)
        weight_total = np.zeros((H, W))

        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                neighbor = padded[r + dy: r + dy + H, r + dx: r + dx + W]
                if dy == 0 and dx == 0:
                    c_i = np.ones((H, W))  # center coeff = 1 (thesis mod)
                else:
                    l1 = np.sum(np.abs(neighbor - img), axis=2)
                    d_i = l1 / (n_bands * max_val)
                    c_i = np.clip((1.0 - d_i) ** p, 0.0, None)

                weighted_sum += c_i[..., None] * neighbor
                weight_total += c_i

        img = weighted_sum / weight_total[..., None]

    return img


def pgf(img: np.ndarray, w: int = 5, tau: float = 30.0) -> np.ndarray:
    """Peer Group Filter (PGF).

    Port of fPeerGroupFiltering.m.

    For each pixel, averages window pixels within L1 spectral distance tau
    of the center. Center pixel excluded (coefficient 0, unlike EPSF).

    Args:
        img: H×W×C float64 array in [0, 255].
        w: Window size (odd integer).
        tau: Spectral distance threshold for peer membership.

    Returns:
        Filtered image, same shape as img.
    """
    img = np.asarray(img, dtype=np.float64)
    r = w // 2
    padded = mirror_pad(img, r)
    H, W = img.shape[:2]

    peer_sum = np.zeros_like(img)
    peer_count = np.zeros((H, W))

    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dy == 0 and dx == 0:
                continue  # center coeff = 0
            neighbor = padded[r + dy: r + dy + H, r + dx: r + dx + W]
            l1 = np.sum(np.abs(neighbor - img), axis=2)
            is_peer = l1 <= tau
            peer_sum += is_peer[..., None] * neighbor
            peer_count += is_peer

    # Pixels with no peers keep their original value
    result = np.where(
        peer_count[..., None] > 0,
        peer_sum / np.maximum(peer_count[..., None], 1),
        img,
    )
    return result


def vectoral_median(img: np.ndarray, w: int = 3) -> np.ndarray:
    """Vectoral Median Filter.

    Port of fVectoralMedianFilter.m.

    For each window, selects the pixel that minimises the sum of L2
    spectral distances to all other pixels in the window.

    Args:
        img: H×W×C float64 array.
        w: Window size (odd integer).

    Returns:
        Filtered image, same shape as img.
    """
    img = np.asarray(img, dtype=np.float64)
    r = w // 2
    padded = mirror_pad(img, r)
    H, W = img.shape[:2]

    # Collect all window pixels: shape (H, W, w*w, C)
    patches = np.stack(
        [
            padded[r + dy: r + dy + H, r + dx: r + dx + W]
            for dy in range(-r, r + 1)
            for dx in range(-r, r + 1)
        ],
        axis=2,
    )  # H×W×(w²)×C

    # Pairwise L2 distances between all window pixels: (H, W, w², w²)
    diff = patches[:, :, :, None, :] - patches[:, :, None, :, :]
    dists = np.sqrt(np.sum(diff ** 2, axis=-1))
    total_dist = dists.sum(axis=-1)  # H×W×(w²)

    # Pick pixel with minimum total distance
    min_idx = total_dist.argmin(axis=2)  # H×W
    rows, cols = np.meshgrid(np.arange(H), np.arange(W), indexing="ij")
    return patches[rows, cols, min_idx]
