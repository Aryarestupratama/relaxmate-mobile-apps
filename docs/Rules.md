# RelaxMate Mobile - Rules (Aturan Proyek)
Version: 0.20 | Status: Draft | Last updated: 2026-11-11
Depends on: PRD-Mobile v0.4, Architecture-Mobile v0.3, Schema-Mobile v0.1, Design-Mobile v0.4, Rules RelaxBoss (web) v1.5 | Owner: Founder (solo developer)

Dokumen ini adalah panduan kerja founder sebagai pengembang tunggal untuk **repo mobile (Flutter)**; bantuan AI boleh dipakai dengan tetap mengikuti seluruh aturan, melakukan verifikasi manual, dan tidak menganggap keluaran otomatis sebagai bukti kebenaran. Untuk pekerjaan di **repo web** (task backend `TASK-M01x`), `Rules.md` web tetap berlaku penuh; aturan di sini hanya menambah. Kata MUST, MUST NOT, SHOULD dipakai secara tegas. Kedalaman: **Lite**. Prinsip: sederhana, fungsi dulu, aman dulu.

---

## 1. Proses

| ID | Aturan |
|---|---|
| RULE-M001 | Sebelum mulai bekerja, baca `progress.md` mobile. Mulai dari task berstatus `Next`. |
| RULE-M002 | Kerjakan satu task pada satu waktu. Kutip dengan ID (misalnya `TASK-M024`). |
| RULE-M003 | Dilarang menambah fitur di luar PRD-Mobile. Ide baru ditulis di `TODO-LATER.md` mobile (di folder dokumen, bukan di repo). |
| RULE-M005 | **Doc Sync:** setiap perubahan perilaku, endpoint, data, atau keputusan memperbarui dokumen terkait dan `progress.md` pada akhir task yang sama, sebelum task ditandai `Done`. |
| RULE-M006 | Bila dokumen ambigu atau bertentangan, catat sebagai Open Question di `progress.md` dan putuskan sebelum melanjutkan; jangan menebak lalu menulisnya seolah fakta. |
| RULE-M007 | **Desain:** token dan komponen di `Design-Mobile` adalah acuan. Tata letak layar yang belum ditulis dibangun sederhana (fungsi dulu) memakai token dan komponen yang ada; jangan berhenti menunggu desain final. |
| RULE-M008 | **Data:** sebelum TASK-M044, hanya data dummy bertanda jelas (akun `example.test`, kontak krisis `dummy`). Build `prod` tidak boleh memuat dummy (RULE-M048). |
| RULE-M009 | **Panduan uji manual** diberikan di obrolan pada setiap task (command dan langkah uji), tidak disimpan sebagai berkas di `docs/`. Berkas panduan uji yang sudah ada dihapus. |

---

## 2. Git dan Dokumen

| ID | Aturan |
|---|---|
| RULE-M010 | Satu branch saja: `main`. Kerja langsung di `main`. |
| RULE-M011 | Alur setiap update: commit, lalu push. Tanpa branch, pull request, CI, atau hook. |
| RULE-M012 | Pesan commit MUST dalam bahasa Inggris, singkat dan jelas (misalnya `add voice input screen`). |
| RULE-M013 | Tidak boleh masuk repo: keystore (`*.jks`, `*.keystore`), `key.properties`, `.env`, `google-services`, kunci apa pun, berkas master audio, ekspor data. Daftar ada di `.gitignore` (termasuk `/audio_master/`, `/exports/`, `*.jsonl`). |
| RULE-M014 | **Dokumen proyek di luar repo.** PRD, Architecture, Schema, Design, Rules, `progress.md`, `TODO-LATER.md` mobile disimpan di folder dokumen dan tidak di-commit. Di repo hanya `README.md` ringkas, kode, aset (`assets/...`), dan folder `tool/` untuk alat bantu pengembangan (A-R4). |

---

## 3. Kode

