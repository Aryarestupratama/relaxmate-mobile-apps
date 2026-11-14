# RelaxMate Mobile - PRD
Version: 0.10 | Status: Draft | Last updated: 2026-11-14
Depends on: PRD RelaxBoss v1.8, Architecture v1.74, Rules v1.5 | Owner: Founder (solo developer)

Label klaim: `[Verified]` = ada sumber yang dicek, `[Inference]` = kesimpulan dari konteks, `[Assumption]` = asumsi yang bisa diubah. Kedalaman: **Lite**.

Dokumen ini terpisah dari PRD RelaxBoss (web). Aplikasi mobile masuk daftar Won't di PRD web v1.8 dan ide tunda di `TODO-LATER.md`, jadi PRD ini tidak mengubah ruang lingkup web (RULE-003). Aplikasi To-Do + Pomodoro punya PRD sendiri nanti dan tidak dibahas di sini.

---

## 1. Overview

**Masalah.** Mahasiswa sering butuh teman bicara pada saat yang tidak pas untuk membuka laptop atau mengetik panjang: larut malam, setelah bimbingan, saat lelah. Chatbot berbasis web terasa seperti “tugas” yang harus dibuka, bukan teman yang hadir. `[Inference]`

**Visi.** RelaxMate Mobile adalah pendamping yang **ada di dekat pengguna**: bisa diajak bicara tanpa mengetik, tidak berganti-ganti percakapan seperti tiket, dan (di Android) bisa hadir sebagai maskot kecil di layar bila pengguna menghendakinya.

**Pitch satu kalimat.** Aplikasi pendamping AI untuk mahasiswa dengan maskot orisinal yang hangat, percakapan harian yang berkelanjutan, suara dua arah, dan penanganan krisis yang tidak pernah kalah oleh fitur lain.

**Konteks.** Memakai backend Laravel RelaxBoss yang sama dan akun yang sama. Dibangun oleh satu developer dengan Flutter. Pengalaman terinspirasi dari **sifat** pendamping yang sabar dan hangat (menyimak dulu, bertanya perasaan, tidak menghakimi). Karakter, nama, rupa, suara, dan frasa **orisinal**; tidak meniru karakter, aset, atau merek pihak lain (risiko hak cipta dan penolakan toko, RULE-049). Maskot web yang sudah ada boleh dijadikan titik tolak desain. Nama karakter: RelaxMate; panggilan akrabnya: **“Mates”**.

---

## 2. Goals, Non-goals, Metrik

**Goals**
- G1: Pengguna merasa ditemani lewat satu alur percakapan yang berkelanjutan dalam sehari.
- G2: Pengguna dapat bercerita tanpa mengetik (suara) dan balasan terasa personal.
- G3: Maskot dapat hadir di luar aplikasi (Android), selalu atas pilihan pengguna dan mudah dimatikan.
- G4: Keselamatan lebih dulu: Crisis Response berlaku sama di teks, suara, dan maskot mengambang.
- G5: Aplikasi layak dipamerkan sebagai portofolio dan lolos kebijakan toko.

**Non-goals (rilis ini)**
- Mood Tracker **lengkap** (insight, model Circumplex, catatan teks) tetap di web, begitu juga Asesmen dan Artikel. Mobile hanya punya input mood di Beranda dan grafik ringkas 7 atau 30 hari (FR-M029, FR-M030; keputusan founder 2026-11-13 yang menggantikan non-goal "tanpa grafik mood" sebelumnya). Titik mobile yang menulis Mood Entry adalah kartu mood di Beranda (FR-M013).
- Tidak ada To-Do/Pomodoro (aplikasi dan PRD terpisah).
- Tidak ada streaming balasan, WebSocket, push notification dari server, atau antrean (RULE-034).
- Tidak ada kata panggil yang mendengarkan terus di latar belakang (keputusan founder 2026-11-04: cari aman). Mikrofon tidak aktif di latar belakang, termasuk saat maskot mengambang tampil; pengguna menyentuh maskot dulu, baru bicara.
- Tidak ada kloning suara, pelatihan model, atau suara dari pihak ketiga tanpa telaah privasi.
- Tidak ada diagnosis; bukan layanan medis.
- Tidak ada login Google, pembayaran, atau tab komunitas.

