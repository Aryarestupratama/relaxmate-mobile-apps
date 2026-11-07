# RelaxMate Mobile - Progress
Version: 0.12 | Status: Living document | Last updated: 2026-11-07
Owner: Founder (solo developer)

Dokumen ini dibaca pertama setiap mulai bekerja di proyek mobile. Perbarui di akhir setiap task atau sesi. Dokumen proyek disimpan **di luar repo kode** (RULE-M014). Task di sisi backend (repo web RelaxBoss) mengikuti `Rules.md` web dan juga dicatat di sini, dengan awalan `TASK-M`, agar satu sumber kebenaran untuk fitur mobile. Perubahan di repo web tetap mengikuti Doc Sync web (`progress.md` web diperbarui bila menyentuh perilaku web).

---

## 1. Status Proyek

| Hal | Status terbaru |
|---|---|
| Tahap | Implementasi berjalan. Selesai (uji manual lolos): **TASK-M010 sampai M017** (seluruh backend MM1, repo web), **M020, M021, M022, M023** (Flutter; M023 lolos 2026-11-07). **MM1 (Backend API) selesai** kecuali prasyarat rilis web. Berikutnya mulai MM2 sisi layar chat (TASK-M024). Dokumen mobile: PRD v0.4, Architecture v0.8, Schema v0.1 (**perlu pembaruan**, lihat Utang dokumen), Design v0.6, Rules v0.7, progress v0.12. Sejak 2026-11-06 **dokumen mengikuti kode**. |
| Berikutnya | Mobile **TASK-M024** (layar chat harian; juga menangani 403 `consent_required` di tengah sesi lewat `ref.invalidate(consentControllerProvider)`). Sebelumnya putuskan OQ-MA10 (paket ikon) dan OQ-MA11 (kirim ke percakapan lama). TASK-M001 (menutup dokumen) tersisa sebagian. |
| Pemblokir | Prasyarat web untuk **rilis**: TASK-031 (go-live), OQ-3 (kontak krisis terverifikasi), OQ-5 (telaah hukum data AI dan pelatihan, termasuk layanan suara pihak ketiga). Tanpa itu, tidak ada rilis mobile. **Keputusan founder (sesi 2026-11-05/06, dicatat di sini sebagai keputusan tertulis):** task kode dibuka tanpa menunggu TASK-M002. TASK-M002 tetap `Blocked` dan wajib selesai sebelum TASK-M045. |
| Alur kerja | Kerja di `main`, commit lalu push, pesan commit bahasa Inggris. Dokumen di luar repo. Uji manual wajib; tanpa CI. |
| Data | Sebelum TASK-M044, hanya data dummy bertanda jelas (akun `example.test`, kontak krisis `dummy`). Build `prod` tidak boleh memuat dummy (RULE-M048). |
| Versi dokumen | PRD-Mobile 0.4, Architecture-Mobile 0.8, Schema-Mobile 0.1 (**perlu pembaruan**, lihat Utang dokumen), Design-Mobile 0.6, Rules-Mobile 0.7, progress 0.12. |

> Status task yang perlu uji manual atau konfirmasi founder tidak dianggap terverifikasi hanya karena catatan Doc Sync sudah ditulis.

---

## 2. Roadmap

Estimasi dalam minggu kerja satu orang `[Assumption]`, belum bertanggal karena menunggu penutupan prasyarat web.

| Milestone | Isi | Estimasi | Task |
|---|---|---|---|
| MM0 | Dokumen, prasyarat, spike | 1-2 mgg | TASK-M001 s.d. M005 |
| MM1 | Backend API `/api/v1` (repo web) | 2-3 mgg | TASK-M010 s.d. M017 |
| MM2 | Fondasi Flutter, Auth, Consent | 2 mgg | TASK-M020 s.d. M023 |
| MM3 | Chat inti, krisis, saran, riwayat | 3 mgg | TASK-M024 s.d. M027 |
| MM4 | Cek Rasa, latihan, maskot dalam app, pengaturan | 2 mgg | TASK-M028 s.d. M031 |
| MM5 | Maskot mengambang (Android) | 2-3 mgg | TASK-M032 s.d. M034 |
| MM6 | Hardening dan rilis Fase 1 (closed testing) | 2-3 mgg | TASK-M040 s.d. M045 |
| MM7 | Fase 2: suara | 3-4 mgg | TASK-M050 s.d. M054 |
| MM8 | Fase 3: TTS percobaan | 1-2 mgg | TASK-M060 s.d. M061 |

Fase 1 (MVP) = MM1 s.d. MM6. Fase 2 = MM7. Fase 3 = MM8.

---

## 3. Task Board

Status: `Next`, `Todo`, `Doing`, `Done`, `Blocked`. Satu task `Doing` pada satu waktu. Migration ditulis pada task fiturnya (RULE-031 web). Kolom Repo: **W** = repo web (Laravel), **M** = repo mobile (Flutter), **D** = dokumen.

### MM0 - Dokumen, prasyarat, spike

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M001 | Menutup dokumen mobile: baca ulang PRD, Architecture, Schema, Design, Rules; pastikan nomor FR/OQ antar dokumen sinkron; serahkan ke folder dokumen | D | Semua | Todo (sebagian: kontrak API dan nama kode diselaraskan di Architecture-M v0.2; sisa: nomor FR/OQ antar dokumen) |
| TASK-M002 | Prasyarat web: TASK-031 selesai, TASK-050 selesai, OQ-3 dan OQ-5 dijawab (atau keputusan tertulis untuk mulai API tanpa menunggu) | W | PRD-M 10 | Blocked |
| TASK-M003 | Spike overlay Android: plugin vs Kotlin sendiri, jenis foreground service (Android 14+), izin, kebijakan Play. Keluaran: catatan keputusan di Architecture-M (menutup OQ-MA1) | M | Architecture-M 6.4, OQ-MA1 | Todo |
| TASK-M004 | Spike STT: kualitas Bahasa Indonesia di 2-3 perangkat, perilaku jeda dan offline (menutup OQ-MA3) | M | Architecture-M 6.3, OQ-MA3 | Todo |
| TASK-M005 | Putuskan OQ yang menghalangi: OQ-M2 (ejaan dan cara menyapa), OQ-M3 (Cek Rasa dan Mood Entry), OQ-MA2 (**selesai 2026-11-06**: tautan tanpa login hanya untuk email dari API), OQ-MA4 (`SendChatMessage` sekarang atau bungkus dulu) | D | PRD-M, Architecture-M | Todo |

