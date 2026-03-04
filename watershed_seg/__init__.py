"""watershed_seg: Automatic multi-scale segmentation of satellite images.

Usage:
    from watershed_seg import Pipeline, segment, evaluate
"""
from .pipeline import Pipeline, segment, evaluate

__all__ = ["Pipeline", "segment", "evaluate"]