**Metrik** (target `[Assumption]`, sesuaikan setelah ada baseline)

| ID | Metrik | Target |
|---|---|---|
| M-M1 | Aktivasi: akun baru mengirim ≥ 3 pesan pada hari pertama | ≥ 50% |
| M-M2 | Retensi: pengguna aktif di ≥ 3 hari berbeda dalam 7 hari | ≥ 30% |
| M-M3 | Adopsi suara: pengguna aktif memakai input suara ≥ 1 kali dalam 14 hari | ≥ 25% |
| M-M4 | Keselamatan: kasus uji krisis (≥ 30 kasus teks + ≥ 10 kasus transkrip suara dengan salah dengar umum) yang memicu Crisis Response | 100% |
| M-M5 | Stabilitas: sesi bebas crash | ≥ 99% |
| M-M6 | Kecepatan: balasan chat p95 | ≤ 8 detik (batas keras 20 detik, FR-017 web) |

---

## 3. Pengguna dan Platform

| Persona | Konteks | Kebutuhan utama |
|---|---|---|
| Mahasiswa | Dominan HP; sering larut malam atau lelah | Bercerita cepat, ditemani, saran awal, jalur ke bantuan nyata |
| Admin (founder) | Tetap lewat web | Monitoring tanpa identitas (FR-031 web) tetap berlaku untuk percakapan dari mobile |

**Platform.** Flutter. **Android dulu**; iOS menyusul. Maskot mengambang **hanya Android** (iOS tidak mengizinkan tampilan di atas aplikasi lain) `[Verified secara umum, cek ulang saat implementasi]`. Selisih fitur antar platform harus tertulis di toko dan di aplikasi.

---

## 4. Karakter dan Pengalaman

- **Sifat:** hangat, sabar, tenang, sederhana. Menyimak dan memvalidasi dulu, menyarankan belakangan.
- **Cek Rasa (nama sementara):** pembuka sesi berupa pertanyaan “Hari ini, kamu yang mana?” dengan lima blob mood (skala 1–5, berlabel teks), bukan kotak teks kosong.
- **Pelukan virtual:** animasi singkat saat pengguna berat; tidak bersuara dan tidak memaksa.
- **Penutup khas:** frasa pamit yang tetap dan hangat.
- **Batas karakter:** tidak mengaku punya perasaan atau menggantikan manusia; tidak memakai kalimat yang menimbulkan rasa bersalah (“aku sedih kalau kamu pergi”); sesekali mengingatkan lembut bahwa ia asisten AI dan mendorong ke orang terdekat atau profesional saat percakapan berat.
- **Panduan karakter** (kosakata, jeda, hal yang tidak pernah dikatakan) ditulis sebagai dokumen terpisah dan menjadi bahan prompt milik founder (RULE-036).

---

## 5. Scope dan Fase (MoSCoW)

| Fase | Isi | Prioritas |
|---|---|---|
| **1 - MVP** | Akun dan consent, percakapan harian, chat teks, Crisis Response, saran tindakan, Cek Rasa, latihan napas dan grounding lokal (visual + getar opsional), mode “Temani saja”, hapus akun, maskot dalam aplikasi, maskot mengambang Android (default mati, bisa diaktifkan dan dinonaktifkan) | Must |
| **2 - Suara** | Input suara (STT), kirim otomatis, mode percakapan suara, klip suara rekaman bawaan, panduan suara latihan napas | Must (rilis berikutnya) |
| **3 - Suara balasan** | TTS percobaan | Should |
| **Could** | Pengingat lokal, kata panggil saat aplikasi terbuka, rilis iOS | Could |
| **Won't** | Lihat Non-goals | - |