### MM1 - Backend API (repo web)

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M010 | Ekstrak `SendChatMessage` (Action) dari `ChatMessageController` (nama sebenarnya di repo web; `RelaxMateController` hanya halaman); web memakainya. Uji manual alur chat web sebelum dan sesudah (kirim, batas harian, 503, krisis) | W | Architecture-M 6.2, 9; RULE-022 | **Done** (uji manual web lolos 2026-11-06) |
| TASK-M011 | `DailyConversationResolver` + config `relaxboss.mobile.*` (cutoff 4, min app version, masa token) | W | FR-M004, Architecture-M 6.1 | **Done** (uji manual lolos 2026-11-06) |
| TASK-M012 | Pasang Sanctum (`install:api`), migration token, named limiter; catat alasan di Architecture web bagian 13 dan revisi ADR-013 | W | ADR-M02, Schema-M 2, RULE-060 web | **Done** (2026-11-06) |
| TASK-M013 | Auth API: register, login, logout, forgot, resend; rute verifikasi email tanpa login (sesuai OQ-MA2) | W | API-M001..M005, FR-M001 | **Done** (2026-11-06) |
| TASK-M014 | API ringkasan: `/me`, `/config`, `/consent` (GET dan POST), training consent, `/crisis-contacts`; middleware `verified` varian API (403 `unverified`) | W | API-M006..M011 | **Done** (2026-11-06) |
| TASK-M015 | API chat: `today`, kirim pesan (retry sudah ada di web lewat `retry=true`, lihat OQ-MA6), `days`, riwayat per percakapan | W | API-M012..M016, FR-M004..M009 | **Done** (uji manual lolos 2026-11-06) |
| TASK-M016 | Hapus akun via API; token dicabut; `active` varian API menolak dan mencabut token (middleware web `active` memakai sesi) | W | API-M017, FR-M003 | **Done** (uji manual lolos 2026-11-07) |
| TASK-M017 | Uji manual API: skenario Postman/curl (isolasi pengguna A vs B, batas, 503), pastikan log bebas isi pesan dan token (RULE-040) | W | NFR-M01, NFR-M02 | **Done** (uji manual lolos 2026-11-07; temuan mailer `log` dicatat sebagai utang web) |

### MM2 - Fondasi Flutter, Auth, Consent

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M020 | Proyek Flutter: struktur folder, flavor `dev`/`prod`, `--dart-define`, `.gitignore` (keystore, `key.properties`), `README.md`, tema token dan font, `analysis_options` ketat | M | Architecture-M 4, 10; Design-M 2 | **Done** (2026-11-06) |
| TASK-M021 | API client (`dio`): token, `X-App-Version`, pemetaan error, `flutter_secure_storage`, layar "Perbarui aplikasi" | M | Architecture-M 5, 7, 11 | **Done** (2026-11-06) |
| TASK-M022 | Layar Daftar, Masuk, Lupa sandi, Cek email (kirim ulang); status memuat/galat/sukses | M | FR-M001, SCR-M03..M06 | **Done** (uji manual lolos 2026-11-06) |
| TASK-M023 | Consent AI dan persetujuan pelatihan (teks dari API-M008), pengaturan dapat diubah | M | FR-M002, SCR-M07 | **Done** (uji manual lolos 2026-11-07). UI mengubah pilihan pelatihan di Pengaturan ikut TASK-M031 (layar Pengaturan belum ada) |

### MM3 - Chat inti

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M024 | Layar chat harian: aliran per hari, kirim, indikator mengetik, galat, "Coba lagi" (retry), sisa kuota, input nonaktif saat batas harian | M | FR-M004, M006, M007, SCR-M08 | **Next** |
| TASK-M025 | Crisis Response: banner permanen, kontak bantuan (cache + fallback aset, bukan dummy di `prod`), tombol `tel:`, uji manual kasus krisis dari `cases.json` lewat aplikasi | M | FR-M010, M011, SCR-M16 | Todo |
| TASK-M026 | Saran tindakan: chip dan peta intent/`suggestion.type` ke tujuan (napas, grounding, kontak, Konsultasi web) | M | FR-M008 | Todo |
| TASK-M027 | Riwayat: garis waktu per tanggal (hanya baca) | M | FR-M005, SCR-M14, M15 | Todo |

### MM4 - Cek Rasa, latihan, maskot, pengaturan

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M028 | Cek Rasa harian: baris blob mood, jawaban dikirim sebagai pesan chat, dapat dilewati | M | FR-M013, SCR-M09 | Todo |
| TASK-M029 | Latihan napas dan grounding 5-4-3-2-1 lokal (visual + getar opsional; panduan suara ditunda ke Fase 2, keputusan founder) | M | FR-M014, SCR-M11, M12 | Todo |
| TASK-M030 | Maskot dalam aplikasi (animasi: diam, menyimak, berpikir, bicara) dan mode "Temani saja" | M | FR-M015, Design-M 9, SCR-M13 | Todo |
| TASK-M031 | Pengaturan, hapus akun, tautan Privasi dan Ketentuan, lapisan privasi di daftar aplikasi terbaru | M | FR-M003, FR-M025, NFR-M01 | Todo |

### MM5 - Maskot mengambang (Android)

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M032 | Alur izin: penjelasan, `SYSTEM_ALERT_WINDOW`, `POST_NOTIFICATIONS`, status izin, default mati | M | FR-M022, Design-M SCR-M18 | Todo |
| TASK-M033 | `OverlayService` (foreground service + notifikasi dengan tombol "Nonaktifkan"), gelembung geser/tempel tepi, mini-panel, "Istirahatkan" (1 jam / sampai besok) | M | FR-M022..M024, Architecture-M 6.4 | Todo |
| TASK-M034 | Pengaturan overlay (aktif/nonaktif, snooze), deep link "Ngobrol" dan "Bicara" ke aplikasi, tanpa mikrofon/jaringan di overlay; uji di beberapa versi Android | M | FR-M023, ADR-M06 | Todo |

### MM6 - Hardening dan rilis Fase 1

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M040 | Audit privasi perangkat: `allowBackup=false`, tanpa cleartext di `prod`, `logcat` bebas isi pesan dan token, penyimpanan hanya sesuai Schema-M 4 | M | NFR-M01, RULE-M040 | Todo |
| TASK-M041 | Perluas `cases.json` (repo web) dengan >= 10 kasus transkrip suara (salah dengar umum); jalankan `relaxboss:check-crisis` dan periksa lewat aplikasi | W | FR-M017, RULE-047 web | Todo |
| TASK-M042 | Aksesibilitas: TalkBack, target >= 48dp, teks 200%, kontras, reduce motion | M | NFR-M03, Design-M 8 | Todo |
| TASK-M043 | Preflight mobile dan build rilis: keystore di luar repo, R8, `debuggable=false`, kontak bantuan bukan dummy, uji di >= 2 perangkat nyata | M | Architecture-M 10, RULE-M048 | Todo |
| TASK-M044 | Aset dan berkas toko: ikon, tangkapan layar, deskripsi, kebijakan privasi diperbarui (web), Data Safety, deklarasi izin overlay dan foreground service; klaim publik hanya yang terkonfirmasi (RULE-049) | D/M | NFR-M07 | Todo |
| TASK-M045 | Internal testing lalu closed testing; kumpulkan masukan; keputusan lanjut produksi | M | OQ-MA5 | Todo |

### MM7 - Fase 2: suara

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M050 | STT: tombol ketuk-bicara, gelembung, hitung mundur kirim otomatis (batal), konfirmasi hasil rendah; audio tidak disimpan | M | FR-M016, M017 | Todo |
| TASK-M051 | Mode percakapan suara (mesin keadaan), interupsi (telepon, fokus audio, latar belakang) kembali ke `idle` | M | FR-M018, Architecture-M 6.3 | Todo |
| TASK-M052 | Klip suara: inventaris, generate dari ElevenLabs **selagi paket berbayar aktif**, simpan master di luar repo, `clips.json`, pemutar, latihan napas bersuara | D/M | FR-M020, ADR-M05, R-M5, R-M7 | Todo |
| TASK-M053 | Kasus uji krisis suara diperluas dan keputusan penyesuaian `keywords.id.php` bila perlu | W | R-M3 | Todo |
| TASK-M054 | (Could) Kata panggil "Mates" saat aplikasi atau mini-panel di depan layar, deteksi di perangkat | M | FR-M019 | Todo |

