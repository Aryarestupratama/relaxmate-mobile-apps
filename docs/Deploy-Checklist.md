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
