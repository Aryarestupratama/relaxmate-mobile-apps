# RelaxMate Mobile - Design System dan Spesifikasi Layar
Version: 0.14 | Status: Draft | Last updated: 2026-11-10
Depends on: PRD-Mobile v0.3, Architecture-Mobile v0.3, Design RelaxBoss (web) | Owner: Founder (solo developer)

Label: `[Assumption]` bisa diubah. Kedalaman: **Lite**. Platform: Android (phone) dulu, mode terang. Tata letak layar yang tidak tertulis dibangun sederhana (fungsi dulu) memakai token dan komponen di dokumen ini (RULE-M007).

---

## 1. Prinsip Desain

1. **Hangat dan tenang.** Nada "kamu", warna lembut, gerak pelan; tidak ada elemen yang menekan atau mengejar.
2. **Satu aksi utama per layar.** Chat adalah rumah; fitur lain dijangkau darinya.
3. **Maskot adalah penghubung,** bukan hiasan: ia menyimak, berpikir, berbicara, dan menemani. Karakter orisinal RelaxMate (aset dari web), tidak meniru karakter pihak lain.
4. **Bantuan nyata tidak pernah tersembunyi.** Jalur ke kontak bantuan selalu ada, bekerja tanpa internet, dan menang atas animasi, suara, dan overlay.
5. **Suara sama pentingnya dengan teks.** Setiap hal yang terdengar punya padanan teks; setiap input suara terlihat sebagai teks.
6. **Jujur tentang batas.** Disclaimer "bukan layanan medis", penanda "AI", dan tidak mengaku punya perasaan.
7. **Konsisten dengan web.** Token, font, dan nada sama dengan RelaxBoss web agar terasa satu produk.

---

## 2. Token

**Sumber nilai: kode website, yaitu `resources/css/app.css`.** Tabel token di dokumen Design web belum sinkron dengan kode (keputusan founder 2026-11-05), jadi bukan acuan warna; bila website mengubah token, mobile diperbarui di task yang sama. Di Flutter dibuat sebagai `ThemeExtension` (`RbColors`, `RbText`, `RbSpace`); **dilarang nilai langsung di widget** (RULE-M050). Diterapkan di TASK-M020 `[Verified]`: selain tiga `ThemeExtension` itu ada kelas konstanta `RbRadius`, `RbSize` (target sentuh 48, avatar 40/56/72, ikon 24), `RbShadow`, `RbMotion`, dan `RbTheme.light()`; widget mengaksesnya lewat `context.rbColors`, `context.rbText`, `context.rbSpace`.

### Tema komponen Material (`RbTheme.light()`) `[Verified]`

Mode terang, `useMaterial3`, latar layar `pageBg`. `ColorScheme`: `primary`/`onPrimary` dari token, `secondary` = `softLavender`, `error` = `danger`, `surface` = `card`, `outline` = `inputBorder`, `outlineVariant` = `border`. Komponen bawaan sudah mengikuti token sehingga widget cukup memakai `FilledButton`, `OutlinedButton`, `TextButton`, `TextField`, dan `SnackBar`:

| Komponen | Gaya |
|---|---|
| `FilledButton` | Bentuk pil, minimal 48 x 48, latar `primary`; ditekan `navHover`; nonaktif latar `surfaceAlt` dan teks `textMuted` |
| `OutlinedButton` | Pil, minimal 48 x 48, bingkai `primary` 2dp |
| `TextButton` | Minimal 48 x 48, teks `primary` |
| Kolom isian | Berlatar `card`, radius 8, bingkai `inputBorder`; fokus `primary` 2dp; galat `danger` (2dp saat fokus); isi horizontal 16 dan vertikal 12 |
| `SnackBar` | Mengambang, latar `primary`, teks `onPrimary`, radius 12 |
| `AppBar` | Latar `pageBg`, tanpa bayangan, judul gaya H3 |

### Warna

| Token | Nilai | Pemakaian |
|---|---|---|
| `primary` | `#0A2244` | Tombol utama, ikon utama, fokus, teks utama (`text` = `primary`) |
| `onPrimary` | `#FFFFFF` | Teks di atas `primary` |
| `pageBg` / `card` | `#FFFFFF` | Latar layar dan kartu |
| `textSecondary` | `#42506A` | Teks pendukung (di atas putih/mist) |
| `textMuted` | `#555B72` | Keterangan, placeholder |
| `border` | `#D5DCE8` | Garis dekoratif kartu |
| `inputBorder` | `#76819A` | Batas input dan kontrol |
| `surfaceAlt` | `#EEF2F8` | Gelembung balasan maskot, panel sekunder |
| `softLavender` | `#DED4FF` | Gelembung pesan pengguna, avatar, lencana "AI", kartu hiasan |
| `softSky` / `softMint` / `softPeach` | Alias ke `softLavender` (`#DED4FF`), sama seperti `app.css` saat ini | Kartu hiasan; jangan membuat nilai sendiri sampai website mengubahnya |
| `brandSoft` | `#C3B1FF` | Hanya lencana di atas permukaan gelap dan tint aktif |
| `mood1`..`mood5` | `#A98BFF`, `#9CCBF2`, `#FFB997`, `#ABEAA2`, `#FCE46F` | Skala mood dan blob (ungu, biru, persik, hijau, kuning) |
| `success` | `#047857` | Sukses |
| `warning` | `#B45309` | Peringatan |
| `danger` | `#DC2626` | Galat, aksi merusak |
| `crisisBg` / `crisisText` | `#FEF2F2` / `#991B1B` | Banner Crisis Response |
| `navHover` | `#163A6B` | Keadaan tekan tombol navy |

**Aturan:** teks di atas pastel dan warna mood selalu `primary`/navy; teks putih dilarang di atas pastel (kontras). Warna mood bukan penanda status; galat dan krisis memakai `danger` dan `crisis*`. Warna tidak pernah satu-satunya pembawa makna.

**Latar gradien tenang** (splash, onboarding, Temani saja, latar video promosi): putih di atas yang memudar ke biru muda lalu lavender di bawah (aset `bg-gradient.png`, 4:5). `[Assumption]` nilai ujung: atas `#FCFCFD`, tengah `#B9D0FF`, bawah `#BFADFF`; teks navy di atas bagian terang, kartu putih di atas bagian berwarna. Nilai tersimpan sebagai `gradientTop`, `gradientMid`, `gradientBottom` di `RbColors`; belum dipakai layar mana pun.

### Tipografi

Plus Jakarta Sans (400-800), dibundel sebagai aset (TTF berat 400, 500, 600, 700, 800 di `assets/fonts`, lisensi SIL OFL); tema tidak menetapkan `fontFamilyFallback` (Flutter memakai font sistem untuk glyph yang tidak ada) `[Verified]`. Ukuran dalam `sp` (mengikuti skala teks pengguna).

| Peran | Ukuran | Berat | Tinggi baris |
|---|---|---|---|
| Teks isi / pesan chat | 16 | 500 | 1,5 |
| Teks kecil | 14 | 400 | 1,5 |
| Keterangan | 12 | 400 | 1,4 |
| H3 | 18 | 600 | 1,4 |
| H2 | 22 | 700 | 1,3 |
| H1 | 28 | 800 | 1,2 |
| Tombol | 16 | 700 | 1,2 |