### MM8 - Fase 3: TTS percobaan

| ID | Task | Repo | Rujukan | Status |
|---|---|---|---|---|
| TASK-M060 | TTS balasan dengan suara perangkat: default mati, tombol berhenti, peringatan privasi, krisis tidak dibacakan otomatis | M | FR-M021 | Todo |
| TASK-M061 | Evaluasi suara premium terbatas (OQ-M6): baca syarat resmi, telaah privasi, putuskan | D | OQ-M6 | Todo |

### Catatan hasil task selesai

**TASK-M017 (web; uji manual lolos 2026-11-07).** Bukti yang diberikan: potongan `storage/logs/laravel.log` (2026-11-07 00:42 sampai 01:05). Yang terbaca dari log: (a) dua akun uji `a-mw5ohdku@example.test` dan `b-mw5ohdku@example.test` (id 7 dan 8) masing-masing dikirimi email verifikasi, jadi pasangan A dan B untuk skenario isolasi sudah ada; akun A juga memicu kirim ulang verifikasi (00:42:01, 00:44:19, 00:44:34, 00:46:49) dan satu email reset sandi (00:42:07); (b) 11 panggilan chat AI berhasil (`ai.completion`: satu pada 00:48, lima pada 00:50, lima pada 00:55) dengan `key_no` bergilir 1 sampai 5; (c) pada 01:05:59 tercatat `ai.unavailable` dengan alasan `no_keys`, tampaknya skenario 503 saat kunci AI tidak tersedia. **RULE-040:** entri `ai.*` hanya memuat `feature`, `version`, `model`, `key_no`, jumlah token, dan `duration_ms`; pada potongan ini tidak ada isi pesan maupun token Sanctum. **Temuan:** mailer `log` (lokal) menulis tautan verifikasi bertanda tangan dan tautan reset sandi beserta tokennya ke `laravel.log`; wajar di lokal, tetapi menjadi kebocoran token bila `MAIL_MAILER=log` terbawa ke produksi (lihat Utang web). **Tidak bisa disimpulkan dari log:** isolasi A vs B (dibuktikan oleh respons, bukan log), batas/429 (respons 429 tidak ditulis ke log aplikasi), dan bentuk respons 503; ketiganya dikonfirmasi lolos oleh founder 2026-11-07, sehingga M017 `Done`.

**TASK-M023 (mobile; kode selesai 2026-11-06, uji manual lolos 2026-11-07).** Fitur `consent/`: `data/` (`ConsentState`, `ConsentPrompt`, `TrainingChoice`, `ConsentRepository` untuk API-M008, M009, M010), `state/` (`ConsentGateState` bertingkat: `ConsentChecking`, `ConsentRequired`, `ConsentComplete`, `ConsentCheckFailed`; `ConsentController`), `ui/` (SCR-M07 `ConsentScreen`, `ConsentGate`, `ConsentChoiceTile` = CMP-M20, `ConsentErrorScreen`). `ConsentGate` membungkus `ChatScreen` di `app_router.dart`: pengguna terverifikasi diperiksa lewat `GET /consent` (satu panggilan untuk teks dan status), lalu melihat layar consent bila belum lengkap, atau layar chat bila lengkap. Hanya bagian yang kurang yang ditampilkan (versi consent AI dan pelatihan dinaikkan terpisah); pilihan pelatihan tanpa nilai awal; tombol utama menyimpan berurutan API-M009 lalu API-M010 dan mencatat kemajuan sebagian bila langkah kedua gagal. Teks consent tidak disalin di klien; teks kosong dari server dianggap balasan rusak. "Keluar" menjadi satu-satunya jalan lain (OQ-MA12). Perubahan kecil: token `RbSize.borderThin` dan `RbSize.borderSelected`, teks `consent*` di `AppTexts`. `tool/mock_api.mjs` (mode `auth`) mendapat `GET /consent`, kedua POST consent, `consent` pada `/me`, dan pembantu `/__bump-ai`, `/__bump-training`, `/__fail-training`, `/__fail-consent`; seluruh endpoint diuji dengan curl di sandbox. **Diperiksa di sandbox:** `dart format` gaya Dart 3.5 (sesuai `sdk: ^3.5.0`) bersih untuk seluruh `lib/`, dan `node --check` untuk server tiruan. **Uji manual di emulator lolos (founder, 2026-11-07).** Layar chat sementara tampil setelah consent lengkap.

**TASK-M016 (web; kode selesai 2026-11-06, uji manual lolos 2026-11-07).** Middleware `EnsureApiUserIsActive` (alias `api.active`) dipasang di grup bertoken `routes/api.php` setelah `auth:sanctum`: akun `is_active = false` dijawab 403 `account_inactive` (pesan sama dengan login) dan semua tokennya dihapus; logout dan kirim ulang verifikasi (grup terpisah) tidak terkena. `DELETE /api/v1/account` (`Api\V1\DeleteAccountController`, `DeleteAccountRequest` web) memakai Action `DeleteUserAccount` yang sama dengan web; Action kini juga menghapus token Sanctum pengguna di dalam transaksi (tabel `personal_access_tokens` tanpa FK, jadi tanpa ini token yatim tertinggal; berlaku juga bagi penghapusan dari web). Sukses 204; galat 422 `validation_failed` dengan `errors.password` atau `errors.account`. Tanpa `api.verified` (keputusan: hak hapus data tidak boleh tertahan verifikasi email; web mensyaratkannya, jadi perlu konfirmasi). `php -l` lolos; Laravel belum dijalankan.

**TASK-M015 (web; uji manual lolos 2026-11-06).** Empat endpoint chat di grup bertoken `routes/api.php` (`auth:sanctum`, `api-user`, lalu `api.verified` dan `ai.consent`), controller tipis di `app/Http/Controllers/Api/V1/Chat/`: `TodayController` (API-M012), `SendMessageController` (API-M013, memakai Action `SendChatMessage` dan `StoreChatMessageRequest` yang sama dengan web, limiter `chat`), `DaysController` (API-M015, `cursorPaginate` 15), `MessagesController` (API-M016, `cursorPaginate` 30, urut `id` naik). Tambahan kecil: `ChatPresenter::apiMessage()` (bentuk web + `created_at` ISO UTC; payload Inertia web tidak berubah) dan `DailyConversationResolver::dayKey()` serta `isCurrent()`. Bentuk JSON lengkap ada di Architecture-M bagian 5. Retry lewat `{ "retry": true }` pada API-M013 (API-M014 tidak dibuat). Keputusan baru: POST ke Percakapan di luar hari percakapan ditolak 409 `conversation_closed` (OQ-MA11). Sintaks PHP dicek dengan `php -l`; **Laravel tidak dijalankan di sandbox** (tanpa Composer/vendor), jadi semua perilaku menunggu uji manual founder.