`[Assumption]` urutan fase. Maskot mengambang Android masuk Fase 1 atas keputusan founder karena menjadi nilai jual; Fase 1 menjadi lebih berat, sehingga modul overlay dibangun terpisah dari inti chat (R-M4).

---

## 6. User Stories

| ID | Cerita | Acceptance Criteria |
|---|---|---|
| US-M01 | Sebagai pengguna, saya masuk dengan akun RelaxBoss dan menyetujui consent AI. | **Given** akun terverifikasi **When** pertama kali membuka chat **Then** dialog consent tampil dan chat belum bisa dipakai sebelum disetujui. |
| US-M02 | Sebagai pengguna, saya melanjutkan obrolan hari ini tanpa membuat percakapan baru. | **Given** saya membuka aplikasi hari yang sama **Then** pesan-pesan sebelumnya tampil dalam satu aliran dan saya langsung bisa melanjutkan. |
| US-M03 | Sebagai pengguna, saya mengetik atau berbicara kepada RelaxMate dan mendapat balasan hangat. | **When** mengirim pesan **Then** balasan tampil dengan saran tindakan yang sesuai; bila AI gagal, pesan tidak hilang dan pesan error ramah tampil. |
| US-M04 | Sebagai pengguna yang sedang krisis, saya segera diarahkan ke bantuan nyata. | **Given** pesan (teks atau hasil suara) terindikasi krisis **Then** teks tetap, kontak bantuan, dan tombol telepon langsung tampil dan banner bertahan selama percakapan. |
| US-M05 | Sebagai pengguna yang lelah mengetik, saya cukup ketuk dan bicara. | **When** saya bicara lalu diam sejenak **Then** teks yang dikenali tampil sebagai gelembung dan terkirim otomatis kecuali saya membatalkan. |
| US-M06 | Sebagai pengguna Android, saya mengaktifkan maskot mengambang agar merasa ditemani, dan mematikannya kapan saja. | **When** saya mengaktifkan dan memberi izin **Then** maskot muncul; **When** menonaktifkan atau “istirahatkan” **Then** maskot hilang sampai saya aktifkan lagi. |
| US-M07 | Sebagai pengguna, saya melakukan latihan napas tanpa koneksi internet. | **Given** tanpa internet **When** memilih latihan **Then** panduan visual tampil (getar opsional) tanpa panggilan server. Panduan suara menyusul di Fase 2. |
| US-M08 | Sebagai pengguna, saya menghapus akun dari dalam aplikasi. | **When** konfirmasi sandi **Then** semua data pribadi terhapus (FR-019 web). |

---

## 7. Functional Requirements

**Akun dan consent**

| ID | Requirement | Prioritas |
|---|---|---|
| FR-M001 | Pengguna MUST mendaftar, verifikasi email, login, logout, dan reset sandi dengan aturan yang sama seperti FR-001 s.d. FR-005 web; akun sama dengan web. | Must |
| FR-M002 | Sebelum fitur AI pertama, pengguna MUST menyetujui consent AI dan MUST memilih ya atau tidak untuk persetujuan pelatihan (tanpa nilai awal); dapat diubah di Pengaturan (FR-013 web, RULE-071). Teks consent MUST menyebut setiap pihak ketiga yang memproses isi percakapan, termasuk layanan suara bila dipakai. Teks dan versinya diambil dari server (API-M008) agar sama dengan web; versi consent AI dan persetujuan pelatihan dinaikkan terpisah saat teksnya berubah. | Must |
| FR-M003 | Pengguna MUST dapat menghapus akun dari aplikasi dengan konfirmasi kata sandi; tautan Kebijakan Privasi dan Ketentuan MUST tersedia di aplikasi. | Must |

**Percakapan**