Pemetaan ke `TextTheme` Material: H1 = `headlineMedium`, H2 = `titleLarge`, H3 = `titleMedium`, teks isi = `bodyLarge`, teks kecil = `bodyMedium`, keterangan = `bodySmall`, tombol = `labelLarge` (`RbTheme.light()`).

Teks layar penting (judul sambutan, krisis) tidak lebih kecil dari 16sp.

### Jarak, bentuk, bayangan, gerak

- Jarak (basis 4): 4, 8, 12, 16, 24, 32, 48.
- Radius: 8 (input kecil), 12 (kartu), 20 (gelembung chat), 24 (panel/sheet), pil penuh (chip, tombol utama besar).
- Bayangan: diturunkan dari `primary` (6% kartu, 12% panel/overlay), bukan angka terpisah. Kartu: blur 12, offset (0, 4); panel/overlay: blur 24, offset (0, 8) (`RbShadow.card` dan `RbShadow.panel`) `[Verified]`.
- Gerak: 150 ms ease-out untuk umpan balik; transisi layar 250 ms; maskot bergerak pelan (napas 3-4 dtk). Hormati `MediaQuery.disableAnimations` (matikan gerak non-esensial; maskot menjadi gambar diam).
- Garis tepi kartu pilihan: 1dp, terpilih 2dp (`RbSize.borderThin`, `RbSize.borderSelected`) `[Verified: kode]`.
- Latihan (TASK-M029): cincin panduan napas 240dp (`RbSize.breathingGuide`), lingkaran dalam bergerak antara 0,5 dan 1 kali ukuran itu (`RbSize.breathingMinScale`) dengan kurva `RbMotion.breathCurve` (ease-in-out); lingkaran angka grounding 112dp dengan angka 56sp yang mengecil otomatis bila teks sistem besar (`RbSize.groundingBadge`, `groundingNumber`).
- Target sentuh minimal **48 x 48 dp**; jarak antar target >= 8dp.
- Hanya portrait pada rilis pertama `[Assumption]`.

---

## 3. Komponen

| ID | Komponen | Spesifikasi |
|---|---|---|
| CMP-M01 | `MateAvatar` | Lingkaran 40/56/72dp berisi avatar RelaxMate (aset web) di atas `softLavender`. Dibangun di TASK-M020 (`MateAvatar`, ukuran `small`/`medium`/`large`) |
| CMP-M02 | `ChatBubble` (dibangun di TASK-M024; lebar maks. 80% = `RbSize.bubbleMaxWidthFactor`, waktu WIB kecil di bawah isi, tanpa `MateAvatar` kecil) | Pengguna: rata kanan, `softLavender`; RelaxMate: rata kiri, `surfaceAlt` + `MateAvatar` kecil; radius 20 (sudut dekat pengirim 6); teks isi; lebar maks. 80% layar; teks biasa; `Semantics` "RelaxMate berkata: ..." |
| CMP-M03 | `TypingIndicator` (TASK-M030: tiga titik `textSecondary` 8dp yang naik-turun bergantian (siklus 1,2 dtk; diam bila gerak dikurangi); teks "RelaxMate sedang menulis..." hanya untuk pembaca layar) | Tiga titik navy bergantian di gelembung RelaxMate; teks tersembunyi "RelaxMate sedang menulis" untuk TalkBack; maks. 20 detik |
| CMP-M04 | `CrisisBanner` | Latar `crisisBg`, teks `crisisText`, judul "Kamu tidak sendirian", maksimal 2 tombol telepon (`tel:`) dan tautan "Lihat semua kontak bantuan"; menempel di atas daftar pesan, **tidak dapat ditutup**; tinggi maksimal 40% layar dan isinya bisa digulir (teks 200%) |
| CMP-M05 | `SuggestionChip` | Pil putih berbingkai navy 2dp, label + ikon; di bawah balasan; chip `escalate_crisis` tidak dapat ditutup Dibangun di TASK-M026 (`SuggestionChips`): memakai gaya `OutlinedButton` tema (>= 48dp), ikon Lucide (`phone`, `heartHandshake`), satu chip per tujuan; tombol tutup "Tutup saran" (`x`) hanya bila dapat ditutup; tampil di bawah balasan sesuai aturan balasan terakhir atau prioritas 1; chip Latihan napas dan Grounding menunggu TASK-M029 `[Verified: kode, belum diuji manual]` |
| CMP-M06 | `ChatInputBar` (TASK-M024: tanpa mikrofon, tombol kirim `IconButton.filled` berikon Lucide `send`; kolom tetap bisa diketik saat pesan diproses) | Kolom teks 1-4 baris (`inputBorder`), placeholder, tombol mikrofon (kiri tombol kirim), tombol kirim navy; dinonaktifkan dengan penjelasan saat batas harian tercapai |
| CMP-M07 | `VoiceButton` | Lingkaran 56dp navy dengan ikon mikrofon; keadaan idle, mendengarkan (cincin berdenyut), nonaktif; selalu ada label teks |
| CMP-M08 | `Waveform` | 18 batang navy yang bergerak mengikuti level suara; tidak membawa makna selain "sedang mendengar" (ada label teks) |
| CMP-M09 | `SendCountdown` | Bilah tipis yang menyusut 1,5 dtk + teks "Mengirim dalam 1,5 detik" + tombol "Batal"; setelah kirim: "Terkirim otomatis" |
| CMP-M10 | `MoodBlobRow` | Lima blob 56dp (`RbSize.moodBlob`) dengan label teks di bawah (tidak hanya warna); satu terpilih diberi cincin `primary` 2dp. Dibangun di TASK-M028: gambar blob yang sama dengan web (`assets/images/mood/mood-1..5.webp`, bukan lingkaran warna token), lima kolom sama lebar (`Expanded`), tiap blob `Semantics` tombol berlabel dengan status terpilih, tanpa pilihan awal |
| CMP-M11 | `BreathingGuide` | Lingkaran yang membesar/mengecil mengikuti ritme, instruksi teks besar ("Tarik napas", "Tahan", "Embuskan"), hitung putaran, tombol "Selesai". Dibangun di TASK-M029: `BreathingGuide` hanya lingkaran hiasan (cincin tetap + lingkaran `softLavender` yang membesar 4 dtk, bertahan 4 dtk, mengecil 6 dtk; diam di ukuran tengah bila gerak dikurangi, tanpa `Semantics`); instruksi (live region, `h2`), "Putaran N dari M", dan "Selesai" ada di `BreathingScreen` `[Belum diuji manual]` |
| CMP-M12 | `EmptyState` | Maskot kecil + satu kalimat hangat + satu aksi |
| CMP-M13 | `ErrorAlert` | Kartu `surfaceAlt` dengan ikon `danger`, pesan ramah, tombol "Coba lagi"; tanpa detail teknis; tidak memakai warna krisis agar merah krisis hanya untuk keselamatan |
| CMP-M14 | `ConsentScreen` (sebelumnya `ConsentSheet`) | Layar penuh yang dapat digulir (`AuthScaffold`): judul dan teks dari API-M008, pilihan pelatihan sebagai dua `ConsentChoiceTile` tanpa nilai awal, tombol utama dan "Keluar". Hanya bagian yang masih kurang yang tampil (consent AI dan pelatihan berversi terpisah). Diterapkan sebagai layar penuh lewat `ConsentGate`, bukan bottom sheet: gerbang ini memblokir fitur AI sehingga tidak boleh ditutup `[Verified: kode, TASK-M023]` |
| CMP-M15 | `SettingToggleRow` | Judul, keterangan satu baris, `Switch`; tinggi >= 56dp |
| CMP-M16 | `DaySeparator` | Pil kecil "Hari ini", "Kemarin", atau tanggal WIB |
| CMP-M17 | `OverlayBubble` | Lingkaran 64dp, avatar RelaxMate, bayangan panel, dapat digeser dan menempel ke tepi; melayang ringan |
| CMP-M18 | `OverlayPanel` | Kartu 280dp: avatar + nama, sapaan lokal, tiga aksi (Ngobrol, Bicara, Istirahatkan), tombol tutup |
| CMP-M19 | `Snack` | Snackbar singkat untuk sukses/galat non-kritis; galat validasi tetap di dekat kolom |
| CMP-M21 | `HistoryEntryTile` | Satu baris riwayat (TASK-M027): kartu `card` berbingkai `border` 1dp, radius kartu, tinggi >= 48dp, jam WIB dan "N giliran" (`caption`, `textMuted`), ikon `chevronRight`; seluruh kartu dapat disentuh |
| CMP-M23 | `CheckinCard` | Kartu Cek Rasa (TASK-M028): latar `brandSoft`, radius kartu, judul "Hari ini, kamu yang mana?" (`h3`, header untuk pembaca layar), `MoodBlobRow`, `FilledButton` "Kirim ke RelaxMate" (nonaktif sampai ada pilihan atau saat mengirim) dan `TextButton` "Lewati" |
| CMP-M24 | `ChatWelcome` | Isi SCR-M08 saat belum ada pesan (TASK-M028): kalimat sambutan di tengah dan, bila boleh, `CheckinCard` di bawahnya; dapat digulir agar muat pada layar kecil, teks 200%, dan papan ketik terbuka |
| CMP-M25 | `ExerciseTile` | Pilihan latihan di daftar Latihan (TASK-M029): kartu `card` berbingkai `border` 1dp, ikon Lucide (`wind`, `eye`), judul `h3`, keterangan `small`, ikon `chevronRight`, tinggi >= 48dp, `Semantics` tombol berlabel judul dan keterangan |
| CMP-M26 | `ExerciseDoneView` | Penutup latihan napas dan grounding (TASK-M029): `MateAvatar` besar, judul `h2` (header), kalimat penutup, "Aku di sini kapan pun kamu butuh. Jaga dirimu, ya.", tombol "Selesai" (keluar) dan "Ulangi", lalu `ExerciseDisclaimer`; dapat digulir |
| CMP-M27 | `ExerciseDisclaimer` | Catatan "bukan layanan medis, tidak menggantikan profesional" dan tombol teks "Lihat semua kontak bantuan" (RULE-M046); di daftar Latihan dan akhir tiap latihan (TASK-M029) |
| CMP-M28 | `MascotView` (TASK-M030) | Maskot beranimasi per keadaan (`MascotState`: `idle`, `listening`, `thinking`, `speaking`); WebP transparan 24 fps, tinggi 140dp di sambutan chat (`RbSize.mascotWelcomeHeight`) dan 280dp di Temani saja (`RbSize.mascotCompanionHeight`); pergantian keadaan memudar silang 250 ms dan mengulang animasi dari awal; gerak dikurangi: gambar diam `half`; `Semantics` gambar dengan label keadaan |
| CMP-M22 | `HistoryLoadMore` | Kaki daftar riwayat dan detail (TASK-M027): tombol teks "Muat lebih banyak" / "Muat pesan berikutnya", indikator saat memuat, atau `ErrorAlert` dengan "Coba lagi" |
| CMP-M20 | `ConsentChoiceTile` | Kartu pilihan tunggal setara tombol radio: tinggi >= 48dp, radius kartu, garis `inputBorder` 1dp; terpilih = latar `surfaceAlt`, garis `primary` 2dp, ikon radio terisi (tidak hanya warna). `Semantics`: `inMutuallyExclusiveGroup`, `checked`, label teks pilihan. Dibangun di TASK-M023 `[Verified: kode]` |


