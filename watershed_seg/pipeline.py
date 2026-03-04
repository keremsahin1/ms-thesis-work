"""High-level Pipeline API.

Orchestrates the four segmentation stages:
    pre-filter → watershed input → watershed → region merging

Thesis-selected defaults:
    EPSF (w=5) → H-image (w=7) → Vincent-Soille → RM3
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional

import numpy as np

from .filters import epsf, pgf, vectoral_median
from .watershed_input import h_image, msgm
from .watershed import vincent_soille, rainfalling
from .merging import rm1, rm2, rm3


@dataclass
class SegmentationResult:
    """Output of Pipeline.run()."""

    labels: np.ndarray         # H×W int32 label map (1-based)
    n_segments: int
    filtered_img: np.ndarray   # image after pre-filter
    gradient_img: np.ndarray   # H-image or MSGM gradient
    watershed_labels: np.ndarray  # labels before region merging
    params: dict = field(default_factory=dict)


class Pipeline:
    """Configurable four-stage segmentation pipeline.

    Args:
        prefilter: 'epsf' | 'pgf' | 'vectoral_median' | None
        prefilter_w: Pre-filter window size (odd int).
        ws_input: 'h_image' | 'msgm'
        ws_input_w: Watershed input window size (H-image only).
        watershed: 'vincent_soille' | 'rainfalling'
        merging: 'rm3' | 'rm1' | 'rm2'
        rm1_threshold: Size threshold for RM1 (pixels).
        rm2_threshold: Heterogeneity cost threshold for RM2.
    """

    def __init__(
        self,
        prefilter: Optional[str] = "epsf",
        prefilter_w: int = 5,
        ws_input: str = "h_image",
        ws_input_w: int = 7,
        watershed: str = "vincent_soille",
        merging: str = "rm3",
        rm1_threshold: int = 100,
        rm2_threshold: float = 3000.0,
    ):
        self.prefilter = prefilter
        self.prefilter_w = prefilter_w
        self.ws_input = ws_input
        self.ws_input_w = ws_input_w
        self.watershed = watershed
        self.merging = merging
        self.rm1_threshold = rm1_threshold
        self.rm2_threshold = rm2_threshold

    def run(
        self, img: np.ndarray, auto_params: bool = False
    ) -> SegmentationResult:
        """Run the full pipeline on an image.

        Args:
            img: H×W×C float64 array in [0, 255].
            auto_params: If True, use G2-based automatic parameter selection
                for merging thresholds (slow — sweeps a parameter range).

        Returns:
            SegmentationResult with label map and all intermediates.
        """
        img = np.asarray(img, dtype=np.float64)

        # Stage 1: Pre-filtering
        if self.prefilter == "epsf":
            filtered = epsf(img, w=self.prefilter_w)
        elif self.prefilter == "pgf":
            filtered = pgf(img, w=self.prefilter_w)
        elif self.prefilter == "vectoral_median":
            filtered = vectoral_median(img, w=self.prefilter_w)
        else:
            filtered = img.copy()

        # Stage 2: Watershed input
        if self.ws_input == "h_image":
            gradient = h_image(filtered, w=self.ws_input_w)
        else:
            gradient = msgm(filtered)

        # Stage 3: Watershed
        if self.watershed == "vincent_soille":
            ws_labels = vincent_soille(gradient)
        else:
            ws_labels = rainfalling(gradient)

        # Stage 4: Region merging
        rm1_t = self.rm1_threshold
        rm2_t = self.rm2_threshold

        if auto_params:
            from .auto_params import (
                auto_select_rm1_threshold, auto_select_rm2_threshold
            )
            rm1_t = auto_select_rm1_threshold(ws_labels, img)
            rm2_t = auto_select_rm2_threshold(ws_labels, img)

        if self.merging == "rm3":
            final_labels = rm3(ws_labels, img, rm1_t, rm2_t)
        elif self.merging == "rm1":
            final_labels = rm1(ws_labels, img, rm1_t)
        else:
            final_labels = rm2(ws_labels, img, rm2_t)

        return SegmentationResult(
            labels=final_labels,
            n_segments=int(final_labels.max()),
            filtered_img=filtered,
            gradient_img=gradient,
            watershed_labels=ws_labels,
            params={
                "prefilter": self.prefilter,
                "prefilter_w": self.prefilter_w,
                "ws_input": self.ws_input,
                "ws_input_w": self.ws_input_w,
                "watershed": self.watershed,
                "merging": self.merging,
                "rm1_threshold": rm1_t,
                "rm2_threshold": rm2_t,
            },
        )


def segment(
    img: np.ndarray,
    auto_params: bool = True,
    **pipeline_kwargs,
) -> SegmentationResult:
    """Convenience function: run Pipeline with thesis-selected defaults.

    Args:
        img: H×W×C float64 array in [0, 255].
        auto_params: Use G2-based auto parameter selection (default True).
        **pipeline_kwargs: Forwarded to Pipeline constructor.

    Returns:
        SegmentationResult.
    """
    return Pipeline(**pipeline_kwargs).run(img, auto_params=auto_params)


def evaluate(
    result: SegmentationResult,
    ground_truth: Optional[np.ndarray] = None,
) -> dict:
    """Evaluate a segmentation result.

    If ground_truth is provided, returns supervised metrics (E1, E2).
    Otherwise returns unsupervised metrics (Moran's I, variance, PSNR).

    Args:
        result: SegmentationResult from Pipeline.run().
        ground_truth: Optional H×W int32 class label map.

    Returns:
        Dict with metric names as keys.
    """
    from .evaluation import (
        supervised_eval, morans_i, intra_variance, psnr, simplified_image
    )

    if ground_truth is not None:
        e1, e2 = supervised_eval(ground_truth, result.labels)
        return {"E1": e1, "E2": e2}

    mi = morans_i(result.labels, result.filtered_img)
    var = intra_variance(result.labels, result.filtered_img)
    simp = simplified_image(result.labels, result.filtered_img)
    ps = psnr(result.filtered_img, simp)
    return {"morans_i": mi, "variance": var, "psnr": ps}