| ID | Aturan |
|---|---|
| RULE-M020 | Dart mengikuti gaya resmi (`dart format`), `analysis_options.yaml` ketat (`flutter_lints`, `strict-casts`, `strict-inference`, `strict-raw-types`, dan lint `always_declare_return_types`, `always_use_package_imports`, `avoid_dynamic_calls`, `avoid_print`, `prefer_single_quotes`, `unawaited_futures`; `android/` dan platform lain dikecualikan); `flutter analyze` bersih sebelum push (dijalankan manual, bukan gerbang). |
| RULE-M021 | Hindari `dynamic`, `!` (null-bang) tanpa alasan, dan `// ignore:`. `dynamic` hanya boleh sebagai argumen tipe yang dipaksa API pustaka (`LocalizationsDelegate<dynamic>`, `ThemeExtension<dynamic>`, `Response<dynamic>`). Model data bertipe; JSON diparse di satu tempat (lapisan `data/`). |
| RULE-M022 | Widget tipis: tampilan saja. Panggilan jaringan hanya lewat repository; logika lewat provider/controller. Widget tidak memanggil `dio` langsung. |
| RULE-M023 | Semua input pengguna tetap divalidasi di server. Validasi klien hanya untuk kemudahan. |
| RULE-M024 | Satu fitur satu folder (`features/<nama>/{data,state,ui}`); widget bersama di `shared/widgets/`; satu widget publik per berkas; nama berkas `snake_case`, kelas `PascalCase`. |
| RULE-M025 | Identifier berbahasa Inggris, teks untuk pengguna Bahasa Indonesia. Kotlin mengikuti gaya Kotlin standar. |
| RULE-M026 | Konstanta produk (batas pesan, URL, nama preferensi, jam batas) hanya dari `core/config`; nilai dari server (batas, versi) tidak digandakan di klien. URL API hanya lewat `--dart-define`. |
| RULE-M027 | Tidak ada kode mati, `print`, `debugPrint` berisi data pengguna, atau TODO tanpa ID task yang tertinggal saat push. Bentuk TODO: `TODO(TASK-Mxxx)`. |

---

## 4. Arsitektur dan Data

| ID | Aturan |
|---|---|
| RULE-M030 | Aplikasi hanya berbicara ke API `/api/v1` milik sendiri. Dilarang memanggil Groq, ElevenLabs, atau layanan AI/suara lain langsung; dilarang menyimpan API key apa pun di aplikasi. |
| RULE-M031 | Token hanya di `flutter_secure_storage`. Isi chat dan transkrip hanya di memori; dilarang ditulis ke disk, cache, preferensi, atau log. Pengaturan non-sensitif boleh di `shared_preferences`. |
| RULE-M032 | Tidak ada proses permanen di server untuk kebutuhan mobile: tanpa streaming, WebSocket, push server (RULE-034 web). Pengingat memakai notifikasi lokal. |
| RULE-M033 | Waktu dari server ISO-8601 UTC; tampilan dikonversi ke WIB. Aturan "hari" dihitung server, bukan klien. |
| RULE-M034 | Pesan krisis dan kontak bantuan selalu bisa ditampilkan tanpa internet (aset fallback + cache). Respons krisis memakai teks dan klip tetap, tidak dibacakan oleh TTS. |
| RULE-M035 | Tangani 401 dengan menghapus token dan kembali ke masuk; jangan menampilkan galat teknis, jejak tumpukan, atau isi respons. |
| RULE-M036 | Prompt AI tetap milik founder di backend (RULE-036 web). Aplikasi tidak memuat prompt. |

---

## 5. Keamanan dan Privasi