---

## 4. Status Standar (semua layar)

| Status | Perilaku |
|---|---|
| Memuat | Skeleton sebentuk konten; tombol menampilkan "Memproses..." dan dinonaktifkan |
| Kosong | `EmptyState` dengan pesan hangat dan satu aksi |
| Galat validasi | Pesan di bawah kolom; fokus ke kolom pertama yang salah; diumumkan ke TalkBack |
| Galat sistem | `ErrorAlert` dengan "Coba lagi"; pesan pengguna yang belum terjawab tetap tampil |
| Sukses | `Snack` singkat atau perubahan status yang jelas |
| Offline | Banner halus "Koneksi terputus"; isian tidak hilang; kontak bantuan, latihan, dan klip tetap bisa dibuka |

### 4.1 Penerapan pada layar yang sudah dibangun

| Layar | Memuat | Kosong | Galat | Sukses | Offline |
|---|---|---|---|---|---|
| SCR-M01 Pembuka dan cek versi (`SplashView`, `StartupGate`) | Maskot besar dan indikator putar berlabel "Memuat..." (pengecualian dari skeleton karena belum ada konten untuk dibentuk) | n/a | Konfigurasi build tidak valid: `ConfigErrorApp` dengan teks "Konfigurasi aplikasi belum lengkap. Hubungi pengembang." Galat pemeriksaan versi tidak ditampilkan (gagal-terbuka) | Lanjut ke aplikasi | Lanjut ke aplikasi; kontak bantuan dan latihan tetap bisa dibuka |
| SCR-M20 Perbarui aplikasi (`UpdateRequiredScreen`) | n/a | n/a | `Snack` "Toko aplikasi belum bisa dibuka. Coba lagi nanti." bila toko gagal dibuka | Tombol membuka halaman aplikasi di toko | Layar tetap tampil; tombol toko dapat gagal dan menampilkan `Snack` yang sama |
| SCR-M08 RelaxMate (`ChatScreen`) | `CircularProgressIndicator` di tengah | Kalimat sambutan di tengah layar (belum ada pesan hari ini) dan kartu Cek Rasa bila batas pesan belum tercapai | Gagal dimuat: `ErrorAlert` dengan "Coba lagi". Gagal kirim: gelembung tertunda dihapus, alasan dari server di `ErrorAlert`, teks dikembalikan ke kolom isian. Balasan gagal (503, timeout): pesan tetap tampil, `ErrorAlert` dengan "Coba lagi" | Gelembung pengguna dan RelaxMate, waktu WIB di bawah isi, "Sisa pesan hari ini: N dari M" di bawah input | Offline: `ErrorAlert` dengan pesan koneksi terputus; teks tidak hilang. Batas harian: input diganti penjelasan "Batas pesan hari ini sudah tercapai...". Tampilan sengaja sederhana sampai desain final; menu bilah atas berisi Riwayat dan Latihan (M029), Pengaturan menyusul (M031) |
| SCR-M04 Masuk (`LoginScreen`) | Tombol "Memproses..." dan dinonaktifkan; kolom hanya-baca | n/a | Kolom wajib/format: pesan di bawah kolom dan fokus ke kolom pertama yang salah. Galat server per kolom (422) tampil di kolomnya; selain itu (401 salah sandi, 403 nonaktif, 429, offline, timeout) `ErrorAlert` di atas tombol | Router memindahkan ke Cek email (belum verifikasi) atau layar utama | Pesan "Koneksi terputus..." lewat `ErrorAlert`; isian tidak hilang |
| SCR-M03 Daftar (`RegisterScreen`) | Sama dengan Masuk | n/a | Sama dengan Masuk; centang Ketentuan wajib (pesan di bawah centang); tautan "Baca Ketentuan" dan "Baca Kebijakan Privasi" membuka halaman web, gagal buka: `Snack` | Pengguna langsung masuk; router memindahkan ke Cek email | Sama dengan Masuk |
| SCR-M05 Lupa kata sandi (`ForgotPasswordScreen`) | Tombol "Memproses..." | n/a | Format email di bawah kolom; galat lain lewat `ErrorAlert` | Formulir diganti catatan sukses (ikon + pesan server yang sama untuk email terdaftar atau tidak) dan tombol "Kembali ke masuk" | Sama dengan Masuk |
| SCR-M06 Cek email (`CheckEmailScreen`) | Tombol yang sedang bekerja "Memproses...", tiga tombol lain nonaktif | n/a | `ErrorAlert` (mis. 429 "terlalu banyak email"); "Saya sudah verifikasi" saat belum terverifikasi: `Snack` "Emailmu belum terverifikasi..." | Kirim ulang: `Snack` "Email verifikasi sudah dikirim ulang...". Terverifikasi: router memindahkan ke layar utama (juga diperiksa diam-diam saat aplikasi kembali ke depan layar) | Galat jaringan lewat `ErrorAlert` |
| SCR-M07 Consent AI dan pelatihan (`ConsentScreen`, `ConsentGate`) | `SplashView` selama status diperiksa (`GET /consent`) | n/a | Belum memilih pelatihan lalu menekan tombol utama: "Pilih salah satu dulu." di bawah pilihan (diumumkan ke TalkBack). Galat server per kolom `choice` tampil di sana; selain itu `ErrorAlert` di atas tombol. Status tidak bisa diperiksa: `ConsentErrorScreen` dengan "Coba lagi" dan "Keluar" | Layar diganti layar utama (`ChatScreen`). Bila hanya sebagian tersimpan (mis. AI tersetujui, pelatihan gagal), layar menampilkan bagian yang tersisa | `ConsentErrorScreen` dengan pesan "Koneksi terputus..."; pilihan yang sudah dipilih tidak hilang |
| SCR-M14 Riwayat (`HistoryScreen`) dan SCR-M15 Detail hari (`ConversationScreen`) (TASK-M027 `[Verified: uji manual founder 2026-11-07]`) | `CircularProgressIndicator` di tengah | SCR-M14: "Belum ada riwayat. Setelah kamu bercerita, hari-harimu akan muncul di sini." | Gagal dimuat: `ErrorAlert` dengan "Coba lagi". Gagal memuat halaman berikutnya: `ErrorAlert` dengan "Coba lagi" di bawah daftar, yang sudah tampil tidak hilang. Detail tidak ditemukan (404): pesan server di `ErrorAlert` | SCR-M14: penanda tanggal ("6 November 2026") di atas baris Percakapan (jam WIB dan "N giliran", tinggi >= 48dp); menyentuh baris membuka SCR-M15. SCR-M15: `ChatBubble` lama ke baru, judul AppBar tanggal dan jam, catatan "Ini riwayat percakapan. Kamu hanya bisa membacanya." di bawah, tanpa kolom isian. "Muat lebih banyak" / "Muat pesan berikutnya" bila masih ada halaman | Riwayat butuh internet (isi tidak disimpan di perangkat, ADR-M07): `ErrorAlert` dengan pesan koneksi terputus |
| Daftar Latihan (`ExercisesScreen`), SCR-M11 Latihan napas (`BreathingScreen`), SCR-M12 Grounding (`GroundingScreen`) (TASK-M029 `[Verified: uji manual founder 2026-11-09]`) | n/a (isi statis dan lokal, tanpa pemuatan) | n/a | n/a (tanpa jaringan, tidak ada galat) | Napas: layar penutup setelah semua putaran. Grounding: layar penutup setelah langkah 5. Keduanya dengan "Selesai", "Ulangi", catatan bukan layanan medis, dan tombol kontak bantuan | Tetap bisa dipakai penuh tanpa internet (perlu sesi masuk) |
| Sesi belum bisa diperiksa (`SessionErrorScreen`, tambahan di luar inventaris) | `SplashView` selama pemeriksaan ulang | n/a | `ErrorAlert` dengan "Coba lagi"; tombol "Keluar" menghapus token di perangkat saja | Kembali ke alur normal | Layar inilah yang tampil saat offline dengan token tersimpan |

