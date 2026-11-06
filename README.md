# RelaxMate Mobile

Aplikasi pendamping AI untuk mahasiswa (Flutter, Android dulu). Memakai backend RelaxBoss lewat API `/api/v1`; tidak pernah memanggil layanan AI langsung dan tidak menyimpan kunci apa pun. RelaxMate **bukan layanan medis** dan tidak menggantikan psikolog atau psikiater.

Dokumen proyek (PRD, Architecture, Design, Rules, progress) disimpan di luar repo ini.

## Menjalankan

Syarat: Flutter SDK (stabil), Android SDK, dan backend RelaxBoss berjalan di lokal (`php artisan serve`).

```bash
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

`10.0.2.2` adalah alamat komputer dari emulator Android. Pada HP asli pakai alamat IP komputer di jaringan yang sama. URL API hanya lewat `--dart-define`; flavor `prod` menolak URL non-HTTPS.

| Flavor | Entry point | Fungsi |
|---|---|---|
| `dev` | `lib/main_dev.dart` | API lokal, cleartext hanya pada build debug |
| `prod` | `lib/main_prod.dart` | Rilis, HTTPS saja |

Build debug: `flutter build apk --debug --flavor dev -t lib/main_dev.dart --dart-define=API_BASE_URL=...`

## Server tiruan (sebelum API ada)

`tool/mock_api.mjs` adalah server tiruan untuk uji manual tanpa backend: mode cek versi (`GET /api/v1/config`) dan mode `auth` (Daftar, Masuk, Lupa sandi, Cek email, `/me`, dengan data di memori). Butuh Node.js.

```bash
node tool/mock_api.mjs old        # versi minimum 9.0.0 -> layar "Perbarui aplikasi"
node tool/mock_api.mjs ok 8001    # aplikasi lanjut normal (port bawaan 8001)
node tool/mock_api.mjs auth       # alur akun; akun contoh dan pembantu dijelaskan di kepala berkas
```

Lalu jalankan aplikasi dengan `API_BASE_URL=http://10.0.2.2:8001`. Mode lain: `slow`, `error`, `unauthorized`.

## Struktur

```
lib/
  main_dev.dart, main_prod.dart   titik masuk per flavor
  bootstrap.dart, app.dart        inisialisasi dan akar aplikasi
  core/
    config/   flavor, AppConfig, konstanta, versi, jalur aset
    api/      ApiClient (dio), provider
    error/    ApiException dan pemetaan galat
    storage/  token di penyimpanan aman
    theme/    token (Rb*) dan ThemeData
    router/   go_router
    texts/    bank teks UI
  features/<nama>/{data,state,ui} satu fitur satu folder
  shared/widgets/                 komponen UI bersama
tool/                             alat pengembangan (bukan bagian aplikasi)
assets/
  fonts/ images/mascot/           font dan maskot
  audio/clips/ crisis/ texts/     diisi pada task fiturnya
android/                          konfigurasi flavor dan manifest
```

## Aturan singkat

- Warna, ukuran teks, radius, dan jarak hanya dari `core/theme`.
- Widget tipis; jaringan hanya lewat repository di `data/` dan `ApiClient`.
- Isi chat dan transkrip tidak ditulis ke disk atau log.
- Jangan masukkan keystore, `key.properties`, `.env`, atau dokumen proyek ke repo.

Font Plus Jakarta Sans berlisensi SIL OFL (`assets/fonts/OFL.txt`).