**TASK-M012 (web, commit `26b7fdb`).** Sanctum 4.3.3 lewat `install:api` (migration `personal_access_tokens`, `config/sanctum.php`). `routes/api.php` dengan grup `v1`. `Support/ApiError` dan `Support/ApiExceptionRenderer` menyeragamkan galat `/api/*` ke `{ "error": { "code", "message" } }`. Limiter `api-register` (5/menit per IP) dan `api-guest` (20/menit per IP). Blok `relaxboss.mobile` (`token_name`, `token_abilities`, `token_expiration_days`, `guest_per_minute`); `sanctum.expiration` diisi dari config di `AppServiceProvider`. `User` memakai `HasApiTokens`. Pemasangan juga menaikkan 36 paket lain dalam rentang semver (`laravel/framework` v13.34.0 ke v13.40.0, dan seterusnya). Diuji manual: `route:list`, amplop 404, token lewat tinker (abilities, masa berlaku 86400 menit), limiter terdaftar.

**TASK-M013 (web).** Lima endpoint `/api/v1/auth` (register, login, logout, forgot-password, resend-verification). `LoginUser` dipecah menjadi `verify()` (tanpa sesi) dan `handle()` (web, perilaku dan pesan tidak berubah) dengan `LoginFailedException`. `IssueMobileToken` (satu token per perangkat; token lama dicabut). Resource `AuthSessionResource` dan `UserSummaryResource`. Tautan verifikasi tanpa login untuk email yang dipicu API (`verification.verify.guest`, `GuestEmailVerificationController`, pesan di `Masuk.tsx`). CORS dimatikan (`config/cors.php`). Diuji manual: validasi 422, daftar, duplikat, kirim ulang (3 lalu 429), tautan verifikasi API vs web, login, pencabutan token lama, logout, akun nonaktif 403, lupa sandi (respons sama), CORS tanpa header, batas login 5 lalu 429, rute terdaftar; regresi web (login, daftar, halaman utama) dinyatakan aman oleh founder.

**TASK-M014 (web, commit `9afd27c`; diperiksa ke repo web 2026-11-06).** Enam endpoint API-M006 sampai M011 di `routes/api.php`: `GET /me` (`user`, `consent`, `limits`, `crisis_contacts_version`), `GET /config` (publik; `min_app_version`, `crisis_contacts_version`, `features.overlay`), `GET /consent` (`ai`, `training`, `state`), `POST /relaxmate/consent`, `POST /account/training-consent` (`choice`), `GET /crisis-contacts` (`version`, `contacts`). Middleware `api.verified` (`EnsureEmailVerifiedApi`, 403 `unverified`) hanya pada dua POST. Limiter `api-public` (per IP) dan `api-user` (per pengguna), masing-masing 60/menit dari `relaxboss.mobile.public_per_minute` dan `user_per_minute`. `min_app_version` bawaan `0.0.0` dari `MOBILE_MIN_APP_VERSION`; `features.overlay` bawaan `true`. `crisis_contacts_version` adalah 12 karakter pertama SHA-1 dari isi daftar. Teks consent di `config/relaxboss.php` bagian `consent` (dipakai web lewat `ConsentInfo` dan API); naikkan `ai_consent_version` atau `ai_training_consent_version` bila teks berubah (OQ-MA8 ditutup). Sanctum 4.3.3 dan Laravel v13.40.0 sesuai `composer.lock`. OQ-MA9 tetap terbuka sampai M025 (`phone` dikirim apa adanya: `119 ext 8`). Token pengguna nonaktif baru ditolak di M016. Hasil uji manual dilaporkan lolos oleh founder; rincian skenarionya tidak ada di repo dan belum tercatat di sini.

**TASK-M020 (mobile).** Proyek Flutter (paket Dart `relaxmate`, Application ID `id.my.relaxboss.relaxmate`, `minSdk 26`). Struktur folder sesuai Architecture-M bagian 4. Flavor `dev` (suffix `.dev`) dan `prod`, `--dart-define=API_BASE_URL` (flavor `prod` menolak non-HTTPS), `ConfigErrorApp` bila konfigurasi tidak valid. Token tema (`RbColors`, `RbText`, `RbSpace`, `RbRadius`, `RbSize`, `RbShadow`, `RbMotion`) dan `RbTheme`, Plus Jakarta Sans dibundel. Manifest: `allowBackup=false`, portrait, cleartext hanya di `src/debug`. Gradle memakai DSL AGP 9 (`extensions.configure<ApplicationExtension>`, `buildFeatures { resValues = true }`). `flutter analyze` bersih; emulator, kasus konfigurasi gagal, dan build debug lolos.

**TASK-M021 (mobile).** `ApiClient` (`dio`; `Authorization`, `X-App-Version`; tanpa log isi atau token), `ApiException` dan `error_mapper` (amplop galat, validasi Laravel, `Retry-After`, timeout, offline), `TokenStorage` (`flutter_secure_storage`), `AppVersion`, fitur `startup` (`StartupGate`, `SplashView`, `UpdateRequiredScreen`, cek `min_app_version` **gagal-terbuka** dengan batas 5 detik), alat `tool/mock_api.mjs`. Paket terpasang: `dio`, `flutter_secure_storage`, `package_info_plus`, `url_launcher`. Diuji manual dengan server tiruan (mode `ok`, `old`, `slow`, `error`, `unauthorized`, server mati) dan backend Laravel asli (`/config` masih 404, aplikasi lanjut).

**TASK-M022 (mobile; kode selesai 2026-11-06, uji manual belum dilakukan).** Fitur `auth/`: `data/` (`UserSummary`, `AuthSession`, `ResendResult`, `AuthRepository` untuk API-M001 sampai M006), `state/` (`AuthState` bertingkat: `AuthRestoring`, `AuthUnauthenticated`, `AuthAuthenticated`, `AuthSessionCheckFailed`; `AuthController`), `ui/` (SCR-M03 `RegisterScreen`, SCR-M04 `LoginScreen`, SCR-M05 `ForgotPasswordScreen`, SCR-M06 `CheckEmailScreen`, `SessionErrorScreen`, `AuthScaffold`, `PasswordField`, `AuthValidators`). Router memilih layar dari keadaan sesi lewat `authRedirect` (`core/router/auth_redirect.dart`): tamu hanya Masuk, Daftar, Lupa sandi; sudah masuk tetapi email belum terverifikasi hanya Cek email; terverifikasi ke layar utama. Token tersimpan dipulihkan saat aplikasi dibuka lewat `GET /me`; bila gagal bukan 401 (offline, timeout, galat server) tampil `SessionErrorScreen` (coba lagi atau keluar) dan token tidak dihapus. 401 pada permintaan bertoken: `ApiClient` menghapus token lalu `SessionExpiredSignal` (`core/api`) memberi tahu `AuthController` sehingga pengguna dialihkan ke Masuk (menutup `TODO(TASK-M022)`). Cek email memeriksa status otomatis saat aplikasi kembali ke depan layar. Komponen baru: `ErrorAlert` (CMP-M13, `shared/widgets`), `WebLauncher` (`core/launch`) dan `AppConfig.webUri` untuk membuka `/ketentuan` dan `/privasi` di host API. **Perbaikan:** izin `INTERNET` ditambahkan ke `AndroidManifest.xml` utama (sebelumnya hanya di manifest debug sehingga build rilis tidak akan bisa terhubung). `tool/mock_api.mjs` mendapat mode `auth` (akun contoh, pembantu `/__verify`, `/__expire`, `/__reset`, batas tiruan); semua skenarionya diuji dengan curl di sandbox setelah satu bug (`devHelpers` membalas dua kali) diperbaiki. `ChatScreen` sementara diberi info email dan tombol Keluar (`TODO(TASK-M031)`). **Belum dijalankan (sandbox tanpa Flutter): `flutter analyze`, `dart format`, build debug, dan uji di emulator.**