Pemeriksaan versi berjalan **sekali per pembukaan aplikasi** (bukan saat kembali dari latar belakang) dan membungkus seluruh router lewat `StartupGate` di `MaterialApp.builder`; selama pemeriksaan (maks. 5 detik) hanya `SplashView` yang tampil. Judul SCR-M20 diberi `Semantics(header: true)` `[Verified]`.

Bantuan (TASK-M025 `[Verified: uji manual founder 2026-11-07]`): semua layar tamu dan sesi (`AuthScaffold`, termasuk consent) memuat tautan "Butuh bantuan sekarang? Lihat kontak bantuan"; SCR-M20 memuat tautan yang sama dan membuka daftar kontak inline (layar di luar router); SCR-M08 memiliki ikon telepon di AppBar, banner krisis saat `has_crisis`, dan tombol "Lihat semua kontak bantuan" saat batas harian tercapai. SCR-M16 `CrisisContactsScreen` (`/kontak-bantuan`): AppBar "Kontak bantuan", kalimat pengantar, kartu kontak (nama, catatan, nomor, tombol "Telepon" dan "Buka situs"), catatan darurat; loading memakai indikator, galat memakai `ErrorAlert`. Kegagalan membuka `tel:` atau situs menampilkan `Snack`. Teks baru ada di `AppTexts` (`crisis*`).

---

## 5. Inventaris Layar

