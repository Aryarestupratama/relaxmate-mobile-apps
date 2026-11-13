# Panduan Uji Manual API Mobile (TASK-M017)

Version: 1.2 | Status: Draft | Last updated: 2026-11-13
Koleksi: `docs/postman/RelaxMate-M017.postman_collection.json` di repo web.
Mencakup API-M001 sampai M006, M008 sampai M013, M015, M016, dan M017 (hapus akun; API-M019 di bagian G dengan koleksi terpisah), plus RULE-033 (isolasi), RULE-040 (log), NFR-M01 dan NFR-M02.

## A. Persiapan (sekali)

1. Repo web terbaru, `.env`:
   - `MAIL_MAILER=log` dan `LOG_LEVEL=debug` (supaya pemeriksaan log paling ketat).
   - `GROQ_KEYS_CHAT` terisi (folder 04 butuh AI aktif). Catat nilainya, dipakai kembali di langkah D3.
2. Terminal di root repo web: `php artisan migrate`, `php artisan config:clear`, lalu `php artisan serve` (biarkan jalan).
3. Kosongkan log: hapus isi `storage/logs/laravel.log` (atau hapus berkasnya) agar pemeriksaan log akhir bersih.
4. Postman: Import `RelaxMate-M017.postman_collection.json`. Buka koleksi, tab Variables, pastikan `baseUrl` = `http://127.0.0.1:8000/api/v1`. Bila Postman di perangkat lain, isi IP komputer dan jalankan `serve --host=0.0.0.0`.
5. Terminal kedua: `php artisan tinker` (dibiarkan terbuka, dipakai untuk langkah manual).

Cara menjalankan di Runner (Postman versi baru): klik koleksi > tombol **Run** (atau klik kanan koleksi > Run collection). Halaman Runner menampilkan **semua request** koleksi dalam satu daftar "Run Sequence" dan semuanya tercentang. **Jangan Start run dengan semua tercentang**: langkah manual dan jeda 60 detik di antara folder akan terlewat. Untuk tiap putaran:

1. Klik **Deselect All**, lalu centang hanya baris request yang dibutuhkan (nomor request ada di namanya, mis. `00.1`, `01.14`). Alternatif: tutup Runner, klik kanan folder di sidebar > **Run** supaya hanya folder itu yang terpilih.
2. Pengaturan di panel kanan:
   - Run type: **Functional**. Run method: **Local**.
   - Iterations: **1** (kecuali 06.1: **7**). Iteration data: None.
   - **Keep variable values: WAJIB tercentang.** Token, ID percakapan, dan runId diisi script; bila tidak dicentang, nilainya hilang setelah run dan folder berikutnya gagal 401.
   - **Stop run if an error occurs: matikan (hapus centang)** agar satu kegagalan tidak menyembunyikan hasil request sesudahnya.
   - Add a delay between requests: **tidak dicentang** (0 ms).
   - "Persist responses for a session", "Save cookies after collection run": biarkan.
3. Klik **Start run**. Hasil yang diharapkan: semua test hijau. Bila ada yang merah, catat nama request dan pesan galatnya.

## B. Urutan uji