**Verifikasi dokumen terhadap kode mobile (2026-11-06, commit `8014c38`).** Repo `relaxmate-mobile-apps` dibaca penuh (`lib/`, `android/`, `pubspec`, `analysis_options`, `tool/`). Cocok dengan dokumen: nilai token `Rb*` dan teks `AppTexts` sama dengan Design-M; flavor, `minSdk 26`, Application ID, `allowBackup=false`, cleartext hanya debug, dan portrait; `ApiException`/`error_mapper`; cek versi gagal-terbuka 5 detik; paket dan versi terpasang. Yang diperbarui di dokumen karena kode berbeda atau lebih rinci: struktur folder nyata, versi paket, validasi `AppConfig`, timeout per fase dan pemetaannya ke `timeout` (bukan `ai_unavailable`), cek versi sekali per pembukaan, tema komponen `RbTheme`, nilai bayangan, daftar lint, dan status penerapan privasi. Tidak ada `print`, `// ignore:`, `Colors.*`/`Color(0x...)` di luar `rb_colors.dart`, atau null-bang di `lib/` (pencarian teks). `flutter analyze` dan build tidak dijalankan ulang di sesi ini (tanpa Flutter di sandbox). Repo web (`RELAXBOSS_WEBSITE`, commit `9afd27c`) dibaca untuk TASK-M012 sampai M014: rute, controller, middleware, limiter, dan config sesuai dengan catatan; bentuk JSON `/config` cocok dengan parser `ServerConfig` mobile.

---

## 4. Keterlacakan (ringkas)

| Kebutuhan | Task |
|---|---|
| Akun, consent, hapus akun (FR-M001..M003) | M012, M013, M014, M016, M022, M023, M031 |
| Percakapan harian dan riwayat (FR-M004..M009) | M010, M011, M015, M024, M027 |
| Keselamatan (FR-M010..M012) | M025, M041, M053 |
| Cek Rasa dan latihan (FR-M013..M015) | M028, M029, M030 |
| Suara (FR-M016..M020) | M050, M051, M052, M054 |
| Suara balasan dan maskot mengambang (FR-M021..M024) | M032, M033, M034, M060 |
| Pengaturan (FR-M025, M026) | M031 |
| NFR dan rilis (NFR-M01..M07) | M017, M040, M042, M043, M044, M045 |

---

## 5. Pertanyaan Terbuka

| ID | Pertanyaan | Dibutuhkan sebelum |
|---|---|---|
| OQ-MP1 | **Ditutup 2026-11-05:** panduan suara latihan napas ke Fase 2; US-M07 dan FR-M014 di PRD-Mobile v0.3 diperbarui. | - |
| OQ-M2 | Ejaan "RelaxMate" vs "RelaxMates" dan cara maskot menyapa pengguna | TASK-M030 |
| OQ-M3 | Cek Rasa hanya pesan chat, atau juga menulis Mood Entry | TASK-M028 |
| OQ-M4 | Ingatan lintas hari (ringkasan terenkripsi) | Setelah MVP |
| OQ-M5 | Batas harian untuk obrolan suara | TASK-M050 |
| OQ-M6 | TTS: suara perangkat saja atau ElevenLabs API terbatas | TASK-M061 |
| OQ-MA1 | Plugin overlay vs Kotlin; jenis foreground service | TASK-M003 |
| OQ-MA2 | **Ditutup 2026-11-06:** email verifikasi yang dipicu API memakai rute bertanda tangan tanpa login (`verification.verify.guest`); email dari alur web tidak berubah (ADR-M09). | - |
| OQ-MA3 | Kualitas STT Bahasa Indonesia, paket bahasa | TASK-M004 |
| OQ-MA4 | `SendChatMessage` diekstrak sekarang atau bungkus dulu. Temuan 2026-11-06: logika ada di satu metode `ChatMessageController::store()` dan retry sudah ada (`retry=true`), jadi ekstraksi terbatas dan jelas batasnya | **Selesai 2026-11-06**: diekstrak sekarang | TASK-M010 |
| OQ-MA5 | Android minimum, aturan closed testing Play, Data Safety | TASK-M043 |
| OQ-MA6 | Bentuk respons dan kode galat API chat (API-M013, M014): ikuti presenter web (`user_message`, `assistant_message`, `has_crisis`, `remaining_today`, kode `invalid_message`, `busy`, `daily_limit`, `rate_limited`, `ai_unavailable`, `nothing_to_retry`) dan tambahkan `created_at` ISO UTC (RULE-M033), atau bentuk di Architecture-M bagian 5. Usulan: ikuti web dan hapus endpoint retry terpisah | **Diputuskan 2026-11-06**: ikuti presenter web, tambah `created_at` ISO UTC, tanpa endpoint retry terpisah | TASK-M015 |
| OQ-MA11 | POST pesan ke Percakapan yang bukan hari ini (setelah pergantian 04.00 WIB) ditolak 409 `conversation_closed` agar riwayat hanya baca (FR-M005). Setuju, atau izinkan menulis ke Percakapan lama? | **Diusulkan 2026-11-06 (di kode)**, perlu konfirmasi | TASK-M024 |
| OQ-MA12 | Bila pengguna menolak consent AI: aplikasi kini hanya menawarkan "Keluar" (tidak ada dashboard seperti di web, dan latihan serta kontak bantuan belum ada). Setelah TASK-M025 dan M029, apakah penolakan membawa pengguna ke layar yang hanya berisi latihan napas, grounding, dan kontak bantuan (tanpa AI)? Usulan: ya | TASK-M029 |
| OQ-MA7 | Batas hari kuota (`ChatQuota` mulai 00.00 WIB) berbeda dari hari percakapan (`DailyConversationResolver`, 04.00 WIB). Antara 00.00 dan 04.00 keduanya tidak sejajar | **Diputuskan 2026-11-06 (opsi A)**: kuota tetap 00.00 WIB, hari percakapan 04.00 WIB; ketidaksejajaran 00.00-04.00 hanya didokumentasikan, web tidak diubah | TASK-M011 |
| OQ-MA8 | **Ditutup 2026-11-06 (TASK-M014):** teks consent ada di `config/relaxboss.php` bagian `consent`; naikkan `ai_consent_version` atau `ai_training_consent_version` bila teks berubah. | - |
| OQ-MA9 | Kontak krisis web memuat `119 ext 8`; format `tel:` untuk ekstensi perlu diputuskan dan diuji di perangkat | TASK-M025 |
| OQ-MA10 | Paket ikon: Lucide (`lucide_icons_flutter`, sesuai RULE-M051) atau `Icons` bawaan Material. M022 memakai `Icons` bawaan agar tidak menambah dependensi yang belum bisa diverifikasi di sandbox. Putuskan sebelum layar chat yang padat ikon | TASK-M024 |
| OQ-3, OQ-5 (web) | Kontak krisis terverifikasi; telaah hukum data AI, pelatihan, dan layanan suara | TASK-M045 |