| ID | Layar | Akses | Rujukan |
|---|---|---|---|
| SCR-M01 | Pembuka dan cek versi | Semua | FR-M001, Architecture-M 11 |
| SCR-M02 | Sambutan singkat (1 layar) | Tamu | PRD-M 4 |
| SCR-M03 | Daftar | Tamu | FR-M001 |
| SCR-M04 | Masuk | Tamu | FR-M001 |
| SCR-M05 | Lupa kata sandi | Tamu | API-M004 |
| SCR-M06 | Cek email / verifikasi | Login | API-M005 |
| SCR-M07 | Consent AI dan persetujuan pelatihan | Login | FR-M002 |
| SCR-M08 | **RelaxMate (aliran harian)** | Login + consent | FR-M004..M009 |
| SCR-M09 | Cek Rasa (kartu di sambutan, awal sesi) | Login + consent | FR-M013 |
| SCR-M10 | Mode percakapan suara | Login + consent | FR-M016..M018 (Fase 2) |
| SCR-M11 | Latihan napas | Login | FR-M014 |
| SCR-M12 | Grounding 5-4-3-2-1 | Login | FR-M014 |
| SCR-M13 | Temani saja | Login | FR-M015 |
| SCR-M14 | Riwayat (garis waktu) | Login + consent | FR-M005 |
| SCR-M15 | Detail hari (hanya baca) | Login + consent | FR-M005 |
| SCR-M16 | Kontak bantuan | Semua | FR-M010, M011 |
| SCR-M17 | Pengaturan | Login | FR-M025 |
| SCR-M18 | Maskot mengambang (penjelasan izin dan pengaturan) | Login | FR-M022 |
| SCR-M19 | Hapus akun | Login | FR-M003 |
| SCR-M20 | Perbarui aplikasi | Semua | API-M007 |
| OVL-M01 | Gelembung maskot (overlay) | Android | FR-M022 |
| OVL-M02 | Mini-panel maskot (overlay) | Android | FR-M024 |

---

## 6. Spesifikasi Layar Utama

### SCR-M08 RelaxMate (aliran harian)
- **Bilah atas:** `MateAvatar` + "RelaxMate" + lencana "AI"; menu (Riwayat, Latihan, Kontak bantuan, Pengaturan). Saat ini ikon telepon (kontak bantuan) langsung di AppBar, menu tiga titik berisi Riwayat dan Latihan (TASK-M029; sebelumnya ikon Riwayat tunggal dari TASK-M027), dan tombol Keluar sementara; Pengaturan menyusul (TASK-M031).
- **Isi:** `DaySeparator` ("Hari ini"), daftar pesan (rata kanan untuk pengguna, rata kiri untuk RelaxMate), `SuggestionChip` di bawah balasan sesuai prioritas intent; `CrisisBanner` menempel di atas setelah krisis terdeteksi.
- **Awal sesi harian:** `CheckinCard` (berisi `MoodBlobRow`) di bawah kalimat sambutan, tampil selama belum ada pesan hari ini dan batas pesan belum tercapai; dapat dilewati atau diabaikan (kolom ketik tetap tersedia).
- **Input:** `ChatInputBar` dengan mikrofon (Fase 2); tombol kirim aktif bila ada teks.
- **Perilaku:** gulir otomatis ke pesan terbaru; keyboard tidak menutup input; pesan gagal menampilkan "Coba lagi" di bawah gelembung; saat 503 saran statis dan latihan lokal ditawarkan; batas harian: input nonaktif dengan penjelasan.
- **Aksesibilitas:** pesan baru diumumkan lewat live region (sopan); urutan fokus: bilah atas, banner, pesan, chip, input.

### SCR-M14 / M15 Riwayat dan detail hari
Dibuka dari ikon Riwayat di AppBar chat. **SCR-M14** (`/riwayat`): garis waktu per tanggal, terbaru dulu. Penanda tanggal memakai kunci hari percakapan dari server (hari berganti 04.00 WIB), jadi percakapan pukul 01.30 tampil di bawah tanggal sebelumnya; beberapa Percakapan di hari yang sama muncul di bawah satu tanggal. Penanda tanggal berperan sebagai `DaySeparator` (CMP-M16) tetapi dibangun sebagai widget privat `_DateHeader` bergaya teks kecil tebal (bukan pil, dan belum memakai "Hari ini"/"Kemarin" karena aturan hari ada di server, RULE-M033). Baris (`HistoryEntryTile`, CMP-M21): kartu `card` berbingkai `border` 1dp, radius kartu, jam WIB dan "N giliran", ikon Lucide `chevronRight`; hari krisis tidak ditandai agar tidak menyorot hari yang berat. **SCR-M15** (`/riwayat/:id`): pesan lama ke baru, hanya baca; gelembung krisis tetap memakai warna krisis (bukan satu-satunya penanda). Kaki daftar (`HistoryLoadMore`, CMP-M22): tombol teks, indikator, atau `ErrorAlert`. Aksesibilitas: baris diumumkan "Buka percakapan <tanggal>, <jam>" sebagai tombol; penanda tanggal berupa header semantik; ikon telepon (kontak bantuan) ada di AppBar kedua layar.

### SCR-M09 Cek Rasa
Dibangun (TASK-M028) sebagai kartu `CheckinCard` di dalam sambutan SCR-M08, **bukan sheet dari bawah** (dokumen mengikuti kode): tidak menutup layar, tidak memaksa jawaban, dan kolom ketik tetap bisa dipakai. "Hari ini, kamu yang mana?" + `MoodBlobRow` + tombol "Kirim ke RelaxMate" dan "Lewati". Jawaban dikirim sebagai pesan chat biasa (teks template, mis. "Hari ini aku merasa: sedih") **dan dicatat sebagai Mood Entry** (OQ-M3, API-M018). Bila pesan terkirim tetapi Mood Entry gagal atau melewati batas harian, `SnackBar` singkat memberi tahu (pesan tetap terkirim). Setelah pesan pertama terkirim, kartu hilang dengan sendirinya.

### SCR-M10 Mode percakapan suara (Fase 2)
Layar penuh berlatar gradien tenang: maskot besar (menyimak / berpikir / bicara), `Waveform` dan teks hasil transkripsi besar di bawah, `SendCountdown`, tombol "Berhenti" jelas. Keadaan mengikuti mesin keadaan Architecture-M 6.3. Teks balasan tetap tampil di bawah maskot (padanan teks untuk suara). Krisis: Crisis Response muncul penuh di layar ini (teks tetap + tombol telepon) dan mode berhenti.

### SCR-M11 / M12 Latihan
Napas: `BreathingGuide` dengan pilihan durasi (1, 3, 5 menit); getar halus opsional; Fase 2 menambah panduan suara (klip). Grounding: lima langkah berurutan (lihat 5, sentuh 4, dengar 3, cium 2, cicipi 1), satu langkah per layar, tombol "Lanjut". Keduanya lokal dan offline.

Dibangun di TASK-M029 `[Verified: uji manual founder 2026-11-09]`: daftar `/latihan` (dua `ExerciseTile` + `ExerciseDisclaimer`) dibuka dari menu AppBar chat; chip saran membuka layar latihan langsung. Napas: pilih durasi lewat `ChoiceChip` (bawaan 3 menit), `SwitchListTile` "Getar halus" (bawaan mati), "Mulai"; saat berjalan lingkaran, instruksi, "Putaran N dari M", "Selesai"; setelah semua putaran `ExerciseDoneView`. Ritme 4-4-6 dtk `[Assumption]`. Grounding: "Langkah N dari 5", angka besar, kalimat "Sebutkan N hal ...", "Ambil waktumu. Tidak perlu terburu-buru.", "Lanjut"; setelah langkah 5 `ExerciseDoneView`. Hanya perlu masuk, tanpa `ConsentGate`. Gerak dikurangi: lingkaran diam dan perpindahan langkah tanpa animasi.

