# gps-spoofer-app/tools/generate_brand_pngs.py
#
# Procedurally generate the four BenessereBot brand-asset PNGs:
#   - icon.png            1024x1024 gradient plate + B + dot + halo
#   - splash-icon.png     1024x1024 identical to icon.png (Expo splash
#                         uses app.json's splash.backgroundColor as the
#                         background, so we keep the PNG foreground-only)
#   - adaptive-icon.png   1024x1024 transparent bg, monogram + dot only
#                         (Android adaptive icon foreground; gets
#                         masked to circle / squircle / squircle-rounded
#                         depending on launcher's iconShape)
#   - favicon.png         48x48 simplified solid plate + B + dot, no
#                         halo, no gradient (web favicon — printed on
#                         browser tabs at <=48 px where gradient legibility
#                         collapses)
#
# This script mirrors src/components/BrandMark.js so the SVG and the
# system-level raster icons stay pixel-comparable: same colors, same
# geometry, same monogram TTF, same accent dot. Idempotent — re-running
# just overwrites the four files.
#
# Run from the project root:
#   python tools/generate_brand_pngs.py
#
# Cross-platform palette synced with src/constants/theme.js:
#   C.primary     = #FF7E67  (255, 126, 103)   coral mango
#   C.terracotta  = #FFA984  (255, 169, 132)   peach
#   C.accent      = #FFB800  (255, 184,   0)   goldenrod
# Monogram and text: pure #FFFFFF.

from __future__ import annotations

import os
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# ---- Brand tokens (must match src/constants/theme.js) ----
C_PRIMARY    = (0xFF, 0x7E, 0x67)   # coral mango
C_TERRACOTTA = (0xFF, 0xA9, 0x84)   # peach
C_ACCENT     = (0xFF, 0xB8, 0x00)   # goldenrod
WHITE        = (0xFF, 0xFF, 0xFF, 0xFF)

# ---- Font selection (Windows-first; mac/linux fallbacks if present) ----
FONT_CANDIDATES = [
    r"C:\Windows\Fonts\seguisb.ttf",     # Segoe UI Bold — primary
    r"C:\Windows\Fonts\arialbd.ttf",     # Arial Bold
    r"C:\Windows\Fonts\calibrib.ttf",    # Calibri Bold
    "/System/Library/Fonts/Helvetica.ttc",  # macOS
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",  # Linux
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
]

def find_font() -> str | None:
    for p in FONT_CANDIDATES:
        if os.path.exists(p):
            return p
    return None

FONT_PATH = find_font()
if FONT_PATH is None:
    print("WARN: no TTF font found; B will render with PIL's tiny default font",
          file=sys.stderr)
else:
    print(f"using font: {FONT_PATH}")

# Optional NumPy for the ~100x faster diagonal-gradient computation.
# lerp() polymorphically returns np.uint8 ndarray only when this is True.
try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False
    np = None  # never assigned elsewhere; gradient_diagonal falls back

# ---- Helpers ----

def lerp(a, b, t):
    """Polymorphic lerp. Returns np.uint8 ndarray when t is a numpy array
    (called from gradient_diagonal), or a plain Python int when t is a
    scalar (called from per-pixel fallback). Centralizing this avoids
    `int(round(numpy.ndarray))` NameErrors — Python's round() doesn't
    descend into numpy types."""
    out = a + (b - a) * t
    if HAS_NUMPY and isinstance(t, np.ndarray):
        return np.clip(out, 0, 255).astype(np.uint8)
    return int(round(out))

def lerp_rgb(c1, c2, t):
    return tuple(lerp(c1[i], c2[i], t) for i in range(3))

def gradient_diagonal(W: int, H: int) -> Image.Image:
    """Top-left -> bottom-right linear gradient between (0xFF, 0x7E, 0x67)
    and (0xFF, 0xA9, 0x84). Uses NumPy if available (much faster),
    otherwise a pure-Python per-pixel loop."""
    if HAS_NUMPY:
        t = (np.arange(W)[None, :] + np.arange(H)[:, None]) / (W + H - 2)
        arr = np.empty((H, W, 3), dtype=np.uint8)
        arr[..., 0] = lerp(C_PRIMARY[0], C_TERRACOTTA[0], t)
        arr[..., 1] = lerp(C_PRIMARY[1], C_TERRACOTTA[1], t)
        arr[..., 2] = lerp(C_PRIMARY[2], C_TERRACOTTA[2], t)
        return Image.fromarray(arr, "RGB")
    grad = Image.new("RGB", (W, H))
    px = grad.load()
    diag = (W - 1) + (H - 1)
    for y in range(H):
        for x in range(W):
            px[x, y] = lerp_rgb(C_PRIMARY, C_TERRACOTTA, (x + y) / diag)
    return grad

def rounded_rect_mask(W: int, H: int, radius: int) -> Image.Image:
    """1-bit mask: white (255) inside the rounded rect, black elsewhere."""
    mask = Image.new("L", (W, H), 0)
    draw = ImageDraw.Draw(mask)
    # PIL rounds radius down to min(W,H)/2 internally, so plain call works.
    draw.rounded_rectangle((0, 0, W - 1, H - 1), radius=radius, fill=255)
    return mask

