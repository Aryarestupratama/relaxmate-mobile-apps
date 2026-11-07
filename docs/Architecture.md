# RelaxMate Mobile - Architecture
Version: 0.13 | Status: Draft | Last updated: 2026-11-07
Depends on: PRD RelaxMate Mobile v0.3, Architecture RelaxBoss (web), Schema RelaxBoss (web), Rules v1.5 | Owner: Founder (solo developer)

Label: `[Verified]` ada sumber (sisi mobile: repo `relaxmate-mobile-apps` commit `8014c38`; sisi backend: repo `RELAXBOSS_WEBSITE` commit `9afd27c`), `[Inference]` kesimpulan, `[Assumption]` bisa diubah. **Dokumen ini mengikuti kode:** bila berbeda dari kode, kode yang benar. Kedalaman: **Lite**. Dokumen ini hanya mengatur sisi mobile dan tambahan di backend. Subsistem AI (rotasi key, `ChatbotService`, `CrisisDetector`), enkripsi, dan admin tetap di Architecture web dan tidak diulang di sini.

---

## 1. Prinsip

1. **Satu backend, dua klien.** Web dan mobile memakai Service yang sama; controller API hanya lapisan tipis (ADR-001 web, RULE-022).
2. **Klien tipis.** Batas pesan, kuota, deteksi krisis, AI, dan aturan “hari” dihitung di server. Aplikasi hanya menampilkan dan mengumpulkan input.
3. **Aplikasi tidak memegang secret.** Tidak ada API key Groq atau layanan suara berbayar di APK (RULE-030, RULE-043).
4. **Isi percakapan tidak disimpan di disk perangkat.** Hanya di memori selama layar terbuka.
5. **Fitur sensitif platform (mikrofon, overlay) selalu atas aksi pengguna,** tampil di depan layar, dan mudah dimatikan. Tidak ada pendengaran di latar belakang.
6. **Tanpa proses permanen di server** (RULE-034): tanpa streaming, WebSocket, queue, atau push server.
7. **Sederhana dulu.** Build lokal, tanpa CI, kerja di `main` (ADR-011 web). Setiap paket punya alasan satu kalimat (bagian 12).

---

## 2. Stack

| Lapisan | Pilihan | Alasan | Label |
|---|---|---|---|
| Klien | Flutter (Dart), Android dulu | Pengalaman founder; iOS menyusul | Keputusan; Dart SDK `^3.5.0` `[Verified]` |
| Android minimum | API 26 (Android 8.0) | Overlay `TYPE_APPLICATION_OVERLAY` tersedia sejak 26 | `[Assumption]` (OQ-MA5); diterapkan di `build.gradle.kts` (`minSdk = 26`, TASK-M020) |
| State | `flutter_riverpod` | Sederhana, mudah diuji manual | `[Verified]` `^3.4.3` (terkunci 3.4.3) |
| Navigasi | `go_router` | Deep link ke mode suara dan latihan | `[Verified]` `^18.1.3` |
| Jaringan | `dio` | Interceptor token dan pemetaan error | `[Verified]` `^5.11.1` |
| Token | `flutter_secure_storage` | Keystore Android | `[Verified]` `^11.2.0` |
| Analisis statis | `flutter_lints` + lint tambahan | Kode konsisten (RULE-M020) | `[Verified]` `^6.0.0` (dev dependency) |
| Suara masuk | `speech_to_text` (pengenal bawaan perangkat) | Tanpa biaya, audio tidak keluar dari alur OS | Kualitas Bahasa Indonesia diuji per perangkat |
| Klip suara | `just_audio` | Putar klip rekaman bundel | Cek versi |
| Suara balasan | `flutter_tts` | Suara bawaan perangkat, percobaan (Fase 3) | Cek versi |
| Maskot | Rive atau Lottie | Animasi menyimak, berpikir, bicara | Pilih saat Task maskot |
| Overlay Android | Plugin overlay atau modul Kotlin sendiri | Maskot mengambang | Putuskan di spike (OQ-MA1) |
| Server | Laravel 13 yang sama, `/api/v1`, Sanctum token | ADR-M02 | `[Verified]` Laravel 13.40.0 dan Sanctum 4.3.3 terpasang (TASK-M012) |

---

## 3. Konteks dan Container

| Container | Teknologi | Tanggung jawab |
|---|---|---|
| App Flutter | Dart | UI, input suara, putar klip, penyimpanan token, panggilan API |
| Modul native Android | Kotlin | Maskot mengambang: window overlay, foreground service, izin |
| API Laravel `/api/v1` | Laravel + Sanctum | Autentikasi token; controller tipis di atas Action/Service web |
| Groq | Lewat `ChatCompletionClient` | Tidak pernah diakses langsung oleh aplikasi |

Aliran data: `App → HTTPS → API Laravel → ChatbotService → (CrisisDetector, ChatCompletionClient → Groq)`. Tidak ada jalur lain keluar dari perangkat kecuali ke domain API sendiri.

---

## 4. Struktur Folder (Flutter)

Sesuai kode di repo `relaxmate-mobile-apps` (commit `8014c38`, setelah TASK-M020 dan M021) `[Verified]`:

```
relaxmate-mobile-apps/              # nama repo; paket Dart: relaxmate
  pubspec.yaml, pubspec.lock, analysis_options.yaml, README.md, .gitignore
  lib/
    main_dev.dart, main_prod.dart   # titik masuk per flavor (memanggil bootstrap)
    bootstrap.dart                  # portrait saja, muat AppConfig, ProviderScope
    app.dart                        # MaterialApp.router: tema, locale id, router, StartupGate (di builder)
    config_error_app.dart           # tampil bila konfigurasi build tidak valid
    core/
      config/     # AppFlavor, AppConfig (+ appConfigProvider, webUri), AppConstants, AppVersion, AppAssets
      api/        # ApiClient (dio), api_providers (token, versi aplikasi, ApiClient), JsonMap,
                  # SessionExpiredSignal (401 dari jaringan ke fitur sesi)
      launch/     # WebLauncher (buka halaman web di peramban perangkat)
      error/      # ApiException, ApiErrorKind, error_mapper
      storage/    # TokenStorage (flutter_secure_storage)
      theme/      # RbColors, RbText, RbSpace (ThemeExtension); RbRadius, RbSize, RbShadow, RbMotion (konstanta);
                  # RbTheme.light(), RbThemeContext (context.rbColors / rbText / rbSpace)
      router/     # AppRoutes, authRedirect (layar yang boleh tampil menurut sesi), routerProvider (go_router)
      texts/      # bank teks UI (AppTexts)
    features/
      startup/    # data/ (ServerConfig, ServerConfigRepository, StoreLauncher),
                  # state/ (versionGateProvider, VersionGateStatus),
                  # ui/ (StartupGate, SplashView, UpdateRequiredScreen)
      chat/       # data/ (ChatMessage, ChatLimits, ChatDay, SendResult, ChatRepository),
                  # state/ (ChatState, ChatController, SendOutcome),
                  # ui/ (ChatScreen, ChatBubble, ChatInputBar, TypingIndicator, ChatWelcome, SuggestionChips)
      auth/       # data/ (UserSummary, AuthSession, ResendResult, AuthRepository),
                  # state/ (AuthState, AuthController),
                  # ui/ (LoginScreen, RegisterScreen, ForgotPasswordScreen, CheckEmailScreen,
                  #      SessionErrorScreen, AuthScaffold, PasswordField, AuthValidators)
      consent/    # data/ (ConsentState, ConsentPrompt, TrainingChoice, ConsentRepository),
                  # state/ (ConsentGateState, ConsentController),
                  # ui/ (ConsentGate, ConsentScreen, ConsentChoiceTile, ConsentErrorScreen)
      crisis/     # data/ (CrisisContact, CrisisContactSet, CrisisContactsRepository),
                  # state/ (CrisisContactsController),
                  # ui/ (CrisisBanner, CrisisCallButton, CrisisContactCard, CrisisContactsList, CrisisContactsScreen)
      history/    # data/ (HistoryDay, HistoryPage, ConversationPage, HistoryRepository, history_timeline),
                  # state/ (HistoryState, HistoryController, ConversationState, ConversationController),
                  # ui/ (HistoryScreen, ConversationScreen, HistoryEntryTile, HistoryLoadMore)
      checkin/    # data/ (MoodLevel, MoodRepository),
                  # state/ (CheckinState, CheckinController),
                  # ui/ (CheckinCard, MoodBlobRow)
      exercises/ voice/ mascot/ overlay/ settings/   # masih .gitkeep
    shared/
      widgets/    # MateAvatar + MateAvatarSize (CMP-M01), ErrorAlert (CMP-M13)
  assets/
    fonts/          # Plus Jakarta Sans (OFL)
    images/mascot/  # avatar RelaxMate (dari aset web); terdaftar di pubspec
    images/mood/    # mood-1..5.webp: blob Cek Rasa (salinan aset web `public/images/mood`); terdaftar di pubspec
    audio/clips/    # klip rekaman + clips.json (intent -> daftar klip); masih .gitkeep
    crisis/         # crisis_contacts.json: fallback kontak bantuan (tanpa data dummy di rilis); terdaftar di pubspec
    texts/          # teks panjang (privasi, ketentuan); masih .gitkeep
  tool/             # alat pengembangan, bukan bagian aplikasi (mock_api.mjs: mode cek versi dan mode auth, termasuk consent, chat, riwayat, dan Mood Entry)
  android/app/
    build.gradle.kts                                  # flavor dev/prod, minSdk 26
    src/main/AndroidManifest.xml, kotlin/id/my/relaxboss/relaxmate/MainActivity.kt   # izin INTERNET di sini (sejak M022)
    src/debug/AndroidManifest.xml                     # cleartext hanya untuk debug
    src/main/kotlin/.../overlay/                      # direncanakan (TASK-M033), belum ada
```

