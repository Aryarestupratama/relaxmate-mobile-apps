#!/usr/bin/env python3
"""Membangun ikon aplikasi RelaxMate dari gambar logo founder (TASK-M070).

Sumber: `design/branding/source/icon_full_1600.png` (logo robot di atas latar navy, dari Canva,
aslinya 3200 px). Butuh Pillow dan numpy. Jalankan dari akar proyek:

    python3 design/branding/build_icons.py

Keluaran: PNG di android/app/src/main/res/ (ikon peluncur biasa, lapisan depan adaptif, lapisan
monokrom, ikon status bar notifikasi, definisi XML) dan design/branding/play_store_icon_512.png.
"""
from pathlib import Path

import numpy as np
from PIL import Image

NAVY = (20, 40, 70)  # rata-rata latar sumber
NAVY_HEX = "#142846"
HERE = Path(__file__).parent
RES = Path("android/app/src/main/res")
SAFE_RADIUS = 0.31  # zona aman adaptif: lingkaran 66 dp dari kanvas 108 dp (radius 0,3056)

src = Image.open(HERE / "source" / "icon_full_1600.png").convert("RGB")
arr = np.asarray(src).astype(float)
dist = np.sqrt(((arr - np.array(NAVY)) ** 2).sum(axis=2))


def smooth(d, lo, hi):
    t = np.clip((d - lo) / (hi - lo), 0, 1)
    return t * t * (3 - 2 * t)


def layer(alpha, black):
    rgb = np.zeros_like(arr) if black else arr
    out = np.dstack([rgb, alpha * 255]).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


color_layer = layer(smooth(dist, 6, 60), black=False)  # latar navy menjadi transparan
mono_layer = layer(smooth(dist, 25, 90), black=True)  # siluet; layar dan latar transparan

solid = np.asarray(color_layer.getchannel("A")) > 128
ys, xs = np.where(solid)
cx, cy = (xs.min() + xs.max()) / 2, (ys.min() + ys.max()) / 2
max_r = np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2).max()


def place(layer_img: Image.Image, canvas: int, radius_frac: float) -> Image.Image:
    """Menaruh isi di tengah kanvas; titik terjauh isi berada pada radius_frac * kanvas dari pusat."""
    scale = radius_frac * canvas / max_r
    w = round(layer_img.width * scale)
    scaled = layer_img.resize((w, w), Image.LANCZOS)
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    out.alpha_composite(scaled, (round(canvas / 2 - cx * scale), round(canvas / 2 - cy * scale)))
    return out


def save(img: Image.Image, path: Path, px: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.resize((px, px), Image.LANCZOS).save(path, optimize=True)


# Ikon biasa (cadangan) dan Play Store: gambar asli utuh, latar penuh tanpa sudut membulat.
for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    save(src, RES / f"mipmap-{folder}" / "ic_launcher.png", px)
save(src, HERE / "play_store_icon_512.png", 512)

# Adaptif: depan berwarna dan monokrom, master 1296 px lalu diperkecil per kerapatan.
fg_master = place(color_layer, 1296, SAFE_RADIUS)
mo_master = place(mono_layer, 1296, SAFE_RADIUS)
for folder, px in {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}.items():
    save(fg_master, RES / f"mipmap-{folder}" / "ic_launcher_foreground.png", px)
    save(mo_master, RES / f"mipmap-{folder}" / "ic_launcher_monochrome.png", px)

# Ikon status bar notifikasi: siluet putih memenuhi ~90% kanvas 24 dp.
stat_master = place(mono_layer, 960, 0.45)
for folder, px in {"mdpi": 24, "hdpi": 36, "xhdpi": 48, "xxhdpi": 72, "xxxhdpi": 96}.items():
    save(stat_master, RES / f"drawable-{folder}" / "ic_stat_relaxmate.png", px)

(RES / "values" / "ic_launcher_background.xml").write_text(
    f'<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">{NAVY_HEX}</color>\n</resources>\n'
)
(RES / "mipmap-anydpi-v26").mkdir(exist_ok=True)
(RES / "mipmap-anydpi-v26" / "ic_launcher.xml").write_text(
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <background android:drawable="@color/ic_launcher_background" />\n'
    '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
    '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />\n'
    '</adaptive-icon>\n'
)
print("selesai; radius isi terjauh (px sumber):", round(max_r))
