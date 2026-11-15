# RelaxMate Mobile - Brief Ilustrasi Sambutan
Version: 0.1 | Status: Draft | Last updated: 2026-11-15
Dipakai oleh: SCR-M02 Sambutan (`WelcomeScreen`), TASK-M073 bagian 2 | Owner: Founder (solo developer)

Aset ini dibuat di luar repo (ChatGPT) lalu dipasang sebagai satu berkas: `assets/images/welcome/welcome-hero.png`.

## 1. Spesifikasi aset

| Hal | Nilai |
|---|---|
| Berkas | `assets/images/welcome/welcome-hero.png` (nama harus sama; kode memuat jalur ini) |
| Rasio dan ukuran | Persegi 1:1, 1024 x 1024 px (hasil generate 1536 atau 2048 boleh, perkecil ke 1024) |
| Latar | Transparan. Tanpa bayangan lantai dan tanpa lingkaran latar; ilustrasi tampil langsung di atas gradien (sejak 2026-11-15 kode tidak lagi menggambar lingkaran) |
| Isi | Hanya karakter dan lima blob mood. Tanpa hiasan segitiga, cincin, kilau, dan sejenisnya (kode juga tidak menggambarnya lagi) |
| Teks di gambar | Tidak ada sama sekali (teks "RelaxMate" di dada lembar karakter dihapus; ikon logo boleh tetap) |
| Warna | Hanya token proyek: navy `#0A2244`, putih `#FFFFFF`, `#EEF2F8`, biru robot yang sudah ada di lembar karakter, dan lima warna mood `#A98BFF`, `#9CCBF2`, `#FFB997`, `#ABEAA2`, `#FCE46F` |
| Zona aman | Semua elemen di dalam kanvas dengan margin sekitar 3% di tiap sisi |
| Ukuran berkas | Sasaran di bawah 500 KB (kompres di squoosh.app atau tinypng.com) |

## 2. Bahan referensi yang diunggah ke ChatGPT

1. `relaxmate.png` (lembar karakter robot yang sudah dibuat founder): acuan bentuk robot.
2. `design/welcome/mood-blobs-reference.png` (lima blob mood dari `assets/images/mood/`): acuan bentuk, wajah, dan warna blob.

Unggah **kedua gambar sekaligus** di pesan yang sama dengan prompt. Gambar acuan Eunoia (tangkapan layar aplikasi lain) **jangan diunggah**: yang dipinjam hanya ide komposisinya (karakter memegang ekspresi perasaan), bukan gambar atau gayanya, supaya karya tetap orisinal (PRD-M 1).

## 3. Prompt utama (tempel apa adanya)

```
Use the two attached images as strict references.
Image 1 is the character sheet of RelaxMate, a friendly robot mascot. Keep the robot EXACTLY the same design: white rounded body and limbs, round white head with a dark navy glossy face screen showing two oval white eyes and a small smile, two short white antennae with ball tips, soft blue ear pods, blue neck, blue hands and blue shoes, and the small leaf/shell logo icon on the chest. Remove the word "RelaxMate" from the chest: keep only the small logo icon, no text.
Image 2 shows five mood blobs. Reuse these blobs EXACTLY (same cloud-like shape, same face, same dark navy outline, same colors): sleepy purple, sad blue, neutral peach, smiling green, happy yellow.

Create ONE flat 2D vector-style illustration, square 1:1, of the same RelaxMate robot standing in a relaxed, welcoming pose, front-facing, head slightly tilted, full body visible from antennae to shoes. The robot holds up two mood blobs, one in each raised hand: the happy yellow blob in its right hand and the smiling green blob in its left hand. The other three blobs (sleepy purple, sad blue, neutral peach) float gently around the robot at head and shoulder height in a loose, balanced arc. Mood: warm, calm, supportive, like a caring friend who understands every feeling.

Style: clean flat vector illustration, smooth shapes, a consistent dark navy outline (#0A2244) of the same thickness as the blob outlines, very subtle soft shading only, no gradients, no 3D render, no realistic lighting. Palette limited to: navy #0A2244, white, light blue-grey #EEF2F8, the robot's existing soft blue, and the five mood colors #A98BFF, #9CCBF2, #FFB997, #ABEAA2, #FCE46F. Do not introduce any other colors.

Composition: everything stays inside a central circle covering about 88% of the canvas, centered, with empty margin around it. Keep the robot slightly below center and the floating blobs above and beside it.

Background: fully transparent PNG. No floor, no ground shadow, no backdrop circle, no confetti, no sparkles, no shapes other than the robot and the five blobs. No text, no letters, no logos with words, no watermark.
```

## 4. Prompt perbaikan (kirim bila hasilnya hampir tepat)

Kirim satu per satu di percakapan yang sama, jangan digabung:

- Robot berubah: `Keep the pose and layout. Make the robot match Image 1 exactly: same head shape, same face screen, same blue ear pods, same blue hands and shoes. Do not redesign it.`
- Blob berubah: `Keep everything else. Replace the five blobs with the exact blobs from Image 2: same shape, same face, same outline, same colors.`
- Ada teks atau hiasan: `Remove all text and all decorative shapes. Only the robot and the five blobs remain.`
- Latar tidak transparan: `Export as a PNG with a truly transparent background, no checkerboard pattern drawn, no shadow, no floor.`
- Terlalu ramai: `Simplify. Keep the robot holding only two blobs and let the other three float with more space between them.`
- Terlalu besar atau terpotong: `Scale everything down so there is clear empty margin on all four sides.`

## 5. Pilihan komposisi lain (bila ingin variasi)

Ganti paragraf komposisi di prompt utama dengan salah satu:

- **Melambai:** `The robot waves with its right hand and holds the yellow blob close to its chest with its left hand. The other four blobs float in a gentle arc above and beside it.`
- **Duduk santai:** `The robot sits cross-legged on the ground, relaxed, with all five blobs floating in a soft arc above it, from sleepy purple on the left to happy yellow on the right.`

## 6. Periksa hasil sebelum dipakai

- [ ] Robot sama dengan lembar karakter (kepala, layar wajah, telinga biru, tangan dan sepatu biru).
- [ ] Lima blob sama dengan referensi dan urutan warnanya lengkap (ungu, biru, persik, hijau, kuning).
- [ ] Tidak ada teks, huruf, atau hiasan lain.
- [ ] Hanya warna dari token; tidak ada warna asing atau gradien mencolok.
- [ ] Tepi bersih di latar terang (tidak ada halo putih atau abu-abu).
- [ ] Semua elemen berada di dalam zona aman; tidak ada yang terpotong.

## 7. Dari hasil ChatGPT ke aset aplikasi

1. Unduh hasil terbaik. Bila latar tidak transparan: hapus di Canva (Background Remover) atau remove.bg.
2. Pastikan kanvas persegi 1:1 dan karakter di tengah dengan margin (Canva: Resize ke 1024 x 1024 px, ekspor PNG, centang "Transparent background").
3. Kompres (squoosh.app atau tinypng.com) sampai di bawah 500 KB.
4. Simpan sebagai `welcome-hero.png` dan **timpa** berkas di `assets/images/welcome/` (ukuran 1024 x 1024; berkas bawaan hanya penampung dari maskot lama).
5. Jalankan ulang aplikasi (`flutter run`; aset baru cukup hot restart) dan lihat sambutan.