Aturan: satu fitur satu folder; tiap fitur berisi `data/` (repository), `state/` (provider), `ui/`. Widget tidak memanggil `dio` langsung, hanya lewat repository dan `ApiClient`. Folder fitur yang belum dikerjakan berisi `.gitkeep`. Folder aset audio, crisis, dan texts baru didaftarkan di `pubspec.yaml` pada task yang mengisinya.

**Sesi dan pengalihan layar (TASK-M022) `[Verified]` terhadap kode.** `AuthController` (Riverpod `Notifier`) memegang `AuthState`: `AuthRestoring` (membaca token tersimpan dan memeriksanya lewat `GET /me`), `AuthUnauthenticated`, `AuthAuthenticated(user)`, dan `AuthSessionCheckFailed` (token ada tetapi pemeriksaan gagal bukan 401: offline, timeout, galat server; token tidak dihapus). Router memanggil `authRedirect(state, lokasi)` setiap keadaan berubah: pemeriksaan sesi hanya `/memuat`; sesi belum bisa diperiksa hanya `/sesi`; tamu hanya `/masuk`, `/daftar`, `/lupa-sandi`; sudah masuk tetapi email belum terverifikasi hanya `/cek-email`; terverifikasi tidak boleh di layar tamu atau peralihan (dialihkan ke `/`). Saat server menolak token (401), `ApiClient` menghapus token lalu `SessionExpiredSignal.fire()`; `AuthController` mendengarkan dan menjadi `AuthUnauthenticated`. Dengan sinyal itu `core/` tidak mengimpor `features/`. Keluar memanggil API-M003 lalu menghapus token; bila panggilan gagal (mis. offline) token di perangkat tetap dihapus.

**Gerbang consent (TASK-M023) `[Verified: uji manual founder 2026-11-07]`.** `ConsentController` (Riverpod `Notifier`) memegang `ConsentGateState`: `ConsentChecking`, `ConsentRequired(prompt)`, `ConsentComplete`, `ConsentCheckFailed(error)`. Ia memeriksa `GET /consent` (API-M008, teks dan status dalam satu panggilan) begitu ada pengguna **terverifikasi**, dan memeriksa ulang hanya bila email pengguna berganti (`select` pada `AuthController`), jadi consent akun lain tidak terbawa. Widget `ConsentGate` membungkus layar yang memakai fitur AI (sekarang `ChatScreen` di `app_router.dart`): memuat = `SplashView`, kurang = `ConsentScreen`, gagal = `ConsentErrorScreen`, lengkap = layar aslinya. Gerbang ini tidak memakai `authRedirect` karena consent bukan keadaan sesi dan latihan serta kontak bantuan harus tetap bisa dibuka tanpa consent (RULE-M034). `submit` menyimpan hanya yang kurang, berurutan: API-M009 (consent AI) lalu API-M010 (pilihan pelatihan); kemajuan sebagian dicatat walau langkah berikutnya gagal. Teks consent tidak pernah disalin di klien; teks kosong dari server dianggap balasan rusak (persetujuan tanpa teks tidak diminta).

**Crisis Response (TASK-M025) `[Verified: uji manual founder 2026-11-07]`.** Fitur `features/crisis`: `data/` (`CrisisContact` dengan `telUri`, `CrisisContactSet`, `CrisisContactsRepository`), `state/` (`CrisisContactsController`, `AsyncNotifier` yang memuat dari cache atau aset lebih dulu, lalu menyegarkan lewat API-M011 hanya bila sudah masuk dan terverifikasi; galat API diabaikan tanpa percobaan ulang, RULE-M044; kontak `dummy` disaring di flavor `prod`, RULE-M048), `ui/` (`CrisisBanner`, `CrisisCallButton`, `CrisisContactCard`, `CrisisContactsList`, `CrisisContactsScreen`). Rute `/kontak-bantuan` dikecualikan dari `authRedirect` di semua status dan berada di luar `ConsentGate`. Layar "Perbarui aplikasi" berada di luar router, jadi memuat `CrisisContactsList` inline. Chat membaca `has_crisis` (per Percakapan) dan `is_crisis` (per pesan); banner tampil selama `hasCrisis` dan tidak dapat ditutup. Teks krisis di gelembung berasal dari server (statis), bukan keluaran AI.

**Chat harian (TASK-M024) `[Verified: uji manual founder 2026-11-07]`.** `ChatController` (Riverpod `Notifier.autoDispose`, dibuang saat layar ditutup) memegang `ChatState`: `ChatLoading`, `ChatLoadFailed(error)`, `ChatReady` (`conversationId`, `messages`, `limits`, `unanswered`, `sending`, `error`). `load()` memanggil API-M012; `send()` dan `retry()` memanggil API-M013 (`{content}` atau `{retry: true}`). Pesan yang dikirim tampil langsung sebagai pesan tertunda (`ChatMessage.pending`, id -1) dengan penanda "sedang menulis". Penanganan galat `send`: **ditolak sebelum tersimpan** (422, 429, offline, 403 selain consent) menghapus gelembung tertunda, menampilkan alasan dari server, dan mengembalikan teks ke kolom isian (`SendOutcome.rejected`); **mungkin tersimpan** (timeout, 5xx termasuk 503 `ai_unavailable`, tidak dikenal) memuat ulang hari ini dari server (`_resync`) agar tampilan sama dengan server, lalu menampilkan galat dengan "Coba lagi" bila `unanswered` (`SendOutcome.kept`); bila sinkronisasi gagal, pesan tertunda tetap tampil dengan "Coba lagi". 409 `conversation_closed` memuat ulang hari ini (Percakapan baru) dan mengembalikan teks. 409 `nothing_to_retry` memuat ulang. 429 `daily_limit` mengosongkan sisa kuota dan menonaktifkan input dengan penjelasan. 403 `consent_required` memanggil `ref.invalidate(consentControllerProvider)` sehingga `ConsentGate` menampilkan layar consent. Tidak ada percobaan ulang otomatis (RULE-M044). Panjang input dibatasi `limits.message_max_chars` dari server; sisa kuota tampil sebagai teks. `is_crisis` dan `suggestion` belum dibaca (TASK-M025 dan M026); sampai itu selesai Crisis Response tampil sebagai gelembung biasa tanpa banner.

**Saran tindakan (TASK-M026) `[Verified: uji manual founder 2026-11-07]`.** Server mengirim `suggestion` (`type`, `priority`, `dismissible`) pada balasan RelaxMate; `intent` tidak dikirim. `ChatSuggestion` membaca tiga jenis dari enum `SuggestionType` backend (`escalate_crisis`, `recommend_professional`, `recommend_support`); jenis lain diabaikan. `destinationsFor(kind)` memetakan jenis ke tujuan: `escalate_crisis` -> kontak bantuan (rute `/kontak-bantuan`) dan Konsultasi; `recommend_professional` -> Konsultasi (halaman web `/konsultasi` lewat `WebLauncher`); `recommend_support` -> latihan napas dan grounding (belum tersedia, `isAvailable` false sampai TASK-M029, jadi tanpa chip). `visibleSuggestionIds` mengikuti web (FR-029): prioritas 1 selalu tampil, saran lain hanya pada balasan RelaxMate terakhir, minus yang ditutup pengguna (disimpan di memori layar chat). Tombol tutup tidak ada pada saran krisis.

