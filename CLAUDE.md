# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MSc thesis (METU, January 2013) by Kerem Sahin: **"Automatic Multi-Scale Segmentation of High Spatial Resolution Satellite Images Using Watersheds"**. The codebase implements and compares a full image segmentation pipeline for high-resolution satellite imagery (Google Earth / GeoEye-1). The novel contribution is a cascaded two-stage region merging algorithm (RM3) that outperforms prior art on both supervised and unsupervised metrics.

The main application (`OOLCC.m`) is a MATLAB GUIDE-based GUI that orchestrates the complete pipeline.

## Running the Application

Pure MATLAB project — no build system. To run:

1. Open MATLAB, `cd` to this repository directory
2. Run `OOLCC` in the MATLAB command window to launch the GUI

All `.m` files must be on the MATLAB path. Individual functions can be called directly from the MATLAB command window for testing.

## Segmentation Pipeline

Four sequential stages — each stage has multiple competing implementations that the GUI lets you compare:

```
Input image
    │
    ▼
1. Pre-filtering          (smooth / denoise while preserving edges)
    │
    ▼
2. Watershed input         (convert filtered image into a gradient/homogeneity map)
    │
    ▼
3. Watershed algorithm     (produce initial over-segmented label map)
    │
    ▼
4. Multi-scale merging     (merge over-segmented regions → final segmentation)
    │
    ▼
Evaluation / export
```

**Selected combination in the thesis:**
EPSF pre-filter → H-Image input → Vincent-Soille watershed → Proposed RM3 merging

## Algorithms Implemented

### Pre-filters
| File | Algorithm | Key param |
|------|-----------|-----------|
| `fEdgePreservedSmoothingFilter.m` | EPSF (**selected**) — center coeff set to 1 (modification for satellite data) | window size w, σ=10 fixed |
| `fPeerGroupFiltering.m` | Peer Group Filter (PGF) | window size w, impulse threshold τ |
| `fVectoralMedianFilter.m` | Vectoral Median Filter | — |

### Watershed input generation
| File | Algorithm | Key param |
|------|-----------|-----------|
| `fGetHImg.m` | H-Image (**selected**) — window homogeneity; multispectral: H=H₁+H₂+…+Hₙ | window size w (3–15) |
| `fGetGradMagIm.m` | Multi-Spectral Gradient Magnitude (MSGM) via Sobel | — |
| `fProjectImByJung.m` | Jung's Haar wavelet projection | scale s |
| `fProjectImByKimKim.m` | Kim & Kim's wavelet projection + marker-controlled watershed | scale s |

### Watershed algorithms
| File | Algorithm | Notes |
|------|-----------|-------|
| `fVincentSoilleWatershed.m` | Vincent-Soille flooding (**selected**) | Better accuracy + boundary preservation |
| `fRainfallingWatershed.m` | Fast Rainfalling (De Smet et al.) | Fewer segments but poor boundaries |

### Multi-scale segmentation (region merging)
| File | Algorithm | Stopping criterion |
|------|-----------|-------------------|
| `fRegionMerge_Proposed.m` | **RM3 — Proposed** (RM1 → RM2 cascade) | Size threshold s_t1, then heterogeneity threshold s_t2 |
| `fRegionMerge1.m` | RM1 — size-based merging | min segment area ≤ s_t (10–5000 px) |
| `fRegionMerge2.m` | RM2 — heterogeneity-based merging | min merging cost ≥ s_t (50–50000) |

**RM3 (the novel contribution):** Runs RM1 first to eliminate noise-like micro-segments, then runs RM2 to merge perceptually similar regions. This gives better balance between over-segmentation reduction and accuracy, at lower cost than RM2 alone.

### Merging cost formula (used by all RM variants)
```
Q = w_spectral × h_spectral + (1 − w_spectral) × h_shape

h_spectral = Σ_b { w_b × (2σ_merged,b − σ_1,b − σ_2,b) }
h_shape    = w_compact × h_compactness + (1−w_compact) × h_smoothness
```
In practice `w_spectral = 1.0` (structural term had negligible effect and was dropped).

## Region Adjacency Graph (RAG)

All region merging algorithms share a RAG-based backbone:

- **`fGetRAG.m`** — builds the graph; nodes = label regions, edges = merging costs between adjacent pairs
- **`fGetAdjacentRegions.m`** — find all adjacent region pairs
- **`fGetMergingCost.m`** — compute Q (above) for a candidate merge
- **`fUpdateEdges.m`** — re-compute edges after a merge (neighbours of merged regions inherit new costs)
- **`fMergeSameLabelledRegs.m`** / **`fRenumberLabels.m`** — post-merge label cleanup

## Evaluation

### Supervised (ground truth available — images 1–8)
- **`fSegDiscrepEval.m`** — E₁ (global pixel error) and E₂ (per-segment accuracy) vs. manual ground truth
- Ground truth flow: raw GT → `fGT2ClassLabel` → `fConvertClassLabels2SegLabels` → `fSegDiscrepEval`

### Unsupervised (no ground truth — images 9–20)
- **`fFindVariance_MoransI_New.m`** — Moran's I (inter-segment autocorrelation) + intra-segment variance
- **`fFindSegmentationAccuracy.m`** — PSNR and Goodness metrics (G1, G2)
- **`fGetGoodness2.m`** — G2 = Moran's I + variance (used for automatic parameter selection)

### Automatic parameter selection
Parameter sweep → evaluate G2 → pick optimum. One function per tunable parameter:
- `fAutomaticSelectEPSFWindowSize.m`
- `fAutomaticSelectH_ImageWindowSize.m`
- `fAutomaticSelectRM1ScaleThreshold.m` / `fAutomaticSelectRM2ScaleThreshold.m`

## Key Architectural Notes

- **Border extension pattern:** `fExtendImgByMirroring` (or `fExtendImgByZeroPadding`) is applied before any filter, then stripped after. Follow this pattern for any new filter.
- **Label maps** are passed as double arrays (`dLabels`). After any merge operation, always call `fRenumberLabels` to keep labels sequential.
- **`fSimplifyImage.m`** / **`fGetSegmentedImg.m`** collapse a label map back into a pixel image (each region → its mean colour) for visualisation and PSNR computation.
- **`fGetBoundaries.m`** extracts region boundary pixels from a label map for overlay display.
- **Export:** `SaveAllFigures.m` saves open figure windows; `save2word.m` writes figures into a Word document.

## Naming Conventions

**Functions:** All helper functions are prefixed with `f`.

**Variables use Hungarian-style prefixes:**
| Prefix | Type |
|--------|------|
| `d` | double |
| `g` | generic input argument |
| `lo` | logical / boolean |
| `s` / `st` | string / struct |

## Dataset

20 Google Earth (GeoEye-1) satellite images:
- Images 1–8: 128×128 and 256×256, manual ground truth available
- Images 9–10: 512×512, no ground truth
- Images 11–20: 1024×1024, no ground truth (unsupervised metrics only)