| ID | Aturan |
|---|---|
| RULE-M040 | Dilarang mencatat di log perangkat (`logcat`, konsol, pelaporan): isi pesan, transkrip suara, token, email, sandi. Log hanya kode, ID, rute, dan durasi. Tidak ada SDK analitik atau pelaporan crash pihak ketiga. |
| RULE-M041 | Mikrofon MUST hanya aktif saat aplikasi di depan layar dan atas aksi pengguna; audio tidak disimpan dan tidak dikirim, hanya teks transkripsi. Tidak ada pendengaran di latar belakang. |
| RULE-M042 | Maskot mengambang MUST NOT memakai `AccessibilityService`, membaca layar, merekam, memanggil jaringan, atau membawa data pengguna; default mati; selalu ada cara menonaktifkan (notifikasi dan Pengaturan). Tidak mulai sendiri setelah reboot. |
| RULE-M043 | Secret hanya di berkas lokal yang di-ignore (`key.properties`); dilarang di kode, commit, tangkapan layar, atau pesan error. Salinan keystore disimpan terpisah; kehilangannya berarti tidak bisa memperbarui aplikasi. |
| RULE-M044 | Rate limit dan penanganan 429 ditampilkan ramah; klien tidak mencoba ulang otomatis tanpa batas (maks. satu retry manual oleh pengguna). |
| RULE-M046 | Hasil atau saran apa pun menyertakan disclaimer "bukan layanan medis/diagnosis" dan jalur ke profesional. Maskot tidak mengaku punya perasaan, tidak menggantikan manusia, dan tidak memicu rasa bersalah. |
| RULE-M047 | Setelah mengubah prompt AI atau `keywords.id.php` di web, atau mengubah alur input suara, **periksa manual** `resources/crisis/cases.json` (>= 30 kasus teks + >= 10 kasus transkrip suara) lewat aplikasi: semua kasus positif harus memicu Crisis Response. |
| RULE-M048 | **Pengaman rilis:** build `prod` tidak boleh dirilis bila preflight mobile gagal: kontak krisis kosong atau dummy, flavor bukan `prod`, `debuggable=true`, cleartext aktif, `allowBackup` aktif, versi consent tidak cocok, atau akun/endpoint `dev` masih tertanam. |
| RULE-M049 | Klaim publik (di toko dan aplikasi): hanya yang terkonfirmasi dan benar (kolaborasi, validasi psikolog, jumlah pengguna, enkripsi, ulasan). Karakter, nama, suara, dan frasa MUST orisinal; tidak meniru karakter, aset, atau merek pihak lain. Teks consent dan Privasi menyebut tinjauan admin tanpa identitas, persetujuan pelatihan, dan setiap pihak ketiga yang memproses isi percakapan. |

---

## 6. UI

| ID | Aturan |
|---|---|
| RULE-M050 | Warna, ukuran teks, radius, dan bayangan hanya dari token di `core/theme` (`RbColors`, `RbText`, `RbSpace` sebagai ThemeExtension; `RbRadius`, `RbSize`, `RbShadow`, `RbMotion` sebagai kelas konstanta). Dilarang nilai heksadesimal, `Color(0x...)`, `Colors.*`, dan angka ukuran/jarak lepas di widget; warna transparan diturunkan dari token (`withValues`/`Color.alphaBlend`), bukan angka terpisah. **Nilai token mengikuti kode website (`app.css`)**, bukan tabel di dokumen Design web yang belum sinkron. Widget mengakses token lewat `context.rbColors`, `context.rbText`, dan `context.rbSpace` (`RbThemeContext`). |
| RULE-M051 | Satu set ikon (`[Assumption]` Lucide untuk Flutter) dan satu cara animasi maskot (sejak M030: WebP beranimasi bawaan Flutter, tanpa library; Rive tidak dipakai); menambah library lain dicatat di Architecture-M bagian 12. OQ-MA10 diputuskan 2026-11-07: Lucide (`lucide_icons_flutter`); `Icons` bawaan yang sudah ada dipindahkan saat layarnya disentuh lagi. |
| RULE-M052 | Teks pada permukaan pastel MUST memakai token teks navy; jangan mengandalkan warna saja untuk status atau makna (selalu ada label atau ikon). |
| RULE-M053 | Setiap layar punya status memuat, kosong, galat, sukses, dan offline (Design-M bagian 4). |
| RULE-M054 | Teks UI pendek diambil dari bank teks Design-M yang diwujudkan di `core/texts/app_texts.dart` (`AppTexts`); teks panjang (privasi, ketentuan) dari `assets/texts`; teks baru mengikuti nada yang sama ("kamu", hangat, tidak menggurui). |
| RULE-M055 | Setiap layar: `Semantics` untuk kontrol, target sentuh >= 48dp, teks tetap utuh pada skala 200%, hormati pengurangan gerak (`MediaQuery.disableAnimations`); diperiksa dengan TalkBack saat mengerjakan UI. |

---

## 7. Dependency

| ID | Aturan |
|---|---|
| RULE-M060 | Menambah paket cukup dicatat dengan alasan satu kalimat di Architecture-M bagian 12. Paket di daftar "Tidak dibawa" (Firebase/FCM, SDK analitik atau crash pihak ketiga, library chat UI, `AccessibilityService`) tidak ditambahkan tanpa alasan tercatat. Pilih paket yang dirawat aktif; dependensi memakai batas `^` di `pubspec.yaml` dan versi dikunci di `pubspec.lock`. |

---

## 8. Suara dan Klip

