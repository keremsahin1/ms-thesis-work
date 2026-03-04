"""Watershed input generation: H-image and MSGM.

Port of fGetHImg.m and fGetGradMagIm.m.
"""
import numpy as np
from skimage.filters import sobel
from .utils import mirror_pad


def h_image(img: np.ndarray, w: int = 7) -> np.ndarray:
    """Homogeneity image (H-image).

    Port of fGetHImg.m.

    For each pixel, sums spectral-direction vectors from all window pixels
    toward the center. High value = heterogeneous (boundary); low value =
    homogeneous (interior).

    Per-band formula:
        H_band(r,c) = sqrt( (Σ_{i,j} diff(i,j) * hor_weight(i,j))²
                           + (Σ_{i,j} diff(i,j) * ver_weight(i,j))² )

    where hor_weight = (j - center_j) / dist(i,j) and diff = neighbor - center.

    Final multi-band: H = sqrt(Σ_b H_band²)

    Args:
        img: H×W×C float64 array.
        w: Window size (odd integer, thesis uses 7).

    Returns:
        H×W float64 H-image.
    """
    img = np.asarray(img, dtype=np.float64)
    H, W, C = img.shape
    r = w // 2

    # Precompute direction weights (same for every spatial position)
    rows_off = np.arange(w) - r
    cols_off = np.arange(w) - r
    RR, CC = np.meshgrid(rows_off, cols_off, indexing="ij")  # w×w
    dist = np.sqrt(RR ** 2 + CC ** 2)
    dist[r, r] = 1.0  # avoid div-by-zero at center (zeroed below)
    hor_mask = CC / dist  # horizontal (col) direction component
    ver_mask = RR / dist  # vertical (row) direction component
    hor_mask[r, r] = 0.0
    ver_mask[r, r] = 0.0

    padded = mirror_pad(img, r)

    # Accumulate horizontal and vertical spectral sums per band
    h_hor = np.zeros((H, W, C))
    h_ver = np.zeros((H, W, C))

    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            hw = hor_mask[r + dy, r + dx]
            vw = ver_mask[r + dy, r + dx]
            if hw == 0.0 and vw == 0.0:
                continue  # skip center pixel
            neighbor = padded[r + dy: r + dy + H, r + dx: r + dx + W]
            diff = neighbor - img  # H×W×C
            h_hor += diff * hw
            h_ver += diff * vw

    # H_band = magnitude of the 2-D sum vector, per band
    h_per_band = np.sqrt(h_hor ** 2 + h_ver ** 2)  # H×W×C

    # Final: L2 norm across bands
    return np.sqrt(np.sum(h_per_band ** 2, axis=2))


def msgm(img: np.ndarray) -> np.ndarray:
    """Multi-Spectral Gradient Magnitude (MSGM) via Sobel.

    Port of fGetGradMagIm.m. Sums per-band Sobel gradient magnitudes.

    Args:
        img: H×W×C float64 array.

    Returns:
        H×W float64 gradient magnitude image.
    """
    img = np.asarray(img, dtype=np.float64)
    result = np.zeros(img.shape[:2])
    for b in range(img.shape[2]):
        result += sobel(img[:, :, b])
    return result