---

## 6. Keputusan Kunci (ringkas)

| Keputusan | Sumber |
|---|---|
| Flutter, Android dulu | ADR-M01 |
| Sanctum token untuk mobile (merevisi ADR-013 web) | ADR-M02 |
| Satu percakapan per hari lewat resolver, tanpa mengubah skema | ADR-M03 |
| Tanpa streaming | ADR-M04 |
| Klip suara rekaman dibundel + suara perangkat untuk balasan panjang | ADR-M05 |
| Overlay tanpa mikrofon, jaringan, data pengguna, atau AccessibilityService | ADR-M06 |
| Isi chat tidak di disk perangkat | ADR-M07 |
| Mikrofon tidak aktif di latar belakang (keputusan founder 2026-11-04: cari aman) | PRD-M Non-goals |
| Karakter orisinal RelaxMate, panggilan "Mates"; tidak meniru karakter pihak lain | PRD-M 1 |
| Nilai token warna mengikuti kode website (`app.css`), bukan tabel Design web yang belum sinkron | Design-M 2, RULE-M050 |
| Panduan suara latihan napas ditunda ke Fase 2; Fase 1 visual + getar | PRD-M v0.3, TASK-M029 |
| Urutan backend: M012, M013, M014 lebih dulu karena membuka layar Masuk (M022); M010 dan M011 hanya dibutuhkan chat (M015) | Keputusan 2026-11-06 |
| Email verifikasi dari API memakai tautan tanpa login; alur web tidak berubah | ADR-M09, OQ-MA2 |
| Satu token per perangkat; login baru mencabut token lama bernama sama | ADR-M10 |
| Galat `/api/*` seragam `{ "error": { "code", "message" } }`; kode final `invalid_credentials` (401), `account_inactive` (403), `rate_limited` (429), `validation_failed` (422), `unauthenticated` (401) | ADR-M11 |
| CORS dimatikan (klien hanya aplikasi native) | ADR-M12 |
| Pemeriksaan versi aplikasi gagal-terbuka (batas 5 detik) | ADR-M13 |
| `crisis_contacts_version` adalah sidik isi daftar kontak (12 karakter pertama SHA-1 dari JSON daftar; berubah hanya bila isi berubah); klien membandingkannya untuk memperbarui cache | Architecture-M 5 (TASK-M014) |
| `min_app_version` bawaan `0.0.0` (env `MOBILE_MIN_APP_VERSION`); penanda `features.overlay` ada di config server untuk R-M4 | Architecture-M 5, 9 (TASK-M014) |
| Teks consent di server (`config/relaxboss.php` bagian `consent`); versi consent AI dan pelatihan dinaikkan terpisah | Architecture-M 5, 9 (TASK-M014) |
| Gerbang consent berupa widget `ConsentGate` dengan `ConsentController` sendiri, bukan cabang `authRedirect`; latihan dan kontak bantuan kelak tidak dibungkus gerbang ini | TASK-M023, ADR-M14 |
| SCR-M07 dibangun sebagai layar penuh (bukan bottom sheet seperti CMP-M14 lama): gerbang ini memblokir fitur AI jadi tidak boleh ditutup | TASK-M023, Design-M CMP-M14 (dokumen mengikuti kode) |
| Consent: hanya bagian yang kurang yang tampil; tombol utama menyimpan berurutan consent AI lalu pilihan pelatihan; "Keluar" sebagai satu-satunya alternatif sementara (OQ-MA12) | TASK-M023, FR-M002 |
| **Dokumen mengikuti kode:** bila dokumen dan kode berbeda, kode yang dianggap benar dan dokumen diperbarui | Keputusan founder 2026-11-06 |
| Paket Dart `relaxmate`; flavor `dev` ber-suffix `.dev`; teks UI di `core/texts/app_texts.dart` | Architecture-M 4, 10 |
| Sesi dimodelkan sebagai `AuthState` bertingkat (memulihkan, tamu, masuk, sesi belum bisa diperiksa); router memilih layar dari keadaan itu lewat `authRedirect` | TASK-M022, Architecture-M 4 |
| 401 dari lapisan jaringan disampaikan lewat `SessionExpiredSignal` agar `core/` tidak mengimpor `features/` | TASK-M022 |
| Form Daftar hanya Nama, Email, Kata sandi, dan centang Ketentuan; Jurusan dan Kampus (opsional di server) tidak ditanyakan di mobile (bisa diisi di web). Dapat diubah bila founder ingin | TASK-M022, FR-M001 |
| Aturan sandi tidak digandakan di klien; klien hanya memeriksa kolom wajib dan bentuk email, pesan server tampil di bawah kolom (RULE-M023, M026) | TASK-M022 |
| Tautan Ketentuan dan Privasi dibuka dari halaman web di host `API_BASE_URL` (`/ketentuan`, `/privasi`), bukan URL kedua di klien | TASK-M022, RULE-M026 |
| Izin `INTERNET` ada di manifest utama; manifest debug hanya menambah cleartext | TASK-M022, RULE-M048 |

---

## 7. Risiko dan Utang