**Cek Rasa (TASK-M028) `[Verified: kode, logika murni dan mock API dijalankan; UI belum diuji]`.** Fitur `features/checkin`. `MoodLevel` (enum 1..5 dengan label yang sama dengan web), `MoodRepository.record` memanggil API-M018 (hanya `mood`). `CheckinController` (Riverpod `Notifier.autoDispose`, dipegang `ChatScreen` lewat `ref.listen`) memegang `CheckinState` (`skipped`, `submitting`, `notice`). `submit(level)` **mengirim pesan chat dulu** lewat `ChatController.send` (teks template "Hari ini aku merasa: sedih"), **baru** mencatat Mood Entry bila pesan diterima atau tersimpan (`SendOutcome.accepted` atau `kept`); pesan ditolak berarti tidak ada Mood Entry dan kartu muncul lagi (belum ada pesan), sehingga tidak ada catatan ganda. Mood Entry yang gagal (jaringan, 5xx, batas harian `mood_limit_reached`) tidak diulang otomatis (RULE-M044); pesan tetap sah dan `notice` ditampilkan satu kali sebagai `SnackBar`. `ChatWelcome` (SCR-M08 kosong) menampilkan sambutan dan, bila belum ada pesan hari ini dan batas pesan belum tercapai, `CheckinCard` (SCR-M09) sampai pengguna mengirim atau menekan "Lewati" (hanya memori, tidak disimpan; kembali ditawarkan bila layar chat dibuka ulang dan belum ada pesan). Kartu tidak memblokir kolom ketik. Tidak ada GET Mood Entry di klien: Mood Tracker tetap di web. Blob memakai gambar yang sama dengan web (`assets/images/mood`).

**Riwayat (TASK-M027) `[Verified: kode, logika murni dan mock API dijalankan; UI belum diuji]`.** Fitur `features/history`, hanya baca (FR-M005). `HistoryRepository` memanggil API-M015 (`days`, kursor `?cursor=`) dan API-M016 (`messages`, kursor); balasan yang bentuknya tidak sesuai kontrak (satu baris atau pesan rusak) ditolak seluruhnya menjadi galat umum. `HistoryController` (`Notifier.autoDispose`) memegang `HistoryState` (`HistoryLoading`, `HistoryLoadFailed(error)`, `HistoryReady(days, nextCursor, loadingMore, moreError)`); `ConversationController` (`Notifier.autoDispose.family`, satu instance per id Percakapan) memegang `ConversationState` dengan pola sama. Keduanya dibuang saat layar ditutup, jadi isi riwayat tidak tertinggal di memori (RULE-M031, ADR-M07) dan selalu diambil segar dari server; tanpa internet riwayat tidak tampil. Halaman berikutnya dimuat hanya atas aksi pengguna lewat tombol (tanpa percobaan ulang otomatis, RULE-M044); gagal memuat halaman berikutnya menyimpan `moreError` tanpa menghapus yang sudah tampil, dan id yang sudah ada tidak digandakan. `buildHistoryTimeline` menyisipkan penanda tanggal dari `day` server (hari percakapan 04.00 WIB; klien tidak menghitung "hari", RULE-M033) di depan baris berurutan dengan `day` sama tanpa mengubah urutan server; `formatDayKey` mengubah `2026-11-06` menjadi "6 November 2026" (bentuk lain dikembalikan apa adanya) dan `timeOfLabel` mengambil jam dari `label` server. Rute `/riwayat` (SCR-M14) dan `/riwayat/:id` (SCR-M15, rute anak) dibungkus `ConsentGate` di `app_router.dart` dan terbuka dari ikon Riwayat di AppBar chat; keduanya tidak dikecualikan dari `authRedirect` (tamu dialihkan ke Masuk). 403 `consent_required` memicu `invalidateIfConsentRequired` (`consent/state/consent_required_handler.dart`), yang memeriksa ulang gerbang consent. Percakapan hari ini ikut muncul di daftar bila sudah berisi pesan (perilaku server) dan dibuka hanya baca. Detail memakai `ChatBubble` yang sama dengan chat: tanpa chip saran, tanpa banner krisis, tanpa "Coba lagi"; ikon telepon ke `/kontak-bantuan` ada di AppBar kedua layar.

---

## 5. Kontrak API `/api/v1`

Semua endpoint JSON, HTTPS saja. Format sukses `{ "data": {...} }`, gagal `{ "error": { "code": "...", "message": "..." } }`, `message` berbahasa Indonesia dan aman ditampilkan (sama dengan web). Header: `Authorization: Bearer {token}`, `Accept: application/json`, `X-App-Version`. Tidak ada header atau kolom yang membedakan input suara dari teks (ADR-018 web: tanpa data riset).

| ID | Method dan path | Akses | Fungsi | Kegagalan utama |
|---|---|---|---|---|
| API-M001 | `POST /auth/register` | Tamu, 5/menit per IP (`api-register`) | Buat akun (aturan FR-001 web), kirim email verifikasi, terbitkan token | 422 `validation_failed` (+ `errors` per kolom); 429 `rate_limited` dengan sisa detik |
| API-M002 | `POST /auth/login` | Tamu, 5 gagal/menit per akun+IP (Action) dan 20/menit per IP (`api-guest`) | Terima email+sandi, kembalikan token Sanctum | 401 `invalid_credentials` (pesan umum); 429 `rate_limited` (+ `Retry-After`); 403 `account_inactive` bila akun dinonaktifkan |
| API-M003 | `POST /auth/logout` | Token | Cabut token saat ini; balasan 204 tanpa isi | 401 `unauthenticated` |
| API-M004 | `POST /auth/forgot-password` | Tamu, 20/menit per IP (`api-guest`) | Kirim tautan reset (sama API-004 web); reset diselesaikan di peramban lewat halaman web | Respons 200 selalu sama; 422 hanya untuk format email |
| API-M005 | `POST /auth/resend-verification` | Token, 3/jam | Kirim ulang email verifikasi; bila sudah terverifikasi membalas `email_verified: true` | 429 `rate_limited` dengan pesan sisa menit |
| API-M006 | `GET /me` | Token, `api-user` | `user` (`name`, `email`, `email_verified`; tanpa ID), `consent` (status, lihat bawah), `limits` (`message_max_chars`, `chat_per_day`, `chat_per_minute`), `crisis_contacts_version` `[Verified]` | 401 |
| API-M007 | `GET /config` | Publik, `api-public` | `min_app_version` (bawaan `0.0.0` dari env `MOBILE_MIN_APP_VERSION`), `crisis_contacts_version`, `features.overlay` (boolean, R-M4) `[Verified]`. Klien membaca `min_app_version` sejak TASK-M021 (gagal-terbuka, ADR-M13); dua kolom lain belum dibaca klien | n/a |
| API-M008 | `GET /consent` | Token, `api-user` | `ai.{title,text,version}`, `training.{question,text,version}`, `state`. Sumber teks di server: `config/relaxboss.php` bagian `consent`, sama dengan web (menutup OQ-MA8; RULE-049) `[Verified]` | n/a |
| API-M009 | `POST /relaxmate/consent` | Token + `api.verified`, `api-user` | Catat consent AI versi terbaru (Action sama dengan web, idempoten); tanpa badan permintaan; balasan `{ "data": { "consent": <state> } }` `[Verified]` | 403 `unverified` |
| API-M010 | `POST /account/training-consent` | Token + `api.verified`, `api-user` | Badan `{ "choice": "granted" \| "denied" }` (wajib, tanpa nilai awal); balasan `{ "data": { "consent": <state> } }`; dapat diubah kapan saja `[Verified]` | 403 `unverified`; 422 `validation_failed` (`choice`) |
| API-M011 | `GET /crisis-contacts` | Token, `api-user` | `{ "data": { "version", "contacts": [ { "name", "phone", "url", "note", "dummy" } ] } }`. `version` = 12 karakter pertama SHA-1 dari isi daftar, jadi berubah hanya bila isi berubah (sama dengan `crisis_contacts_version` di `/me` dan `/config`). `phone` dikirim apa adanya (saat ini `119 ext 8`; format `tel:` diputuskan di TASK-M025, OQ-MA9); `url` hanya `https` atau `null`; `dummy` menandai kontak contoh (dasar preflight RULE-M048) `[Verified]` | n/a |
| API-M012 | `GET /relaxmate/today` | Token + `api.verified` + `ai.consent`, `api-user` | Ambil atau buat Percakapan hari ini (bagian 6.1); kembalikan `conversation`, seluruh `messages` hari itu, `unanswered`, `limits` (bentuk di bawah) `[Verified: uji manual lolos]` | 403 `unverified`; 403 `consent_required` |
| API-M013 | `POST /relaxmate/conversations/{id}/messages` | Token + `api.verified` + `ai.consent`, limiter `chat` 5/menit + `api-user`, 20/hari di Action | Kirim pesan `{ "content" }`, atau ulang balasan `{ "retry": true }` (tanpa `content`); logika sama dengan web lewat `SendChatMessage` `[Verified: uji manual lolos]` | 422 `invalid_message`; 429 `daily_limit`, `busy`, `rate_limited`; 409 `nothing_to_retry`; 409 `conversation_closed` (Percakapan bukan hari ini); 503 `ai_unavailable` (pesan pengguna tetap tersimpan); 404 |
| API-M014 | ~~`POST .../messages/{message}/retry`~~ **Tidak dibuat** (OQ-MA6): retry memakai API-M013 dengan `{ "retry": true }` | - | Panggil ulang balasan untuk pesan pengguna terakhir yang belum dijawab; tidak menambah hitungan harian | 409 `nothing_to_retry` |
| API-M015 | `GET /relaxmate/days` | Token + `api.verified` + `ai.consent`, `api-user` | Riwayat: Percakapan yang sudah berisi pesan, terbaru dulu, `history_per_page` (15) per halaman, kursor `?cursor=` `[Verified: uji manual lolos]`. Klien memakainya sejak TASK-M027 (`HistoryRepository.days`) | n/a |
| API-M016 | `GET /relaxmate/conversations/{id}/messages` | Token + `api.verified` + `ai.consent`, milik sendiri | Baca satu percakapan, hanya baca, urut lama ke baru, 30 per halaman, kursor `?cursor=` `[Verified: uji manual lolos]`. Klien memakainya sejak TASK-M027 (`HistoryRepository.messages`) | 404 |
| API-M017 | `DELETE /account` | Token + `api.active`, `api-user`; tanpa `api.verified` (agar yang salah mengetik email tetap bisa menghapus data) | Badan `{ "password" }`. Memakai Action `DeleteUserAccount` yang sama dengan web (batas `delete_account_per_minute`, tolak admin terakhir); semua token pengguna dihapus di dalam transaksi. Sukses 204 tanpa isi `[Verified: uji manual lolos]` | 422 `validation_failed` dengan `errors.password` (sandi salah atau terlalu banyak percobaan) atau `errors.account` (admin terakhir); 401 |
| API-M018 | `POST /mood-entries` | Token + `api.verified`, limiter `api-mood` (`mood_per_minute`, 10/menit) + `api-user`; **tanpa** `ai.consent` (Mood Tracker web juga tidak memintanya) | Buat Mood Entry dari Cek Rasa (FR-M013, OQ-M3). Badan `{ "mood": 1..5 }` (wajib), opsional `arousal_input` (`energized` \| `tired`) dan `note` (maks. `mood_note_max_chars`); klien mobile hanya mengirim `mood`. Memakai Action `CreateMoodEntry` yang sama dengan web (API-011), jadi batas harian `mood_per_day` (5, hari WIB) dan enkripsi `note` ikut. Sukses 201 `{ "data": { "entry": { "id", "mood", "mood_label", "created_at" (ISO UTC) } } }`; catatan tidak dikembalikan `[Verified: kode; uji manual menunggu founder]` | 422 `validation_failed` (+ `errors.mood`); 429 `mood_limit_reached` (batas harian) atau `rate_limited`; 403 `unverified`; 401 |

