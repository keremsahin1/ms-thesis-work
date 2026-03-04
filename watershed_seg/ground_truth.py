"""Ground truth label conversion utilities.

Port of fGT2ClassLabel.m and fConvertClassLabels2SegLabels.m.
"""
import numpy as np
from skimage.measure import label as connected_components


def class_labels_to_seg_labels(class_map: np.ndarray) -> np.ndarray:
    """Convert a class label map to per-segment labels.

    Port of fGT2ClassLabel + fConvertClassLabels2SegLabels.

    Each spatially connected component within a single class becomes a
    separate segment. Background (class 0) stays 0.

    Args:
        class_map: H×W int array of class labels (0 = background).

    Returns:
        H×W int32 segment label map (1..N, 0 = background).
    """
    class_map = np.asarray(class_map, dtype=np.int32)
    seg_labels = np.zeros_like(class_map)
    seg_count = 0

    for cls in np.unique(class_map):
        if cls == 0:
            continue
        mask = class_map == cls
        components = connected_components(mask, connectivity=2)
        n_comp = int(components.max())
        seg_labels[mask] = components[mask] + seg_count
        seg_count += n_comp

    return seg_labels.astype(np.int32)
