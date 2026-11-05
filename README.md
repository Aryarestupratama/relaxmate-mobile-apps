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

## Struktur

```
lib/
  main_dev.dart, main_prod.dart   titik masuk per flavor
  bootstrap.dart, app.dart        inisialisasi dan akar aplikasi
  core/
    config/   flavor, AppConfig, konstanta, jalur aset
    theme/    token (Rb*) dan ThemeData
    router/   go_router
    texts/    bank teks UI
    api/ error/ storage/          diisi pada TASK-M021
  features/<nama>/{data,state,ui} satu fitur satu folder
  shared/widgets/                 komponen UI bersama
assets/
  fonts/ images/mascot/           font dan maskot
  audio/clips/ crisis/ texts/     diisi pada task fiturnya
android/                          konfigurasi flavor dan manifest
```

## Aturan singkat

- Warna, ukuran teks, radius, dan jarak hanya dari `core/theme`.
- Widget tipis; jaringan hanya lewat repository di `data/`.
- Isi chat dan transkrip tidak ditulis ke disk atau log.
- Jangan masukkan keystore, `key.properties`, `.env`, atau dokumen proyek ke repo.

Font Plus Jakarta Sans berlisensi SIL OFL (`assets/fonts/OFL.txt`).