**Bentuk nyata API-M001 sampai M005 `[Verified]` (TASK-M013).** Semua galat memakai amplop `{ "error": { "code", "message" } }` dengan `message` Bahasa Indonesia; validasi 422 menambah `errors` per kolom.

- Register: isi `name`, `email`, `password`, `terms` (wajib `true`), opsional `major`, `institution_name`. Balasan 201: `{ "data": { "token", "token_type": "Bearer", "expires_at" (ISO-8601 UTC), "user": { "name", "email", "email_verified" }, "email_sent" } }`.
- Login: isi `email`, `password`. Balasan 200 sama dengan register tanpa `email_sent`. Login baru mencabut token lama perangkat yang sama (ADR-M10).
- Logout: 204. Lupa sandi: 200 `{ "data": { "message" } }`. Kirim ulang: 200 `{ "data": { "email_verified", "email_sent" } }`.
- Kode galat umum di seluruh `/api/*`: `unauthenticated` 401, `forbidden` 403, `not_found` 404, `validation_failed` 422, `rate_limited` 429 (+ `Retry-After`), `http_error` untuk galat HTTP lain. Galat 500 memakai penanganan bawaan tanpa jejak tumpukan.

**Bentuk nyata API-M006 sampai M011 `[Verified]` (TASK-M014, repo web commit `9afd27c`).**

- Rute bertoken memakai `auth:sanctum` dan limiter `api-user`. Hanya API-M009 dan API-M010 yang memakai `api.verified` (403 `unverified`, "Verifikasi emailmu dulu, ya. Cek kotak masukmu."); `GET /me`, `/consent`, dan `/crisis-contacts` boleh dibaca akun belum terverifikasi.
- `GET /config` tanpa token: `{ "data": { "min_app_version": "0.0.0", "crisis_contacts_version": "<12 hex>", "features": { "overlay": true } } }`. Bawaan `0.0.0` berarti tidak ada versi yang diblokir sampai env `MOBILE_MIN_APP_VERSION` diisi.
- `<state>` (dipakai `/me`, `/consent`, dan balasan POST consent):
  `{ "ai": { "granted", "accepted_version", "required_version" }, "training": { "choice", "answered", "accepted_version", "required_version" }, "complete" }`. `accepted_version` dan `choice` bernilai `null` bila belum dijawab; `complete` benar bila consent AI dan pilihan pelatihan sudah lengkap pada versi terbaru.
- `GET /consent`: `{ "data": { "ai": { "title", "text", "version" }, "training": { "question", "text", "version" }, "state": <state> } }`. `version` berupa bilangan bulat dari `ai_consent_version` dan `ai_training_consent_version`; naikkan bila teks berubah.
- Galat memakai amplop seragam (ADR-M11); limiter melebihi batas membalas 429 `rate_limited`.
- Sisi klien `[Verified]`: aplikasi baru memanggil `GET /config` dan membaca `min_app_version` saja (`ServerConfig`); bentuk `/config` asli cocok dengan parser klien. `GET /me` dipakai sejak TASK-M022; `GET /consent`, `POST /relaxmate/consent`, dan `POST /account/training-consent` dipakai sejak TASK-M023 (`ConsentRepository`; uji manual lolos 2026-11-07); `/crisis-contacts` dipakai sejak TASK-M025 (`CrisisContactsRepository`).

**Bentuk nyata API-M012, M013, M015, M016 (TASK-M015; kode di repo web; uji manual lolos 2026-11-06).** Format sukses `{ "data": {...} }`. Semua waktu `created_at` berformat ISO-8601 UTC (`2026-11-06T09:30:00Z`, RULE-M033); `time` adalah teks WIB siap tampil dari presenter web.

Objek `message` (sama untuk keempat endpoint):

```
{ "id": 12, "role": "user" | "assistant", "content": "...", "time": "14.30 WIB",
  "is_crisis": false,
  "suggestion": null | { "type": "recommend_support", "priority": 3, "dismissible": true },
  "created_at": "2026-11-06T07:30:00Z" }
```

`suggestion` hanya ada pada pesan `assistant`; `suggestion.type` ada di enum `SuggestionType` server (klien mengabaikan nilai yang tidak dikenal). `intent` tidak dikirim.

- `GET /relaxmate/today`: `{ "conversation": { "id": "<uuid>", "has_crisis": false, "day": "2026-11-06", "created_at" }, "messages": [message...], "unanswered": false, "limits": { "message_max_chars": 2000, "per_day": 20, "remaining_today": 17 } }`. `unanswered` true bila pesan terakhir adalah pesan pengguna tanpa balasan (mis. AI gagal): klien menampilkan "Coba lagi". Memanggilnya membuat Percakapan hari ini bila belum ada (resolver, bagian 6.1).
- `POST /relaxmate/conversations/{id}/messages`: badan `{ "content": "..." }` atau `{ "retry": true }`. Sukses 200: `{ "user_message": message, "assistant_message": message, "has_crisis": false, "remaining_today": 16 }`. Galat memakai amplop seragam; kode: `invalid_message` 422 (pesan kosong atau lebih dari `message_max_chars`; kolom `content` tidak dipakai, hanya `message`), `daily_limit` 429, `busy` 429, `rate_limited` 429 (+ `Retry-After`), `nothing_to_retry` 409, `conversation_closed` 409, `ai_unavailable` 503, `consent_required` 403, `unverified` 403, `not_found` 404 (Percakapan orang lain sama dengan tidak ada). Pada `ai_unavailable` pesan pengguna sudah tersimpan: klien memuat ulang `today` atau memanggil ulang dengan `retry`.
- `GET /relaxmate/days`: `{ "days": [ { "id": "<uuid>", "day": "2026-11-06", "label": "6 November 2026, 14.30 WIB", "total_turns": 8, "has_crisis": false } ], "next_cursor": "..." | null }`. Satu baris per Percakapan; beberapa Percakapan dari web di hari yang sama muncul sebagai beberapa baris dengan `day` sama. `day` memakai jam batas hari percakapan (04.00 WIB).
- `GET /relaxmate/conversations/{id}/messages`: `{ "conversation": { "id", "has_crisis", "label" }, "messages": [message...], "next_cursor": "..." | null }`, urut lama ke baru. Kursor diteruskan apa adanya sebagai `?cursor=`.