| ID | Requirement | Prioritas |
|---|---|---|
| FR-M004 | Aplikasi MUST menampilkan **satu aliran percakapan per hari**: server mengambil atau membuat Percakapan aktif untuk hari WIB berjalan; pesan sebelum jam batas (`[Assumption]` 04.00 WIB, di `config/relaxboss.php`) masih dihitung hari sebelumnya. Pengguna tidak membuat Percakapan baru secara manual. | Must |
| FR-M005 | Hari-hari sebelumnya MUST dapat dibuka sebagai garis waktu per tanggal (hanya baca). | Must |
| FR-M006 | Batas beban AI MUST mengikuti web: pesan maks. 2.000 karakter, konteks maks. 10 pesan terakhir dan 9.000 karakter, keluaran maks. 800 token; 5 pesan per menit; kuota harian per pengguna (awal 20 pesan, lihat OQ-M5). Kelebihan ditolak dengan pesan ramah dan sisa kuota tampil. | Must |
| FR-M007 | Bila AI gagal atau melewati 20 detik, aplikasi MUST menampilkan pesan error ramah dan tidak menghilangkan pesan pengguna. Tanpa streaming; indikator “sedang mengetik” cukup. | Must |
| FR-M008 | Balasan MUST disertai intent dan saran tindakan (FR-029 web) yang dipetakan ke tujuan di aplikasi (latihan napas, grounding, kontak bantuan). | Must |
| FR-M009 | Pemanggilan Groq MUST hanya lewat backend `ChatCompletionClient` (RULE-030); aplikasi tidak pernah memegang API key. Hanya isi percakapan dan jurusan (bila diisi) yang boleh dikirim ke penyedia AI (RULE-041). | Must |

**Keselamatan**

| ID | Requirement | Prioritas |
|---|---|---|
| FR-M010 | Pesan berisiko krisis MUST memicu Crisis Response (FR-018 web): pesan empatik tetap, kontak bantuan terverifikasi, tombol telepon langsung (`tel:`), ajakan menghubungi orang terdekat atau profesional. Banner bertahan selama Percakapan hari itu. Berlaku sama untuk teks, transkrip suara, mini-panel maskot, dan mode suara. | Must |
| FR-M011 | Kontak bantuan MUST disimpan di perangkat dan tetap tampil tanpa internet. Respons krisis MUST memakai teks tetap (dan klip tetap bila ada), bukan keluaran AI yang dibacakan otomatis. | Must |
| FR-M012 | Semua tampilan MUST memuat disclaimer “bukan layanan medis/diagnosis” dan jalur ke profesional; maskot MUST NOT mengaku punya perasaan, menggantikan manusia, atau memicu rasa bersalah. | Must |

**Cek Rasa dan latihan**

| ID | Requirement | Prioritas |
|---|---|---|
| FR-M013 | Pengguna MUST dapat mencatat mood (skala 1 sampai 5) dari kartu mood di **Beranda** (FR-M029); jawaban dicatat sebagai Mood Entry (ENT-006) lewat API-M018 sehingga tampil di Mood Tracker web (OQ-M3, diputuskan founder 2026-11-07). Satu hari boleh beberapa catatan (batas `limits.mood_per_day`); grafik memakai catatan terakhir tiap hari. Kartu mood **tidak lagi** tampil di chat (keputusan founder 2026-11-13; sebelumnya jawabannya juga dikirim sebagai pesan chat). Tidak membuat tabel baru, tidak memanggil AI. | Must |
| FR-M014 | Aplikasi MUST menyediakan latihan napas dan grounding 5-4-3-2-1 yang berjalan **lokal**, tanpa AI dan tanpa kuota, termasuk saat offline. Fase 1 berupa panduan visual dengan getar opsional; panduan suara menyusul di Fase 2 bersama klip suara (FR-M020). | Must |
| FR-M015 | Mode “Temani saja”: maskot hadir tanpa percakapan (animasi tenang, napas pelan), tanpa panggilan AI. | Should |