| Langkah | Apa | Cara | Hasil yang diharapkan |
|---|---|---|---|
| 1 | Folder `00 Persiapan` + `01 Auth` | Runner: centang baris 00.1 sampai 01.14 saja (16 request), kurang dari 1 menit | Hijau semua. 01.6 sengaja 429 (batas 5 daftar per menit); bila 01.1 sudah 429, tunggu 60 detik dan mulai dari 00.1. |
| 2 | Folder `02 Akun belum terverifikasi` | Runner: centang 02.1 sampai 02.6 | Hijau. 02.4 dan 02.5 harus 403 `unverified`. |
| 3 | **Manual: verifikasi A dan B** | Di tinker: `App\Models\User::where('email','like','%@example.test')->whereNull('email_verified_at')->get()->each->markEmailAsVerified();` | Tanpa galat. Alternatif: buka tautan dari `laravel.log` (email 02.6) di peramban. |
| 4 | Folder `02B Setelah verifikasi manual` | Runner | `email_verified` true untuk A dan B. |
| 5 | Folder `03 Consent` | Runner | Hijau. Consent lengkap untuk A dan B. |
| 6 | Folder `04 Chat A` | Runner, jeda 0 | Hijau. Lima POST di folder ini tepat di batas 5 per menit. Bila 04.5 mendapat 503, `GROQ_KEYS_CHAT` belum aktif. **Tunggu 60 detik sesudahnya.** |
| 7 | Folder `05 Isolasi pengguna A vs B` | Runner | Hijau. Semua akses B ke data A harus 404, bukan 403 dan bukan 200. |
| 8 | `06 Batas dan galat layanan`, bagian rate | Runner: pilih **hanya 06.1**, Iterations **7**, Delay 0. Lalu kirim 06.2 (tombol Send) | 06.1: maksimal 5 respons 200, sisanya 429 `rate_limited` dengan `Retry-After`. 06.2 hijau. **Tunggu 60 detik.** |
| 9 | 06.3 batas harian | Edit `config/relaxboss.php`: `'chat_per_day' => 1`, jalankan `php artisan config:clear`, tunggu 60 detik sejak 06.1, kirim 06.3 | 429 `daily_limit`. **Kembalikan ke 20** dan `php artisan config:clear`. |
| 10 | 06.4 s.d. 06.6 AI mati lalu hidup | Kosongkan `GROQ_KEYS_CHAT=` di `.env`, `php artisan config:clear`. Kirim 06.4 (503 `ai_unavailable`), 06.5 (`unanswered` true). Opsional kirim 06.7 (krisis tetap 200). Kembalikan nilai key, `config:clear`, kirim 06.6 | 06.6: balasan masuk, kuota tidak berkurang. |
| 11 | 06.8 dan 06.9 hari berganti | Di tinker: `App\Models\Conversation::find('ISI_convA')->forceFill(['created_at'=>now()->subDays(2)])->save();` (`convA` ada di Variables koleksi). Kirim 06.8, lalu 06.9 | 06.8: 409 `conversation_closed`. 06.9: percakapan baru. Kirim ulang 04.10: percakapan lama tetap terbaca (200). |
| 12 | 07.1 s.d. 07.3 akun nonaktif | Di tinker: `App\Models\User::where('email','b-ISI_runId@example.test')->update(['is_active'=>false]);` (`runId` ada di Variables). Kirim 07.1, 07.2, 07.3 berurutan | 403 `account_inactive`, lalu 401 (token dicabut), lalu login 403. |
| 13 | 07.4 s.d. 07.9 hapus akun A | Send satu per satu atau Runner dengan memilih 07.4 s.d. 07.9 | 422 tanpa sandi, 422 sandi salah, A masih ada, 204, lalu 401 dan login 401. |

Lanjutan langkah 6 dan 8 butuh jeda 60 detik karena limiter `chat` 5/menit per pengguna.

## C. Pemeriksaan log dan data (RULE-040, RULE-032)

Jalankan setelah langkah 13, dengan `laravel.log` yang sudah dikosongkan di awal.

1. Isi pesan, sandi, dan token tidak boleh ada di log.
   - Git Bash, Linux, macOS: `grep -c -E "MARKER-|Bearer|Sandi-M017-aman1|pengen mati|capek banget" storage/logs/laravel.log` harus `0`.
   - PowerShell: `Select-String -Path storage\logs\laravel.log -Pattern 'MARKER-','Bearer','Sandi-M017-aman1','pengen mati','capek banget'` tidak boleh menampilkan apa pun.
   - Tambahan: salin 12 karakter pertama token B (bagian sesudah tanda `|`) dari Variables `tokenB`, cari di log: tidak boleh ada.
   - Catatan: dengan `MAIL_MAILER=log`, isi email verifikasi dan reset (nama, email, tautan bertanda tangan) tertulis di log. Itu perilaku dev, bukan kebocoran aplikasi (produksi memakai SMTP), jadi tidak dihitung.
2. Baris log `ai.completion` dan `ai.unavailable` hanya berisi metadata (fitur, model, jumlah token, durasi).
3. Isi pesan terenkripsi di database. Di tinker: `Illuminate\Support\Facades\DB::table('messages')->orderByDesc('id')->value('content');` harus berupa teks acak (biasanya diawali `eyJ`), tidak memuat kata dari pesan uji.

## D. Pembersihan

1. Kembalikan `chat_per_day` ke 20 dan `GROQ_KEYS_CHAT` ke nilai semula, lalu `php artisan config:clear`.
2. Hapus akun B (A sudah terhapus di 07.7). Di tinker:
   ```php
   $ids = App\Models\User::where('email','like','b-%@example.test')->pluck('id');
   Laravel\Sanctum\PersonalAccessToken::whereIn('tokenable_id',$ids)->delete();
   App\Models\User::whereIn('id',$ids)->delete();
   ```
3. Ulang dari awal kapan saja: jalankan 00.1 (membuat `runId` dan email baru); tidak perlu membersihkan apa pun selain batas 5 daftar per menit.

## E. Yang dilaporkan kembali

