# Panduan Uji TASK-M025 (Crisis Response)

## 1. Persiapan
`shared_preferences` sudah tertulis di `pubspec.yaml` (`^2.5.0`). Jalankan:
```bash
flutter pub get
dart format .
flutter analyze
```
- `flutter analyze` harus **bersih** (sebelumnya 4 temuan karena paket ini belum ada). Bila ada temuan lain, kirim persis seperti keluarannya.
- `pubspec.lock` akan berubah; **ikut di-commit**.
- `shared_preferences` adalah plugin native: **hentikan aplikasi lalu jalankan ulang penuh** (bukan hot reload/hot restart), kalau tidak muncul `MissingPluginException`. Kalau tetap muncul: `flutter clean`, `flutter pub get`, jalankan ulang.

## 2. Jalankan mock dan aplikasi
```bash
node tool/mock_api.mjs auth
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001   # sesuaikan dengan cara run flavor Anda
```
Akun contoh ada di kepala `tool/mock_api.mjs`.

## 3. Uji manual
1. **Layar tamu**: di Masuk, Daftar, Lupa sandi, Cek email, dan Consent ada tautan "Butuh bantuan sekarang? Lihat kontak bantuan". Ketuk: daftar kontak tampil (cukup dengan kontak bawaan aset).
2. **Banner krisis**: masuk, buka chat, kirim pesan berisi `uji krisis`. Balasan tampil dengan latar krisis, banner "Kamu tidak sendirian" muncul di atas daftar, memiliki tombol telepon dan "Lihat semua kontak bantuan". Banner tidak bisa ditutup. Kirim pesan biasa: banner tetap ada. Tutup dan buka lagi aplikasi (login ulang): banner tetap ada pada hari yang sama.
3. **Offline**: matikan mock (Ctrl+C), buka `/kontak-bantuan` dari ikon telepon di AppBar chat: kontak tetap tampil.
4. **Penyegaran cache**: nyalakan mock lagi, buka `http://localhost:8001/__contacts-v2` di browser, lalu login ulang dan buka layar kontak: muncul kontak ke-3. `__contacts-v1` mengembalikan ke semula. Mock mengirim satu kontak dummy; di flavor `prod` kontak dummy tidak tampil.
5. **Layar Perbarui aplikasi**: `node tool/mock_api.mjs old`, jalankan aplikasi: ketuk "Butuh bantuan sekarang?", daftar kontak tampil inline.
6. **Batas harian**: saat jatah habis, ada tombol "Lihat semua kontak bantuan".
7. **Teks 200%**: set ukuran font sistem maksimum; banner tidak menutup kolom ketik (dibatasi 40% layar dan bisa digulir).
8. **Telepon (perangkat nyata)**: ketuk "Telepon" pada Healing119: dialer terbuka dengan `119,8`. Pastikan ekstensi 8 terkirim; bila tidak, coba ubah `AppConstants.telExtensionPause` menjadi `,,` (OQ-MA9). Emulator tidak punya dialer, kegagalan akan menampilkan Snack berisi nomor.

## 3b. Uji dengan backend nyata (kasus krisis)
Di repo web: `php artisan relaxboss:check-crisis`. Lalu, dengan backend dan kunci Groq aktif, kirim lewat aplikasi beberapa kasus positif dari `resources/crisis/cases.json` (35 chat dan 5 pfa): banner harus muncul, dan balasan krisis berupa teks tetap dari server.

## 4. Catatan
- Isi `assets/crisis/crisis_contacts.json` harus dicocokkan dengan kontak terverifikasi (OQ-3) sebelum rilis.
- Hasil uji: laporkan ke sesi berikutnya agar progress.md diperbarui (M025 `Done`).
