# Automatic Multi-Scale Segmentation of High Spatial Resolution Satellite Images

MSc thesis by Kerem Sahin (METU, January 2013).

This repository contains the original MATLAB implementation alongside a modern Python port (`watershed_seg`) of the full segmentation pipeline. The novel contribution is **RM3**, a cascaded two-stage region merging algorithm that outperforms prior art on both supervised and unsupervised metrics.

## Pipeline

```
Input image
    │
    ▼
1. Pre-filtering       EPSF* | PGF | Vectoral Median
    │
    ▼
2. Watershed input     H-Image* | MSGM
    │
    ▼
3. Watershed           Vincent-Soille* | Rainfalling
    │
    ▼
4. Region merging      RM3* (proposed) | RM1 | RM2
    │
    ▼
Segmented label map
```

`*` = thesis-selected combination

## Python Package

### Installation

```bash
pip install -e ".[dev]"
```

### Quick start

```python
import numpy as np
from watershed_seg import segment, evaluate

img = np.load("your_image.npy")  # H×W×C float64

result = segment(img)             # auto parameter selection
print(result.n_segments)

metrics = evaluate(result)
print(metrics["psnr"], metrics["morans_i"])
```

### Pipeline with explicit parameters

```python
from watershed_seg import Pipeline, evaluate

p = Pipeline(
    prefilter="epsf",
    ws_input="h_image",
    merging="rm3",
    rm1_threshold=20,
    rm2_threshold=500,
)
result = p.run(img)
metrics = evaluate(result, ground_truth=gt_labels)  # optional
print(metrics["E1"], metrics["E2"])
```

### Public API

| Symbol | Description |
|--------|-------------|
| `Pipeline` | Full pipeline with configurable stages |
| `segment(img, auto_params=True)` | One-call convenience wrapper |
| `evaluate(result, ground_truth=None)` | Unsupervised + optional supervised metrics |
| `watershed_seg.filters` | `epsf`, `pgf`, `vectoral_median` |
| `watershed_seg.watershed_input` | `h_image`, `msgm` |
| `watershed_seg.watershed` | `vincent_soille`, `rainfalling` |
| `watershed_seg.merging` | `rm1`, `rm2`, `rm3` |
| `watershed_seg.evaluation` | `morans_i`, `intra_variance`, `goodness2`, `psnr`, `simplified_image` |
| `watershed_seg.auto_params` | `auto_select_rm1_threshold`, `auto_select_rm2_threshold`, etc. |

## Notebooks

| Notebook | Description |
|----------|-------------|
| `notebooks/01_pipeline_walkthrough.ipynb` | End-to-end demo of each pipeline stage |
| `notebooks/02_algorithm_comparison.ipynb` | Side-by-side comparison of all algorithm variants |
| `notebooks/03_auto_parameter_selection.ipynb` | G2 sweep curve and auto vs. manual threshold |

## Tests

```bash
pytest tests/ -v   # 77 tests
```

## Repository Structure

```
matlab/          Original MATLAB source (51 .m files + GUI)
watershed_seg/   Python package
tests/           pytest suite
notebooks/       Jupyter demo notebooks
docs/plans/      Design and implementation plan documents
```

## Reference

Sahin, K. (2013). *Automatic Multi-Scale Segmentation of High Spatial Resolution Satellite Images Using Watersheds*. MSc Thesis, Middle East Technical University.
