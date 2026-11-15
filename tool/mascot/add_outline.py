"""Membuat salinan animasi maskot dengan garis tepi gelap (TASK-M075 tahap poles chat maskot).

Maskot berwarna putih, jadi menyatu dengan latar terang. Skrip ini membaca
`assets/images/mascot/anim/{state}.webp`, menebalkan alfa (jarak Euclid, tepi halus), mengisi
tebalan itu dengan warna garis, lalu menaruh bingkai asli di atasnya. Hasil ke
`assets/images/mascot/outlined/{state}.webp`. Kanvas diberi bantalan di kiri, kanan, dan atas
supaya garis tidak terpotong; bawah tidak, karena badan terpotong di tepi bawah (setengah badan).

Pakai (dari akar repo):  python3 tool/mascot/add_outline.py
Butuh: pillow, numpy, scipy. Warna dan tebal garis diatur lewat konstanta di bawah.
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy.ndimage import distance_transform_edt

OUTLINE_RGB = (15, 23, 42)  # hampir hitam dengan sedikit biru navy
OUTLINE_PX = 4.0  # tebal garis pada resolusi berkas (360 px lebar)
PAD = 8  # bantalan kiri, kanan, atas (px)
STATES = ("idle", "thinking", "speaking")
STILL_SRC = "relaxmate-half.webp"  # gambar diam (gerak dikurangi), 476 px lebar
STILL_WIDTH = 476

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "assets/images/mascot/anim"
DST = ROOT / "assets/images/mascot/outlined"


def outline_frame(frame: Image.Image, scale: float = 1.0) -> Image.Image:
    outline_px = OUTLINE_PX * scale
    pad = int(round(PAD * scale))
    rgba = np.asarray(frame.convert("RGBA"), dtype=np.float32)
    h, w = rgba.shape[:2]
    canvas = np.zeros((h + pad, w + 2 * pad, 4), dtype=np.float32)
    canvas[pad:, pad : pad + w] = rgba
    alpha = canvas[..., 3] / 255.0
    # Jarak tiap piksel ke piksel tubuh terdekat (alfa > 0,5); 0 di dalam tubuh.
    dist = distance_transform_edt(alpha < 0.5)
    ring = np.clip(outline_px + 0.5 - dist, 0.0, 1.0)
    # Di tepi bawah kanvas tidak ada garis: badan memang terpotong di sana.
    edge = int(outline_px) + 1
    ring[-edge:, :] = np.where(alpha[-edge:, :] > 0.5, ring[-edge:, :], 0.0)
    ring = np.maximum(ring, alpha)
    base = np.zeros_like(canvas)
    base[..., 0], base[..., 1], base[..., 2] = OUTLINE_RGB
    base[..., 3] = ring * 255.0
    # Komposisi "over": bingkai asli di atas lapisan garis.
    a_top = alpha[..., None]
    rgb = canvas[..., :3] * a_top + base[..., :3] * (1 - a_top)
    out_a = np.maximum(canvas[..., 3], base[..., 3])
    out = np.dstack([rgb, out_a]).clip(0, 255).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


def main() -> None:
    DST.mkdir(parents=True, exist_ok=True)
    still = Image.open(SRC.parent / STILL_SRC)
    outline_frame(still, scale=still.width / 360.0).save(
        DST / "still.webp", quality=90, alpha_quality=100, method=6
    )
    print("still", still.size)
    for state in STATES:
        src = Image.open(SRC / f"{state}.webp")
        frames, durations = [], []
        for index in range(getattr(src, "n_frames", 1)):
            src.seek(index)
            durations.append(src.info.get("duration", 42))
            frames.append(outline_frame(src.copy()))
        frames[0].save(
            DST / f"{state}.webp",
            save_all=True,
            append_images=frames[1:],
            duration=durations,
            loop=0,
            quality=70,
            alpha_quality=85,
            method=6,
            lossless=False,
        )
        print(state, len(frames), "frames", frames[0].size)


if __name__ == "__main__":
    main()