| ID | Risiko / utang | Catatan |
|---|---|---|
| R-M1 | Penolakan toko | Karakter orisinal, disclaimer, hapus akun, overlay default mati |
| R-M3 | Krisis terlewat karena salah dengar | TASK-M041, M053 |
| R-M4 | Aturan foreground service/overlay berubah; Fase 1 lebih berat karena overlay ikut MVP | Spike TASK-M003; modul overlay terpisah dan bisa dimatikan lewat feature flag |
| R-M5/M7 | Biaya dan konsistensi suara | Generate semua klip dalam satu sesi selagi paket berbayar aktif |
| Utang web | Refaktor `SendChatMessage` menyentuh produksi web | Uji manual sebelum dan sesudah (TASK-M010) |
| Utang dokumen | Sinkronisasi nama OQ-MA/OQ-M dan nomor FR antar dokumen | Dicek di TASK-M001 |
| Utang dokumen | Schema-Mobile belum memuat tabel `personal_access_tokens` (Schema-M bagian 2); file tidak ikut serta dalam sinkronisasi ini | Tambahkan: `id`, `tokenable_type`, `tokenable_id`, `name`, `token` (hash, unik), `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at` |
| Utang web | Pemasangan Sanctum ikut menaikkan 36 paket (framework v13.40.0); `composer audit` belum dilaporkan | Jalankan `composer audit` dan catat hasilnya |
| Utang web | Mailer `log` menulis tautan verifikasi dan token reset sandi ke `laravel.log` (terlihat pada uji M017, lokal). Pastikan `MAIL_MAILER` produksi bukan `log`, dan jangan membagikan potongan log tanpa menyamarkan tautannya | Prasyarat rilis (TASK-M045) |
| Utang mobile | Layar "Perbarui aplikasi" belum punya tautan Kontak bantuan (menyalahi Design-M prinsip 4) | `TODO(TASK-M025)`; jangan rilis sebelum M025 |
| Utang mobile | Jalur 401 (`ApiClient` menghapus token, `SessionExpiredSignal`, lalu layar Masuk) sudah dikodekan di M022 tetapi belum diuji | Uji lewat `/__expire` di server tiruan (panduan uji M022); hapus baris ini setelah lolos |
| Utang dokumen | Rincian uji manual TASK-M014 belum tercatat (repo hanya memuat kode) | Lengkapi di catatan hasil |
| Utang mobile | `ServerConfig` baru membaca `min_app_version`; `crisis_contacts_version` (string 12 hex) dan `features.overlay` (boolean) sudah dikirim `/config` tetapi belum dibaca | M025 dan M033/M034 |
| Utang mobile | Cek versi baru diuji dengan server tiruan; `/config` asli ada sejak M014 dan bentuknya cocok dengan parser (diperiksa lewat kode, belum dijalankan) | Uji jalan terhadap backend asli sebelum M022 |
| Utang mobile | `android/app/build.gradle.kts`: rilis masih ditandatangani kunci debug dan ada dua `TODO` templat tanpa ID (RULE-M027) | TASK-M043; jangan rilis sebelumnya |
| Utang mobile | Komentar di `pubspec.yaml` ("Versi `any` hanya untuk setup awal...") usang karena versi sudah memakai `^` | Hapus di commit berikutnya |
| Utang mobile | `AppConstants.requestTimeout` berlaku per fase (connect, send, receive) dan dipetakan ke `timeout`, bukan `ai_unavailable` seperti tertulis di komentarnya | Putuskan perlakuan di M024; samakan komentar |
| Catatan web | `GET /crisis-contacts` memuat penanda `dummy` per kontak; preflight RULE-M048 dapat memakainya. Daftar produksi saat ini hanya Healing119.id (`119 ext 8`); kontak Laboratorium muncul bila `PSYCH_LAB_HOTLINE_PHONE` terisi | M025, M043 |
| Utang mobile | Layar Daftar, Masuk, Lupa sandi, Cek email, dan sesi belum punya tautan Kontak bantuan (Design-M prinsip 4) | `TODO(TASK-M025)` di `AuthScaffold`; jangan rilis sebelum M025 |
| Utang mobile | UI untuk mengubah pilihan persetujuan pelatihan kapan saja (FR-M002, "dapat diubah di Pengaturan") belum ada karena layar Pengaturan baru dibuat di TASK-M031. `ConsentRepository.setTraining` (API-M010) sudah ada; M031 menambah layar dan membaca pilihan saat ini (`training.choice` belum diurai `ConsentState`) | M031 |
| Utang mobile | 403 `consent_required` di tengah sesi (versi consent dinaikkan saat aplikasi terbuka) belum ditangani; `ConsentGate` memeriksa saat layar dibuka | M024: `ref.invalidate(consentControllerProvider)` saat menerima kode itu |
| Utang mobile | Layar consent memakai `AuthScaffold`, jadi ikut belum punya tautan Kontak bantuan (Design-M prinsip 4) | `TODO(TASK-M025)` yang sama di `AuthScaffold` |
| Utang mobile | `ChatScreen` sementara memuat info email dan tombol Keluar | `TODO(TASK-M031)`; M024 mengganti layarnya |
| Utang mobile | Panjang minimum sandi baru diketahui pengguna setelah kirim (tidak digandakan di klien) | Pertimbangkan `password_min_length` di `GET /config` (backend) sebagai petunjuk di layar Daftar |
| Utang mobile | Keluar tanpa internet hanya menghapus token di perangkat; token di server tetap berlaku sampai kedaluwarsa (60 hari) | Putuskan di M031 (antrean pencabutan atau terima risikonya) |
| Utang mobile | Kode M022 belum melewati `flutter analyze`, `dart format`, dan build debug (sandbox tanpa Flutter) | Jalankan sebelum commit (panduan uji M022) |
| Observasi mobile | `StartupGate` menahan seluruh aplikasi sampai cek versi selesai (maks. 5 detik); kelak kontak bantuan harus bisa dibuka tanpa menunggu (Design-M prinsip 4, RULE-M034) | Evaluasi di M025 |

---

## 8. Log Sesi

| Tanggal | Ringkasan |
|---|---|
| 2026-11-05 | Dokumen mobile disusun: PRD v0.2, Architecture v0.1, Schema v0.1, Design v0.1, Rules v0.1, progress v0.1. Ditemukan inkonsistensi US-M07 vs klip suara (OQ-MP1). |
| 2026-11-05 (lanjutan) | Keputusan founder: warna mengikuti kode website; panduan suara napas ke Fase 2. PRD-M v0.3, Design-M v0.2, Rules-M v0.2 diperbarui; OQ-MP1 dan OQ-D1 ditutup. |
| 2026-11-06 | Sesi implementasi. Repo web dan dokumen dibaca; ditemukan ketidakcocokan dokumen dan kode (nama controller chat, bentuk respons dan kode galat, batas hari kuota, sumber teks consent, format `tel:`) dan dicatat sebagai OQ-MA6 s.d. MA9. Founder membuka task kode lebih awal. TASK-M020 dan M021 (Flutter) selesai dan lolos uji manual; TASK-M012 dan M013 (backend) selesai dan di-push ke `main` repo web. |
| 2026-11-06 (lanjutan) | TASK-M014 (backend) selesai. Dokumen disinkronkan ke kode mobile (commit `8014c38`): PRD, Architecture, Design, Rules, progress. Dipastikan Architecture-M adalah dokumen mobile di folder dokumen, bukan Architecture web; perubahan backend M014 dicatat di Architecture-M bagian 5, 7, 9, sedangkan Doc Sync web tetap terpisah. Repo web (`9afd27c`) kemudian diperiksa dan cocok dengan catatan M012 sampai M014; fakta backend kini berlabel `[Verified]`. |
| 2026-11-06 (sesi M022) | Repo mobile dan web dibaca ulang; TASK-M022 dikodekan (auth, sesi, router, `ErrorAlert`, `WebLauncher`), izin `INTERNET` ditambahkan ke manifest utama, `tool/mock_api.mjs` mendapat mode `auth` dan diuji dengan curl. Dokumen disinkronkan (progress 0.5, Architecture 0.4, Design 0.5, Rules 0.5). Kode belum dianalisis dan diuji di Flutter; menunggu uji manual founder. |
| 2026-11-06 (sesi M010) | Alur backend lebih dulu: M010, M011, M015, M016, M017. M022 `Done`; utang Doc Sync web M012-M014 dihapus (dokumen web sudah diperbarui). OQ-MA4, MA6, MA7 diputuskan. TASK-M010: `SendChatMessage` (Action), `ChatTurnRejectedException`, `SendChatMessageResult`; `ChatMessageController::store()` menjadi tipis; perilaku dan teks galat web tidak berubah. Menunggu uji manual web. progress.md v0.6. |
| 2026-11-06 (sesi M011) | M010 `Done` (uji manual web lolos). TASK-M011: `Services\Chat\DailyConversationResolver` (`today()`, `window()`; hari percakapan berganti 04.00 WIB, kunci cache terpisah dari kunci giliran chat) dan `relaxboss.mobile.day_cutoff_hour` = 4. Token (60 hari) dan `min_app_version` sudah ada dari M012/M014. Menunggu uji manual lewat tinker. progress.md v0.7. |
| 2026-11-06 (sesi M015) | Repo dibaca ulang (web `4258424`, mobile `c1bdbd1`). TASK-M015 dikodekan: API-M012, M013, M015, M016 (+ `ChatPresenter::apiMessage`, `DailyConversationResolver::dayKey/isCurrent`). Retry lewat M013, API-M014 tidak dibuat. Architecture-M v0.5, progress v0.8. Menunggu uji manual (M011 dan M015). |
| 2026-11-06 (sesi M016) | Founder melaporkan uji M011 dan M015 lolos (`Done`). TASK-M016 dikodekan: `api.active`, `DELETE /account`, pencabutan token di `DeleteUserAccount`. Menunggu uji manual. Architecture-M v0.6, progress v0.9. |
| 2026-11-06 (sesi M023) | Repo web (`905f455`) dan mobile (`696e6e3`) dibaca ulang; M016 tetap `Doing` (belum ada laporan uji). TASK-M023 dikodekan: `features/consent`, `ConsentGate` di router, token garis dan teks consent, mock API diperluas. Dokumen disinkronkan (Architecture 0.7, Design 0.6, Rules 0.6, progress 0.10); status Tahap yang usang (M022) dibetulkan. OQ-MA12 dibuka. Menunggu uji manual M016 dan M023. |
| 2026-11-07 (sesi M017) | Founder menjalankan M017 dan memberikan potongan `laravel.log`. Log diperiksa terhadap RULE-040 (bersih untuk `ai.*`), temuan mailer `log` dicatat sebagai utang web. M017 `Doing` sampai founder mengonfirmasi hasil skenario isolasi A vs B, batas, dan 503. `progress.md` digabung dengan versi M023 (v0.10, sudah di `main`) menjadi v0.11. |
| 2026-11-07 (konfirmasi) | Founder mengonfirmasi uji manual M016, M017, dan M023 lolos: ketiganya `Done`; MM1 (backend) selesai. Utang web `active` varian API dan utang uji M023 dihapus. TASK-M024 menjadi `Next`. Architecture 0.8, Rules 0.7, progress 0.12. |

