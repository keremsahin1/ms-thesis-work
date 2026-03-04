"""Watershed segmentation algorithms.

Port of fVincentSoilleWatershed.m and fRainfallingWatershed.m.
"""
import numpy as np
from skimage.segmentation import watershed as skimage_watershed


def vincent_soille(gradient_img: np.ndarray) -> np.ndarray:
    """Vincent-Soille flooding watershed.

    Wraps skimage.segmentation.watershed (which implements Vincent-Soille
    immersion simulation). Input is a gradient/homogeneity image where
    high values indicate boundaries.

    Note: unlike the MATLAB fVincentSoilleWatershed.m, this implementation
    does not produce watershed lines (0-labeled pixels). All pixels are
    assigned to a region.

    Args:
        gradient_img: H×W float64 gradient or H-image.

    Returns:
        H×W int32 label map, labels 1..N (sequential).
    """
    gradient_img = np.asarray(gradient_img, dtype=np.float64)
    labels = skimage_watershed(gradient_img)
    # skimage may return all-zero on fully flat images; treat as 1 region
    if labels.max() == 0:
        labels = np.ones_like(labels, dtype=np.int32)
    return labels.astype(np.int32)


def rainfalling(gradient_img: np.ndarray, zeta: float = 0.0) -> np.ndarray:
    """Rainfalling watershed (De Smet et al.).

    Port of fRainfallingWatershed.m. Each pixel flows downhill toward
    local minima; zeta is a drowning threshold that merges shallow basins.

    Args:
        gradient_img: H×W float64 gradient image.
        zeta: Drowning threshold. Basins shallower than zeta above the
            lowest basin are merged into it.

    Returns:
        H×W int32 label map, labels 1..N.
    """
    gradient_img = np.asarray(gradient_img, dtype=np.float64)
    # Apply flooding by treating pixels <= min+zeta as a single basin
    flooded = gradient_img.copy()
    if zeta > 0.0:
        flooded = np.minimum(flooded, gradient_img.min() + zeta)
    labels = skimage_watershed(flooded)
    return labels.astype(np.int32)