Keputusan TASK-M015 (dikonfirmasi founder 2026-11-07, OQ-MA11): POST ke Percakapan yang **bukan hari ini** (jendela 04.00 WIB) ditolak 409 `conversation_closed`, supaya riwayat tetap hanya baca (FR-M005) dan klien yang lupa berganti hari tidak menulis ke hari kemarin. Percakapan dari web di jendela hari yang sama tetap boleh menerima pesan.

**Temuan 2026-11-06 (OQ-MA6):** presenter web hari ini mengembalikan `user_message`, `assistant_message`, `has_crisis`, dan `remaining_today`; pesan berisi `id`, `role`, `content`, `time` (teks "14.30 WIB"), `is_crisis`, dan `suggestion` (`type`, `priority`, `dismissible`); `intent` tidak dikirim ke klien. Kode galat web: `invalid_message`, `busy`, `daily_limit`, `rate_limited`, `ai_unavailable`, `nothing_to_retry`, `consent_required`, `account_inactive`. Bentuk final diputuskan di TASK-M015 (di atas): mengikuti presenter web dan menambah `created_at` ISO UTC (RULE-M033).

Klien memetakan `suggestion.type` dan `intent` ke tujuan di aplikasi (latihan napas, grounding, kontak bantuan, halaman Konsultasi web). Kode intent yang tidak dikenal diabaikan tanpa galat (daftar intent ada di server, ADR-017 web). Balasan ditampilkan sebagai teks biasa. Bentuk data lengkap ada di Schema mobile.

---

## 6. Alur Kunci

### 6.1 Percakapan harian (tanpa perubahan skema)

Skema `conversations` dan `messages` (ENT-007, ENT-008) tidak berubah. Aturan “satu aliran per hari” dihitung oleh `Services\Chat\DailyConversationResolver`:

1. Hitung **kunci hari**: waktu sekarang dikurangi `relaxboss.mobile.day_cutoff_hour` (awal 4) dalam WIB lewat `Support/Wib.php` (RULE-035).
2. Cari percakapan milik pengguna, `status = active`, yang `created_at`-nya jatuh di jendela hari itu (jendela = kunci hari pukul `cutoff` sampai hari berikutnya pukul `cutoff`). Ambil yang terbaru.
3. Bila tidak ada, buat baru di dalam `Cache::lock` per pengguna agar dua perangkat tidak membuat dua percakapan.
4. Percakapan yang dibuat dari web di jendela yang sama ikut dipakai (satu pengguna, satu aliran per hari).

`has_crisis` tetap per percakapan, sehingga banner krisis berlaku sepanjang hari itu dan reset di hari berikutnya. Konteks AI tetap 10 pesan terakhir dan 9.000 karakter (FR-026 web); aplikasi tidak menjanjikan ingatan lintas hari (OQ-M4).

### 6.2 Kirim pesan

Urutan sama dengan bagian 6.2 Architecture web: consent, rate limit, panjang pesan, `Cache::lock` per pengguna, `ChatbotService::handle()` yang menyimpan pesan pengguna, memeriksa `CrisisDetector`, lalu memanggil `ChatCompletionClient` atau mengembalikan Crisis Response statis. Pemeriksaan itu hari ini ada di `ChatMessageController::store()` (TASK-020; `RelaxMateController` hanya halaman); agar tidak digandakan, **diekstrak ke Action `SendChatMessage`** yang dipanggil web dan API (bagian 9).

Bila terputus atau 503, aplikasi menampilkan pesan pengguna dengan tombol “Coba lagi” yang memanggil API-M013 dengan `{ "retry": true }` (tanpa endpoint terpisah, OQ-MA6); pesan tidak dikirim ulang sebagai pesan baru.

### 6.3 Suara

Pipeline input: `tombol ketuk → pengenal bawaan (id_ID) → transkrip → gelembung → hitung mundur 1,5 dtk (dapat dibatalkan) → API-M013`. Audio tidak disimpan dan tidak dikirim; hanya teks. Hasil keyakinan rendah ditahan untuk konfirmasi. Transkrip diperiksa `CrisisDetector` di server seperti teks biasa, jadi `cases.json` diperluas dengan ejaan hasil salah dengar (RULE-047).

Mode percakapan suara adalah mesin keadaan sederhana:

| Keadaan | Berpindah ke | Pemicu |
|---|---|---|
| `idle` | `listening` | Ketuk mikrofon atau kata panggil (aplikasi di depan layar) |
| `listening` | `countdown` | Jeda bicara terdeteksi |
| `countdown` | `sending` / `idle` | Habis / dibatalkan |
| `sending` | `thinking` | Pesan tersimpan |
| `thinking` | `speaking` / `idle` | Balasan tiba (TTS aktif) / galat |
| `speaking` | `listening` / `idle` | Mode percakapan aktif / berhenti |

Interupsi (telepon masuk, fokus audio hilang, aplikasi ke latar belakang) selalu mengembalikan ke `idle` dan melepas mikrofon.

**Klip suara:** `assets/audio/clips/clips.json` memetakan kunci (sapaan, pembuka empatik per intent, panduan napas, penutup, krisis, sistem) ke berkas. Pemilihan klip dilakukan klien dari `intent` dan konteks; tidak ada panggilan API suara saat runtime. Klip hadir di Fase 2; Fase 1 memakai teks dan visual saja. TTS balasan (Fase 3) memakai `flutter_tts`; pesan krisis hanya memakai klip dan teks tetap, tidak dibacakan oleh TTS.

### 6.4 Maskot mengambang (Android)

| Hal | Keputusan |
|---|---|
| Komponen | `OverlayService` (foreground service dengan notifikasi permanen berisi tombol “Nonaktifkan”) dan window `TYPE_APPLICATION_OVERLAY` |
| Izin | `SYSTEM_ALERT_WINDOW` (alur Pengaturan khusus) dan `POST_NOTIFICATIONS`; dijelaskan sebelum diminta; default **mati** |
| Isi overlay | Gelembung maskot yang dapat digeser dan menempel ke tepi; mini-panel berisi sapaan dari teks lokal dan tiga aksi: **Ngobrol** (buka aplikasi), **Bicara** (buka aplikasi di mode suara), **Istirahatkan** (1 jam atau sampai besok) |
| Tidak dilakukan | Tidak merekam di overlay, tidak memanggil API dari overlay, tidak membawa data pengguna, tidak memakai `AccessibilityService`, tidak membaca layar, tidak menampilkan di layar kunci |
| Status | `enabled`, `snoozeUntil`, posisi Y di `shared_preferences` (bukan data sensitif) |
| Setelah reboot | Tidak mulai sendiri; pengguna mengaktifkan lagi dari aplikasi `[Assumption]` (mengurangi izin dan risiko review) |
| Jenis foreground service | Dicek terhadap aturan Android 14+ dan kebijakan Play saat spike (OQ-MA1) |

Karena overlay tidak merekam dan tidak memanggil jaringan, mikrofon hanya pernah aktif di dalam aplikasi yang sedang terbuka.

---

## 7. Autentikasi (Sanctum Personal Access Token)

| Hal | Keputusan |
|---|---|
| Jenis | Token pribadi Sanctum (stateless), tanpa cookie dan tanpa CSRF; web tetap memakai session |
| Penerbitan | API-M001 (register) dan API-M002 (login) lewat `IssueMobileToken`; satu token per perangkat bernama `mobile-android`; kemampuan (`abilities`) `['relaxmate']` `[Assumption]` |
| Masa berlaku | 60 hari: `sanctum.expiration` 86.400 menit (dari config `relaxboss.mobile.token_expiration_days`) dan `expires_at` eksplisit pada token; token dibuat ulang lewat login `[Assumption]` |
| Pencabutan | Logout, hapus akun, atau akun dinonaktifkan admin (middleware `active` menolak dan mencabut). Middleware `api.active` (TASK-M016) menolak token akun nonaktif dengan 403 `account_inactive` dan menghapus semua token pengguna itu pada permintaan berikutnya |
| Middleware | `auth:sanctum` (TASK-M013); `api.verified` (403 `unverified`, sudah ada, TASK-M014 `[Verified]`); `api.active` (TASK-M016 `[Verified: kode]`: 403 `account_inactive`, mencabut semua token; dipasang setelah `auth:sanctum` pada semua rute bertoken kecuali logout dan kirim ulang verifikasi); `EnsureAiConsent` untuk rute AI (sama dengan web) |
| Penyimpanan klien | `flutter_secure_storage` (Keystore); dihapus saat logout, 401, atau hapus akun |
| Batas | Login 5 gagal/menit per akun+IP (Action `LoginUser`) dan 20/menit per IP (`api-guest`); register 5/menit per IP (`api-register`); kirim ulang 3/jam (Action); rute publik lain `api-public` dan rute bertoken `api-user` (angka dari `relaxboss.mobile.public_per_minute` dan `user_per_minute`, TASK-M014 `[Verified]`) |
| Log | Dilarang mencatat token atau isi pesan (RULE-040); hanya kode, ID, rute, dan durasi |

