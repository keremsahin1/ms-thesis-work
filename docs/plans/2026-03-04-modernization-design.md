# Modernization Design: watershed_seg Python Package

**Date:** 2026-03-04
**Project:** ms-thesis-work — Automatic Multi-Scale Segmentation of High Spatial Resolution Satellite Images Using Watersheds (Kerem Sahin, METU 2013)

---

## Goal

Port the MATLAB thesis codebase to an installable Python library targeting researchers and academics in remote sensing and computer vision. The result should be reproducible, citable, and easy to extend.

## Approach

**Approach A — Layered Python package with scikit-image integration.**

Port each algorithm to Python, replacing bespoke helpers with `scikit-image` / `scipy` equivalents where they exist. Custom Python is used for algorithms with no ecosystem equivalent (EPSF, H-image, RM1/RM2/RM3, Moran's I). The full pipeline — pre-filter → watershed input → watershed → multi-scale merging → evaluation + auto-parameter selection — is included.

---

## Repository Structure

```
ms-thesis-work/
├── matlab/                         # original MATLAB source (reference only)
│   ├── OOLCC.m
│   ├── OOLCC.fig
│   └── f*.m  (all helper functions)
├── watershed_seg/                  # installable Python package
│   ├── __init__.py                 # public API: segment(), evaluate(), Pipeline
│   ├── filters.py                  # EPSF, PGF, vectoral median
│   ├── watershed_input.py          # H-image, MSGM, Jung, KimKim projections
│   ├── watershed.py                # Vincent-Soille (skimage), Rainfalling (custom)
│   ├── merging.py                  # RM1, RM2, RM3 (proposed cascade)
│   ├── rag.py                      # RAG build, merging cost, edge update
│   ├── evaluation.py               # E1/E2, Moran's I, G2, PSNR, Goodness
│   ├── auto_params.py              # G2-based parameter sweep
│   └── ground_truth.py             # GT label conversion utilities
├── notebooks/
│   ├── 01_pipeline_walkthrough.ipynb
│   ├── 02_algorithm_comparison.ipynb
│   └── 03_auto_parameter_selection.ipynb
├── tests/
│   ├── test_filters.py
│   ├── test_watershed_input.py
│   ├── test_watershed.py
│   ├── test_merging.py
│   ├── test_rag.py
│   └── test_evaluation.py
├── data/                           # gitignored — 20 satellite images
├── docs/plans/
│   └── 2026-03-04-modernization-design.md
├── pyproject.toml
└── CLAUDE.md
```

---

## Public API

### High-level (one-liner with auto-params)

```python
from watershed_seg import segment, evaluate

img = np.load("image1.npy")          # H×W×C float array, values 0–1
result = segment(img)                 # auto-selects params via G2 sweep
print(result.labels)                  # H×W int32 label map
print(result.n_segments)
```

### Fine-grained control via Pipeline

```python
from watershed_seg import Pipeline

p = Pipeline(
    prefilter="epsf",          prefilter_w=5,
    ws_input="h_image",        ws_input_w=7,
    watershed="vincent_soille",
    merging="rm3",             rm1_threshold=100,  rm2_threshold=3000,
)
result = p.run(img)
metrics = evaluate(result, ground_truth=gt_labels)   # returns E1, E2
```

`segment()` is equivalent to `Pipeline(...defaults...).run(img)` with auto-param selection enabled.

Each pipeline stage is also callable directly for notebook-level exploration:

```python
from watershed_seg.filters import epsf
from watershed_seg.watershed_input import h_image
from watershed_seg.merging import rm3
```

---

## Algorithm Mapping

| Stage | MATLAB source | Python implementation |
|---|---|---|
| EPSF pre-filter | `fEdgePreservedSmoothingFilter.m` | Custom NumPy |
| PGF pre-filter | `fPeerGroupFiltering.m` | Custom NumPy |
| Vectoral median filter | `fVectoralMedianFilter.m` | Custom NumPy |
| H-image | `fGetHImg.m` | Custom NumPy (vectorized window ops) |
| MSGM (Sobel) | `fGetGradMagIm.m` | `skimage.filters.sobel` per channel, summed |
| Jung projection | `fProjectImByJung.m` | Custom Python port |
| Kim & Kim projection | `fProjectImByKimKim.m` | Custom Python port |
| Vincent-Soille watershed | `fVincentSoilleWatershed.m` | `skimage.segmentation.watershed` |
| Rainfalling watershed | `fRainfallingWatershed.m` | Custom Python port |
| RAG construction | `fGetRAG.m` | `skimage.future.graph.RAG` (extended) |
| RM1 — size merging | `fRegionMerge1.m` | Custom Python using RAG |
| RM2 — heterogeneity merging | `fRegionMerge2.m` | Custom Python using RAG |
| RM3 — proposed cascade | `fRegionMerge_Proposed.m` | Custom Python using RAG |
| Moran's I + variance | `fFindVariance_MoransI_New.m` | Custom NumPy |
| E₁/E₂ supervised eval | `fSegDiscrepEval.m` | Custom NumPy |
| PSNR / Goodness | `fFindSegmentationAccuracy.m` | Custom NumPy |
| Auto-param selection | `fAutomatic*.m` | Grid search loop over G2 |
| GT conversion | `fGT2ClassLabel.m` / `fConvertClassLabels2SegLabels.m` | `ground_truth.py` |

**Key dependencies:** `numpy`, `scipy`, `scikit-image`, `matplotlib`, `jupyter`, `pytest`

---

## Testing Strategy

- **Unit tests** (pytest) per module: validate output shape, dtype, value range
- **Regression test** for RM3: run on a small synthetic label map with a known merge sequence, assert expected final label map
- **Evaluation sanity**: E₁=0 and E₂=1 when segmentation exactly matches ground truth
- No bit-exact MATLAB parity (numerical differences from scikit-image internals are acceptable)

---

## Notebooks

| Notebook | Purpose |
|---|---|
| `01_pipeline_walkthrough.ipynb` | End-to-end run on one image; visualize each stage |
| `02_algorithm_comparison.ipynb` | Compare all pre-filters / watershed inputs / merging methods |
| `03_auto_parameter_selection.ipynb` | G2 sweep curves; auto vs. manual param comparison |

---

## Out of Scope

- GUI (OOLCC.m is not ported — Python library is the interface)
- Real-time performance optimization (Numba can be added later without API changes)
- Word/figure export (`save2word.m`, `SaveAllFigures.m`)
- Bit-exact numerical parity with MATLAB outputs