---

## 9. Catatan Serah Terima

1. Mulai dari task berstatus `Next`: TASK-M024 (layar chat); putuskan OQ-MA10 dan OQ-MA11 lebih dulu. Task kode sudah dibuka lebih awal lewat keputusan founder 2026-11-05/06; prasyarat web (TASK-M002) tetap wajib sebelum rilis (TASK-M045).
2. Urutan kerja: MM1 (backend) dan MM2 (Flutter) boleh berselang-seling. Yang sudah ditempuh: M010 sampai M017, M020, M021, M022, M023 (uji lolos). Yang disarankan berikutnya: M024, dan seterusnya sampai MM6. Fase 2 dan 3 dirilis sesudahnya.
3. Spike TASK-M003 sebaiknya dikerjakan lebih awal karena overlay adalah bagian paling berisiko; bila hasilnya buruk, putuskan apakah overlay keluar dari Fase 1 (ubah PRD-M).
4. Setiap perubahan perilaku, route, skema, atau keputusan memperbarui dokumen terkait dan progress ini di akhir task yang sama (RULE-M005).
5. Cara menerapkan hasil task: backend berupa zip untuk ditimpa di root repo web (periksa `git diff --stat` sebelum commit); mobile berupa zip untuk ditimpa di root repo mobile. Sandbox tidak punya PHP penuh, Composer, atau Flutter, jadi verifikasi selalu lewat uji manual lokal.
6. **Dokumen mengikuti kode** (keputusan 2026-11-06): sebelum menulis dokumen, baca kode; bila berbeda, perbarui dokumen. Fakta web diperiksa ke repo `RELAXBOSS_WEBSITE` (bukan hanya dari catatan); yang belum bisa diperiksa ditandai jelas sebagai belum diverifikasi.

## Change Log

| Versi | Tanggal | Perubahan |
|---|---|---|
| 0.12 | 2026-11-07 | M016, M017, M023 `Done` (uji manual lolos); MM1 selesai; M024 `Next`; catatan hasil dan Tahap/Berikutnya disegarkan; utang yang selesai dihapus. |
| 0.11 | 2026-11-07 | TASK-M017 `Doing` (dijalankan, log diperiksa, menunggu konfirmasi): catatan hasil dan temuan mailer `log`, utang web baru, log sesi; Status Proyek dan Serah Terima disegarkan. Digabung di atas v0.10 (M023). |
| 0.10 | 2026-11-06 | TASK-M023 `Doing` (kode selesai, menunggu uji manual): catatan hasil, OQ-MA12, keputusan gerbang consent, utang baru, log sesi; Status Proyek dan Serah Terima disegarkan (M022 sudah `Done`). |
| 0.9 | 2026-11-06 | M011 dan M015 `Done`; M016 `Doing` (kode selesai): catatan hasil, utang `active` varian API, log sesi. |
| 0.8 | 2026-11-06 | TASK-M015 `Doing` (kode selesai, menunggu uji manual): catatan hasil, OQ-MA11, log sesi, urutan berikutnya. |
| 0.7 | 2026-11-06 | M010 `Done`; M011 `Doing` (kode selesai); log sesi M011. |
| 0.6 | 2026-11-06 | M022 `Done`; M010 `Doing` (kode selesai); OQ-MA4, MA6, MA7 diputuskan; utang Doc Sync web M012-M014 dihapus; urutan berikutnya M010, M011, M015, M016, M017. |
| 0.5 | 2026-11-06 | TASK-M022 `Doing` (kode selesai, menunggu uji manual) beserta catatan hasil; OQ-MA10 (paket ikon); keputusan baru (sesi bertingkat, sinyal 401, form Daftar, aturan sandi di server, tautan web, izin INTERNET); utang baru; utang 401 diperbarui. |
| 0.4 | 2026-11-06 | TASK-M014 Done; M022 menjadi Next; catatan hasil M014; verifikasi dokumen terhadap kode mobile; OQ-MA8 ditutup; keputusan baru (sidik kontak, `min_app_version` bawaan, teks consent di server, dokumen mengikuti kode); utang baru dari audit kode dan Doc Sync web; fakta backend diperiksa ke repo web (`9afd27c`). |
| 0.3 | 2026-11-06 | Sinkronisasi setelah TASK-M012, M013, M020, M021 selesai: status task, catatan hasil, OQ-MA2 ditutup, OQ-MA6 s.d. MA9 baru, keputusan kunci, risiko dan utang, log sesi, catatan serah terima. |
| 0.2 | 2026-11-05 | OQ-MP1 dan OQ-D1 ditutup; keputusan warna dan panduan suara napas; versi dokumen disinkronkan. |
| 0.1 | 2026-11-05 | Draf awal: roadmap MM0-MM8, Task Board TASK-M001..M061, keterlacakan, OQ, keputusan, risiko. |