Email verifikasi (OQ-MA2, **ditutup 2026-11-06**): tautan web `verification.verify` mensyaratkan sesi login, padahal pengguna mobile membukanya di peramban HP tanpa sesi. Email yang dipicu lewat `/api/*` memakai rute baru `verification.verify.guest` (`/verifikasi-email/tautan/{id}/{hash}`), bertanda tangan dan tanpa login; email dari alur web tetap memakai rute lama (ADR-M09). Setelah verifikasi, peramban diarahkan ke halaman Masuk web dengan pesan "Emailmu sudah terverifikasi". Pengaturan ulang sandi diselesaikan di halaman web `/reset-sandi/{token}` yang sudah ada.

---

## 8. Penyimpanan di Perangkat dan Privasi

| Data | Lokasi | Catatan |
|---|---|---|
| Token Sanctum | `flutter_secure_storage` | Dihapus saat logout/401 |
| Isi chat, transkrip | **Memori saja** | Tidak ditulis ke disk, cache, atau log; hilang saat aplikasi ditutup |
| Kontak bantuan | `shared_preferences` (kunci `crisis_contacts_v1`) + fallback aset `assets/crisis/crisis_contacts.json` | Tidak sensitif; dibaca dari perangkat lebih dulu, API-M011 hanya menyegarkan bila `version` berbeda |
| Pengaturan (suara, overlay, snooze) | `shared_preferences` | Tidak sensitif |
| Klip suara, latihan | Aset aplikasi | Statis |

Perlindungan lain: layar disamarkan di daftar aplikasi terbaru lewat lapisan privasi pada siklus hidup aplikasi (bukan `FLAG_SECURE`, agar tangkapan layar tetap diizinkan pengguna `[Assumption]`); notifikasi lokal tidak memuat isi; `android:allowBackup="false"` agar token dan data tidak ikut cadangan (diterapkan TASK-M020); `usesCleartextTraffic` tidak ditulis di manifest utama (bawaan `false`) dan hanya `true` di `src/debug` agar emulator bisa memanggil API lokal; tidak ada SDK analitik atau pelaporan crash pihak ketiga. Setelah dipakai, notifikasi dan penyimpanan bersih mengikuti RULE-040 sampai RULE-049.

**Status kode `[Verified]` (commit `8014c38`):** yang sudah berjalan hanya token di `flutter_secure_storage`, `allowBackup=false`, cleartext khusus debug, portrait saja, dan tanpa SDK analitik/crash. `shared_preferences`, lapisan privasi di daftar aplikasi terbaru, kontak bantuan di perangkat, dan notifikasi dikerjakan di task fiturnya (M025, M031 sampai M034).

---

## 9. Perubahan di Backend

| Perubahan | Rincian |
|---|---|
| Paket | `laravel/sanctum` via `php artisan install:api` (membuat `routes/api.php`); alasan dicatat di Architecture web bagian 13 dan ADR-013 direvisi (RULE-060). **Terpasang di TASK-M012**: Sanctum 4.3.3; `install:api` ikut menaikkan 36 paket lain dalam rentang semver (framework v13.34.0 ke v13.40.0) |
| Migration | Satu berkas `personal_access_tokens` dari Sanctum (RULE-031); skema chat tidak berubah |
| Controller | `app/Http/Controllers/Api/V1/*` tipis; validasi lewat FormRequest; keluaran lewat API Resource |
| Action baru | `SendChatMessage` (diekstrak dari `ChatMessageController`, TASK-M010), `DailyConversationResolver` (TASK-M011); **sudah ada:** `IssueMobileToken`, `LoginUser::verify()` (tanpa sesi) dengan `LoginFailedException` (TASK-M013) |
| Konfigurasi | `config/relaxboss.php`, blok `mobile` (`public_per_minute` dan `user_per_minute` bawaan 60; `features.overlay` bawaan `true`): `token_name` (`mobile-android`), `token_abilities`, `token_expiration_days` (60), `guest_per_minute` (20) (TASK-M012); `public_per_minute`, `user_per_minute`, `min_app_version` (bawaan `0.0.0`, env `MOBILE_MIN_APP_VERSION`), `features.overlay` (penanda fitur untuk R-M4) (TASK-M014 `[Verified]`); `day_cutoff_hour` (4) menyusul (TASK-M011). Bagian `consent`: teks dan `ai_consent_version` serta `ai_training_consent_version` (TASK-M014). Batas pesan tetap dari `limits` yang ada (RULE-026) |
| Rate limit | Limiter `api-register` dan `api-guest` (TASK-M012); `api-public` (`GET /config`, per IP) dan `api-user` (`/me`, `/consent`, `/crisis-contacts`, dan dua POST consent, per pengguna) (TASK-M014 `[Verified]`); login per akun+IP dan kirim ulang di Action; chat memakai limiter `chat` yang ada (sudah membalas JSON) (RULE-044) |
| Middleware | `api.verified`: varian API dari `verified`, membalas 403 `unverified` (TASK-M014 `[Verified]`) |
| Format galat | `Support/ApiError` dan `Support/ApiExceptionRenderer` menyeragamkan galat `/api/*` ke `{ "error": { "code", "message" } }` (ADR-M11) |
| Verifikasi email | Rute `verification.verify.guest` dan `GuestEmailVerificationController`; `VerifyEmail::createUrlUsing` memilih rute menurut `request()->is('api/*')` (ADR-M09) |
| CORS | `config/cors.php` tanpa `paths`: header `Access-Control-Allow-Origin` tidak dikirim (ADR-M12) |
| Policy | Percakapan dan pesan lewat relasi pemilik (RULE-033); tidak ada `find($id)` polos |
| Admin | Monitoring percakapan tetap tanpa identitas (RULE-042); tidak ada kolom platform atau perangkat |
| Dokumen web | Doc Sync: Architecture web (route API, ADR-013, bagian 13), Schema web (tabel token), `progress.md` web |

Refaktor `SendChatMessage` menyentuh jalur produksi web, jadi dikerjakan sebagai task sendiri dengan uji manual alur chat web sebelum dan sesudah.

---

## 10. Konfigurasi dan Build

| Hal | Ketentuan |
|---|---|
| Flavor | `dev` (API lokal, `10.0.2.2` pada emulator, cleartext hanya di debug, suffix ID `.dev`, nama "RelaxMate Dev") dan `prod` (HTTPS saja; `AppConfig` menolak URL non-HTTPS) |
| URL API | Lewat `--dart-define=API_BASE_URL=...`, bukan di kode |
| Validasi URL | `AppConfig.load` menolak: kosong (`missing_api_base_url`); bukan http/https atau memuat path, query, atau fragmen (`invalid_api_base_url`); `http` pada flavor `prod` (`insecure_api_base_url`). `/api/v1` ditambahkan oleh `AppConfig`, jadi `API_BASE_URL` hanya berisi host. Galat apa pun menampilkan `ConfigErrorApp` tanpa detail `[Verified]` |
| Application ID | `id.my.relaxboss.relaxmate` (`.dev` untuk flavor dev) `[Assumption]`; paket Dart `relaxmate` (impor `package:relaxmate/...`) |
| Gradle (AGP 9) | DSL baru: flavor dikonfigurasi lewat `extensions.configure<ApplicationExtension>` (bukan blok `android { productFlavors }`), dan `buildFeatures { resValues = true }` wajib agar `resValue("string", "app_name", ...)` per flavor dapat dipakai |
| Menjalankan | `flutter run --flavor dev -t lib/main_dev.dart --dart-define=API_BASE_URL=http://10.0.2.2:8000`; server tiruan untuk uji awal: `node tool/mock_api.mjs <mode>` |
| Penandatanganan | Keystore dan `key.properties` di luar repo (setara RULE-013); salinan keystore disimpan terpisah, kehilangannya = tidak bisa memperbarui aplikasi. **Saat ini** build `release` masih ditandatangani dengan kunci debug (templat Gradle, `TODO` bawaan); diganti di TASK-M043 `[Verified]` |
| Rilis | `flutter build appbundle` lokal, R8 aktif, Play App Signing; jalur Play: internal testing, lalu closed testing, lalu produksi (aturan penguji akun baru dicek saat itu, OQ-MA5) |
| Preflight mobile | Daftar periksa sebelum rilis: fallback kontak bantuan bukan dummy, flavor `prod`, `debuggable=false`, tidak ada cleartext, versi consent sesuai server, kasus krisis `cases.json` lulus termasuk transkrip suara |
| Analisis statis | `analysis_options.yaml`: `flutter_lints`, `strict-casts`, `strict-inference`, `strict-raw-types`, dan lint `always_declare_return_types`, `always_use_package_imports`, `avoid_dynamic_calls`, `avoid_print`, `prefer_single_quotes`, `unawaited_futures`; `android/`, `ios/`, dan platform lain dikecualikan `[Verified]` |
| Dokumen dan repo | Dokumen mobile di folder dokumen, di luar repo (RULE-014); repo hanya `README.md` dan aset kode |