| ID | Aturan |
|---|---|
| RULE-M070 | Klip suara dibuat dari suara maskot yang dirancang sendiri; generate selagi paket ElevenLabs berbayar aktif, dalam satu sesi, dengan voice ID dan pengaturan dicatat; berkas master disimpan di luar repo. Baca syarat resmi ElevenLabs sebelum rilis dan simpan salinannya. |
| RULE-M071 | Tidak ada panggilan API suara berbayar dari aplikasi. Penambahan suara premium via API butuh keputusan OQ-M6 dan telaah privasi. |
| RULE-M072 | Dilarang melatih atau mengkloning model suara dari hasil layanan lain tanpa konfirmasi tertulis bahwa syaratnya mengizinkan. |
| RULE-M073 | Fitur suara baru (STT, TTS, mode percakapan) MUST mengikuti RULE-M041 dan diuji dengan kasus krisis suara (RULE-M047). |

---

## 9. Definition of Done

Sebuah task selesai bila:
1. Perilaku sesuai FR yang dirujuk dan sudah dicoba manual di perangkat atau emulator (alur utama dan kasus gagal yang disebut di Task Board), termasuk mode offline bila relevan.
2. Tidak ada data sensitif di log (RULE-M040) dan `flutter analyze` bersih; `flutter build apk --debug` berhasil bila task menyentuh kode native.
3. Dokumen terkait dan `progress.md` sudah diperbarui (RULE-M005).
4. Sudah di-commit dan di-push ke `main`.

Tidak ada syarat test otomatis, CI, atau staging. Task backend mengikuti Definition of Done web.

---

## 10. Daftar Larangan Cepat

Jangan: menambah fitur di luar PRD, memanggil Groq atau layanan suara langsung dari aplikasi, menyimpan isi chat atau transkrip di disk, mencatat isi pesan atau token di log, mengaktifkan mikrofon di latar belakang, memakai `AccessibilityService` atau membaca layar, memakai warna atau ukuran langsung di widget, memasukkan keystore atau dokumen proyek ke repo, merilis build dengan kontak dummy, meniru karakter pihak lain, menebak saat dokumen ambigu.

---

## Assumptions
- A-R1: Aturan ini berlaku untuk founder sebagai pengembang tunggal; bila ada kontributor lain, berlaku sama.
- A-R2: `dart format` dan `flutter analyze` dijalankan manual di lokal dan tidak menjadi gerbang CI.
- A-R3: Nomor RULE-M mengikuti pola RULE web; nomor yang dilewati (misalnya M004, M045) sengaja tidak dipakai.
- A-R4: Folder `tool/` di repo mobile boleh memuat alat bantu pengembangan (mis. `mock_api.mjs`) yang tidak ikut aplikasi, tanpa dependensi, dan tanpa data pengguna atau rahasia.