**Suara (Fase 2)**

| ID | Requirement | Prioritas |
|---|---|---|
| FR-M016 | Input suara MUST memakai pengenal suara bawaan perangkat dengan tombol ketuk-untuk-bicara; audio MUST NOT disimpan atau dikirim ke server, hanya teks hasil transkripsi. | Must |
| FR-M017 | Setelah jeda bicara, teks MUST tampil sebagai gelembung dan **terkirim otomatis** setelah hitung mundur singkat (`[Assumption]` 1,5 detik) yang dapat dibatalkan; pengguna dapat mengoreksi sesudah terkirim. Hasil dengan keyakinan rendah SHOULD dikonfirmasi lebih dulu. Transkrip MUST melewati `CrisisDetector` seperti pesan teks. | Must |
| FR-M018 | Mode percakapan suara (dengar, kirim, balas, dengar lagi) SHOULD tersedia, dengan tombol berhenti yang jelas dan penghentian otomatis bila diam lama. | Should |
| FR-M019 | Kata panggil “Mates” boleh aktif **hanya saat aplikasi atau sesi maskot sedang di depan layar**, lewat deteksi kata kunci di perangkat. Mikrofon tidak aktif di latar belakang. | Could |
| FR-M020 | Klip suara rekaman bundel (sapaan, pembuka empatik per intent, panduan napas, penutup, sistem, krisis) MUST diputar lokal, dipilih klien dari intent atau mood tanpa panggilan API suara saat runtime. | Must |

**Maskot mengambang (Fase 1, Android) dan suara balasan (Fase 3)**

| ID | Requirement | Prioritas |
|---|---|---|
| FR-M021 | TTS balasan (percobaan, Fase 3) MUST default mati, bisa dihentikan, dan menampilkan peringatan privasi saat pertama diaktifkan (balasan bisa terdengar orang lain). Balasan panjang memakai suara perangkat; suara premium via API hanya setelah OQ-M6 dan telaah privasi. | Should |
| FR-M022 | Maskot mengambang (Android) MUST default **mati**, dapat diaktifkan dan dinonaktifkan dari Pengaturan dan notifikasi, dengan penjelasan izin “tampil di atas aplikasi lain” sebelum diminta. | Must |
| FR-M023 | Maskot mengambang MUST NOT membaca layar, memakai AccessibilityService, atau memantau aplikasi lain; ia hanya gambar yang dapat disentuh. | Must |
| FR-M024 | Sentuh maskot membuka mini-panel (sapaan, tombol bicara, buka aplikasi). Tersedia “istirahatkan” (1 jam atau sampai besok), geser, tempel ke tepi, dan tutup. Tidak tampil di layar kunci. | Must |

**Pengaturan**