---

## 11. Error Handling dan Offline

| Kondisi | Perilaku klien |
|---|---|
| Tanpa internet | Kontak bantuan, latihan napas/grounding, dan klip tetap jalan; chat menampilkan status offline ramah, pesan tidak dikirim |
| 401 | `ApiClient` menghapus token hanya bila permintaan membawa token (login yang salah tidak dianggap sesi berakhir); mengarahkan ke Masuk menunggu TASK-M022; tidak menampilkan isi galat teknis |
| 403 `consent_required` | Tampilkan consent versi terbaru. `ConsentGate` memeriksa saat layar AI dibuka (M023); 403 di tengah sesi (versi dinaikkan saat aplikasi terbuka) ditangani di layar chat, TASK-M024 |
| 429 `daily_limit` / `busy` | Pesan ramah dengan sisa kuota atau tunggu sebentar |
| 503 `ai_unavailable` | Pesan pengguna tetap tampil, tombol “Coba lagi” (API-M013 dengan `retry`); saran statis dan latihan lokal ditawarkan |
| Timeout 20 dtk | `AppConstants.requestTimeout` berlaku **per fase** (connect, send, receive), bukan total. Saat ini `error_mapper` memetakannya ke `ApiErrorKind.timeout` dengan pesan `errorTimeout`, bukan ke `ai_unavailable` `[Verified]`; timeout diperlakukan setara `ai_unavailable` di `ChatController` (pesan pengguna tetap tampil + "Coba lagi"; TASK-M024) |
| Galat login | 401 `invalid_credentials` (pesan umum), 403 `account_inactive`, 429 `rate_limited` dengan `Retry-After`; ditampilkan dengan pesan dari server |
| Pemetaan galat klien | `error_mapper` mengubah galat `dio` menjadi `ApiException` (jenis: `offline`, `timeout`, `unauthorized`, `forbidden`, `notFound`, `conflict`, `validation`, `rateLimited`, `server`, `unknown`) dengan pesan dari amplop server atau teks bawaan `AppTexts`; `toString()` tanpa pesan agar aman di log. `ApiException` juga membawa `code`, `statusCode`, `retryAfterSeconds` (header `Retry-After`), dan `fieldErrors` (pesan pertama per kolom, dari `errors`); 409 dipetakan ke `conflict`, 5xx ke `server`, 4xx lain ke `unknown` |
| Konfigurasi tidak valid | `API_BASE_URL` kosong, tidak valid, atau `http` pada flavor `prod` menampilkan `ConfigErrorApp` tanpa detail teknis |
| Versi terlalu lama | `min_app_version` dari API-M007 memunculkan layar "Perbarui aplikasi" (SCR-M20). Pemeriksaan **gagal-terbuka** (ADR-M13): offline, timeout 5 detik, atau galat server tetap mengizinkan aplikasi lanjut. Pemeriksaan dijalankan sekali per pembukaan aplikasi (bukan saat kembali dari latar belakang); `StartupGate` menahan aplikasi dengan `SplashView` selama pemeriksaan (maks. 5 detik). `AppVersion.isOlder` mengabaikan akhiran `+build` dan menghitung bagian non-angka sebagai 0; `min_app_version` kosong berarti tanpa batas `[Verified]` |
| Galat tak terduga | Pesan umum; tidak ada isi pesan, token, atau jejak tumpukan di tampilan atau log |

Setiap layar punya status memuat, kosong, galat, dan sukses (RULE-053).

---

## 12. Anggaran Dependency

| Paket | Alasan satu kalimat | Status |
|---|---|---|
| `flutter_riverpod` | State dan injeksi dependensi yang sederhana | Terpasang (M020), `^3.4.3` |
| `go_router` | Navigasi deklaratif dan deep link | Terpasang (M020), `^18.1.3` |
| `flutter_localizations` (SDK) | Teks komponen Material berbahasa Indonesia | Terpasang (M020) |
| `dio` | Interceptor untuk token, versi, dan pemetaan error | Terpasang (M021), `^5.11.1` |
| `flutter_secure_storage` | Token di Keystore | Terpasang (M021), `^11.2.0` |
| `package_info_plus` | Header `X-App-Version` | Terpasang (M021), `^10.2.2` |
| `url_launcher` | `tel:` untuk kontak bantuan dan buka halaman web atau toko | Terpasang (M021, untuk tombol toko), `^6.3.3` |
| `flutter_lints` (dev) | Aturan lint dasar untuk `flutter analyze` (RULE-M020) | Terpasang (M020), `^6.0.0` |
| `lucide_icons_flutter` | Satu set ikon (RULE-M051; OQ-MA10 diputuskan 2026-11-07) | Terpasang (M024) lewat `flutter pub add lucide_icons_flutter`; hanya `LucideIcons.send` dipakai sejauh ini |
| `shared_preferences` | Cache kontak bantuan dan pengaturan tidak sensitif | Terpasang (M025, ditambahkan ke `pubspec.yaml` di sesi M026), `^2.5.0` |
| `speech_to_text` | Input suara lewat pengenal perangkat | Belum |
| `just_audio` | Memutar klip rekaman | Belum |
| `flutter_tts` | Suara balasan percobaan | Belum |
| `rive` atau `lottie` | Animasi maskot | Belum |
| `permission_handler` | Meminta izin mikrofon, notifikasi, overlay | Belum |
| Plugin overlay atau Kotlin sendiri | Maskot mengambang (OQ-MA1) | Belum |
| `flutter_local_notifications` | Pengingat lokal opsional (Could) | Belum |

Alat pengembangan di luar aplikasi: Node.js untuk `tool/mock_api.mjs` (tanpa dependensi, tidak ikut APK).

**Tidak dibawa:** Firebase/FCM (push server ditunda), SDK analitik dan pelaporan crash pihak ketiga (privasi), library chat UI siap pakai (UI mengikuti Design), `AccessibilityService`.

---

## 13. Architecture Decision Records

