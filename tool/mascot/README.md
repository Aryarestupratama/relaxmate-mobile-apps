# Sumber animasi maskot (TASK-M030)

Animasi maskot di `assets/images/mascot/anim/*.webp` (idle, listening, thinking, speaking;
360x491 px, 24 fps, transparan, loop mulus) dirender dari rig SVG, bukan Rive. Alasan: paket
gratis Rive menyisipkan layar splash Rive pada berkas ekspor. Aplikasi tidak memakai paket
`rive`; Flutter memutar WebP beranimasi lewat `Image.asset`.

Berkas di sini hanya untuk membuat ulang aset (tidak ikut build aplikasi):

- `relaxmate-mascot-rig.svg`: rig berlapis (kepala, mata, mulut, antena, lengan, badan) dengan
  titik putar `data-pivot`.
- `build_rig.py` dan `pad.mjs`: pembuat rig (hanya bila bentuk karakter diubah).
- `anim.mjs`: tabel keyframe empat keadaan, merender bingkai PNG transparan lewat Chromium
  (Playwright). Bingkai dirangkai menjadi WebP dengan Pillow
  (`save_all=True, duration=round(1000/24), loop=0, quality=60, alpha_quality=70, method=6`).

Pakai: `node anim.mjs "$(npm root -g)" 360` (butuh Playwright global), lalu rangkai
`anim/{state}_NNN.png` menjadi `{state}.webp`.
