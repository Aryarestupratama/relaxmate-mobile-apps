# Checklist Deploy Backend (sebelum build rilis mobile)

Versi 0.1 | 2026-11-13. Dipakai setiap kali backend RelaxBoss diperbarui ke shared hosting.

## Sebelum deploy
- [ ] Perubahan sudah di-commit dan dipush; zip/berkas yang diunggah sama dengan commit itu.
- [ ] Bila `resources/prompts/relaxmate.system.md` berubah: `php artisan relaxboss:check-crisis` lolos (RULE-047).
- [ ] `.env` produksi: `APP_ENV=production`, `APP_DEBUG=false`, `MAIL_MAILER` **bukan** `log`, kunci Groq terisi (`GROQ_KEYS_CHAT`, `GROQ_KEYS_ASSESSMENT`), `AI_CHAT_REASONING_EFFORT` sesuai keputusan.
- [ ] Hanya HTTPS; aplikasi rilis menolak `http://`.

## Setelah deploy
- [ ] `php artisan migrate --force`, lalu `php artisan config:cache` dan `route:cache`.
- [ ] Buka situs publik di browser: beranda, Tentang (anggota tim, ikon Instagram).
- [ ] Jalankan uji asap dengan akun uji khusus (terverifikasi, bukan akun pribadi):
  `SMOKE_EMAIL=... SMOKE_PASSWORD=... node tool/smoke_api.mjs https://alamat-backend --write --crisis`
- [ ] Semua LOLOS; bila ada GAGAL, jangan bangun aplikasi sebelum diperbaiki.
- [ ] Daftar kontak krisis dari `/crisis-contacts` adalah daftar terverifikasi supervisor, tanpa `dummy: true`.
- [ ] Akun uji dihapus atau dibiarkan khusus untuk uji; jangan membagikan tautan verifikasi atau token dari log.

# Build Rilis Mobile (TASK-M043)

Versi 0.1 | 2026-11-13. Dikerjakan setelah checklist backend di atas lolos.

## Sekali saja: android/key.properties
Buat `android/key.properties` (sudah di `.gitignore`, jangan di-commit). Pakai garis miring `/` pada path, bukan `\`, karena `\` adalah karakter escape di berkas properties:

```properties
storeFile=C:/ARYA RESTU PRATAMA/PROJECT/project kesehatan mental/product/relaxmate-mobile apps/keys/relaxmate-upload.jks
storePassword=SANDI_KEYSTORE
keyAlias=upload
keyPassword=SANDI_KEYSTORE
```

## Setiap rilis
- [ ] `git pull`, lalu naikkan `version:` di `pubspec.yaml` (angka setelah `+` harus naik di setiap unggahan).
- [ ] `flutter analyze` bersih.
- [ ] `node tool/release_preflight.mjs` semua LOLOS (juga menjalankan `tool/privacy_audit.mjs`).
- [ ] Bangun:
  `flutter build appbundle --release --flavor prod -t lib/main_prod.dart --dart-define=API_BASE_URL=https://relaxboss.my.id`
- [ ] Periksa tanda tangan: `node tool/release_preflight.mjs --artifact build/app/outputs/flutter-apk/app-prod-release.apk` (memakai `apksigner` dari Android SDK build-tools) atau `--artifact build/app/outputs/bundle/prodRelease/app-prod-release.aab` (memakai `jarsigner` dari folder `bin` JDK Android Studio di PATH). Bila alatnya tidak ditemukan, hasilnya LEWAT.
- [ ] Uji APK rilis di >= 2 perangkat nyata: `flutter build apk --release --flavor prod -t lib/main_prod.dart --dart-define=API_BASE_URL=https://relaxboss.my.id`, pasang, lalu jalankan alur inti (daftar, masuk, chat, krisis, kontak bantuan, overlay).