| ID | Keputusan | Alasan | Konsekuensi |
|---|---|---|---|
| ADR-M01 | Flutter, Android dulu | Pengalaman founder, satu basis kode untuk iOS nanti | Tidak berbagi kode dengan React web; kontrak API yang sama |
| ADR-M02 | Sanctum token untuk mobile; **merevisi ADR-013 web** | Klien native tanpa cookie; ditunda sampai fase mobile | Satu paket dan satu migration; web tetap session. **Diterapkan di TASK-M012**; pemasangan ikut menaikkan 36 paket lain (semver) |
| ADR-M03 | Satu percakapan per hari lewat `DailyConversationResolver`, tanpa mengubah skema | Obrolan terasa berkelanjutan; banner krisis reset wajar | Ingatan AI tetap 10 pesan; ingatan lintas hari ditunda (OQ-M4) |
| ADR-M04 | Tanpa streaming; indikator “mengetik” | Hosting tanpa proses permanen (ADR-006 web) | Balasan tampil sekaligus, hingga 20 detik |
| ADR-M05 | Klip suara rekaman dibundel + suara perangkat untuk balasan panjang | Biaya dan kuota API suara; konsistensi suara maskot | Penambahan klip butuh rilis aplikasi baru |
| ADR-M06 | Overlay tanpa mikrofon, jaringan, data pengguna, atau AccessibilityService | Keamanan dan review toko | “Bicara” dari overlay membuka aplikasi dulu |
| ADR-M07 | Isi chat tidak disimpan di disk perangkat | Privasi (ADR-005 web) | Riwayat dimuat dari server tiap dibuka; butuh internet |
| ADR-M08 | Transkrip suara dikirim sebagai teks biasa, tanpa penanda suara | ADR-018 web: tanpa data riset | Kasus uji krisis perlu variasi salah dengar |
| ADR-M09 | Email verifikasi yang dipicu API memakai rute bertanda tangan **tanpa login** (`verification.verify.guest`); email dari alur web tidak berubah (menutup OQ-MA2) | Pengguna mobile membuka tautan di peramban HP tanpa sesi; opsi kecil dan tidak menyentuh alur web | Tautan bertanda tangan menjadi bukti verifikasi (berlaku sesuai `auth.verification.expire`); pengguna mendarat di halaman Masuk web |
| ADR-M10 | Satu token per perangkat; login baru mencabut token lama bernama sama (`mobile-android`) | Token tidak menumpuk; logout dan login ulang bersih | Dua HP dengan nama token sama saling mencabut; bila perlu multi-perangkat, nama token dibuat unik |
| ADR-M11 | Galat seragam `{ "error": { "code", "message" } }` di seluruh `/api/*` lewat `ApiExceptionRenderer`; 500 memakai penanganan bawaan | Klien memetakan galat di satu tempat; pesan aman ditampilkan | Rute web tidak tersentuh; kode final: `invalid_credentials`, `account_inactive`, `rate_limited`, `validation_failed`, `unauthenticated` |
| ADR-M12 | CORS dimatikan untuk API | Klien hanya aplikasi native; mengurangi paparan ke peramban pihak lain | Bila suatu hari ada klien peramban, CORS harus dibuka dengan daftar origin eksplisit |
| ADR-M13 | Pemeriksaan versi aplikasi (`min_app_version`) gagal-terbuka dengan batas 5 detik | Kontak bantuan dan latihan harus tetap bisa dipakai offline (RULE-M034) | Aplikasi lama tidak diblokir bila server tidak terjangkau |
| ADR-M14 | Gerbang consent berupa widget pembungkus (`ConsentGate`) dengan `ConsentController` sendiri, bukan cabang `authRedirect` | Consent bukan keadaan sesi; latihan dan kontak bantuan tidak boleh ikut tertahan; `authRedirect` tetap fungsi murni dan kecil | Setiap layar AI baru harus dibungkus `ConsentGate` (atau satu `ShellRoute` bila sudah banyak); riwayat dan detail hari sudah (TASK-M027), Cek Rasa menyusul |

---

## Assumptions

- A-MA1: Android minimum API 26; iOS tidak masuk rilis pertama.
- A-MA2: Satu token per perangkat, masa berlaku 60 hari (diterapkan, TASK-M012 dan M013).
- A-MA3: Jam batas “hari” 04.00 WIB, bisa diubah di config.
- A-MA4: **Terjawab (TASK-M015, kode):** bentuk JSON dan nama endpoint chat final seperti di bagian 5; uji manual lolos 2026-11-06.
- A-MA5: Application ID `id.my.relaxboss.relaxmate`.
- A-MA6: Batas kasar rute tamu 20/menit per IP (`relaxboss.mobile.guest_per_minute`), bisa diubah di config.
- A-MA7: **Terjawab (TASK-M014):** kolom bernama `min_app_version`; klien (`ServerConfig`) sudah memakai nama itu.
- A-MA8: **Terjawab (diperiksa ke repo web, commit `9afd27c`):** `api-guest` = login dan lupa sandi, `api-public` = `GET /config`, `api-user` = rute bertoken ringan (`/me`, `/consent`, `/crisis-contacts`, POST consent); register memakai `api-register`; `resend-verification` hanya `auth:sanctum` (batas 3/jam di Action).

## Open Questions

| ID | Pertanyaan | Dibutuhkan sebelum |
|---|---|---|
| OQ-MA1 | Plugin overlay atau modul Kotlin sendiri; jenis foreground service yang diterima Android 14+ dan Play | Task maskot mengambang (lakukan spike kecil lebih dulu) |
| OQ-MA2 | **Ditutup 2026-11-06:** rute bertanda tangan tanpa login hanya untuk email yang dipicu API (ADR-M09) | - |
| OQ-MA3 | Pengenalan suara: seberapa baik Bahasa Indonesia offline di perangkat target, dan perlu paket bahasa unduhan? | Fase 2 |
| OQ-MA4 | Apakah `SendChatMessage` diekstrak sekarang, atau API membungkus `ChatMessageController` sementara? Temuan: logika terkumpul di `store()` dan retry sudah ada | Task API chat |
| OQ-MA5 | Android minimum final, aturan closed testing Play untuk akun baru, dan kebutuhan Data Safety | Persiapan rilis |
| OQ-MA6 | Bentuk respons dan kode galat API chat: ikuti presenter web (bagian 5) atau bentuk rancangan? Usulan: ikuti web dan tambah `created_at` ISO UTC | TASK-M015 |
| OQ-MA7 | Batas hari kuota (00.00 WIB) vs hari percakapan (04.00 WIB) | TASK-M011 |
| OQ-MA8 | **Ditutup 2026-11-06 (TASK-M014):** teks consent kini di `config/relaxboss.php` bagian `consent`, disajikan `GET /consent`; versi dinaikkan lewat `ai_consent_version` dan `ai_training_consent_version`. | - |
| OQ-MA9 | Format `tel:` untuk `119 ext 8`: sementara `tel:119,8` (jeda koma); uji di perangkat nyata | TASK-M025 |

## Change Log

| Versi | Tanggal | Perubahan |
|---|---|---|
| 0.13 | 2026-11-07 | TASK-M028: API-M018 (`POST /mood-entries`), struktur `features/checkin` dan `ChatWelcome`, aset `images/mood`, paragraf Cek Rasa, limiter `api-mood`. |
| 0.12 | 2026-11-07 | TASK-M027: struktur `features/history` (dan `features/crisis` yang sebelumnya belum tertulis di pohon), paragraf Riwayat, API-M015 dan M016 dipakai klien, ADR-M14 diperbarui, label uji manual M024 sampai M026 diperbarui. |
| 0.11 | 2026-11-07 | TASK-M026: paragraf Saran tindakan, `shared_preferences: ^2.5.0` tertulis di pubspec. |
| 0.10 | 2026-11-07 | TASK-M025: struktur `features/crisis`, aset fallback terdaftar, `shared_preferences` dipakai, rute `/kontak-bantuan`, paragraf Crisis Response, OQ-MA9 sementara `tel:119,8`. |
| 0.9 | 2026-11-07 | TASK-M024: struktur `features/chat`, paragraf Chat harian, timeout setara `ai_unavailable`, OQ-MA11 dikonfirmasi, dependency `lucide_icons_flutter`. |
| 0.8 | 2026-11-07 | Penanda `[Verified]` API-M012 sampai M017 dan gerbang consent diperbarui: uji manual M015, M016, M017, M023 lolos. |
| 0.7 | 2026-11-06 | TASK-M023: struktur `features/consent`, paragraf Gerbang consent, status klien API-M008 sampai M010, penanganan `consent_required`, ADR-M14. |
| 0.6 | 2026-11-06 | TASK-M016: API-M017 bentuk nyata (422 per kolom, 204), middleware `api.active`, token dihapus saat akun dihapus. |
| 0.5 | 2026-11-06 | TASK-M015: bentuk nyata API-M012, M013, M015, M016; API-M014 tidak dibuat (retry lewat M013); kode galat chat termasuk `conversation_closed`; A-MA4 terjawab. |
| 0.4 | 2026-11-06 | TASK-M022: struktur folder `features/auth`, `core/launch`, `session_expired_signal`, `auth_redirect`, `ErrorAlert`; paragraf Sesi dan pengalihan layar; izin `INTERNET` pindah ke manifest utama; `tool/mock_api.mjs` punya mode `auth`. |
| 0.3 | 2026-11-06 | Sinkronisasi ke kode mobile (commit `8014c38`) dan hasil TASK-M014: struktur folder dan versi paket nyata, API-M006 sampai M011 final dan sudah dicocokkan dengan repo web (`9afd27c`, bentuk JSON lengkap), middleware `api.verified`, limiter `api-public`/`api-user`, konfigurasi `mobile.*` dan bagian `consent`, validasi `AppConfig`, perilaku timeout dan cek versi apa adanya, status penerapan privasi, utang penandatanganan rilis; OQ-MA8 ditutup, A-MA7 terjawab, A-MA8 baru; label `[Verified]`. |
| 0.2 | 2026-11-06 | Sinkronisasi setelah TASK-M012, M013, M020, M021: struktur folder nyata, bentuk API-M001 sampai M005 dan kode galat, Sanctum dan perubahan backend, flavor dan Gradle AGP 9, penanganan galat dan cek versi, status dependency, ADR-M09 sampai M13, OQ-MA2 ditutup, OQ-MA6 sampai MA9. |
| 0.1 | 2026-11-05 | Draf awal: stack, container, kontrak API, alur harian/suara/overlay, Sanctum, privasi perangkat, ADR-M01 s.d. M08. |