### SCR-M13 Temani saja
Layar gradien tenang, maskot napas pelan, satu kalimat ("Aku di sini. Tidak perlu bicara."), tombol "Selesai". Tanpa AI dan tanpa kuota.

Dibangun di TASK-M030 `[Belum diuji manual]` (`CompanionScreen`, rute `/temani`): gradien `gradientTop` ke `gradientMid` ke `gradientBottom` (pertama kali dipakai), `MascotView` `idle` 280dp, kalimat `h2` (header untuk pembaca layar), `FilledButton` "Selesai" yang kembali ke layar sebelumnya (atau chat bila dibuka langsung). Tanpa AppBar agar layar tetap sunyi; tombol kembali sistem juga menutup. Dibuka dari menu tiga titik chat (Riwayat, Latihan, Temani saja). Hanya perlu masuk, tanpa `ConsentGate`. Gerak dikurangi: maskot diam.

### SCR-M18 Maskot mengambang
Penjelasan sederhana sebelum izin: "Maskot bisa muncul kecil di layarmu supaya kamu merasa ditemani. Maskot tidak membaca layarmu dan tidak mendengarkan." Toggle aktif/nonaktif, status izin ("Izin tampil di atas aplikasi lain: aktif/belum"), tombol "Buka pengaturan izin", pilihan istirahat. Default mati.

### OVL-M01 / M02 Overlay
Gelembung 64dp di tepi layar; sentuh membuka mini-panel dengan sapaan dari teks lokal dan tiga aksi: **Ngobrol** (buka aplikasi), **Bicara** (buka aplikasi di mode suara), **Istirahatkan** (1 jam / sampai besok). Tidak tampil di layar kunci; tidak merekam; tidak memuat data pengguna.

---

## 7. Bank Teks (UX Writing)

Nada: hangat, sederhana, tidak menggurui, memakai "kamu". Teks yang sama dengan web (consent, Crisis Response, disclaimer) **diambil dari sumber yang sama lewat API** (API-M008) atau dari Design web, bukan disalin ulang, agar tidak berbeda (RULE-049). Di kode, bank teks UI pendek ada di `core/texts/app_texts.dart` (`AppTexts`); teks baru ditambahkan di sana dan di tabel ini.