def make_plate(W: int, H: int, *, gradient: bool) -> Image.Image:
    """Build the rounded plate. Returns an RGBA image."""
    if gradient:
        rgb = gradient_diagonal(W, H)
        base = rgb.convert("RGBA")
    else:
        base = Image.new("RGBA", (W, H), C_PRIMARY + (255,))
    mask = rounded_rect_mask(W, H, radius=int(0.22 * min(W, H)))
    base.putalpha(mask)
    return base

def make_halo(W: int, H: int) -> Image.Image:
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = W / 2.0, H / 2.0
    r = 0.48 * min(W, H)
    stroke = max(1, int(0.025 * min(W, H)))
    draw.ellipse(
        (cx - r, cy - r, cx + r, cy + r),
        outline=C_ACCENT + (128,),  # 50% alpha (128/255)
        width=stroke,
    )
    return im

def make_monogram(W: int, H: int, *, font_size_factor: float,
                  color=WHITE, offset_y_factor: float = 0.0) -> Image.Image:
    """Returns RGBA image with a centered 'B' glyph."""
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    if FONT_PATH is None:
        # Fallback: tiny default font — leaves a visible but ugly 'B'.
        draw.text((W * 0.30, H * 0.20), "B", fill=color)
        return im
    font = ImageFont.truetype(FONT_PATH, int(font_size_factor * min(W, H)))
    bbox = font.getbbox("B")  # (l, t, r, b)
    glyph_w = bbox[2] - bbox[0]
    glyph_h = bbox[3] - bbox[1]
    x = (W - glyph_w) / 2 - bbox[0]
    y = (H - glyph_h) / 2 - bbox[1] + offset_y_factor * min(W, H)
    draw.text((x, y), "B", font=font, fill=color)
    return im

def make_accent_dot(W: int, H: int, *, cx_factor: float, cy_factor: float,
                    r_factor: float) -> Image.Image:
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = cx_factor * W, cy_factor * H
    r = r_factor * min(W, H)
    draw.ellipse(
        (cx - r, cy - r, cx + r, cy + r),
        fill=C_ACCENT + (255,),
    )
    return im

def composite(layers: list[Image.Image]) -> Image.Image:
    W, H = layers[0].size
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    for ly in layers:
        out.alpha_composite(ly)
    return out

# ---- Per-asset generators ----

def generate_full_icon(W: int, *, gradient: bool) -> Image.Image:
    """'icon' / 'splash' variant: halo (optional) + plate + B + dot."""
    plate = make_plate(W, W, gradient=gradient)
    # Tighter monogram sizing: at 1024, font is ~520px tall; visually
    # ~50% of the plate (bowl height, not ascent). Slight downward
    # offset to compensate for uppercase letters' visual baseline.
    mark = make_monogram(W, W, font_size_factor=(0.78 if gradient else 0.84),
                         offset_y_factor=(0.06 if gradient else 0.04))
    dot = make_accent_dot(W, W, cx_factor=0.68, cy_factor=0.68, r_factor=0.04)
    return composite([plate, mark, dot])

def generate_haloed_icon(W: int) -> Image.Image:
    """'icon' / 'splash' variant WITH halo."""
    halo = make_halo(W, W)
    return composite([halo, generate_full_icon(W, gradient=True)])

def generate_adaptive_icon(W: int) -> Image.Image:
    """Android adaptive-icon foreground: transparent, just monogram + dot.
    Monogram sized down to fit Android's central 66% safe area after the
    launcher's iconShape mask crops it to circle/squircle."""
    mark = make_monogram(W, W, font_size_factor=0.55)
    dot = make_accent_dot(W, W, cx_factor=0.56, cy_factor=0.70, r_factor=0.035)
    return composite([mark, dot])

def generate_favicon(W: int = 48) -> Image.Image:
    """Simplified mark for browser tabs at <=48px. Solid coral plate,
    no gradient (gradient legibility collapses at 48px), no halo."""
    plate = make_plate(W, W, gradient=False)
    mark = make_monogram(W, W, font_size_factor=0.84, offset_y_factor=0.04)
    dot = make_accent_dot(W, W, cx_factor=0.70, cy_factor=0.72, r_factor=0.06)
    return composite([plate, mark, dot])

# ---- Main ----

def main():
    repo_root = Path(__file__).resolve().parent.parent
    assets = repo_root / "assets"
    assets.mkdir(parents=True, exist_ok=True)

    icon       = generate_haloed_icon(1024)
    splash     = generate_haloed_icon(1024)  # identical bytes to icon
    adaptive   = generate_adaptive_icon(1024)
    favicon    = generate_favicon(48)

    icon.save(assets / "icon.png",            format="PNG", optimize=True)
    splash.save(assets / "splash-icon.png",  format="PNG", optimize=True)
    adaptive.save(assets / "adaptive-icon.png", format="PNG", optimize=True)
    favicon.save(assets / "favicon.png",       format="PNG", optimize=True)

    print(f"wrote 4 PNGs into {assets}:")
    for p in ["icon.png", "splash-icon.png", "adaptive-icon.png", "favicon.png"]:
        full = assets / p
        kb = full.stat().st_size / 1024
        print(f"  {p:20s}  {kb:7.1f} KB")

if __name__ == "__main__":
    main()
