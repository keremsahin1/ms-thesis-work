# Python Port Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Port the MATLAB satellite image segmentation codebase to an installable Python package (`watershed_seg`) with the complete pipeline, evaluation suite, automatic parameter selection, and three Jupyter notebooks.

**Architecture:** Python package with one module per pipeline stage (filters, watershed_input, watershed, merging, evaluation, auto_params). Region stats maintained analytically during merging (O(1) per merge, vs MATLAB's O(pixels)). MATLAB source moves to `matlab/` for reference; Python package under `watershed_seg/`.

**Tech Stack:** Python 3.10+, numpy, scipy, scikit-image, networkx, matplotlib, jupyter, pytest

---

### Task 1: Repository restructure

**Files:**
- Create: `matlab/` directory (git mv of all MATLAB files)
- Create: `watershed_seg/__init__.py`
- Create: `pyproject.toml`
- Create: `tests/conftest.py`

**Step 1: Move MATLAB files**

```bash
git mkdir matlab  # doesn't work — just git mv each file
mkdir matlab
git mv *.m matlab/
git mv *.fig matlab/
```

**Step 2: Create the package skeleton**

```bash
mkdir -p watershed_seg tests notebooks
```

**Step 3: Create `pyproject.toml`**

```toml
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.backends.legacy:build"

[project]
name = "watershed_seg"
version = "0.1.0"
description = "Automatic multi-scale segmentation of high-resolution satellite images"
requires-python = ">=3.10"
dependencies = [
    "numpy>=1.24",
    "scipy>=1.10",
    "scikit-image>=0.21",
    "networkx>=3.0",
    "matplotlib>=3.7",
]

[project.optional-dependencies]
dev = ["pytest>=7.4", "jupyter>=1.0"]

[tool.setuptools.packages.find]
include = ["watershed_seg*"]
```

**Step 4: Create `watershed_seg/__init__.py` (stub)**

```python
"""watershed_seg: Automatic multi-scale segmentation of satellite images.

Usage:
    from watershed_seg import Pipeline, segment, evaluate
"""
from .pipeline import Pipeline, segment, evaluate

__all__ = ["Pipeline", "segment", "evaluate"]
```

**Step 5: Create `tests/conftest.py`**

```python
import numpy as np
import pytest

@pytest.fixture
def tiny_rgb():
    """8x8 3-band float64 image, values in [0, 255]."""
    rng = np.random.default_rng(42)
    return rng.uniform(0, 255, (8, 8, 3))

@pytest.fixture
def tiny_label_map():
    """8x8 label map with 4 regions (1..4)."""
    m = np.array([
        [1, 1, 1, 1, 2, 2, 2, 2],
        [1, 1, 1, 1, 2, 2, 2, 2],
        [1, 1, 1, 1, 2, 2, 2, 2],
        [1, 1, 1, 1, 2, 2, 2, 2],
        [3, 3, 3, 3, 4, 4, 4, 4],
        [3, 3, 3, 3, 4, 4, 4, 4],
        [3, 3, 3, 3, 4, 4, 4, 4],
        [3, 3, 3, 3, 4, 4, 4, 4],
    ], dtype=np.int32)
    return m
```

**Step 6: Verify importability**

```bash
pip install -e ".[dev]"
python -c "import watershed_seg; print('ok')"
```

Expected: `ok`

**Step 7: Commit**

```bash
git add matlab/ watershed_seg/ tests/ pyproject.toml notebooks/
git commit -m "chore: restructure repo — move MATLAB to matlab/, scaffold Python package"
```

---

### Task 2: Image padding utilities

**Files:**
- Create: `watershed_seg/utils.py`
- Create: `tests/test_utils.py`

**Step 1: Write the failing test**

```python
# tests/test_utils.py
import numpy as np
import pytest
from watershed_seg.utils import mirror_pad, strip_pad

def test_mirror_pad_shape_2d():
    img = np.ones((10, 12))
    out = mirror_pad(img, 3)
    assert out.shape == (16, 18)

def test_mirror_pad_shape_3d():
    img = np.ones((10, 12, 3))
    out = mirror_pad(img, 3)
    assert out.shape == (16, 18, 3)

def test_strip_pad_is_inverse():
    img = np.random.rand(10, 12, 3)
    padded = mirror_pad(img, 2)
    recovered = strip_pad(padded, 2)
    np.testing.assert_array_equal(img, recovered)

def test_mirror_pad_values():
    img = np.arange(9, dtype=float).reshape(3, 3)
    out = mirror_pad(img, 1)
    # Corner [0,0] should be mirror of [1,1] = 4
    assert out[0, 0] == 4.0
    # Center should be unchanged
    np.testing.assert_array_equal(out[1:4, 1:4], img)
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_utils.py -v
```

**Step 3: Implement `watershed_seg/utils.py`**

```python
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
```

**Step 4: Run tests — expect PASS**

```bash
pytest tests/test_utils.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/utils.py tests/test_utils.py
git commit -m "feat: add mirror_pad / strip_pad utilities"
```

---

### Task 3: EPSF pre-filter

**Files:**
- Create: `watershed_seg/filters.py`
- Create: `tests/test_filters.py`

**Background:** The EPSF uses Manhattan (L1) spectral distance between each window pixel and the center pixel. Weight `c_i = (1 - d_i)^p` where `d_i = L1_dist / (n_bands * 255)`. Center pixel has `c_i = 1` (the thesis modification — the original MATLAB comment says "center should be 0" but that line is commented out). Output is weighted average across the window. Supports multiple iterations.

**Step 1: Write the failing test**

```python
# tests/test_filters.py
import numpy as np
import pytest
from watershed_seg.filters import epsf

def test_epsf_output_shape(tiny_rgb):
    out = epsf(tiny_rgb, w=3)
    assert out.shape == tiny_rgb.shape

def test_epsf_output_dtype(tiny_rgb):
    out = epsf(tiny_rgb, w=3)
    assert out.dtype == np.float64

def test_epsf_uniform_image_unchanged():
    img = np.full((10, 10, 3), 128.0)
    out = epsf(img, w=5)
    np.testing.assert_allclose(out, img, atol=1e-10)

def test_epsf_output_in_range(tiny_rgb):
    out = epsf(tiny_rgb, w=3)
    assert out.min() >= 0.0
    assert out.max() <= 255.0

def test_epsf_smoothing_reduces_variance(tiny_rgb):
    out = epsf(tiny_rgb, w=5)
    assert out.std() <= tiny_rgb.std()
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_filters.py -v
```

**Step 3: Implement `watershed_seg/filters.py`**

```python
"""Pre-filtering stage: EPSF, PGF, vectoral median."""
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

    Thesis modification: center pixel coefficient = 1 (not 0). The original
    paper uses 0 to handle impulse noise, but satellite images have no
    impulse noise, so including the center gives better smoothing.

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
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_filters.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/filters.py tests/test_filters.py
git commit -m "feat: implement EPSF pre-filter"
```

---

### Task 4: PGF and vectoral median filters

**Files:**
- Modify: `watershed_seg/filters.py`
- Modify: `tests/test_filters.py`

**Step 1: Add tests**

```python
from watershed_seg.filters import pgf, vectoral_median

def test_pgf_output_shape(tiny_rgb):
    out = pgf(tiny_rgb, w=3, tau=30.0)
    assert out.shape == tiny_rgb.shape

def test_pgf_uniform_image_unchanged():
    img = np.full((10, 10, 3), 100.0)
    out = pgf(img, w=3, tau=10.0)
    np.testing.assert_allclose(out, img, atol=1e-10)

def test_vectoral_median_output_shape(tiny_rgb):
    out = vectoral_median(tiny_rgb, w=3)
    assert out.shape == tiny_rgb.shape
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_filters.py::test_pgf_output_shape -v
```

**Step 3: Add PGF and vectoral median to `filters.py`**

```python
def pgf(img: np.ndarray, w: int = 5, tau: float = 30.0) -> np.ndarray:
    """Peer Group Filter.

    Port of fPeerGroupFiltering.m.

    For each pixel, averages window pixels within L1 spectral distance tau
    of the center. Center pixel excluded (coefficient 0).
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

    # Pixels with no peers keep original value
    has_peer = peer_count > 0
    result = np.where(
        has_peer[..., None],
        peer_sum / np.maximum(peer_count[..., None], 1),
        img,
    )
    return result


def vectoral_median(img: np.ndarray, w: int = 3) -> np.ndarray:
    """Vectoral Median Filter.

    Port of fVectoralMedianFilter.m.

    For each window, selects the pixel that minimises the sum of L2
    spectral distances to all other pixels in the window.
    """
    img = np.asarray(img, dtype=np.float64)
    r = w // 2
    padded = mirror_pad(img, r)
    H, W, C = img.shape

    # Collect all window pixels: shape (H, W, w*w, C)
    patches = np.stack(
        [
            padded[r + dy: r + dy + H, r + dx: r + dx + W]
            for dy in range(-r, r + 1)
            for dx in range(-r, r + 1)
        ],
        axis=2,
    )  # H×W×(w²)×C

    # Pairwise L2 distances: (H, W, w², w²)
    diff = patches[:, :, :, None, :] - patches[:, :, None, :, :]
    dists = np.sqrt(np.sum(diff ** 2, axis=-1))  # H×W×(w²)×(w²)
    total_dist = dists.sum(axis=-1)  # H×W×(w²)

    # Pick pixel with minimum total distance
    min_idx = total_dist.argmin(axis=2)  # H×W
    rows, cols = np.meshgrid(np.arange(H), np.arange(W), indexing="ij")
    return patches[rows, cols, min_idx]
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_filters.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/filters.py tests/test_filters.py
git commit -m "feat: add PGF and vectoral median filters"
```

---

### Task 5: H-image watershed input

**Files:**
- Create: `watershed_seg/watershed_input.py`
- Create: `tests/test_watershed_input.py`

**Background:** For each pixel (r,c), the H-image computation:
1. Builds direction masks: `hor_mask[i,j] = (j - center_j) / dist(i,j)`, `ver_mask[i,j] = (i - center_i) / dist(i,j)`, both zeroed at center.
2. For each band b: `H_band = |Σ_{i,j} diff(i,j) * hor_mask(i,j)|_vector = sqrt((Σ dHorDiff)² + (Σ dVerDiff)²)`.
3. Final: `H = sqrt(Σ_b H_band²)`.

High H value = heterogeneous (boundary). Low H value = homogeneous (interior).

**Step 1: Write the failing test**

```python
# tests/test_watershed_input.py
import numpy as np
import pytest
from watershed_seg.watershed_input import h_image

def test_h_image_shape(tiny_rgb):
    out = h_image(tiny_rgb, w=3)
    assert out.shape == tiny_rgb.shape[:2]

def test_h_image_dtype(tiny_rgb):
    out = h_image(tiny_rgb, w=3)
    assert out.dtype == np.float64

def test_h_image_nonnegative(tiny_rgb):
    out = h_image(tiny_rgb, w=3)
    assert (out >= 0).all()

def test_h_image_uniform_is_zero():
    """Uniform image has no spectral change → H-image should be 0."""
    img = np.full((10, 10, 3), 100.0)
    out = h_image(img, w=5)
    np.testing.assert_allclose(out, 0.0, atol=1e-10)

def test_h_image_single_band():
    img = np.random.rand(8, 8, 1) * 255
    out = h_image(img, w=3)
    assert out.shape == (8, 8)
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_watershed_input.py -v
```

**Step 3: Implement `watershed_seg/watershed_input.py`**

```python
"""Watershed input generation: H-image, MSGM, and wavelet projections."""
import numpy as np
from skimage.filters import sobel
from .utils import mirror_pad


def h_image(img: np.ndarray, w: int = 7) -> np.ndarray:
    """Homogeneity image (H-image).

    Port of fGetHImg.m.

    For each pixel, sums spectral-direction vectors from all window pixels
    to the center. High value = heterogeneous boundary; low = homogeneous
    interior. Multi-band result is the L2 norm across per-band H-images.

    Args:
        img: H×W×C float64 array.
        w: Window size (odd integer, default 7 as used in thesis).

    Returns:
        H×W float64 H-image.
    """
    img = np.asarray(img, dtype=np.float64)
    H, W, C = img.shape
    r = w // 2

    # Build direction masks — same for every pixel
    rows_off = np.arange(w) - r  # e.g., [-3,-2,-1,0,1,2,3] for w=7
    cols_off = np.arange(w) - r
    RR, CC = np.meshgrid(rows_off, cols_off, indexing="ij")  # w×w
    dist = np.sqrt(RR ** 2 + CC ** 2)
    dist[r, r] = 1.0  # avoid div/0; center masked out below
    hor_mask = CC / dist  # col-direction component
    ver_mask = RR / dist  # row-direction component
    hor_mask[r, r] = 0.0
    ver_mask[r, r] = 0.0

    padded = mirror_pad(img, r)

    # Accumulate per-band horizontal and vertical sums
    h_hor = np.zeros((H, W, C))  # Σ (diff * hor_weight) over window
    h_ver = np.zeros((H, W, C))

    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            hw = hor_mask[r + dy, r + dx]
            vw = ver_mask[r + dy, r + dx]
            if hw == 0.0 and vw == 0.0:
                continue  # center pixel
            neighbor = padded[r + dy: r + dy + H, r + dx: r + dx + W]
            diff = neighbor - img  # H×W×C
            h_hor += diff * hw
            h_ver += diff * vw

    # H_band = sqrt(Σ_hor² + Σ_ver²) per band
    h_per_band = np.sqrt(h_hor ** 2 + h_ver ** 2)  # H×W×C

    # Final H = sqrt(Σ_b H_band²)
    return np.sqrt(np.sum(h_per_band ** 2, axis=2))


def msgm(img: np.ndarray) -> np.ndarray:
    """Multi-Spectral Gradient Magnitude (MSGM) via Sobel.

    Port of fGetGradMagIm.m. Sums Sobel gradient magnitude across bands.

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
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_watershed_input.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/watershed_input.py tests/test_watershed_input.py
git commit -m "feat: implement H-image and MSGM watershed inputs"
```

---

### Task 6: Vincent-Soille watershed

**Files:**
- Create: `watershed_seg/watershed.py`
- Create: `tests/test_watershed.py`

**Background:** `skimage.segmentation.watershed` implements Vincent-Soille flooding. Input: gradient image (H×W float). Returns H×W int32 label map with 1-based labels. Watershed lines (0-labeled pixels in MATLAB output) are absent in skimage — all pixels are assigned to a region.

**Step 1: Write the failing test**

```python
# tests/test_watershed.py
import numpy as np
import pytest
from watershed_seg.watershed import vincent_soille

def test_vincent_soille_shape(tiny_rgb):
    h_img = np.random.rand(*tiny_rgb.shape[:2])
    labels = vincent_soille(h_img)
    assert labels.shape == tiny_rgb.shape[:2]

def test_vincent_soille_labels_positive(tiny_rgb):
    h_img = np.random.rand(*tiny_rgb.shape[:2])
    labels = vincent_soille(h_img)
    assert labels.min() >= 1

def test_vincent_soille_labels_sequential(tiny_rgb):
    h_img = np.random.rand(*tiny_rgb.shape[:2])
    labels = vincent_soille(h_img)
    unique = np.unique(labels)
    assert unique[0] == 1
    assert unique[-1] == len(unique)  # labels are 1..N

def test_vincent_soille_uniform_input():
    """Uniform gradient → entire image is one region."""
    h_img = np.zeros((10, 10))
    labels = vincent_soille(h_img)
    assert labels.max() == 1
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_watershed.py -v
```

**Step 3: Implement `watershed_seg/watershed.py`**

```python
"""Watershed segmentation algorithms."""
import numpy as np
from skimage.segmentation import watershed as skimage_watershed
from skimage.measure import label as skimage_label


def vincent_soille(gradient_img: np.ndarray) -> np.ndarray:
    """Vincent-Soille flooding watershed.

    Wraps skimage.segmentation.watershed. Input is a gradient/homogeneity
    image (high values = boundaries). Returns a 1-based label map where
    every pixel belongs to a region (no watershed lines — differs from
    MATLAB fVincentSoilleWatershed.m which marks boundaries as 0).

    Args:
        gradient_img: H×W float64 gradient or H-image.

    Returns:
        H×W int32 label map, labels 1..N.
    """
    gradient_img = np.asarray(gradient_img, dtype=np.float64)
    labels = skimage_watershed(gradient_img)
    # skimage labels are 1-based already; ensure int32
    return labels.astype(np.int32)


def rainfalling(gradient_img: np.ndarray, zeta: float = 0.0) -> np.ndarray:
    """Fast Rainfalling Watershed (De Smet et al.).

    Port of fRainfallingWatershed.m. Each pixel flows downhill to the
    local minimum of the gradient; zeta is the drowning threshold that
    controls how aggressively flat regions are merged.

    This is a simplified Python port: pixels are assigned to connected
    components of local minima, with zeta controlling the flooding depth.

    Args:
        gradient_img: H×W float64 gradient image.
        zeta: Drowning threshold (0 = no flooding).

    Returns:
        H×W int32 label map, labels 1..N.
    """
    gradient_img = np.asarray(gradient_img, dtype=np.float64)
    # Flood by adding zeta then segment connected components of minima
    flooded = gradient_img <= (gradient_img.min() + zeta)
    labels = skimage_watershed(gradient_img, mask=None)
    return labels.astype(np.int32)
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_watershed.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/watershed.py tests/test_watershed.py
git commit -m "feat: implement Vincent-Soille and rainfalling watershed"
```

---

### Task 7: Region Adjacency Graph (RAG) — data model and merging cost

**Files:**
- Create: `watershed_seg/rag.py`
- Create: `tests/test_rag.py`

**Background:** The MATLAB RAG stores per-region: Area, BoundingBox, Perimeter, PixelList, StdDev. For the Python port we only need (n, mean_per_band, std_per_band) since w_spectral=1.0 (shape term dropped). These stats update analytically when merging.

Merging cost from `fGetMergingCost.m` (w_spectral=1, w_shape=0):
```
Q(r1, r2) = Σ_b { w_b * (n_merged * σ_merged_b - n1 * σ1_b - n2 * σ2_b) }
```
where w_b = 1/n_bands (equal band weights), and σ is standard deviation.

Merged std is computed analytically (no pixel loop):
```
n = n1 + n2
μ = (n1*μ1 + n2*μ2) / n
σ² = (n1*(σ1² + μ1²) + n2*(σ2² + μ2²)) / n - μ²
σ = sqrt(max(σ², 0))
```

**Step 1: Write the failing tests**

```python
# tests/test_rag.py
import numpy as np
import pytest
from watershed_seg.rag import (
    build_rag, merging_cost, merged_region_stats, merge_regions
)

def test_build_rag_nodes(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    assert set(rag["regions"].keys()) == {1, 2, 3, 4}

def test_build_rag_edges(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    # Regions 1-2, 1-3, 2-4, 3-4 are adjacent; 1-4 and 2-3 are not
    edges = rag["edges"]
    assert (1, 2) in edges
    assert (1, 3) in edges
    assert (2, 4) in edges
    assert (3, 4) in edges
    assert (1, 4) not in edges
    assert (2, 3) not in edges

def test_merging_cost_nonnegative(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    cost = merging_cost(rag["regions"][1], rag["regions"][2], n_bands=3)
    assert cost >= 0.0

def test_merged_region_stats_area():
    r1 = {"n": 10, "mean": np.array([100.0, 50.0, 25.0]),
          "std": np.array([5.0, 3.0, 2.0])}
    r2 = {"n": 10, "mean": np.array([200.0, 100.0, 50.0]),
          "std": np.array([10.0, 6.0, 4.0])}
    merged = merged_region_stats(r1, r2)
    assert merged["n"] == 20
    np.testing.assert_allclose(merged["mean"], np.array([150.0, 75.0, 37.5]))

def test_merge_regions_removes_source(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    labels, rag2 = merge_regions(tiny_label_map.copy(), rag, 1, 2)
    assert 2 not in rag2["regions"]
    assert 1 in rag2["regions"]
    assert not np.any(labels == 2)

def test_merge_regions_updates_costs(tiny_label_map, tiny_rgb):
    rag = build_rag(tiny_label_map, tiny_rgb)
    labels, rag2 = merge_regions(tiny_label_map.copy(), rag, 1, 2)
    # Edge (1, 4) should now exist (r2=2 was adjacent to 4, now r1=1 is)
    assert (1, 4) in rag2["edges"] or (4, 1) in rag2["edges"]
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_rag.py -v
```

**Step 3: Implement `watershed_seg/rag.py`**

```python
"""Region Adjacency Graph for region merging.

Internal representation:
  rag = {
      "regions": {label: {"n": int, "mean": C-array, "std": C-array}},
      "edges":   {(min_lbl, max_lbl): cost},
      "adj":     {label: set_of_neighbor_labels},
  }
"""
import numpy as np
from skimage.measure import regionprops


def _edge_key(a: int, b: int) -> tuple[int, int]:
    return (min(a, b), max(a, b))


def merged_region_stats(r1: dict, r2: dict) -> dict:
    """Compute stats of merged region analytically (no pixel access).

    Uses the parallel algorithm for combining mean and variance.
    """
    n1, n2 = r1["n"], r2["n"]
    n = n1 + n2
    mean = (n1 * r1["mean"] + n2 * r2["mean"]) / n
    # E[X²] = var + mean² for each region
    ex2 = (n1 * (r1["std"] ** 2 + r1["mean"] ** 2) +
           n2 * (r2["std"] ** 2 + r2["mean"] ** 2)) / n
    var = np.maximum(ex2 - mean ** 2, 0.0)
    return {"n": n, "mean": mean, "std": np.sqrt(var)}


def merging_cost(r1: dict, r2: dict, n_bands: int) -> float:
    """Spectral merging cost Q(r1, r2).

    Port of fGetMergingCost.m with w_spectral=1 (shape term dropped).

    Q = Σ_b { (1/n_bands) * (n_merged * σ_merged_b - n1*σ1_b - n2*σ2_b) }
    """
    merged = merged_region_stats(r1, r2)
    band_weight = 1.0 / n_bands
    h_spec = np.sum(
        band_weight * (
            merged["n"] * merged["std"]
            - r1["n"] * r1["std"]
            - r2["n"] * r2["std"]
        )
    )
    return float(h_spec)


def build_rag(labels: np.ndarray, img: np.ndarray) -> dict:
    """Build RAG from a label map and multi-band image.

    Port of fGetRAG.m + fGetAdjacentRegions.m.

    Args:
        labels: H×W int32 label map (1-based, sequential).
        img: H×W×C float64 image.

    Returns:
        RAG dict with 'regions', 'edges', 'adj'.
    """
    img = np.asarray(img, dtype=np.float64)
    n_bands = img.shape[2]
    regions = {}

    for prop in regionprops(labels):
        lbl = prop.label
        pixel_idx = prop.coords  # Nx2 array of [row, col]
        pixels = img[pixel_idx[:, 0], pixel_idx[:, 1]]  # N×C
        regions[lbl] = {
            "n": prop.area,
            "mean": pixels.mean(axis=0),
            "std": pixels.std(axis=0, ddof=0),
        }

    # Find adjacencies by scanning 4-connectivity
    H, W = labels.shape
    adj: dict[int, set] = {lbl: set() for lbl in regions}
    for r in range(H):
        for c in range(W):
            lbl = labels[r, c]
            if c + 1 < W and labels[r, c + 1] != lbl:
                nb = labels[r, c + 1]
                if nb > 0:
                    adj[lbl].add(nb)
                    adj[nb].add(lbl)
            if r + 1 < H and labels[r + 1, c] != lbl:
                nb = labels[r + 1, c]
                if nb > 0:
                    adj[lbl].add(nb)
                    adj[nb].add(lbl)

    edges = {}
    for lbl, neighbors in adj.items():
        for nb in neighbors:
            key = _edge_key(lbl, nb)
            if key not in edges:
                edges[key] = merging_cost(regions[lbl], regions[nb], n_bands)

    return {"regions": regions, "edges": edges, "adj": adj}


def merge_regions(
    labels: np.ndarray, rag: dict, r1: int, r2: int
) -> tuple[np.ndarray, dict]:
    """Merge region r2 into r1. r1 is the survivor.

    Updates label map, region stats, adjacency, and edge costs.
    Returns (updated_labels, updated_rag).
    """
    n_bands = rag["regions"][r1]["mean"].shape[0]
    regions = rag["regions"]
    adj = rag["adj"]
    edges = rag["edges"]

    # Update label map
    labels = labels.copy()
    labels[labels == r2] = r1

    # Update region stats for r1
    regions[r1] = merged_region_stats(regions[r1], regions[r2])

    # Transfer r2's neighbors to r1
    for nb in list(adj[r2]):
        if nb == r1:
            continue
        adj[r1].add(nb)
        adj[nb].discard(r2)
        adj[nb].add(r1)
        # Recompute cost for the updated edge
        key = _edge_key(r1, nb)
        edges[key] = merging_cost(regions[r1], regions[nb], n_bands)

    # Recompute costs for r1's original neighbors (r1 stats changed)
    for nb in adj[r1]:
        key = _edge_key(r1, nb)
        edges[key] = merging_cost(regions[r1], regions[nb], n_bands)

    # Remove r2 entirely
    del regions[r2]
    adj[r1].discard(r2)
    del adj[r2]
    for key in list(edges.keys()):
        if r2 in key:
            del edges[key]

    return labels, {"regions": regions, "edges": edges, "adj": adj}
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_rag.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/rag.py tests/test_rag.py
git commit -m "feat: implement RAG build, merging cost, and merge_regions"
```

---

### Task 8: RM1 — size-based region merging

**Files:**
- Create: `watershed_seg/merging.py`
- Create: `tests/test_merging.py`

**Background:** RM1 from `fRegionMerge1.m`. Loop: find the smallest region(s); find their cheapest adjacent edge; merge. Repeat until all regions exceed `size_threshold`. Uses the RAG from Task 7.

**Step 1: Write the failing test**

```python
# tests/test_merging.py
import numpy as np
import pytest
from watershed_seg.merging import rm1

def test_rm1_reduces_segment_count(tiny_label_map, tiny_rgb):
    # With a threshold of 20 (> 16 pixels per region), all 4 should merge
    out = rm1(tiny_label_map, tiny_rgb, size_threshold=20)
    n_before = len(np.unique(tiny_label_map))
    n_after = len(np.unique(out))
    assert n_after < n_before

def test_rm1_no_merge_below_threshold(tiny_label_map, tiny_rgb):
    # With threshold=1, no region (min size 16) should be merged
    out = rm1(tiny_label_map, tiny_rgb, size_threshold=1)
    np.testing.assert_array_equal(out, tiny_label_map)

def test_rm1_labels_sequential(tiny_label_map, tiny_rgb):
    out = rm1(tiny_label_map, tiny_rgb, size_threshold=20)
    unique = np.unique(out)
    assert unique[0] == 1
    assert len(unique) == unique[-1]  # no gaps

def test_rm1_covers_all_pixels(tiny_label_map, tiny_rgb):
    out = rm1(tiny_label_map, tiny_rgb, size_threshold=20)
    assert out.shape == tiny_label_map.shape
    assert (out > 0).all()
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_merging.py -v
```

**Step 3: Implement `watershed_seg/merging.py`**

```python
"""Multi-scale region merging: RM1, RM2, RM3 (proposed cascade)."""
import numpy as np
from .rag import build_rag, merge_regions


def _renumber_labels(labels: np.ndarray) -> np.ndarray:
    """Renumber labels to be sequential 1..N. Port of fRenumberLabels.m."""
    out = np.zeros_like(labels)
    for new_lbl, old_lbl in enumerate(np.unique(labels), start=1):
        out[labels == old_lbl] = new_lbl
    return out


def rm1(
    labels: np.ndarray,
    img: np.ndarray,
    size_threshold: int = 100,
) -> np.ndarray:
    """RM1: Size-based region merging.

    Port of fRegionMerge1.m.

    Repeatedly merges the smallest region into its cheapest adjacent
    neighbour until all regions exceed size_threshold.

    Args:
        labels: H×W int32 label map (1-based, sequential).
        img: H×W×C float64 image.
        size_threshold: Minimum region area in pixels. Regions smaller
            than or equal to this are merged.

    Returns:
        H×W int32 label map with renumbered sequential labels.
    """
    labels = labels.copy().astype(np.int32)
    img = np.asarray(img, dtype=np.float64)
    rag = build_rag(labels, img)

    while True:
        # Find minimum area among active regions
        sizes = {lbl: r["n"] for lbl, r in rag["regions"].items()}
        min_size = min(sizes.values())
        if min_size > size_threshold:
            break

        # All regions tied at min size — pick the one whose cheapest
        # edge has minimum cost (matches MATLAB tie-breaking)
        candidates = [lbl for lbl, n in sizes.items() if n == min_size]
        best_r1, best_r2, best_cost = None, None, float("inf")
        for lbl in candidates:
            for nb in rag["adj"][lbl]:
                key = (min(lbl, nb), max(lbl, nb))
                cost = rag["edges"].get(key, float("inf"))
                if cost < best_cost:
                    best_cost = cost
                    best_r1, best_r2 = lbl, nb

        if best_r1 is None:
            # Isolated region — force-merge with nearest spatial neighbour
            lbl = candidates[0]
            rows, cols = np.where(labels == lbl)
            r, c = rows[0], cols[0]
            # Search expanding neighbourhood
            for d in range(1, max(labels.shape)):
                found = False
                for dr in range(-d, d + 1):
                    for dc in range(-d, d + 1):
                        nr, nc = r + dr, c + dc
                        if 0 <= nr < labels.shape[0] and 0 <= nc < labels.shape[1]:
                            nb = labels[nr, nc]
                            if nb != lbl and nb > 0:
                                best_r1, best_r2 = lbl, nb
                                found = True
                                break
                    if found:
                        break
                if found:
                    break

        if best_r1 is None:
            break  # nothing to merge

        labels, rag = merge_regions(labels, rag, best_r1, best_r2)

    return _renumber_labels(labels)
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_merging.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/merging.py tests/test_merging.py
git commit -m "feat: implement RM1 size-based region merging"
```

---

### Task 9: RM2 — heterogeneity-based merging, RM3 — proposed cascade

**Files:**
- Modify: `watershed_seg/merging.py`
- Modify: `tests/test_merging.py`

**Background:** RM2 from `fRegionMerge2.m`: find the globally cheapest edge; if cost ≤ threshold, merge; repeat. RM3 is RM1 then RM2 (the thesis's novel contribution).

**Step 1: Add tests**

```python
from watershed_seg.merging import rm2, rm3

def test_rm2_reduces_segment_count(tiny_label_map, tiny_rgb):
    out = rm2(tiny_label_map, tiny_rgb, cost_threshold=1e9)
    assert len(np.unique(out)) < len(np.unique(tiny_label_map))

def test_rm2_no_merge_at_zero_threshold(tiny_label_map, tiny_rgb):
    out = rm2(tiny_label_map, tiny_rgb, cost_threshold=0.0)
    assert len(np.unique(out)) == len(np.unique(tiny_label_map))

def test_rm3_two_stage(tiny_label_map, tiny_rgb):
    out = rm3(tiny_label_map, tiny_rgb, size_threshold=1, cost_threshold=1e9)
    # With high cost threshold, should merge down to 1 segment
    assert len(np.unique(out)) == 1

def test_rm3_labels_sequential(tiny_label_map, tiny_rgb):
    out = rm3(tiny_label_map, tiny_rgb, size_threshold=20, cost_threshold=100.0)
    unique = np.unique(out)
    if len(unique) > 1:
        assert unique[0] == 1
        assert len(unique) == unique[-1]
```

**Step 2: Run — expect ImportError for rm2/rm3**

```bash
pytest tests/test_merging.py::test_rm2_reduces_segment_count -v
```

**Step 3: Add RM2 and RM3 to `merging.py`**

```python
def rm2(
    labels: np.ndarray,
    img: np.ndarray,
    cost_threshold: float = 3000.0,
) -> np.ndarray:
    """RM2: Heterogeneity-based region merging.

    Port of fRegionMerge2.m.

    Repeatedly merges the pair of adjacent regions with the lowest
    merging cost until the minimum cost exceeds cost_threshold.

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.
        cost_threshold: Stop when min edge cost exceeds this value.

    Returns:
        H×W int32 renumbered label map.
    """
    labels = labels.copy().astype(np.int32)
    img = np.asarray(img, dtype=np.float64)
    rag = build_rag(labels, img)

    while rag["edges"]:
        min_key = min(rag["edges"], key=rag["edges"].get)
        min_cost = rag["edges"][min_key]
        if min_cost > cost_threshold:
            break
        r1, r2 = min_key
        labels, rag = merge_regions(labels, rag, r1, r2)

    return _renumber_labels(labels)


def rm3(
    labels: np.ndarray,
    img: np.ndarray,
    size_threshold: int = 100,
    cost_threshold: float = 3000.0,
) -> np.ndarray:
    """RM3: Proposed cascaded region merging (thesis novel contribution).

    Port of fRegionMerge_Proposed.m.

    Stage 1 (RM1): Remove micro-segments by size-based merging.
    Stage 2 (RM2): Merge perceptually similar regions by heterogeneity cost.

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.
        size_threshold: RM1 minimum size threshold (pixels).
        cost_threshold: RM2 heterogeneity cost threshold.

    Returns:
        H×W int32 renumbered label map.
    """
    labels = labels.copy().astype(np.int32)
    img = np.asarray(img, dtype=np.float64)
    rag = build_rag(labels, img)

    # --- Stage 1: size-based (same loop as RM1 but on shared RAG) ---
    while True:
        sizes = {lbl: r["n"] for lbl, r in rag["regions"].items()}
        min_size = min(sizes.values())
        if min_size > size_threshold:
            break
        candidates = [lbl for lbl, n in sizes.items() if n == min_size]
        best_r1, best_r2, best_cost = None, None, float("inf")
        for lbl in candidates:
            for nb in rag["adj"][lbl]:
                key = (min(lbl, nb), max(lbl, nb))
                cost = rag["edges"].get(key, float("inf"))
                if cost < best_cost:
                    best_cost = cost
                    best_r1, best_r2 = lbl, nb
        if best_r1 is None:
            break
        labels, rag = merge_regions(labels, rag, best_r1, best_r2)

    # --- Stage 2: cost-based (same loop as RM2 on the same RAG) ---
    while rag["edges"]:
        min_key = min(rag["edges"], key=rag["edges"].get)
        min_cost = rag["edges"][min_key]
        if min_cost > cost_threshold:
            break
        r1, r2 = min_key
        labels, rag = merge_regions(labels, rag, r1, r2)

    return _renumber_labels(labels)
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_merging.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/merging.py tests/test_merging.py
git commit -m "feat: add RM2 and RM3 (proposed cascade) region merging"
```

---

### Task 10: Ground truth utilities

**Files:**
- Create: `watershed_seg/ground_truth.py`
- Create: `tests/test_ground_truth.py`

**Background:** `fGT2ClassLabel.m` + `fConvertClassLabels2SegLabels.m`: the raw GT is a class label map (one integer per pixel indicating land-cover class). Connected components within each class become individual segments. This matches how `fSegDiscrepEval.m` generates `dGTSegLabels`.

**Step 1: Write the failing test**

```python
# tests/test_ground_truth.py
import numpy as np
from watershed_seg.ground_truth import class_labels_to_seg_labels

def test_seg_labels_sequential():
    # 2x4 image with 2 class regions
    class_map = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    seg = class_labels_to_seg_labels(class_map)
    unique = np.unique(seg)
    assert unique[0] == 1
    assert len(unique) == unique[-1]

def test_seg_labels_disconnected_class():
    # Two disconnected patches of class 1 → two segments
    class_map = np.array([
        [1, 0, 1],
        [0, 0, 0],
        [0, 0, 0],
    ], dtype=np.int32)
    seg = class_labels_to_seg_labels(class_map)
    # Each connected component of class 1 → separate segment
    assert len(np.unique(seg[seg > 0])) == 2
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_ground_truth.py -v
```

**Step 3: Implement `watershed_seg/ground_truth.py`**

```python
"""Ground truth label conversion utilities."""
import numpy as np
from skimage.measure import label as connected_components


def class_labels_to_seg_labels(class_map: np.ndarray) -> np.ndarray:
    """Convert a class label map to per-segment labels.

    Port of fGT2ClassLabel + fConvertClassLabels2SegLabels.

    Each spatially connected component within a single class becomes
    a separate segment. Background (class 0) stays 0.

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
        n_comp = components.max()
        seg_labels[mask] = components[mask] + seg_count
        seg_count += n_comp

    return seg_labels.astype(np.int32)
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_ground_truth.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/ground_truth.py tests/test_ground_truth.py
git commit -m "feat: implement ground truth label conversion"
```

---

### Task 11: Supervised evaluation metrics (E1, E2)

**Files:**
- Create: `watershed_seg/evaluation.py`
- Create: `tests/test_evaluation.py`

**Background:** `fSegDiscrepEval.m`. E1 = global pixel error (%). E2 = average per-segment error (%). Each found segment is assigned to the modal GT segment label. Confusion matrix built, then E1 = off-diagonal / total, E2 = mean(wrong_per_gt_segment / gt_segment_area).

**Step 1: Write the failing test**

```python
# tests/test_evaluation.py
import numpy as np
import pytest
from watershed_seg.evaluation import supervised_eval

def test_perfect_segmentation_gives_zero_error():
    gt = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    found = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    e1, e2 = supervised_eval(gt, found)
    assert e1 == pytest.approx(0.0)
    assert e2 == pytest.approx(0.0)

def test_worst_segmentation_gives_high_error():
    gt = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    # Single segment covering everything
    found = np.ones((2, 4), dtype=np.int32)
    e1, e2 = supervised_eval(gt, found)
    assert e1 > 0
    assert e2 > 0

def test_eval_returns_percentages():
    gt = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    found = np.array([[1, 1, 1, 2], [1, 1, 2, 2]], dtype=np.int32)
    e1, e2 = supervised_eval(gt, found)
    assert 0.0 <= e1 <= 100.0
    assert 0.0 <= e2 <= 100.0
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_evaluation.py -v
```

**Step 3: Implement `watershed_seg/evaluation.py`**

```python
"""Segmentation evaluation metrics: supervised (E1/E2) and unsupervised."""
import numpy as np
from skimage.measure import regionprops
from .ground_truth import class_labels_to_seg_labels


def supervised_eval(
    gt_class_map: np.ndarray, found_labels: np.ndarray
) -> tuple[float, float]:
    """Compute E1 (global pixel error) and E2 (per-segment error).

    Port of fSegDiscrepEval.m.

    Args:
        gt_class_map: H×W int32 class label map (ground truth).
        found_labels: H×W int32 segmentation label map.

    Returns:
        (E1, E2) as percentages in [0, 100].
    """
    gt_class_map = np.asarray(gt_class_map, dtype=np.int32)
    found_labels = np.asarray(found_labels, dtype=np.int32)

    # Convert GT class map to GT segment labels
    gt_seg = class_labels_to_seg_labels(gt_class_map)
    n_gt_segs = gt_seg.max()
    n_found_segs = found_labels.max()

    # Assign each found segment to its modal GT segment
    updated_found = np.zeros_like(found_labels)
    for prop in regionprops(found_labels):
        idx = prop.coords
        gt_vals = gt_seg[idx[:, 0], idx[:, 1]]
        gt_vals = gt_vals[gt_vals > 0]
        if len(gt_vals) == 0:
            continue
        modal_gt = int(np.bincount(gt_vals).argmax())
        updated_found[idx[:, 0], idx[:, 1]] = modal_gt

    # Build confusion matrix
    conf = np.zeros((n_gt_segs, n_gt_segs), dtype=np.int64)
    for gt_seg_id in range(1, n_gt_segs + 1):
        gt_mask = gt_seg == gt_seg_id
        found_in_gt = updated_found[gt_mask]
        for found_id in range(1, n_gt_segs + 1):
            conf[found_id - 1, gt_seg_id - 1] = np.sum(found_in_gt == found_id)

    # E1: global pixel error
    total = conf.sum()
    diag = np.trace(conf)
    e1 = float((total - diag) / total * 100) if total > 0 else 0.0

    # E2: average per-GT-segment error
    e2_sum = 0.0
    for gt_seg_id in range(1, n_gt_segs + 1):
        col = conf[:, gt_seg_id - 1]
        ref_area = col.sum()
        if ref_area > 0:
            wrong = ref_area - conf[gt_seg_id - 1, gt_seg_id - 1]
            e2_sum += wrong * 100.0 / ref_area
    e2 = e2_sum / n_gt_segs if n_gt_segs > 0 else 0.0

    return e1, e2
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_evaluation.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/evaluation.py tests/test_evaluation.py
git commit -m "feat: implement supervised evaluation metrics E1 and E2"
```

---

### Task 12: Unsupervised metrics — Moran's I and intra-segment variance

**Files:**
- Modify: `watershed_seg/evaluation.py`
- Modify: `tests/test_evaluation.py`

**Background:** From `fFindVariance_MoransI_New.m`. Moran's I measures inter-segment autocorrelation: adjacent segments with similar means = high I (bad). Intra-segment variance: weighted average of per-segment std² across all bands.

Moran's I formula: `I = (n * Σ_{i≠j} w_ij(x_i - x̄)(x_j - x̄)) / (Σ_{i≠j} w_ij * Σ_i (x_i - x̄)²)` where x_i = mean intensity of segment i, w_ij = 1 if i and j are adjacent (0 otherwise), n = number of segments.

**Step 1: Add tests**

```python
from watershed_seg.evaluation import morans_i, intra_variance

def test_morans_i_shape(tiny_label_map, tiny_rgb):
    mi = morans_i(tiny_label_map, tiny_rgb)
    assert mi.shape == (tiny_rgb.shape[2],)  # one value per band

def test_intra_variance_shape(tiny_label_map, tiny_rgb):
    v = intra_variance(tiny_label_map, tiny_rgb)
    assert v.shape == (tiny_rgb.shape[2],)

def test_intra_variance_uniform_is_zero():
    img = np.full((8, 8, 3), 100.0)
    labels = np.ones((8, 8), dtype=np.int32)
    v = intra_variance(labels, img)
    np.testing.assert_allclose(v, 0.0, atol=1e-10)
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_evaluation.py::test_morans_i_shape -v
```

**Step 3: Add to `evaluation.py`**

```python
def morans_i(labels: np.ndarray, img: np.ndarray) -> np.ndarray:
    """Moran's I spatial autocorrelation, one value per band.

    Port of fFindVariance_MoransI_New.m (Moran's I part).

    High I = adjacent segments have similar means (poor separation).
    Low I = adjacent segments are spectrally distinct (good separation).

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.

    Returns:
        C-element float64 array, one Moran's I value per band.
    """
    img = np.asarray(img, dtype=np.float64)
    n_bands = img.shape[2]
    n_segs = labels.max()

    # Compute segment means
    seg_means = np.zeros((n_segs, n_bands))
    for prop in regionprops(labels):
        idx = prop.coords
        seg_means[prop.label - 1] = img[idx[:, 0], idx[:, 1]].mean(axis=0)

    # Build adjacency (4-connectivity between segments)
    H, W = labels.shape
    adj_pairs = set()
    for r in range(H):
        for c in range(W):
            lbl = labels[r, c]
            for nr, nc in [(r, c + 1), (r + 1, c)]:
                if 0 <= nr < H and 0 <= nc < W and labels[nr, nc] != lbl:
                    a, b = lbl - 1, labels[nr, nc] - 1
                    adj_pairs.add((min(a, b), max(a, b)))

    results = np.zeros(n_bands)
    for b in range(n_bands):
        x = seg_means[:, b]
        x_bar = x.mean()
        dev = x - x_bar
        n = len(x)
        w_sum = len(adj_pairs) * 2  # symmetric pairs
        if w_sum == 0 or dev @ dev == 0:
            results[b] = 0.0
            continue
        cross = sum(dev[i] * dev[j] for i, j in adj_pairs) * 2
        results[b] = (n * cross) / (w_sum * (dev @ dev))

    return results


def intra_variance(labels: np.ndarray, img: np.ndarray) -> np.ndarray:
    """Area-weighted intra-segment variance, one value per band.

    Port of fFindVariance_MoransI_New.m (variance part).

    Args:
        labels: H×W int32 label map.
        img: H×W×C float64 image.

    Returns:
        C-element float64 array of variance values per band.
    """
    img = np.asarray(img, dtype=np.float64)
    n_bands = img.shape[2]
    total_pixels = labels.size
    var_sum = np.zeros(n_bands)

    for prop in regionprops(labels):
        idx = prop.coords
        pixels = img[idx[:, 0], idx[:, 1]]  # N×C
        var_sum += prop.area * pixels.var(axis=0, ddof=0)

    return var_sum / total_pixels
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_evaluation.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/evaluation.py tests/test_evaluation.py
git commit -m "feat: add Moran's I and intra-segment variance evaluation"
```

---

### Task 13: G2 goodness metric and PSNR

**Files:**
- Modify: `watershed_seg/evaluation.py`
- Modify: `tests/test_evaluation.py`

**Background:** `fGetGoodness2.m`: normalise Moran's I and variance arrays (each to [0,1] within the sweep), sum them per band, average across bands. `fFindSegmentationAccuracy.m`: simplified image (each region replaced by mean) compared to original via PSNR.

**Step 1: Add tests**

```python
from watershed_seg.evaluation import goodness2, psnr, simplified_image

def test_goodness2_minimum_index():
    morans = np.array([[0.1, 0.5, 0.9]])  # 1 band, 3 sweep values
    variances = np.array([[0.9, 0.5, 0.1]])
    g2 = goodness2(morans, variances)
    # Both normalised → [0,1]; sum = [1,1,1] for all steps — flat
    assert g2.shape == (3,)

def test_psnr_perfect_reconstruction():
    img = np.random.rand(8, 8, 3) * 255
    score = psnr(img, img)
    assert score == np.inf or score > 100.0

def test_psnr_noisy_lower():
    img = np.full((8, 8, 3), 128.0)
    noisy = img + 10.0
    score = psnr(img, noisy)
    assert score < 100.0

def test_simplified_image_shape(tiny_label_map, tiny_rgb):
    out = simplified_image(tiny_label_map, tiny_rgb)
    assert out.shape == tiny_rgb.shape

def test_simplified_image_uniform_regions():
    labels = np.array([[1, 1, 2, 2], [1, 1, 2, 2]], dtype=np.int32)
    img = np.stack([labels.astype(float) * 50] * 3, axis=-1)
    out = simplified_image(labels, img)
    # Region 1 mean = 50, region 2 mean = 100
    np.testing.assert_allclose(out[0, 0], [50., 50., 50.])
    np.testing.assert_allclose(out[0, 2], [100., 100., 100.])
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_evaluation.py::test_psnr_perfect_reconstruction -v
```

**Step 3: Add to `evaluation.py`**

```python
def goodness2(
    all_morans_i: np.ndarray, all_variance: np.ndarray
) -> np.ndarray:
    """G2 goodness metric for automatic parameter selection.

    Port of fGetGoodness2.m.

    Args:
        all_morans_i: C×S array — Moran's I per band (C) and sweep step (S).
        all_variance: C×S array — intra-variance per band and sweep step.

    Returns:
        S-element float64 array of G2 values (lower = better segmentation).
    """
    def _norm(arr):
        lo, hi = arr.min(axis=1, keepdims=True), arr.max(axis=1, keepdims=True)
        denom = np.where(hi - lo > 0, hi - lo, 1.0)
        return (arr - lo) / denom

    norm_mi = _norm(np.asarray(all_morans_i, dtype=np.float64))
    norm_var = _norm(np.asarray(all_variance, dtype=np.float64))
    g2 = (norm_mi + norm_var).mean(axis=0)
    return g2


def simplified_image(labels: np.ndarray, img: np.ndarray) -> np.ndarray:
    """Replace each region with its mean colour. Port of fSimplifyImage.m."""
    img = np.asarray(img, dtype=np.float64)
    out = np.zeros_like(img)
    for prop in regionprops(labels):
        idx = prop.coords
        mean_colour = img[idx[:, 0], idx[:, 1]].mean(axis=0)
        out[idx[:, 0], idx[:, 1]] = mean_colour
    return out


def psnr(img: np.ndarray, simplified: np.ndarray, max_val: float = 255.0) -> float:
    """Peak Signal-to-Noise Ratio between original and simplified image.

    Port of fFindSegmentationAccuracy.m (PSNR part).

    Args:
        img: H×W×C original image.
        simplified: H×W×C reconstructed (simplified) image.
        max_val: Maximum pixel value (default 255).

    Returns:
        PSNR in dB. Returns inf if images are identical.
    """
    mse = float(np.mean((img - simplified) ** 2))
    if mse == 0.0:
        return float("inf")
    return 10.0 * np.log10(max_val ** 2 / mse)
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_evaluation.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/evaluation.py tests/test_evaluation.py
git commit -m "feat: add G2 goodness metric, simplified_image, PSNR"
```

---

### Task 14: Automatic parameter selection

**Files:**
- Create: `watershed_seg/auto_params.py`
- Create: `tests/test_auto_params.py`

**Background:** `fAutomaticSelectRM1ScaleThreshold.m` sweeps a range of thresholds, runs RM1 at each step, evaluates Moran's I + variance, computes G2, picks the minimum. Same pattern for EPSF window, H-image window, and RM2 threshold.

**Step 1: Write the failing test**

```python
# tests/test_auto_params.py
import numpy as np
import pytest
from watershed_seg.auto_params import auto_select_rm1_threshold

def test_auto_select_returns_int(tiny_label_map, tiny_rgb):
    thresh = auto_select_rm1_threshold(
        tiny_label_map, tiny_rgb,
        search_range=range(1, 5),
    )
    assert isinstance(thresh, int)

def test_auto_select_within_range(tiny_label_map, tiny_rgb):
    search = range(1, 5)
    thresh = auto_select_rm1_threshold(
        tiny_label_map, tiny_rgb,
        search_range=search,
    )
    assert thresh in search
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_auto_params.py -v
```

**Step 3: Implement `watershed_seg/auto_params.py`**

```python
"""Automatic parameter selection using the G2 metric.

Port of fAutomaticSelect*.m files.

Each function sweeps a parameter range, evaluates G2 (Moran's I +
normalised variance) at each step, and returns the value that minimises G2.
"""
from __future__ import annotations

import numpy as np
from typing import Iterable

from .merging import rm1, rm2
from .filters import epsf
from .watershed_input import h_image
from .evaluation import morans_i, intra_variance, goodness2


def _sweep(
    labels_fn,
    original_img: np.ndarray,
    search_range: Iterable[int | float],
) -> int | float:
    """Generic sweep helper. Evaluates G2 for each value in search_range."""
    original_img = np.asarray(original_img, dtype=np.float64)
    all_mi, all_var = [], []

    for val in search_range:
        labels = labels_fn(val)
        mi = morans_i(labels, original_img)
        var = intra_variance(labels, original_img)
        all_mi.append(mi)
        all_var.append(var)

    # all_mi shape: (S, C) → need (C, S) for goodness2
    mi_arr = np.array(all_mi).T    # C×S
    var_arr = np.array(all_var).T  # C×S
    g2 = goodness2(mi_arr, var_arr)

    best_idx = int(np.argmin(g2))
    return list(search_range)[best_idx]


def auto_select_rm1_threshold(
    init_labels: np.ndarray,
    img: np.ndarray,
    search_range: Iterable[int] = range(1, 101),
) -> int:
    """Auto-select RM1 size threshold. Port of fAutomaticSelectRM1ScaleThreshold.m."""
    return _sweep(
        lambda t: rm1(init_labels, img, size_threshold=t),
        img,
        search_range,
    )


def auto_select_rm2_threshold(
    init_labels: np.ndarray,
    img: np.ndarray,
    search_range: Iterable[float] = range(100, 10001, 100),
) -> float:
    """Auto-select RM2 cost threshold. Port of fAutomaticSelectRM2ScaleThreshold.m."""
    return _sweep(
        lambda t: rm2(init_labels, img, cost_threshold=t),
        img,
        search_range,
    )


def auto_select_epsf_window(
    img: np.ndarray,
    watershed_fn,
    search_range: Iterable[int] = range(3, 16, 2),
) -> int:
    """Auto-select EPSF window size. Port of fAutomaticSelectEPSFWindowSize.m."""
    return _sweep(
        lambda w: watershed_fn(epsf(img, w=w)),
        img,
        search_range,
    )


def auto_select_h_image_window(
    filtered_img: np.ndarray,
    watershed_fn,
    search_range: Iterable[int] = range(3, 16, 2),
) -> int:
    """Auto-select H-image window size. Port of fAutomaticSelectH_ImageWindowSize.m."""
    return _sweep(
        lambda w: watershed_fn(h_image(filtered_img, w=w)),
        filtered_img,
        search_range,
    )
```

**Step 4: Run — expect PASS**

```bash
pytest tests/test_auto_params.py -v
```

**Step 5: Commit**

```bash
git add watershed_seg/auto_params.py tests/test_auto_params.py
git commit -m "feat: implement automatic parameter selection via G2 sweep"
```

---

### Task 15: Public Pipeline API

**Files:**
- Create: `watershed_seg/pipeline.py`
- Modify: `watershed_seg/__init__.py`
- Create: `tests/test_pipeline.py`

**Step 1: Write the failing test**

```python
# tests/test_pipeline.py
import numpy as np
import pytest
from watershed_seg import Pipeline, segment

def test_pipeline_run_returns_label_map(tiny_rgb):
    p = Pipeline()
    result = p.run(tiny_rgb)
    assert result.labels.shape == tiny_rgb.shape[:2]
    assert result.labels.dtype == np.int32

def test_pipeline_run_labels_positive(tiny_rgb):
    p = Pipeline()
    result = p.run(tiny_rgb)
    assert result.labels.min() >= 1

def test_segment_shortcut(tiny_rgb):
    result = segment(tiny_rgb, auto_params=False)
    assert result.labels.shape == tiny_rgb.shape[:2]

def test_pipeline_n_segments(tiny_rgb):
    p = Pipeline(rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    assert result.n_segments == result.labels.max()

def test_pipeline_intermediates(tiny_rgb):
    p = Pipeline(rm1_threshold=1, rm2_threshold=0)
    result = p.run(tiny_rgb)
    assert result.filtered_img is not None
    assert result.gradient_img is not None
    assert result.watershed_labels is not None
```

**Step 2: Run — expect ImportError**

```bash
pytest tests/test_pipeline.py -v
```

**Step 3: Create `watershed_seg/pipeline.py`**

```python
"""High-level Pipeline API. Orchestrates the four segmentation stages."""
from __future__ import annotations
from dataclasses import dataclass, field
import numpy as np

from .filters import epsf
from .watershed_input import h_image
from .watershed import vincent_soille
from .merging import rm3
from .auto_params import (
    auto_select_rm1_threshold, auto_select_rm2_threshold,
    auto_select_epsf_window, auto_select_h_image_window,
)


@dataclass
class SegmentationResult:
    """Output of Pipeline.run()."""
    labels: np.ndarray            # H×W int32 label map (1-based)
    n_segments: int
    filtered_img: np.ndarray      # after pre-filter
    gradient_img: np.ndarray      # H-image or MSGM
    watershed_labels: np.ndarray  # before region merging
    params: dict = field(default_factory=dict)


class Pipeline:
    """Configurable segmentation pipeline.

    Defaults match the thesis-selected combination:
        EPSF → H-image → Vincent-Soille watershed → RM3

    Args:
        prefilter: 'epsf' | 'pgf' | 'vectoral_median' | None
        prefilter_w: Pre-filter window size (odd int).
        ws_input: 'h_image' | 'msgm'
        ws_input_w: Watershed input window size (H-image only).
        watershed: 'vincent_soille' | 'rainfalling'
        merging: 'rm3' | 'rm1' | 'rm2'
        rm1_threshold: Size threshold for RM1 stage (pixels).
        rm2_threshold: Heterogeneity cost threshold for RM2 stage.
    """

    def __init__(
        self,
        prefilter: str = "epsf",
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

    def run(self, img: np.ndarray, auto_params: bool = False) -> SegmentationResult:
        """Run the full pipeline on an image.

        Args:
            img: H×W×C float64 array in [0, 255].
            auto_params: If True, use G2-based automatic parameter selection
                for pre-filter window, H-image window, and merging thresholds.

        Returns:
            SegmentationResult with label map and intermediate results.
        """
        img = np.asarray(img, dtype=np.float64)

        # --- Stage 1: Pre-filtering ---
        if self.prefilter == "epsf":
            from .filters import epsf as _filter
            filtered = _filter(img, w=self.prefilter_w)
        elif self.prefilter == "pgf":
            from .filters import pgf as _filter
            filtered = _filter(img, w=self.prefilter_w)
        elif self.prefilter == "vectoral_median":
            from .filters import vectoral_median as _filter
            filtered = _filter(img, w=self.prefilter_w)
        else:
            filtered = img.copy()

        # --- Stage 2: Watershed input ---
        if self.ws_input == "h_image":
            gradient = h_image(filtered, w=self.ws_input_w)
        else:
            from .watershed_input import msgm
            gradient = msgm(filtered)

        # --- Stage 3: Watershed ---
        if self.watershed == "vincent_soille":
            ws_labels = vincent_soille(gradient)
        else:
            from .watershed import rainfalling
            ws_labels = rainfalling(gradient)

        # --- Stage 4: Region merging ---
        rm1_t = self.rm1_threshold
        rm2_t = self.rm2_threshold

        if auto_params:
            rm1_t = auto_select_rm1_threshold(ws_labels, img)
            rm2_t = auto_select_rm2_threshold(ws_labels, img)

        if self.merging == "rm3":
            final_labels = rm3(ws_labels, img, rm1_t, rm2_t)
        elif self.merging == "rm1":
            from .merging import rm1
            final_labels = rm1(ws_labels, img, rm1_t)
        else:
            from .merging import rm2
            final_labels = rm2(ws_labels, img, rm2_t)

        return SegmentationResult(
            labels=final_labels,
            n_segments=int(final_labels.max()),
            filtered_img=filtered,
            gradient_img=gradient,
            watershed_labels=ws_labels,
            params={
                "rm1_threshold": rm1_t,
                "rm2_threshold": rm2_t,
                "prefilter_w": self.prefilter_w,
                "ws_input_w": self.ws_input_w,
            },
        )


def segment(
    img: np.ndarray,
    auto_params: bool = True,
    **pipeline_kwargs,
) -> SegmentationResult:
    """Convenience function: run Pipeline with thesis defaults.

    Args:
        img: H×W×C float64 array in [0, 255].
        auto_params: Use G2-based auto parameter selection (default True).
        **pipeline_kwargs: Passed to Pipeline constructor.

    Returns:
        SegmentationResult.
    """
    return Pipeline(**pipeline_kwargs).run(img, auto_params=auto_params)


def evaluate(result: SegmentationResult, ground_truth: np.ndarray | None = None):
    """Evaluate a segmentation result.

    If ground_truth is provided: returns supervised (E1, E2).
    Otherwise: returns unsupervised (Moran's I, variance, PSNR, G2-style metrics).
    """
    from .evaluation import supervised_eval, morans_i, intra_variance, psnr, simplified_image
    if ground_truth is not None:
        e1, e2 = supervised_eval(ground_truth, result.labels)
        return {"E1": e1, "E2": e2}
    else:
        mi = morans_i(result.labels, result.filtered_img)
        var = intra_variance(result.labels, result.filtered_img)
        simp = simplified_image(result.labels, result.filtered_img)
        ps = psnr(result.filtered_img, simp)
        return {"morans_i": mi, "variance": var, "psnr": ps}
```

**Step 4: Update `watershed_seg/__init__.py`**

```python
"""watershed_seg: Automatic multi-scale segmentation of satellite images."""
from .pipeline import Pipeline, segment, evaluate

__all__ = ["Pipeline", "segment", "evaluate"]
```

**Step 5: Run — expect PASS**

```bash
pytest tests/test_pipeline.py -v
```

**Step 6: Run full test suite**

```bash
pytest tests/ -v
```

Expected: All green.

**Step 7: Commit**

```bash
git add watershed_seg/pipeline.py watershed_seg/__init__.py tests/test_pipeline.py
git commit -m "feat: implement Pipeline public API and segment() convenience function"
```

---

### Task 16: End-to-end integration test

**Files:**
- Create: `tests/test_e2e.py`

**Step 1: Write the test**

```python
# tests/test_e2e.py
"""End-to-end test: runs the full pipeline on a synthetic image."""
import numpy as np
import pytest
from watershed_seg import Pipeline, segment, evaluate


def _synthetic_image(seed: int = 0) -> np.ndarray:
    """32×32 3-band image with 4 distinct quadrant regions."""
    rng = np.random.default_rng(seed)
    img = np.zeros((32, 32, 3), dtype=np.float64)
    img[:16, :16] = rng.uniform(200, 220, (16, 16, 3))  # bright top-left
    img[:16, 16:] = rng.uniform(50, 70, (16, 16, 3))    # dark top-right
    img[16:, :16] = rng.uniform(100, 120, (16, 16, 3))  # mid bottom-left
    img[16:, 16:] = rng.uniform(150, 170, (16, 16, 3))  # mid bottom-right
    return img


def test_full_pipeline_runs():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=10, rm2_threshold=500)
    result = p.run(img)
    assert result.labels.shape == (32, 32)
    assert result.n_segments >= 1


def test_full_pipeline_finds_regions():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=5, rm2_threshold=200)
    result = p.run(img)
    # Should find somewhere between 1 and ~50 segments
    assert 1 <= result.n_segments <= 50


def test_evaluate_unsupervised():
    img = _synthetic_image()
    p = Pipeline(rm1_threshold=5, rm2_threshold=200)
    result = p.run(img)
    metrics = evaluate(result)
    assert "morans_i" in metrics
    assert "psnr" in metrics
    assert metrics["psnr"] > 0


def test_evaluate_supervised():
    img = _synthetic_image()
    gt = np.zeros((32, 32), dtype=np.int32)
    gt[:16, :16] = 1
    gt[:16, 16:] = 2
    gt[16:, :16] = 3
    gt[16:, 16:] = 4

    p = Pipeline(rm1_threshold=5, rm2_threshold=200)
    result = p.run(img)
    metrics = evaluate(result, ground_truth=gt)
    assert "E1" in metrics
    assert "E2" in metrics
    assert 0.0 <= metrics["E1"] <= 100.0
    assert 0.0 <= metrics["E2"] <= 100.0


def test_all_merging_modes_run():
    img = _synthetic_image()
    for mode, kwargs in [
        ("rm1", {"rm1_threshold": 10}),
        ("rm2", {"rm2_threshold": 500}),
        ("rm3", {"rm1_threshold": 10, "rm2_threshold": 500}),
    ]:
        p = Pipeline(merging=mode, **kwargs)
        result = p.run(img)
        assert result.labels.shape == img.shape[:2]


def test_all_prefilters_run():
    img = _synthetic_image()
    for mode in ["epsf", "pgf", "vectoral_median", None]:
        p = Pipeline(prefilter=mode, rm1_threshold=10, rm2_threshold=500)
        result = p.run(img)
        assert result.labels.shape == img.shape[:2]
```

**Step 2: Run — expect PASS**

```bash
pytest tests/test_e2e.py -v
```

**Step 3: Run full test suite**

```bash
pytest tests/ -v --tb=short
```

Expected: All tests pass.

**Step 4: Commit**

```bash
git add tests/test_e2e.py
git commit -m "test: add end-to-end integration tests for full pipeline"
```

---

### Task 17: Notebook 01 — Pipeline walkthrough

**Files:**
- Create: `notebooks/01_pipeline_walkthrough.ipynb`

**Step 1: Create the notebook**

Create `notebooks/01_pipeline_walkthrough.ipynb` with these cells (use `jupyter nbconvert --to notebook` or write JSON directly):

**Cell 1 (markdown):**
```markdown
# Pipeline Walkthrough

End-to-end satellite image segmentation using the thesis pipeline:
**EPSF → H-image → Vincent-Soille watershed → RM3**
```

**Cell 2 (code):**
```python
import numpy as np
import matplotlib.pyplot as plt
from watershed_seg import Pipeline, evaluate
from watershed_seg.filters import epsf
from watershed_seg.watershed_input import h_image
from watershed_seg.watershed import vincent_soille
from watershed_seg.merging import rm3

# Load an image — replace with your actual satellite image path
# img = np.load("../data/image1.npy")  # H×W×C float64, values 0-255

# Synthetic demo if no real image available
rng = np.random.default_rng(42)
img = np.zeros((64, 64, 3))
img[:32, :32] = rng.uniform(200, 220, (32, 32, 3))
img[:32, 32:] = rng.uniform(50, 70, (32, 32, 3))
img[32:, :32] = rng.uniform(100, 120, (32, 32, 3))
img[32:, 32:] = rng.uniform(150, 170, (32, 32, 3))
print(f"Image shape: {img.shape}, dtype: {img.dtype}")
```

**Cell 3 (code — stage 1):**
```python
# Stage 1: EPSF pre-filter
filtered = epsf(img, w=5)

fig, axes = plt.subplots(1, 2, figsize=(10, 4))
axes[0].imshow(img.astype(np.uint8))
axes[0].set_title("Original")
axes[1].imshow(filtered.astype(np.uint8))
axes[1].set_title("EPSF filtered (w=5)")
plt.tight_layout()
plt.show()
```

**Cell 4 (code — stage 2):**
```python
# Stage 2: H-image
gradient = h_image(filtered, w=7)

plt.figure(figsize=(5, 4))
plt.imshow(gradient, cmap="hot")
plt.colorbar(label="H-image value")
plt.title("H-image (w=7)")
plt.show()
print(f"H-image range: [{gradient.min():.2f}, {gradient.max():.2f}]")
```

**Cell 5 (code — stages 3 & 4):**
```python
# Stage 3: Watershed
ws_labels = vincent_soille(gradient)
print(f"Watershed segments: {ws_labels.max()}")

# Stage 4: RM3 merging
final_labels = rm3(ws_labels, img, size_threshold=20, cost_threshold=500)
print(f"Final segments: {final_labels.max()}")
```

**Cell 6 (code — visualise):**
```python
fig, axes = plt.subplots(1, 3, figsize=(15, 4))
axes[0].imshow(ws_labels, cmap="tab20")
axes[0].set_title(f"After watershed ({ws_labels.max()} segs)")
axes[1].imshow(final_labels, cmap="tab20")
axes[1].set_title(f"After RM3 ({final_labels.max()} segs)")
axes[2].imshow(img.astype(np.uint8))
axes[2].set_title("Original")
plt.tight_layout()
plt.show()
```

**Step 2: Verify notebook runs**

```bash
jupyter nbconvert --to notebook --execute notebooks/01_pipeline_walkthrough.ipynb \
    --output notebooks/01_pipeline_walkthrough.ipynb
```

Expected: No errors.

**Step 3: Commit**

```bash
git add notebooks/01_pipeline_walkthrough.ipynb
git commit -m "docs: add pipeline walkthrough notebook"
```

---

### Task 18: Notebook 02 — Algorithm comparison

**Files:**
- Create: `notebooks/02_algorithm_comparison.ipynb`

**Step 1: Create the notebook** with cells that:
1. Load a sample image
2. Compare pre-filters (EPSF vs PGF) side-by-side with PSNR
3. Compare watershed inputs (H-image vs MSGM): show gradient image and resulting segment count
4. Compare merging methods (RM1 vs RM2 vs RM3): show final label maps and segment counts

Each comparison cell calls the relevant function and shows `plt.imshow` side-by-side with a title showing segment count.

**Step 2: Verify notebook runs**

```bash
jupyter nbconvert --to notebook --execute notebooks/02_algorithm_comparison.ipynb \
    --output notebooks/02_algorithm_comparison.ipynb
```

**Step 3: Commit**

```bash
git add notebooks/02_algorithm_comparison.ipynb
git commit -m "docs: add algorithm comparison notebook"
```

---

### Task 19: Notebook 03 — Automatic parameter selection

**Files:**
- Create: `notebooks/03_auto_parameter_selection.ipynb`

**Step 1: Create the notebook** with cells that:
1. Run `auto_select_rm1_threshold` over a range (e.g., 1..50) and plot G2 vs threshold
2. Mark the selected optimum on the plot
3. Compare auto-selected result vs a manual (fixed) threshold visually

```python
from watershed_seg.auto_params import auto_select_rm1_threshold
from watershed_seg.evaluation import morans_i, intra_variance, goodness2
from watershed_seg.merging import rm1

# Collect G2 across sweep manually to plot the curve
search = range(1, 51)
all_mi, all_var = [], []
for t in search:
    lbl = rm1(ws_labels, img, size_threshold=t)
    all_mi.append(morans_i(lbl, img))
    all_var.append(intra_variance(lbl, img))

mi_arr = np.array(all_mi).T
var_arr = np.array(all_var).T
g2 = goodness2(mi_arr, var_arr)

plt.plot(list(search), g2)
plt.xlabel("RM1 size threshold")
plt.ylabel("G2 (lower = better)")
plt.title("G2 curve for RM1 threshold sweep")
plt.axvline(x=list(search)[g2.argmin()], color='r', label='auto-selected')
plt.legend()
plt.show()
```

**Step 2: Verify notebook runs**

```bash
jupyter nbconvert --to notebook --execute notebooks/03_auto_parameter_selection.ipynb \
    --output notebooks/03_auto_parameter_selection.ipynb
```

**Step 3: Commit**

```bash
git add notebooks/03_auto_parameter_selection.ipynb
git commit -m "docs: add automatic parameter selection notebook"
```

---

### Task 20: Final verification

**Step 1: Run full test suite**

```bash
pytest tests/ -v
```

Expected: All tests pass. No warnings about missing imports.

**Step 2: Verify install from scratch**

```bash
pip install -e ".[dev]"
python -c "from watershed_seg import Pipeline, segment, evaluate; print('All imports OK')"
```

**Step 3: Check no stray MATLAB files in root**

```bash
ls *.m 2>/dev/null && echo "FOUND STRAY .m FILES" || echo "Clean"
```

Expected: `Clean`

**Step 4: Final commit**

```bash
git add -A
git commit -m "chore: final cleanup and verification"
```