| Konteks | Teks |
|---|---|
| Sambutan | "Halo, aku RelaxMate. Teman ceritamu. Aku bukan psikolog atau layanan medis, tapi aku siap mendengarkan." |
| Cek Rasa (TASK-M028) | "Hari ini, kamu yang mana?"; tombol "Kirim ke RelaxMate", "Lewati"; label blob "Sangat sedih", "Sedih", "Biasa", "Senang", "Luar biasa" (sama dengan web); pesan chat "Hari ini aku merasa: <label huruf kecil>"; bila Mood Entry gagal: "Perasaanmu sudah terkirim ke RelaxMate, tetapi belum tercatat di Mood Tracker. Kamu bisa mencatatnya lewat web." (batas harian memakai pesan server) |
| Placeholder input | "Bicara atau ketik..." (target setelah mikrofon Fase 2); sekarang "Ketik pesanmu..." |
| Chat harian (TASK-M024) | Lencana "AI"; tombol "Kirim"; "RelaxMate sedang menulis..."; pembaca layar: "Kamu berkata: ..." dan "RelaxMate berkata: ..."; "Sisa pesan hari ini: N dari M"; "Batas pesan hari ini sudah tercapai. Kita lanjut lagi besok, ya."; pesan galat dari server |
| Riwayat (TASK-M027) | Judul dan tooltip "Riwayat"; kosong: "Belum ada riwayat. Setelah kamu bercerita, hari-harimu akan muncul di sini."; "Muat lebih banyak"; "Muat pesan berikutnya"; "Ini riwayat percakapan. Kamu hanya bisa membacanya."; "N giliran"; pembaca layar: "Buka percakapan <tanggal>, <jam>"; nama bulan di `AppTexts.months` |
| Mengetik | "RelaxMate sedang menulis..." |
| AI tidak tersedia | "RelaxMate sedang tidak bisa membalas. Pesanmu tetap tersimpan. Coba lagi sebentar lagi." Tombol: "Coba lagi" |
| Batas harian | "Kamu sudah mencapai batas percakapan hari ini. Besok kamu bisa lanjut bercerita. Kalau kamu butuh bantuan sekarang, lihat kontak bantuan." |
| Offline | "Koneksi terputus. Pesanmu belum terkirim. Latihan napas dan kontak bantuan tetap bisa dibuka." |
| Suara: mendengarkan | "Mendengarkan..." |
| Suara: hitung mundur | "Mengirim dalam 1,5 detik" ; "Batal" ; "Terkirim otomatis" |
| Suara: kurang jelas | "Aku kurang menangkap itu. Coba ulangi, ya?" |
| Suara: izin mikrofon | "Untuk bicara denganku, izinkan akses mikrofon. Suaramu hanya diubah jadi teks di HP-mu, dan tidak disimpan." |
| Suara: izin ditolak | "Mikrofon belum diizinkan. Kamu tetap bisa mengetik." |
| TTS pertama kali | "Balasan akan dibacakan. Hati-hati, orang di sekitarmu bisa ikut mendengar." |
| Maskot: izin | "Maskot bisa muncul kecil di layarmu supaya kamu merasa ditemani. Maskot tidak membaca layarmu dan tidak mendengarkan." |
| Maskot: notifikasi | "RelaxMate menemanimu" ; tombol "Nonaktifkan" |
| Maskot: istirahat | "Istirahatkan 1 jam" ; "Sampai besok" |
| Maskot: sapaan panel | "Hai! Hari ini rasanya gimana?" |
| Penutup khas | "Aku di sini kapan pun kamu butuh. Jaga dirimu, ya." |
| Pengingat batas karakter | "Aku asisten AI, bukan pengganti orang-orang terdekatmu atau profesional. Kalau terasa berat, bicara dengan mereka juga ya." |
| Latihan napas | "Tarik napas...", "Tahan...", "Embuskan pelan-pelan..." ; "Selesai" |
| Grounding | "Sebutkan 5 hal yang kamu lihat." "Sebutkan 4 hal yang bisa kamu sentuh." "Sebutkan 3 hal yang kamu dengar." "Sebutkan 2 hal yang kamu cium." "Sebutkan 1 hal yang bisa kamu cicipi." ; "Ambil waktumu. Tidak perlu terburu-buru." ; "Lanjut" (TASK-M029; "rasa" diganti "cicipi" agar tidak ambigu dengan sentuh) |
| Latihan (umum) | "Beberapa menit untuk menenangkan diri. Semuanya berjalan di HP-mu, tanpa AI, dan bisa dipakai tanpa internet." ; "Latihan ini membantu menenangkan diri. Ini bukan layanan medis dan tidak menggantikan profesional. Kalau terasa berat, kamu tidak harus menghadapinya sendirian." ; "Aku di sini kapan pun kamu butuh. Jaga dirimu, ya." ; "Selesai", "Ulangi" (TASK-M029; teks lengkap di `AppTexts`) |
| Temani saja | "Aku di sini. Tidak perlu bicara." |
| Perbarui aplikasi | "Versi aplikasi ini sudah terlalu lama. Perbarui dulu supaya semuanya berjalan aman." |
| Hapus akun | Sama dengan web: "Semua datamu akan dihapus permanen dan tidak bisa dikembalikan. Masukkan kata sandi untuk melanjutkan." |
| Galat umum | "Ada yang tidak berjalan semestinya. Coba lagi, ya." |
| Memuat | "Memuat..." (label aksesibilitas indikator putar) |
| Label aksesibilitas maskot | "Maskot RelaxMate" (`AppTexts.mascotLabel`) |
| Penanda flavor `dev` | "Mode pengembangan" (hanya flavor `dev`; `AppTexts.devBadge`) |
| Perbarui aplikasi: tombol | "Perbarui sekarang" ; toko gagal dibuka: "Toko aplikasi belum bisa dibuka. Coba lagi nanti." |
| Galat jaringan: offline | "Koneksi terputus. Periksa internetmu, lalu coba lagi." |
| Galat jaringan: terlalu lama | "Permintaan terlalu lama. Coba lagi sebentar lagi, ya." |
| Sesi berakhir | "Sesimu sudah berakhir. Silakan masuk lagi." |
| Tidak boleh mengakses | "Kamu belum bisa mengakses ini." |
| Tidak ditemukan | "Yang kamu cari tidak ditemukan." |
| Sudah diproses | "Permintaan ini sudah pernah diproses." |
| Validasi umum | "Periksa lagi isianmu, ya." |
| Terlalu banyak percobaan | "Terlalu banyak percobaan. Coba lagi sebentar lagi." ; dengan sisa waktu: "Terlalu banyak percobaan. Coba lagi dalam N detik." |
| Layanan bermasalah | "Layanan sedang bermasalah. Coba lagi sebentar lagi." |
| Konfigurasi tidak lengkap | "Konfigurasi aplikasi belum lengkap. Hubungi pengembang." (hanya pada build yang salah konfigurasi) |
| Masuk | Judul "Masuk"; keterangan "Lanjutkan ceritamu bersama RelaxMate."; tombol "Masuk"; tautan "Lupa kata sandi?" dan "Belum punya akun? Daftar" |
| Daftar | Judul "Buat akun"; keterangan "Akun ini sama dengan akun RelaxBoss di website."; kolom Nama, Email, Kata sandi; centang "Aku sudah membaca dan menyetujui Ketentuan dan Kebijakan Privasi."; tautan "Baca Ketentuan", "Baca Kebijakan Privasi"; tombol "Daftar"; "Sudah punya akun? Masuk" |
| Lupa kata sandi | Judul "Lupa kata sandi"; keterangan "Masukkan emailmu. Kami kirim tautan untuk mengatur ulang kata sandi."; tombol "Kirim tautan"; "Kembali ke masuk"; pesan sukses dari server (cadangan: "Jika email itu terdaftar, tautan untuk mengatur ulang kata sandi sudah dikirim. Cek kotak masukmu, ya.") |
| Cek email | Judul "Cek emailmu"; "Kami mengirim tautan verifikasi ke {email}. Buka tautannya, lalu kembali ke sini."; tombol "Saya sudah verifikasi", "Kirim ulang email", "Keluar"; "Emailmu belum terverifikasi. Cek kotak masuk atau folder spam, ya."; "Email verifikasi sudah dikirim ulang. Cek kotak masukmu, ya." |
| Validasi kolom | "Nama wajib diisi.", "Email wajib diisi.", "Format email belum benar.", "Kata sandi wajib diisi.", "Centang dulu bahwa kamu sudah membaca ketentuan." (sama dengan pesan server) |
| Consent (SCR-M07) | Judul dan isi consent AI, serta pertanyaan dan keterangan pelatihan: **dari server** (API-M008), tidak disalin. Teks klien: tombol "Setuju dan lanjutkan" (consent AI belum disetujui) atau "Simpan pilihan" (hanya pelatihan yang kurang); judul bila hanya pelatihan yang kurang "Satu pilihan untukmu"; pilihan "Boleh" dan "Tidak boleh"; validasi "Pilih salah satu dulu." (sama dengan pesan server); tombol "Keluar" |
| Consent: status tidak bisa diperiksa | Judul "Belum bisa memuat persetujuan"; "Sebelum bercerita, kami perlu memastikan persetujuanmu. Pastikan internetmu aktif, lalu coba lagi."; "Coba lagi", "Keluar" |
| Sesi belum bisa diperiksa | Judul "Belum bisa memeriksa sesimu"; "Kamu masih masuk di perangkat ini. Pastikan internetmu aktif, lalu coba lagi." |
| Umum (tombol) | "Memproses...", "Coba lagi", "Keluar"; label ikon sandi "Tampilkan kata sandi" / "Sembunyikan kata sandi"; "Halaman belum bisa dibuka. Coba lagi nanti." |
| Email terverifikasi (halaman Masuk web) | "Emailmu sudah terverifikasi. Kembali ke aplikasi RelaxMate, atau masuk di sini." |

Kontak bantuan tidak ditulis di bank teks; selalu dari API-M011 atau aset fallback yang sudah diverifikasi (OQ-3).

---

## 8. Aksesibilitas

- Kontras mengikuti token (teks `primary` di atas putih/pastel).
- Semua kontrol punya `Semantics` (label, peran, status); gambar dekoratif dikecualikan.
- Pesan baru dan perubahan status suara diumumkan lewat live region sopan; urutan fokus logis.
- Target sentuh >= 48dp; teks tetap utuh pada skala 200%; tanpa gulir horizontal.
- Setiap suara punya padanan teks; setiap input suara tampak sebagai teks; tombol kirim otomatis dapat dibatalkan.
- Warna bukan satu-satunya pembawa makna (blob mood selalu berlabel).
- Hormati pengurangan gerak; getar opsional.
- Pemeriksaan manual per milestone: TalkBack, skala teks 200%, mode kontras tinggi, perangkat kecil (360dp).

---

## 9. Maskot, Aset, dan Gerak

| Keadaan | Dipakai di | Aset |
|---|---|---|
| Diam / bernapas | Beranda, Temani saja, overlay | `idle` (sprite web) atau `half` |
| Menyimak | Mode suara saat mendengarkan | `listening` `[Assumption: dibuat dari sprite web]` |
| Berpikir | Menunggu balasan | `thinking` (sprite web) |
| Bicara | Balasan terbaca / klip diputar | `speaking` (sprite web) |
| Pelukan virtual | Saat pengguna berat | Animasi singkat tanpa suara `[Assumption]` |