| ID | Requirement | Prioritas |
|---|---|---|
| FR-M025 | Pengaturan MUST memuat: suara (input, balasan), maskot mengambang, persetujuan pelatihan, privasi, hapus akun. | Must |
| FR-M026 | Pengingat lokal opsional SHOULD tersedia dengan teks tanpa isi sensitif dan jendela jam terbatas (mengikuti ADR-019 web: tanpa push server). | Could |
| FR-M027 | Chat harian MUST punya dua tampilan yang bisa diganti kapan saja: **maskot** (maskot di tengah atas, balasan terakhir di bawahnya) dan **obrolan** (daftar gelembung). Bawaan maskot; pilihan disimpan di perangkat. Isi, kuota, banner krisis, saran tindakan, dan Cek Rasa identik di kedua tampilan; krisis tidak boleh tertutup animasi maskot. Tanpa suara dan tanpa panggilan AI tambahan. (keputusan founder 2026-11-11) | Should |
| FR-M028 | Aplikasi MUST punya layar **Tentang RelaxBoss** yang menjelaskan bahwa RelaxMate bagian dari RelaxBoss: kisah awal, visi, arti nama, kolaborasi kampus, penegasan bukan diagnosis atau layanan medis dengan jalan ke Kontak bantuan, serta tautan ke situs dan Instagram RelaxBoss. Isi mengikuti halaman Tentang di situs; daftar tim dan acara cukup lewat tautan ke situs. Dibuka dari Pengaturan. (usulan founder 2026-11-13) | Should |
| FR-M029 | Layar pertama setelah masuk MUST berupa **Beranda**, bukan chat: sapaan, kartu mood hari ini (FR-M013), grafik ringkas 7 hari, tombol utama "Ngobrol dengan RelaxMate", jalan pintas Latihan napas dan Temani saja, dan tautan Kontak bantuan yang selalu terlihat. Navigasi bawah empat tab: Beranda, Ngobrol, Latihan, Mood. Pengaturan lewat ikon di Beranda. Mood Sedih atau Sangat sedih memunculkan kartu lembut ke Kontak bantuan tanpa memanggil AI (batas diperluas dari Sangat sedih saja mengikuti mockup founder, 2026-11-14). Beranda tidak membutuhkan consent AI; consent hanya dicek saat membuka Ngobrol (FR-M002). (keputusan founder 2026-11-13) | Must |
| FR-M030 | Layar **Mood** MUST menampilkan grafik suasana hati 7 atau 30 hari (satu titik per hari, warna sesuai mood), ringkasan (rata-rata, hari terbaik, jumlah hari diisi), daftar catatan terakhir, keadaan kosong yang ramah, ringkasan teks untuk pembaca layar, dan penegasan bahwa ini bukan diagnosis. Data dari API-M019. (keputusan founder 2026-11-13) | Must |

---

## 8. Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-M01 | **Privasi:** RULE-040 s.d. RULE-049 berlaku di mobile. Tidak mencatat isi pesan, transkrip, atau token di log; token di penyimpanan aman perangkat; isi chat tidak disimpan polos di perangkat; notifikasi tidak memuat isi sensitif; pratinjau aplikasi di daftar terbaru disamarkan `[Assumption]`. |
| NFR-M02 | **Keamanan:** TLS saja; token dapat dicabut (logout, hapus akun, nonaktifkan oleh admin); rate limit sisi server pada login, chat, dan reset. |
| NFR-M03 | **Aksesibilitas:** dukungan TalkBack (label, urutan fokus), target sentuh ≥ 48dp, kontras mengikuti token Design, jangan mengandalkan warna saja. |
| NFR-M04 | **Performa:** cold start ≤ 3 detik `[Assumption]`; ukuran unduhan ≤ 60 MB termasuk klip suara `[Assumption]`. |
| NFR-M05 | **Baterai:** maskot mengambang dan mode suara tidak boleh menahan CPU saat tidak dipakai; hormati penghematan baterai Android. |
| NFR-M06 | **Offline:** kontak krisis, latihan napas, dan klip tetap berfungsi tanpa internet; chat AI menampilkan status offline yang ramah. |
| NFR-M07 | **Kebijakan toko:** memenuhi kebijakan aplikasi kesehatan, konten AI, penghapusan akun, formulir keamanan data, dan izin overlay/foreground service. Detail dicek saat persiapan rilis `[Assumption]`. |

---

## 9. Tech Stack (usulan)

