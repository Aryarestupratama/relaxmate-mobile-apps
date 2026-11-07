# Panduan Uji TASK-M026 (Saran tindakan)

## 1. Persiapan
```bash
flutter pub get
dart format .
flutter analyze
```
`flutter analyze` harus bersih (tidak ada paket baru di task ini). Bila ada temuan, kirim persis seperti keluarannya.

## 2. Jalankan mock dan aplikasi
```bash
node tool/mock_api.mjs auth
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001   # sesuaikan dengan cara run flavor Anda
```
Masuk dengan `verified@example.test` / `Password123`, setujui consent bila diminta, lalu buka chat. Pemicu saran ada di kepala `tool/mock_api.mjs`.

## 3. Uji manual
| # | Langkah | Hasil yang diharapkan |
|---|---|---|
| 1 | Kirim `halo saran profesional` | Di bawah balasan muncul chip **Bicara dengan profesional** (ikon) dan tombol tutup (X). |
| 2 | Ketuk chip tersebut | Peramban terbuka ke `.../konsultasi` (halaman tiruan "Konsultasi Profesional (halaman tiruan)"). Kembali ke aplikasi: chat utuh. |
| 3 | Ketuk X | Chip dan X hilang. Pesan dan balasan tetap ada. |
| 4 | Kirim `halo saran profesional` lagi, lalu kirim pesan biasa (mis. `ok`) | Chip pada balasan **lama** hilang karena sudah ada balasan baru (saran non-mendesak hanya tampil pada balasan terakhir, sama dengan web). |
| 5 | Kirim `uji krisis` | Banner krisis muncul (M025), balasan berlatar krisis, dan di bawahnya chip **Lihat kontak bantuan** dan **Bicara dengan profesional**. **Tidak ada X.** |
| 6 | Ketuk **Lihat kontak bantuan** | Layar kontak bantuan terbuka; tombol kembali membawa ke chat. |
| 7 | Kirim dua pesan biasa | Chip krisis pada balasan krisis **tetap ada** (prioritas 1 selalu tampil). |
| 8 | Kirim `halo saran dukungan` | Balasan tampil **tanpa chip** (Latihan napas dan Grounding baru ada di TASK-M029). Tidak ada galat. |
| 9 | Kirim `halo saran baru` | Balasan tampil **tanpa chip** dan tanpa galat (jenis saran tidak dikenal diabaikan). |
| 10 | Keluar, masuk lagi, buka chat | Saran dimuat dari server: chip krisis tetap tampil; chip profesional tampil lagi hanya bila balasan terakhirnya yang membawa saran (penutupan hanya di memori). |
| 11 | Teks sistem 200% (Pengaturan Android) | Chip membungkus ke baris berikutnya, tidak terpotong, tombol tetap bisa diketuk. |
| 12 | TalkBack aktif | Urutan fokus: gelembung, chip, tombol tutup (dibacakan "Tutup saran"). Chip dibacakan sesuai labelnya. |

Catatan: batas 20 pesan/hari di mock. Bila habis: `http://localhost:8001/__set-sent?email=verified@example.test&n=0` atau `/__reset`.

## 4. Uji dengan backend nyata (opsional)
Dengan backend dan kunci Groq aktif, kirim cerita yang berat dan berlangsung lama agar AI memberi saran profesional, atau pesan yang memicu krisis (kasus di `resources/crisis/cases.json`). Saran dipilih server (prioritas intent), jadi hasilnya tidak deterministik: yang diperiksa hanya bahwa chip sesuai jenis saran dan tidak ada galat.

## 5. Yang dilaporkan kembali
- Keluaran `flutter analyze` (harus bersih) dan nomor langkah di atas yang gagal beserta tangkapan layarnya.
- Apakah chip Konsultasi membuka peramban di perangkat nyata (bukan hanya emulator).
- Hasil uji M025 (`docs/M025-Test-Guide.md`) agar kedua task bisa ditandai `Done`.