Aset sumber: `relaxmate-avatar.webp`, `relaxmate-half.webp`, dan sprite `idle`/`speaking`/`thinking`/`walk` dari repo web/reel. Format animasi diputuskan di TASK-M030 (2026-11-09): WebP beranimasi transparan per keadaan, dirender dari rig SVG karakter (`tool/mascot/`), 24 fps, 360x491 px; bukan Rive (splash paket gratis) dan bukan sprite web. `idle`, `listening`, `thinking`, `speaking` sudah ada; "pelukan virtual" belum dibuat. Gaya gambar tidak dicampur dalam satu layar (sprite pixel vs ilustrasi mulus) tanpa alasan; pilih satu keluarga per layar. Karakter orisinal RelaxMate: tidak meniru karakter, bentuk, atau suara pihak lain.

Ikon: satu set (`[Assumption]` Lucide untuk Flutter), ukuran 24dp, stroke 2. OQ-MA10 diputuskan 2026-11-07: Lucide (`lucide_icons_flutter`), dipakai pertama kali di `ChatInputBar` (TASK-M024). Layar auth, consent, dan `ErrorAlert` masih memakai `Icons` bawaan Material dan dipindahkan saat UI disentuh lagi.

---

## Assumptions
- A-D1: Mode terang saja, portrait saja untuk rilis pertama.
- A-D2: Nilai warna ujung gradien adalah perkiraan dari gambar latar (sudah tersimpan di `RbColors`); final di Task tema.
- A-D3: Label skala mood mengikuti web (SCR-016); Cek Rasa memakai blob, bukan angka.
- A-D4: Ukuran gelembung overlay 64dp dan panel 280dp dapat disesuaikan setelah spike TASK-M003.
- A-D5: Layar pembuka memakai indikator putar tanpa skeleton karena belum ada konten untuk dibentuk (pengecualian bagian 4).
- A-D6: Layar tamu memakai satu kerangka (`AuthScaffold`: avatar, judul, keterangan, isi; bisa digulir) tanpa AppBar; kembali dari Daftar dan Lupa sandi lewat tombol kembali sistem. Tanpa onboarding terpisah.
- A-D7: Form Daftar tidak menanyakan Jurusan dan Kampus (opsional di server); dapat diisi di web.

## Open Questions

| ID | Pertanyaan | Dibutuhkan sebelum |
|---|---|---|
| OQ-D1 | **Ditutup 2026-11-05:** mobile mengikuti kode website (`app.css`); alias `soft-sky/mint/peach` = lavender. | - |
| OQ-D2 | **Ditutup 2026-11-09 (founder):** format animasi maskot = WebP beranimasi dari rig SVG; keadaan menyimak sudah dibuat. Animasi "pelukan virtual" tetap belum ada (Fase 2). | - |
| OQ-D3 | **Ditutup 2026-11-06:** M022 dan M023 tidak menambah onboarding; setelah verifikasi email pengguna langsung ke layar consent bila belum lengkap. | - |
| OQ-D4 | **Ditutup 2026-11-10 `[Assumption]`:** ejaan "RelaxMate" (seperti di kode dan bank teks); sapaan "Halo, aku RelaxMate. ..."; maskot memanggil pengguna "kamu". Dibuka lagi bila founder memilih "RelaxMates". | - |

## Change Log

| Versi | Tanggal | Perubahan |
|---|---|---|
| 0.14 | 2026-11-10 | TASK-M030: SCR-M13 dibangun, CMP-M28 `MascotView`, CMP-M03 titik beranimasi, bagian 9 (format animasi diputuskan), OQ-D2 dan OQ-D4 ditutup; M029 diverifikasi. |
| 0.13 | 2026-11-07 | TASK-M029: SCR-M11 dan M12 dibangun, CMP-M11 diterapkan, CMP-M25 sampai M27 (`ExerciseTile`, `ExerciseDoneView`, `ExerciseDisclaimer`), token latihan, menu AppBar chat (Riwayat, Latihan), bank teks latihan dan grounding disesuaikan, baris status 4.1. |
| 0.12 | 2026-11-07 | SCR-M14 dan M15 (M027) serta SCR-M09 (M028) terverifikasi uji manual; penanda diperbarui. |
| 0.11 | 2026-11-07 | TASK-M028: SCR-M09 dibangun sebagai kartu (bukan sheet), CMP-M10 `MoodBlobRow` memakai gambar blob web, CMP-M23 `CheckinCard`, CMP-M24 `ChatWelcome`, token `RbSize.moodBlob`, bank teks Cek Rasa. |
| 0.10 | 2026-11-07 | TASK-M027: SCR-M14 dan M15 dibangun (bagian 4.1 dan 6), CMP-M21 `HistoryEntryTile` dan CMP-M22 `HistoryLoadMore`, bank teks riwayat, label uji manual M025 diperbarui. |
| 0.9 | 2026-11-07 | TASK-M026: CMP-M05 `SuggestionChips` dibangun (label tujuan, tanpa teks saran panjang). |
| 0.8 | 2026-11-07 | TASK-M025: CMP-M04 dan SCR-M16 diimplementasikan, tautan bantuan di layar tamu, sesi, consent, SCR-M20 dan SCR-M08, utang bantuan dihapus. |
| 0.7 | 2026-11-07 | TASK-M024: SCR-M08 diganti `ChatScreen` aliran harian, catatan CMP-M02, M03, M06, bank teks chat, keputusan paket ikon Lucide. |
| 0.6 | 2026-11-06 | TASK-M023: SCR-M07 di bagian 4.1, CMP-M14 diterapkan sebagai `ConsentScreen` layar penuh, CMP-M20 `ConsentChoiceTile`, token tebal garis, bank teks consent, OQ-D3 ditutup. |
| 0.5 | 2026-11-06 | TASK-M022: status layar SCR-M03 sampai M06 dan layar sesi di bagian 4.1; bank teks auth; `ErrorAlert` diterapkan; A-D6, A-D7; ikon sementara; OQ-D3 digeser ke M023. |
| 0.4 | 2026-11-06 | Sinkronisasi ke kode (commit `8014c38`): bagian Tema komponen Material, nilai bayangan, pemetaan `TextTheme`, tanpa `fontFamilyFallback` eksplisit, isi `ChatScreen` sementara, cek versi sekali per pembukaan, teks `mascotLabel` dan `devBadge` di bank teks. |
| 0.3 | 2026-11-06 | Sinkronisasi setelah TASK-M020 dan M021: token diwujudkan di kode (`Rb*`), font dibundel, `MateAvatar`, bagian 4.1 (status layar yang sudah dibangun), bank teks galat jaringan dan perbarui aplikasi, A-D5. |
| 0.2 | 2026-11-05 | Keputusan founder: nilai token mengikuti kode website (`app.css`), bukan tabel Design web; alias `soft-*` = lavender; OQ-D1 ditutup. |
| 0.1 | 2026-11-05 | Draf awal: token (dari `app.css` web), komponen CMP-M01..M19, inventaris layar SCR-M01..M20 dan OVL, spesifikasi layar utama, bank teks, aksesibilitas, aset maskot. |