- A-R6: Pemeriksaan kode TASK-M022 terhadap aturan (2026-11-06, pencarian teks): lihat catatan hasil M022 di `progress.md`; `flutter analyze` dan `dart format` belum dijalankan (A-R2).
- A-R11: Pemeriksaan kode TASK-M028 terhadap aturan (2026-11-07, pencarian teks): tanpa `print`, `// ignore:`, `Colors.*`/`Color(0x...)`, `dynamic`, null-bang, atau `TODO` di `lib/features/checkin` dan `chat_welcome.dart`; ukuran, jarak, dan warna hanya dari token (ditambah `RbSize.moodBlob`); teks di `AppTexts`; jalur aset di `AppAssets`; panggilan jaringan hanya lewat `MoodRepository` (RULE-M022); tombol blob `Semantics` dengan target >= 48dp (RULE-M055); `dart format` gaya Dart 3.5 bersih; `flutter analyze` bersih (dijalankan founder, 2026-11-07).
- A-R18: Pemeriksaan TASK-M040 (2026-11-11): `tool/privacy_audit.mjs` memeriksa 23 hal secara statis (log, manifest, izin, cleartext, aturan ekstraksi data, SDK terlarang, penulisan berkas, kunci penyimpanan, kolom input, overlay) dan dijalankan sebelum rilis (preflight M043). Alat itu terbukti gagal pada kode sebelum M040 (7 dari 23 gagal) dan lolos sesudahnya. RULE-M040 diperluas dalam praktik: build rilis membisukan log kerangka kerja. Belum dijalankan: `dart format`, `flutter analyze`, build.
- A-R17: Pemeriksaan TASK-M034 (2026-11-10, pencarian teks): `features/overlay` dan `features/startup` tanpa `print`, `// ignore:`, `dynamic`, null-bang, atau `TODO`; manifest tanpa `RECORD_AUDIO`, kamera, atau layanan aksesibilitas; layanan hanya dimulai atas ketukan pengguna saat aplikasi terbuka (saklar Pengaturan atau tombol "Nyalakan" di spanduk). Kotlin belum dikompilasi di sandbox.
- A-R16: Pemeriksaan TASK-M033 (2026-11-10): layanan tidak memakai mikrofon, kamera, jaringan, `AccessibilityService`, atau pembacaan layar; tidak dimulai dari latar belakang (hanya `OverlayChannel.start` atas aksi pengguna); `START_NOT_STICKY`; teks native di `strings.xml`, warna di `colors.xml` (RULE tokens berlaku untuk Dart saja `[Assumption]`). Kotlin belum dikompilasi di sandbox.
- A-R15: Pemeriksaan kode TASK-M032 terhadap aturan (2026-11-10, pencarian teks): `lib/features/overlay` tanpa `print`, `// ignore:`, `dynamic`, null-bang, atau `TODO`; teks dari `AppTexts`; warna dari token; izin diminta hanya setelah penjelasan dan atas aksi pengguna; tidak ada izin latar belakang. Kotlin belum dikompilasi di sandbox. Belum dijalankan: `dart format`, `flutter analyze`, build Android, uji perangkat.
- A-R14: Pemeriksaan kode TASK-M031 terhadap aturan (2026-11-10, pencarian teks): `lib/features/settings` dan berkas yang diubah tanpa `print`, `// ignore:`, `Colors.*`/`Color(0x...)`, null-bang, atau `TODO`; teks hanya dari `AppTexts`; warna dari token; kata sandi tidak disimpan, dicatat, atau dikirim selain ke API-M017 (RULE-M040). Belum dijalankan: `dart format`, `flutter analyze`, uji emulator.
- A-R13: Pemeriksaan kode TASK-M030 terhadap aturan (2026-11-10, pencarian teks): `lib/features/mascot` dan `typing_indicator.dart` tanpa `print`, `// ignore:`, `Colors.*`/`Color(0x...)`, `dynamic`, null-bang, atau `TODO`; teks hanya dari `AppTexts`; ukuran dari `RbSize`; gerak dikurangi dihormati. Belum dijalankan: `dart format`, `flutter analyze`, uji emulator.
- A-R12: Pemeriksaan kode TASK-M029 terhadap aturan (2026-11-07, pencarian teks): `lib/features/exercises` tanpa `print`, `// ignore:`, `Colors.*`/`Color(0x...)`, `dynamic`, null-bang, atau `TODO`; teks hanya dari `AppTexts`, angka produk (ritme napas, pilihan menit) dari `AppConstants`, ukuran dan kurva dari token `RbSize`/`RbMotion` (RULE-M026, M050); lebar baris kode <= 80. Sandbox tanpa Flutter dan Dart (pub.dev diblokir), jadi `dart format`, `flutter analyze`, dan emulator belum dijalankan (A-R2); logika murni (putaran 4/13/21, urutan tahap, langkah grounding) direplikasi di Python.
- A-R10: Pemeriksaan kode TASK-M026 terhadap aturan (2026-11-07, pencarian teks): tanpa `print`, `// ignore:`, `Colors.*`/`Color(0x...)`, `dynamic`, atau null-bang di berkas saran; teks hanya dari `AppTexts`, URL halaman dari `AppConstants` dan `AppConfig.webUri` (RULE-M026), ikon Lucide (RULE-M051); empat `TODO(TASK-M029)` sengaja untuk tujuan latihan yang belum ada. Logika murni diuji di Dart (21 pemeriksaan); `flutter analyze` dan emulator belum dijalankan (A-R2).
- A-R9: Pemeriksaan kode TASK-M025 terhadap aturan (2026-11-07, pencarian teks): tanpa `print`, `// ignore:`, `Colors.*`, `dynamic`, atau null-bang di `lib/features/crisis`; warna dan jarak lewat token; teks di `AppTexts`; tombol memakai `Semantics` dan target minimal 48dp; kontak dummy tidak ada di aset dan disaring di `prod` (RULE-M048); isi chat tidak disimpan (RULE-M031). `flutter analyze` belum dijalankan (sandbox tanpa Flutter).
- A-R8: Pemeriksaan kode TASK-M024 terhadap aturan (2026-11-07, pencarian teks): tanpa `print`, `// ignore:`, `Colors.*`, `dynamic`, atau null-bang di `lib/features/chat`; ukuran dan jarak hanya dari token (ditambah `RbSize.bubbleMaxWidthFactor`); tanpa `LogInterceptor` atau pencatatan isi pesan (RULE-M040); tanpa percobaan ulang otomatis (RULE-M044); `dart format` gaya Dart 3.5 bersih; `flutter analyze` dan uji emulator belum dijalankan (A-R2).
- A-R7: Pemeriksaan kode TASK-M023 terhadap aturan (2026-11-06, pencarian teks): tanpa `print`, `// ignore:`, `Colors.*`/`Color(0x...)`, `dynamic`, atau null-bang di `lib/features/consent`; ukuran dan jarak hanya dari token; `dart format` gaya Dart 3.5 bersih; uji manual M023 lolos 2026-11-07; hasil `flutter analyze` tidak dilaporkan terpisah (A-R2).
- A-R5: Pemeriksaan kode terhadap aturan (commit `8014c38`, 2026-11-06, pencarian teks): tidak ada `print`, `// ignore:`, `Colors.*`/`Color(0x...)` di luar `rb_colors.dart`, atau null-bang di `lib/`; `dynamic` hanya pada tiga argumen tipe di RULE-M021. Pengecualian sementara: dua `TODO` templat tanpa ID di `android/app/build.gradle.kts` dan penandatanganan rilis dengan kunci debug dibereskan di TASK-M043.