- Ringkasan Runner tiap folder (lulus/gagal) dan nama request yang merah beserta pesan galat.
- Hasil tiga pemeriksaan di bagian C.
- Perilaku yang menurut Anda janggal walau test hijau.

## F. Masalah umum

| Gejala | Penyebab | Perbaikan |
|---|---|---|
| "Could not get any response" | `php artisan serve` mati atau `baseUrl` salah | Jalankan ulang serve, cek Variables |
| 401 di mana-mana | Token belum terisi | Jalankan 00.1 lalu 01.1 dst. dari awal |
| 429 di 01.1 | Batas 5 daftar per menit | Tunggu 60 detik |
| 503 `ai_unavailable` di 04.5 | `GROQ_KEYS_CHAT` kosong atau tidak valid | Isi key, `config:clear` |
| 429 `rate_limited` di folder 04 atau 06 | Lebih dari 5 POST per menit | Tunggu 60 detik |
| 403 `unverified` di folder 03 | Langkah 3 belum dijalankan | Jalankan perintah verifikasi di tinker |
| Test merah "ID sama" di 04.2 | Lewat pukul 04.00 WIB di antara dua request | Ulangi dari 00.1 |

## G. API-M019 `GET /mood-entries` (TASK-M077)

Koleksi terpisah: `docs/postman/RelaxMate-M077.postman_collection.json` (12 request). Data uji dibuat oleh `docs/postman/m077-seed.php`. Tidak butuh AI, consent, atau migration baru.

1. Repo web terbaru (sudah di-pull dengan kode M077). Terminal: `php artisan config:clear`, `php artisan route:list --path=api/v1/mood-entries`. Harus muncul **dua** baris: `GET|HEAD` (`mood-entries.index`) dan `POST` (`mood-entries.store`).
2. `php artisan serve` (biarkan jalan). Terminal kedua: `php artisan tinker`, lalu jalankan `include 'docs/postman/m077-seed.php';`. Skrip membuat akun `m077-a`, `m077-b`, `m077-c` (`@example.test`) dan mencetak `tokenA`, `tokenB`, `tokenC`; keluaran terakhir harus `Entri A: 6 ... entri B: 1`.
3. Postman: Import `RelaxMate-M077.postman_collection.json`. Di tab Variables isi `tokenA`, `tokenB`, `tokenC` dari keluaran tinker (nilai utuh, termasuk angka dan tanda `|`), pastikan `baseUrl` benar. Simpan.
4. Runner: pilih seluruh folder 00 sampai 04, Iterations 1, **Keep variable values** tercentang, Delay 0. Hasil yang diharapkan: **12 request, semua test hijau**.
5. Periksa mata: kirim `01.1` lewat tombol Send, lihat Body. Harus tampak tiga elemen `days` berurut naik tanggalnya, `summary`, dan `range`; **tidak ada kata `note`**.
6. Cek tambahan di tinker (tanpa isi catatan keluar di respons): `App\Models\MoodEntry::where('user_id', App\Models\User::where('email','m077-a@example.test')->value('id'))->count();` harus `7` (6 hasil seed + 1 dari 04.1).
7. Cek log: `grep -c "RAHASIA-M077" storage/logs/laravel.log` harus `0` (PowerShell: `Select-String -Path storage\logs\laravel.log -Pattern 'RAHASIA-M077'` tidak menampilkan apa pun).
8. Uji ulang kapan saja: jalankan lagi `include` seed (akun lama dihapus, token baru dicetak), perbarui tiga token, ulang Runner.
9. Pembersihan: di tinker `$ids = App\Models\User::where('email','like','m077-%@example.test')->pluck('id'); Laravel\Sanctum\PersonalAccessToken::whereIn('tokenable_id',$ids)->delete(); App\Models\User::whereIn('id',$ids)->delete();`

Catatan: bila Runner dijalankan tepat di 00.00 sampai 01.00 WIB, `04.2` bisa merah karena catatan seed hari ini dibuat pukul 01.00 WIB; ulangi sesudah pukul 01.00. Isi yang diperiksa: satu titik per hari WIB, catatan terakhir menang, 7 dan 30 hari berbeda, `days` liar ditolak 422, B tidak melihat data A, belum terverifikasi 403, tanpa token 401.

## Change Log

| Versi | Tanggal | Perubahan |
|---|---|---|
| 1.2 | 2026-11-13 | Bagian G: uji API-M019 `GET /mood-entries` (TASK-M077), koleksi `RelaxMate-M077` terpisah. |
| 1.1 | 2026-11-07 | Langkah Runner disesuaikan dengan Postman versi baru (Deselect All, Keep variable values, Stop run). |
| 1.0 | 2026-11-07 | Panduan awal TASK-M017. |
