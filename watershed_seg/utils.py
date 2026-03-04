"""Shared image padding utilities."""
import numpy as np


def mirror_pad(img: np.ndarray, pad: int) -> np.ndarray:
    """Pad image by mirroring, matching MATLAB fExtendImgByMirroring.

    Works for 2-D (H×W) and 3-D (H×W×C) arrays.
    """
    if img.ndim == 2:
        return np.pad(img, pad, mode="reflect")
    return np.pad(img, ((pad, pad), (pad, pad), (0, 0)), mode="reflect")


def strip_pad(img: np.ndarray, pad: int) -> np.ndarray:
    """Remove padding added by mirror_pad."""
    if img.ndim == 2:
        return img[pad:-pad, pad:-pad]
    return img[pad:-pad, pad:-pad, :]