| Lapisan | Pilihan | Catatan |
|---|---|---|
| Framework | Flutter (Dart), Android dulu | Pengalaman founder; iOS menyusul |
| Navigasi / state | `go_router`, Riverpod | Terpasang: `go_router` ^18.1.3, `flutter_riverpod` ^3.4.3 (TASK-M020) |
| Jaringan | `dio` | Hanya ke API Laravel; terpasang ^5.11.1 (TASK-M021) |
| Token | `flutter_secure_storage` | Tanpa cache chat polos; terpasang ^11.2.0 (TASK-M021) |
| STT / TTS | `speech_to_text`, `flutter_tts` | Pengenal dan suara bawaan perangkat |
| Klip suara | `just_audio` atau sejenis | Berkas dibundel di aset |
| Maskot | WebP beranimasi per keadaan (Image.asset, tanpa paket) | Animasi diam, menyimak, berpikir, bicara; Rive dibuang di TASK-M030 |
| Overlay Android | Kandidat: `flutter_overlay_window` + kode Kotlin, atau modul Kotlin sendiri | Diputuskan di spike TASK-M003 (OQ-MA1); foreground service; izin overlay |
| Backend | Laravel yang sama, `/api/v1/*` | Controller tipis di atas Service (RULE-022); Sanctum token (terpasang di TASK-M012; alasan dicatat di Architecture web bagian 13, RULE-060); tanpa streaming/WebSocket/queue (RULE-034) |

**Dampak ke backend** (rincian di Architecture mobile): autentikasi token; endpoint percakapan hari ini, kirim pesan, riwayat, consent, hapus akun; konfigurasi batas “hari” di config. Skema chat yang ada diharapkan tidak berubah; migration tambahan hanya untuk token (RULE-031).

---

## 10. Prasyarat

- TASK-031 (go-live web) selesai; backend produksi stabil.
- OQ-3 (kontak krisis terverifikasi) dan OQ-5 (telaah hukum data AI dan pelatihan) dijawab; OQ-5 juga mencakup layanan suara pihak ketiga.
- Prompt RelaxMate milik founder (RULE-036) disesuaikan untuk balasan lebih pendek dan memperkenalkan diri sebagai “Mates”, lalu `relaxboss:check-crisis` dan `cases.json` diperluas dengan kasus transkrip suara (RULE-047).
- Aturan kerja mobile (versi Rules untuk repo Flutter) dan Doc Sync berlaku.

---

## 11. Risiko

| ID | Risiko | Mitigasi |
|---|---|---|
| R-M1 | Penolakan toko (kesehatan mental + AI, overlay, kemiripan karakter) | Karakter orisinal; disclaimer; hapus akun; privasi jelas; overlay default mati tanpa pembacaan layar |
| R-M2 | Ketergantungan emosional pada maskot | Batas karakter (bagian 4); dorongan ke manusia dan profesional |
| R-M3 | Krisis terlewat karena salah dengar | CrisisDetector pada transkrip; konfirmasi hasil rendah; kasus uji suara |
| R-M4 | Aturan foreground service dan overlay Android berubah | Modul overlay dibangun terpisah dari inti chat dan dapat dimatikan lewat feature flag bila ditolak toko; uji di beberapa versi Android |
| R-M5 | Biaya dan kuota suara (ElevenLabs Starter terbatas) | Klip rekaman bundel; balasan panjang memakai suara perangkat; API suara hanya terbatas |
| R-M6 | Kuota Groq cepat habis oleh obrolan suara | Batas harian di config; model cadangan; respons statis (RULE-045) |
| R-M7 | Konsistensi suara klip | Satu sesi generate, voice ID dan pengaturan dicatat, simpan master di luar repo |
| R-M8 | Selisih fitur Android dan iOS membingungkan | Tulis jelas di toko dan aplikasi |

---

## Assumptions

- A-M1: Android dulu; iOS tidak masuk rilis pertama.
- A-M2: Satu akun untuk web dan mobile; Admin tetap di web.
- A-M3: Percakapan hari ini dihitung WIB dengan batas 04.00; angka di config.
- A-M4: Target metrik dan ukuran adalah asumsi sampai ada baseline.
- A-M5: Suara maskot dirancang sendiri lewat Voice Design ElevenLabs; hak pakai berkas yang dibuat di paket berbayar dan syarat resminya dibaca ulang sebelum rilis.

## Open Questions