## Change Log

| Versi | Tanggal | Perubahan |
|---|---|---|
| 0.20 | 2026-11-11 | A-R18 (pemeriksaan M040). |
| 0.19 | 2026-11-10 | A-R17 (pemeriksaan M034). |
| 0.18 | 2026-11-10 | A-R16 (pemeriksaan M033). |
| 0.17 | 2026-11-10 | A-R15 (pemeriksaan kode M032). |
| 0.16 | 2026-11-10 | A-R14 (pemeriksaan kode M031). |
| 0.15 | 2026-11-10 | RULE-M051 disesuaikan (maskot WebP tanpa library); A-R13 (pemeriksaan kode M030). |
| 0.14 | 2026-11-07 | A-R12: pemeriksaan kode TASK-M029. |
| 0.13 | 2026-11-07 | A-R11 diperbarui: `flutter analyze` M028 bersih. |
| 0.12 | 2026-11-07 | A-R11 (pemeriksaan kode M028). |
| 0.11 | 2026-11-07 | RULE-M009 (panduan uji manual di obrolan, bukan di `docs/`). |
| 0.10 | 2026-11-07 | A-R10 (pemeriksaan kode M026). |
| 0.9 | 2026-11-07 | A-R9 (pemeriksaan kode M025). |
| 0.8 | 2026-11-07 | RULE-M051 diperbarui (OQ-MA10 diputuskan); A-R8 (pemeriksaan kode M024). |
| 0.7 | 2026-11-07 | A-R7 diperbarui setelah uji manual M023 lolos. |
| 0.6 | 2026-11-06 | A-R7 (pemeriksaan kode TASK-M023); token `RbSize.borderThin` dan `RbSize.borderSelected` menggantikan angka tebal garis di widget (RULE-M050). |
| 0.5 | 2026-11-06 | RULE-M051: ikon Material bawaan sementara (OQ-MA10); A-R6 (pemeriksaan kode M022). |
| 0.4 | 2026-11-06 | Sinkronisasi ke kode (commit `8014c38`): lint tambahan di RULE-M020, batas `dynamic` di RULE-M021, `shared/widgets/` di RULE-M024, bentuk `TODO(TASK-Mxxx)` di RULE-M027, akses token lewat `RbThemeContext` di RULE-M050, batas `^` di RULE-M060, isi `.gitignore` di RULE-M013; A-R5. |
| 0.3 | 2026-11-06 | Sinkronisasi nomor versi dokumen; RULE-M014 (folder `tool/`), RULE-M050 (kelas token nyata), RULE-M054 (`AppTexts`); A-R4. |
| 0.2 | 2026-11-05 | RULE-M050: nilai token mengikuti kode website (`app.css`), bukan dokumen Design web. |
| 0.1 | 2026-11-05 | Draf awal: adaptasi Rules web untuk Flutter, privasi perangkat, mikrofon dan overlay, klip suara, pengaman rilis. |
