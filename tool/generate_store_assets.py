#!/usr/bin/env python3
"""
Google Play store graphic generator for Alphabet Adventure 3D.

Produces the two graphics Play requires alongside the screenshots:
  store/play/icon_512.png              512x512  opaque PNG (store listing icon)
  store/play/feature_graphic_1024x500.png       opaque PNG (banner)

Both are derived from the shipped launcher icon so the store listing and the
launcher stay visually identical. Run:  python3 tool/generate_store_assets.py
"""

import os
from PIL import Image, ImageDraw, ImageFont

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UI_DIR = os.path.join(PROJECT_ROOT, "assets", "images", "ui")
OUT_DIR = os.path.join(PROJECT_ROOT, "store", "play")

# Brand palette, mirrored from lib/ui/core/app_colors.dart
CORAL = (255, 107, 107)
CORAL_DARK = (229, 75, 75)
TEAL_DARK = (56, 178, 169)
YELLOW = (255, 209, 102)
YELLOW_DARK = (244, 184, 37)
CREAM = (255, 247, 214)
SKY = (232, 247, 255)
TEXT_DARK = (45, 49, 66)

ROUNDED = "/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf"
FALLBACK = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def font(size):
    path = ROUNDED if os.path.exists(ROUNDED) else FALLBACK
    return ImageFont.truetype(path, size)


def flatten(img, bg):
    """Composite an RGBA image onto an opaque background."""
    out = Image.new("RGB", img.size, bg)
    out.paste(img, (0, 0), img)
    return out


def generate_icon():
    """512x512 opaque store icon, downscaled from the 1024 launcher icon."""
    src = Image.open(os.path.join(UI_DIR, "app_icon.png")).convert("RGBA")
    icon = src.resize((512, 512), Image.LANCZOS)
    out = flatten(icon, CORAL)
    path = os.path.join(OUT_DIR, "icon_512.png")
    out.save(path, "PNG")
    return path


def _gradient(w, h, top, bottom):
    grad = Image.new("RGB", (1, h))
    px = grad.load()
    for y in range(h):
        t = y / max(1, h - 1)
        px[0, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    return grad.resize((w, h), Image.BICUBIC)


def _text(draw, xy, text, fnt, fill, shadow=None, offset=4, anchor="la"):
    if shadow:
        draw.text((xy[0], xy[1] + offset), text, font=fnt, fill=shadow, anchor=anchor)
    draw.text(xy, text, font=fnt, fill=fill, anchor=anchor)


def _star(draw, cx, cy, r, fill):
    import math
    pts = []
    for i in range(10):
        rad = r if i % 2 == 0 else r * 0.45
        a = math.pi / 2 * 3 + i * math.pi / 5
        pts.append((cx + math.cos(a) * rad, cy + math.sin(a) * rad))
    draw.polygon(pts, fill=fill)


def fit_font(draw, text, max_w, start):
    """Largest font size at or below `start` that keeps `text` within max_w."""
    size = start
    while size > 8 and draw.textlength(text, font=font(size)) > max_w:
        size -= 1
    return font(size)


def generate_feature_graphic():
    """1024x500 opaque banner."""
    W, H = 1024, 500
    img = _gradient(W, H, CREAM, SKY)
    draw = ImageDraw.Draw(img, "RGBA")

    # Text column, kept clear of the mascot and inside a safe margin
    TX, TR = 452, 992
    TW = TR - TX

    # Faint scattered alphabet, confined to the mascot side and the edges so it
    # never sits behind the wordmark
    ghosts = [
        ("A", 58, 66, 92), ("B", 292, 396, 74), ("D", 214, 58, 62),
        ("E", 60, 300, 56), ("Z", 372, 168, 48), ("C", 150, 452, 52),
    ]
    for ch, x, y, size in ghosts:
        draw.text((x, y), ch, font=font(size), fill=CORAL + (34,), anchor="mm")

    # Pip, lifted straight from the launcher icon foreground
    pip = Image.open(os.path.join(UI_DIR, "app_icon_foreground.png")).convert("RGBA")
    pip = pip.resize((392, 392), Image.LANCZOS)
    img.paste(pip, (34, 62), pip)

    # Wordmark line 1
    f1 = fit_font(draw, "ALPHABET", TW, 96)
    _text(draw, (TX, 128), "ALPHABET", f1, CORAL, CORAL_DARK, 6, "lm")

    # Wordmark line 2 + the 3D badge, sized together to share the column
    badge_w, badge_h, gap = 92, 66, 18
    f2 = fit_font(draw, "ADVENTURE", TW - badge_w - gap, 70)
    _text(draw, (TX, 232), "ADVENTURE", f2, TEAL_DARK, (44, 150, 142), 5, "lm")

    bx0 = TX + draw.textlength("ADVENTURE", font=f2) + gap
    bx1, by0, by1 = bx0 + badge_w, 232 - badge_h // 2, 232 + badge_h // 2
    draw.rounded_rectangle([bx0, by0 + 5, bx1, by1 + 5], 18, fill=YELLOW_DARK)
    draw.rounded_rectangle([bx0, by0, bx1, by1], 18, fill=YELLOW, outline=YELLOW_DARK, width=4)
    _text(draw, ((bx0 + bx1) / 2, 234), "3D", font(42), TEXT_DARK, anchor="mm")

    # Tagline pill, auto-fitted to the same column
    tag = "Letters - Sounds - First Words - Ages 4-8"
    pad = 30
    ft = fit_font(draw, tag, TW - 2 * pad, 34)
    tw = draw.textlength(tag, font=ft)
    px0, py0, ph = TX, 306, 66
    draw.rounded_rectangle([px0, py0, px0 + tw + 2 * pad, py0 + ph], ph // 2,
                           fill=(255, 255, 255, 232))
    _text(draw, (px0 + pad, py0 + ph / 2), tag, ft, TEXT_DARK, anchor="lm")

    # Reassurance line, the strongest differentiator for a kids app
    reassure = "No ads  -  No in-app purchases  -  Works offline"
    fs = fit_font(draw, reassure, TW, 28)
    _text(draw, (TX, 418), reassure, fs, (100, 108, 122), anchor="lm")

    # A few celebratory stars, clear of the text column
    for cx, cy, r in ((418, 96, 22), (410, 330, 16), (128, 452, 14)):
        _star(draw, cx, cy, r, YELLOW)

    path = os.path.join(OUT_DIR, "feature_graphic_1024x500.png")
    img.save(path, "PNG")
    return path


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    for p in (generate_icon(), generate_feature_graphic()):
        im = Image.open(p)
        print(f"  {os.path.relpath(p, PROJECT_ROOT)}  {im.size[0]}x{im.size[1]}  {im.mode}  "
              f"{os.path.getsize(p)/1024:.0f} KB")