| ID | Pertanyaan | Dibutuhkan sebelum |
|---|---|---|
| OQ-M1 | Ditutup: maskot mengambang masuk Fase 1 (keputusan founder, 2026-11-04). | Menetapkan roadmap |
| OQ-M2 | Sebagian ditutup: nama karakter RelaxMate dengan panggilan “Mates”, juga dipakai sebagai kata panggil. Terbuka: cara maskot menyapa pengguna dan ejaan “RelaxMate” atau “RelaxMates”. | Fase 2 |
| OQ-M3 | **Diputuskan founder 2026-11-07:** Cek Rasa mengirim pesan chat dan juga menulis Mood Entry (ENT-006) agar tampil di web. | - |
| OQ-M4 | Ingatan lintas hari (ringkasan terenkripsi) diadakan atau tidak? Terkait TODO-LATER dan kuota | Setelah MVP |
| OQ-M5 | Batas harian untuk obrolan suara tetap 20 atau dinaikkan (mengubah config web juga)? | Fase 2 |
| OQ-M6 | Balasan panjang: suara perangkat saja, atau ElevenLabs API terbatas? Baca syarat resmi (output, data pelatihan) dan telaah privasi | Fase 3 |
| OQ-M7 | Sebagian ditutup: `minSdk 26` diterapkan `[Assumption]`, Application ID `id.my.relaxboss.relaxmate`, repo mobile terpisah dari repo web (paket Dart `relaxmate`). Terbuka: kewajiban closed testing Play dan versi Android minimum final (OQ-MA5) | Persiapan rilis |
| OQ-M8 | Apakah iOS dirilis, dan fitur apa yang berbeda? | Setelah Android stabil |

## Change Log

| Versi | Tanggal | Perubahan |
|---|---|---|
| 0.10 | 2026-11-14 | TASK-M072 dibangun: FR-M029 kartu bantuan lembut untuk Sedih dan Sangat sedih (mengikuti mockup); mood dicatat dengan satu ketukan, tanpa pesan chat. |
| 0.9 | 2026-11-13 | Konsep Beranda: FR-M029 (Beranda sebagai layar pertama, navigasi bawah), FR-M030 (grafik mood), FR-M013 dipindah ke Beranda, non-goal grafik mood dicabut. |
| 0.8 | 2026-11-13 | FR-M028: layar Tentang RelaxBoss. |
| 0.7 | 2026-11-11 | FR-M027: dua tampilan chat (maskot dan obrolan), bawaan maskot. |
| 0.6 | 2026-11-10 | Tabel teknologi: maskot memakai WebP beranimasi, bukan Rive atau Lottie (TASK-M030). |
| 0.5 | 2026-11-07 | OQ-M3 diputuskan: Cek Rasa juga menulis Mood Entry (FR-M013 diperbarui; non-goal Mood Tracker dipertegas). |
| 0.4 | 2026-11-06 | Sinkronisasi ke kode dan backend: teks consent dari server (FR-M002), versi paket terpasang dan kandidat overlay disamakan dengan Architecture-M (bagian 9), OQ-M7 sebagian ditutup. |
| 0.3 | 2026-11-05 | Panduan suara latihan napas ditunda ke Fase 2 (keputusan founder): US-M07 dan FR-M014 diperbarui; Fase 1 hanya visual dan getar opsional. |
| 0.2 | 2026-11-04 | Maskot mengambang masuk Fase 1 (OQ-M1 ditutup). “Mates” adalah panggilan akrab karakter RelaxMate, bukan panggilan untuk pengguna (OQ-M2 sebagian ditutup); kata panggil memakai “Mates”, hanya saat aplikasi atau mini-panel terbuka. Tidak ada pendengaran di latar belakang (keputusan founder: cari aman). |
| 0.1 | 2026-11-04 | Draf awal: konsep karakter, fase, FR, NFR, tech stack, risiko. |
