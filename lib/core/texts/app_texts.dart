/// Bank teks UI (RULE-M054). Nada: "kamu", hangat, tidak menggurui.
/// Teks panjang (privasi, ketentuan) ada di `assets/texts`; teks consent dan
/// Crisis Response berasal dari API, bukan disalin di sini (RULE-049 web).
abstract final class AppTexts {
  static const String appName = 'RelaxMate';

  static const String welcome =
      'Halo, aku RelaxMate. Teman ceritamu. Aku bukan psikolog atau layanan '
      'medis, tapi aku siap mendengarkan.';

  static const String mascotLabel = 'Maskot RelaxMate';

  static const String configError =
      'Konfigurasi aplikasi belum lengkap. Hubungi pengembang.';

  static const String loading = 'Memuat...';

  // Perbarui aplikasi (SCR-M20).
  static const String updateTitle = 'Perbarui aplikasi';
  static const String updateBody =
      'Versi aplikasi ini sudah terlalu lama. Perbarui dulu supaya semuanya '
      'berjalan aman.';
  static const String updateAction = 'Perbarui sekarang';
  static const String storeOpenFailed =
      'Toko aplikasi belum bisa dibuka. Coba lagi nanti.';

  // Galat jaringan dan API (Architecture-M bagian 11). Tanpa detail teknis.
  static const String errorGeneric =
      'Ada yang tidak berjalan semestinya. Coba lagi, ya.';
  static const String errorOffline =
      'Koneksi terputus. Periksa internetmu, lalu coba lagi.';
  static const String errorTimeout =
      'Permintaan terlalu lama. Coba lagi sebentar lagi, ya.';
  static const String errorUnauthorized =
      'Sesimu sudah berakhir. Silakan masuk lagi.';
  static const String errorForbidden = 'Kamu belum bisa mengakses ini.';
  static const String errorNotFound = 'Yang kamu cari tidak ditemukan.';
  static const String errorConflict = 'Permintaan ini sudah pernah diproses.';
  static const String errorValidation = 'Periksa lagi isianmu, ya.';
  static const String errorRateLimited =
      'Terlalu banyak percobaan. Coba lagi sebentar lagi.';
  static const String errorServer =
      'Layanan sedang bermasalah. Coba lagi sebentar lagi.';

  static String rateLimitedIn(int seconds) =>
      'Terlalu banyak percobaan. Coba lagi dalam $seconds detik.';

  // Umum.
  static const String processing = 'Memproses...';
  static const String retry = 'Coba lagi';
  static const String logout = 'Keluar';
  static const String showPassword = 'Tampilkan kata sandi';
  static const String hidePassword = 'Sembunyikan kata sandi';
  static const String webOpenFailed =
      'Halaman belum bisa dibuka. Coba lagi nanti.';

  // Kolom isian dan validasi klien (sama dengan pesan server agar konsisten).
  static const String fieldName = 'Nama';
  static const String fieldEmail = 'Email';
  static const String fieldPassword = 'Kata sandi';
  static const String fieldNameRequired = 'Nama wajib diisi.';
  static const String fieldEmailRequired = 'Email wajib diisi.';
  static const String fieldEmailInvalid = 'Format email belum benar.';
  static const String fieldPasswordRequired = 'Kata sandi wajib diisi.';
  static const String fieldPasswordConfirm = 'Konfirmasi kata sandi';
  static const String fieldPasswordConfirmRequired =
      'Ulangi kata sandimu di kolom ini.';
  static const String fieldPasswordMismatch =
      'Konfirmasi kata sandi belum sama.';
  static const String authBack = 'Kembali';
  static const String termsRequired =
      'Centang dulu bahwa kamu sudah membaca ketentuan.';

  // Sambutan (SCR-M02).
  static const String welcomeTitle =
      'Rasakan dukungan setiap hari bersama RelaxMate';
  static const String welcomeBody =
      'Catat suasana hati, bercerita, dan menenangkan diri dengan lembut.';
  static const String welcomeHeroLabel =
      'Ilustrasi RelaxMate memegang lima ekspresi suasana hati';
  static const String welcomeStart = 'Mulai';
  static const String welcomeHaveAccount = 'Sudah punya akun?';

  // Masuk (SCR-M04).
  static const String loginTitle = 'Halo, selamat datang kembali';
  static const String loginSubtitle =
      'Masuk untuk melanjutkan ceritamu bersama RelaxMate.';
  static const String loginAction = 'Masuk';
  static const String loginToForgot = 'Lupa kata sandi?';
  static const String loginNoAccount = 'Belum punya akun?';
  static const String loginToRegister = 'Daftar';

  // Daftar (SCR-M03).
  static const String registerTitle = 'Buat akunmu';
  static const String registerSubtitle =
      'Akun ini sama dengan akun RelaxBoss di website.';
  static const String registerAction = 'Daftar';
  static const String registerHaveAccount = 'Sudah punya akun?';
  static const String registerToLogin = 'Masuk';
  // Kalimat centang Daftar dipecah agar "Ketentuan" dan "Kebijakan Privasi" bisa
  // menjadi tautan di dalam kalimat (tanpa tombol baca terpisah).
  static const String termsAcceptPrefix = 'Aku sudah membaca dan menyetujui ';
  static const String termsAcceptTerms = 'Ketentuan';
  static const String termsAcceptAnd = ' dan ';
  static const String termsAcceptPrivacy = 'Kebijakan Privasi';
  static const String termsAcceptSuffix = '.';

  // Lupa kata sandi (SCR-M05).
  static const String forgotTitle = 'Lupa kata sandi';
  static const String forgotSubtitle =
      'Masukkan emailmu. Kami kirim tautan untuk mengatur ulang kata sandi.';
  static const String forgotAction = 'Kirim tautan';
  static const String forgotSentFallback =
      'Jika email itu terdaftar, tautan untuk mengatur ulang kata sandi sudah '
      'dikirim. Cek kotak masukmu, ya.';
  static const String forgotBack = 'Kembali ke masuk';

  // Cek email (SCR-M06).
  static const String checkEmailTitle = 'Cek emailmu';
  static const String checkEmailDone = 'Saya sudah verifikasi';
  static const String checkEmailResend = 'Kirim ulang email';
  static const String checkEmailResent =
      'Email verifikasi sudah dikirim ulang. Cek kotak masukmu, ya.';
  static const String checkEmailNotYet =
      'Emailmu belum terverifikasi. Cek kotak masuk atau folder spam, ya.';

  static String checkEmailBody(String email) =>
      'Kami mengirim tautan verifikasi ke $email. Buka tautannya, lalu kembali '
      'ke sini.';

  // Sesi belum bisa diperiksa (offline, timeout, galat server).
  static const String sessionCheckTitle = 'Belum bisa memeriksa sesimu';
  static const String sessionCheckBody =
      'Kamu masih masuk di perangkat ini. Pastikan internetmu aktif, lalu coba '
      'lagi.';

  // Consent AI dan persetujuan pelatihan (SCR-M07). Judul dan isi consent berasal dari
  // server (API-M008), bukan dari sini.
  static const String consentAgree = 'Setuju dan lanjutkan';
  static const String consentSaveChoice = 'Simpan pilihan';
  static const String consentTrainingTitle = 'Satu pilihan untukmu';
  static const String consentTrainingYes = 'Boleh';
  static const String consentTrainingNo = 'Tidak boleh';
  static const String consentChoiceRequired = 'Pilih salah satu dulu.';
  static const String consentCheckTitle = 'Belum bisa memuat persetujuan';
  static const String consentCheckBody =
      'Sebelum bercerita, kami perlu memastikan persetujuanmu. Pastikan '
      'internetmu aktif, lalu coba lagi.';

  // Chat harian (SCR-M08). Pesan galat dan batas berasal dari server.
  static const String chatInputHint = 'Ketik pesanmu...';
  static const String chatSend = 'Kirim';
  static const String chatTyping = 'RelaxMate sedang menulis...';
  static const String chatHeaderSubtitle = 'Ruang amanmu untuk bercerita';

  /// Penanda tanggal di atas percakapan, mis. "Hari ini · Minggu, 15 November 2026".
  static String chatDateLabel(String date) => '$today · $date';
  static const String chatYouSaid = 'Kamu berkata';
  static const String chatMateSaid = 'RelaxMate berkata';
  static const String chatDailyLimit =
      'Batas pesan hari ini sudah tercapai. Kita lanjut lagi besok, ya.';

  static String chatRemaining(int remaining, int perDay) =>
      'Sisa pesan hari ini: $remaining dari $perDay';

  // Mood: label skala mengikuti web (enum `MoodLevel` server). Dicatat dari kartu mood di
  // Beranda (SCR-M22, FR-M013).
  static const String moodVerySad = 'Sangat sedih';
  static const String moodSad = 'Sedih';
  static const String moodNeutral = 'Biasa';
  static const String moodHappy = 'Senang';
  static const String moodGreat = 'Luar biasa';
  static const String moodNotSaved =
      'Perasaanmu belum tercatat. Coba lagi sebentar lagi, ya.';

  /// Kalimat pembuka chat bila mood hari ini sudah tercatat (OQ-MP5); tidak dikirim otomatis.
  static String moodChatMessage(String label) =>
      'Aku merasa ${label.toLowerCase()} hari ini';
  static const String chatMoodChipHint = 'Mau mulai dari perasaanmu hari ini?';

  // Kontak bantuan dan Crisis Response (SCR-M16, CMP-M04). Teks tetap di klien, bukan
  // keluaran AI (FR-M011). Daftar kontak sendiri dari server atau aset, bukan dari sini.
  static const String crisisContactsTitle = 'Kontak bantuan';
  static const String crisisContactsIntro =
      'Kalau kamu butuh bicara dengan manusia sekarang, hubungi layanan di '
      'bawah ini. Kamu tidak harus menghadapi ini sendirian.';
  static const String crisisContactsEmergency =
      'Kalau ada bahaya langsung bagi dirimu atau orang lain, hubungi layanan '
      'darurat setempat.';
  static const String crisisBannerTitle = 'Kamu tidak sendirian';
  static const String crisisBannerBody =
      'Kalau kamu berpikir untuk menyakiti dirimu sendiri, tolong hubungi '
      'bantuan sekarang atau minta seseorang yang kamu percaya menemanimu.';
  static const String crisisSeeAll = 'Lihat semua kontak bantuan';
  static const String crisisCall = 'Telepon';
  static const String crisisOpenSite = 'Buka situs';
  static const String crisisNeedHelp =
      'Butuh bantuan sekarang? Lihat kontak bantuan';
  static const String crisisMenuTooltip = 'Kontak bantuan';
  static const String crisisHelpShort = 'Bantuan';

  static String crisisCallFailed(String phone) =>
      'Panggilan belum bisa dimulai. Hubungi $phone lewat aplikasi telepon.';

  static String crisisCallContact(String name) => 'Hubungi $name';

  // Saran tindakan di bawah balasan (CMP-M05, FR-M008). Teks panjang saran tidak disalin dari
  // web (RULE-049): chip hanya berlabel tujuan.
  static const String suggestionContacts = 'Lihat kontak bantuan';
  static const String suggestionConsultation = 'Bicara dengan profesional';
  static const String suggestionDismiss = 'Tutup saran';

  // Menu di bilah atas chat (SCR-M08).
  static const String chatMenuTooltip = 'Menu';
  static const String chatModeMascot = 'Maskot';
  static const String chatModeConversation = 'Obrolan';

  /// Label pembaca layar untuk pengalih tampilan; [current] nama tampilan yang sedang dipakai.
  static String chatModeSemantics(String current) =>
      'Tampilan chat: $current. Ketuk untuk mengganti.';

  // Tampilan maskot chat (FR-M027): SOS saat krisis dan tombol Tenangkan diri di kolom ketik.
  static const String sosLabel = 'SOS';
  static const String sosSemantics = 'SOS, buka kontak bantuan';
  static const String calmTooltip = 'Tenangkan diri';
  static const String calmSheetTitle = 'Mau tenang sebentar?';
  static const String calmSheetBody =
      'Dua latihan singkat yang berjalan di perangkatmu, tanpa kuota.';
  static const String calmBreathingHint = 'Napas pelan, sekitar dua menit';
  static const String calmGroundingHint = 'Kenali sekitarmu lewat lima indra';

  // Pengaturan (SCR-M17) dan Hapus akun (SCR-M19), FR-M003, FR-M025.
  static const String settingsTitle = 'Pengaturan';
  static const String settingsAccount = 'Akun';
  static const String settingsTraining = 'Persetujuan pelatihan';
  static const String settingsTrainingSaved = 'Pilihanmu disimpan.';
  static const String settingsPractice = 'Latihan';
  static const String settingsMascot = 'Maskot';
  static const String settingsDisplay = 'Tampilan';
  static const String settingsChatMascotMode = 'Maskot di chat';
  static const String settingsChatMascotModeHint =
      'Maskot di tengah layar dan balasan terakhir di bawahnya. Matikan untuk daftar obrolan biasa.';
  static const String settingsPrivacy = 'Privasi dan bantuan';
  static const String settingsPrivacyCover =
      'Sembunyikan layar di aplikasi terbaru';
  static const String settingsPrivacyCoverHint =
      'Saat kamu berpindah aplikasi, layar RelaxMate diganti gambar polos '
      'supaya isinya tidak terlihat di daftar aplikasi terbaru.';
  static const String settingsPolicy = 'Kebijakan Privasi';
  static const String settingsTerms = 'Ketentuan layanan';
  static const String settingsHelp = 'Kontak bantuan';
  static const String settingsDeleteAccount = 'Hapus akun';
  static const String settingsAbout = 'Tentang RelaxBoss';

  // Tentang RelaxBoss (SCR-M21, FR-M028). Isi mengikuti halaman Tentang di situs RelaxBoss.
  static const String aboutTitle = 'Tentang RelaxBoss';
  static const String aboutHeadline = 'RelaxMate adalah bagian dari RelaxBoss';
  static const String aboutIntro =
      'RelaxBoss adalah teman yang sederhana, gratis, dan ramah untuk membantu '
      'mahasiswa mengenali dan mengelola stres lebih awal. RelaxMate adalah '
      'teman bicara virtual berbasis AI di dalam aplikasi ini.';
  static const String aboutStoryTitle = 'Berawal dari burnout';
  static const String aboutStoryBody =
      'Ide RelaxBoss muncul dari pengalaman pengembangnya sendiri: mengalami '
      'burnout saat kuliah. Dari situ lahir pertanyaan sederhana, bagaimana '
      'kalau mahasiswa punya tempat untuk mengenali stres lebih awal, tanpa '
      'biaya dan tanpa rasa canggung?';
  static const String aboutVisionTitle = 'Visi';
  static const String aboutVisionBody =
      'Membantu mahasiswa mengenali dan mengelola stres lebih awal, dengan cara '
      'yang sederhana, gratis, dan ramah. Kami percaya kamu yang memegang '
      'kendali atas kondisimu, bukan sebaliknya.';
  static const String aboutNameTitle = 'Tentang nama';
  static const String aboutNameRelax = 'Relax';
  static const String aboutNameRelaxBody = 'Ajakan untuk tenang.';
  static const String aboutNameBoss = 'Boss';
  static const String aboutNameBossBody =
      'Pengingat bahwa kamulah yang memegang kendali atas stresmu.';
  static const String aboutCampusTitle = 'Dibangun bersama kampus';
  static const String aboutCampusBody =
      'RelaxBoss dikembangkan di lingkungan Universitas Mercu Buana, hasil '
      'kolaborasi Fakultas Psikologi dan Fakultas Ilmu Komputer.';
  static const String aboutSafeTitle = 'Ruang yang aman, bukan diagnosis';
  static const String aboutSafeBody =
      'RelaxBoss dan RelaxMate bukan psikolog atau layanan medis, dan '
      'hasilnya bukan diagnosis. Untuk penilaian yang tepat, bicarakan dengan '
      'profesional. Jika kamu butuh bantuan segera, buka Kontak bantuan.';
  static const String aboutHelpButton = 'Buka Kontak bantuan';
  static const String aboutLinksTitle = 'Kenali lebih jauh';
  static const String aboutWebsite = 'Situs RelaxBoss';
  static const String aboutWebsiteFull = 'Cerita lengkap dan tim di situs';
  static const String aboutInstagram = 'Instagram @relaxboss_id';
  static String settingsVersion(String version) => 'Versi $version';

  static const String deleteBody =
      'Akunmu dan semua datamu akan dihapus dan tidak bisa dipulihkan: '
      'percakapan, riwayat, dan catatan suasana hati. Masukkan kata sandimu '
      'untuk melanjutkan.';
  static const String deleteButton = 'Hapus akun saya';
  static const String deleteConfirmTitle = 'Hapus akunmu?';
  static const String deleteConfirmBody =
      'Ini tidak bisa dibatalkan. Semua datamu akan hilang.';
  static const String deleteCancel = 'Batal';
  static const String deleteConfirm = 'Ya, hapus';

  // Maskot mengambang (SCR-M18, FR-M022): izin dan pilihan. Gelembungnya sendiri di TASK-M033.
  static const String overlayTitle = 'Maskot mengambang';
  static const String overlayIntro =
      'Maskot bisa muncul kecil di layarmu supaya kamu merasa ditemani. '
      'Maskot tidak membaca layarmu dan tidak mendengarkan.';
  static const String overlayToggle = 'Tampilkan maskot mengambang';
  static const String overlayPermissionOverlay =
      'Izin tampil di atas aplikasi lain';
  static const String overlayPermissionNotifications = 'Izin notifikasi';
  static const String overlayGranted = 'aktif';
  static const String overlayNotGranted = 'belum';
  static const String overlayOpenSettings = 'Buka pengaturan izin';
  static const String overlayAllowNotifications = 'Izinkan notifikasi';
  static const String overlayOpenNotificationSettings =
      'Buka pengaturan notifikasi';
  static const String overlayNotificationsHint =
      'Notifikasi dipakai untuk tombol "Nonaktifkan" pada maskot. Tanpa izin ini '
      'kamu tetap bisa menutup maskot lewat tombol tutup di panelnya, tetapi '
      'tombol di notifikasi tidak terlihat.';
  static const String overlayExplainTitle =
      'Izinkan tampil di atas aplikasi lain?';
  static const String overlayExplainBody =
      'Android akan membuka halaman pengaturan. Cari RelaxMate lalu nyalakan '
      '"Izinkan tampil di atas aplikasi lain". Izin ini hanya dipakai untuk '
      'menampilkan maskot; maskot tidak membaca layar dan tidak merekam. Kamu '
      'bisa mematikannya kapan saja.';
  static const String overlayExplainConfirm = 'Buka pengaturan';
  static const String overlayExplainLater = 'Nanti saja';
  static const String overlayResumeOffer =
      'Maskot sedang istirahat. Mau dinyalakan lagi?';
  static const String overlayResumeYes = 'Nyalakan';
  static const String overlayResumeLater = 'Nanti';
  static const String overlayRestingTomorrow = 'Maskot istirahat sampai besok.';
  static String overlayRestingUntil(String time) =>
      'Maskot istirahat sampai $time.';
  static const String overlayStartFailed =
      'Maskot belum bisa dimulai. Pastikan izin tampil di atas aplikasi lain '
      'aktif, lalu coba lagi.';
  static const String overlaySettingsFailed =
      'Halaman pengaturan belum bisa dibuka. Buka pengaturan Android secara manual.';

  // Tautan di layar consent bagi yang belum atau tidak menyetujui (OQ-MA12).
  static const String consentExercisesLink = 'Latihan napas dan grounding';
  static const String consentSettingsLink = 'Pengaturan dan hapus akun';
  static const String consentHomeLink = 'Kembali ke Beranda';

  // Maskot dan Temani saja (SCR-M13, FR-M015). Tanpa AI dan tanpa kuota; maskot tidak
  // mengaku punya perasaan (RULE-M046).
  static const String companionMenu = 'Temani saja';
  static const String companionTileSubtitle =
      'Ditemani maskot, tanpa perlu bicara';
  static const String companionTitle = 'Temani saja';
  static const String companionBody = 'Aku di sini. Tidak perlu bicara.';
  static const String companionDone = 'Selesai';
  static const String mascotStateIdle = 'Maskot RelaxMate sedang diam';
  static const String mascotStateListening = 'Maskot RelaxMate menyimak';
  static const String mascotStateThinking = 'Maskot RelaxMate sedang berpikir';
  static const String mascotStateSpeaking = 'Maskot RelaxMate sedang bicara';

  // Latihan lokal (SCR-M11, SCR-M12, FR-M014). Berjalan di perangkat: tanpa AI, tanpa kuota,
  // tanpa internet. Disclaimer dan jalur ke bantuan mengikuti RULE-M046.
  static const String exercisesTitle = 'Latihan';
  static const String exercisesHeading = 'Tenangkan diri sebentar';
  static const String exercisesIntro =
      'Pilih yang terasa pas hari ini. Semuanya berjalan di HP-mu, tanpa AI '
      'dan tanpa internet.';
  static const String exercisesDisclaimer =
      'Latihan ini membantu menenangkan diri. Ini bukan layanan medis dan '
      'tidak menggantikan profesional. Kalau terasa berat, kamu tidak harus '
      'menghadapinya sendirian.';
  static const String exerciseDone = 'Selesai';
  static const String exerciseAgain = 'Ulangi';
  static const String exerciseClosing =
      'Aku di sini kapan pun kamu butuh. Jaga dirimu, ya.';

  static String exerciseTileLabel(String title, String subtitle) =>
      '$title. $subtitle';

  // Latihan napas (SCR-M11).
  static const String breathingTitle = 'Latihan napas';
  static const String breathingSubtitle = 'Napas pelan selama 1 sampai 5 menit';
  static const String breathingIntro =
      'Duduk dengan nyaman. Lingkaran membesar saat kamu menarik napas dan '
      'mengecil saat kamu mengembuskan.';
  static const String breathingDurationLabel = 'Berapa lama?';
  static const String breathingHaptics = 'Getar halus';
  static const String breathingHapticsHint =
      'Getaran lembut tiap pergantian napas, mengikuti pengaturan getar '
      'HP-mu.';
  static const String breathingStart = 'Mulai';
  static const String breathingStop = 'Akhiri';
  static const String breathingInhale = 'Tarik napas...';
  static const String breathingHold = 'Tahan...';
  static const String breathingExhale = 'Embuskan pelan-pelan...';
  static const String breathingDoneTitle = 'Latihan selesai';

  static String breathingMinutes(int minutes) => '$minutes menit';

  static String breathingCycle(int cycle, int total) =>
      'Putaran $cycle dari $total';

  static String breathingDoneBody(int cycles) =>
      'Kamu sudah menyelesaikan $cycles putaran napas. Perhatikan sebentar '
      'bagaimana rasanya sekarang.';

  // Grounding 5-4-3-2-1 (SCR-M12). Satu indra per langkah, dari 5 sampai 1.
  static const String groundingTitle = 'Grounding 5-4-3-2-1';
  static const String groundingSubtitle = 'Kenali sekitarmu lewat lima indra';
  static const String groundingNext = 'Lanjut';

  /// Kata pembuka di atas angka besar; angka lalu [groundingSee] dan seterusnya melengkapi
  /// kalimatnya ("Sebutkan" / 5 / "hal yang bisa kamu lihat"), jadi jumlahnya tidak
  /// diulang di teks.
  static const String groundingLead = 'Sebutkan';
  static const String groundingSee = 'hal yang bisa kamu lihat';
  static const String groundingTouch = 'hal yang bisa kamu sentuh';
  static const String groundingHear = 'suara yang bisa kamu dengar';
  static const String groundingSmell = 'aroma yang bisa kamu cium';
  static const String groundingTaste = 'rasa yang bisa kamu cicipi';
  static const String groundingSeeHint =
      'Pelan-pelan saja. Warna, bentuk, atau cahaya juga boleh.';
  static const String groundingTouchHint =
      'Rasakan kain bajumu, sandaran kursi, atau permukaan di bawah tanganmu.';
  static const String groundingHearHint =
      'Dengarkan suara yang dekat, lalu yang jauh.';
  static const String groundingSmellHint =
      'Tidak tercium apa-apa? Bayangkan aroma yang kamu suka.';
  static const String groundingTasteHint =
      'Boleh rasa di mulutmu sekarang, atau bayangkan makanan kesukaanmu.';
  static const String groundingDoneTitle = 'Kamu sudah sampai di sini';
  static const String groundingDoneBody =
      'Kamu sudah mengenali sekitarmu lewat kelima indra. Tarik napas '
      'sebentar dan rasakan bagaimana kamu sekarang.';

  /// Untuk pembaca layar: kalimat utuh dari kata pembuka, angka, dan isi langkah.
  static String groundingStepLabel(int count, String what) =>
      '$groundingLead $count $what';
  static String groundingProgress(int step, int total) =>
      'Langkah $step dari $total';

  // Riwayat (SCR-M14) dan detail hari (SCR-M15), hanya baca (FR-M005). Label tanggal dan jam
  // percakapan berasal dari server.
  static const String historyTitle = 'Riwayat';
  static const String historyTooltip = 'Riwayat';
  static const String historyEmpty =
      'Belum ada riwayat. Setelah kamu bercerita, hari-harimu akan muncul di '
      'sini.';
  static const String historyLoadMore = 'Muat lebih banyak';
  static const String historyLoadMoreMessages = 'Muat pesan berikutnya';
  static const String historyReadOnly =
      'Ini riwayat percakapan. Kamu hanya bisa membacanya.';

  static const List<String> months = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String historyTurns(int turns) => '$turns giliran';

  static String historyOpenDay(String date, String time) =>
      'Buka percakapan $date, $time';

  // Navigasi bawah, Beranda, dan Mood (TASK-M072; SCR-M22, SCR-M23).
  static const String navHome = 'Beranda';
  static const String navChat = 'Ngobrol';
  static const String navExercises = 'Latihan';
  static const String navMood = 'Mood';
  static const String navSettings = 'Pengaturan';

  static const List<String> weekdays = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const List<String> weekdaysShort = <String>[
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];
  static const List<String> monthsShort = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const String today = 'Hari ini';

  static const String greetMorning = 'Selamat pagi';
  static const String greetNoon = 'Selamat siang';
  static const String greetAfternoon = 'Selamat sore';
  static const String greetEvening = 'Selamat malam';
  static String homeGreeting(String salutation, String firstName) =>
      firstName.isEmpty ? salutation : '$salutation, $firstName';
  static const String homeGreetingSub =
      'Pelan-pelan saja. Di sini kamu boleh jujur.';
  static const String settingsTooltip = 'Pengaturan';
  static const String homeMoodTitle = 'Gimana perasaanmu hari ini?';
  static const String homeMoodCancel = 'Batal';
  static const String homeMoodSaving = 'Mencatat perasaanmu...';
  static String homeMoodDone(String label) => 'Hari ini kamu merasa $label';
  static const String homeMoodChange = 'Ubah';
  static const String homeInviteTitle = 'Mau cerita sedikit?';
  static const String homeInviteBubble = 'Hari ini terasa seperti apa?';
  static const String homeInviteBubbleLow =
      'Aku di sini. Mau cerita pelan-pelan?';
  static const String homeInviteChat = 'Cerita ke RelaxMate';
  static const String homeInviteCompanion = 'Temani saja';
  static const String homeChartTitle = 'Naik turun perasaanmu';
  static const String homeChartSeeAll = 'Lihat riwayat';
  static const String homeChartEmpty =
      'Catat perasaanmu hari ini. Grafiknya muncul setelah 2 hari tercatat.';
  static const String homeChartOneDay =
      'Baru satu hari tercatat. Satu hari lagi, garisnya mulai muncul.';
  static const String homeChatTitle = 'Ngobrol dengan RelaxMate yuk';
  static const String homeChatSubtitle = 'Ceritakan apa saja, tanpa dihakimi.';
  static const String homeBreathingTitle = 'Latihan napas';
  static const String homeBreathingSubtitle = 'Tenang dalam beberapa menit';
  static const String homeCompanionTitle = 'Temani saja';
  static const String homeCompanionSubtitle = 'Tanpa harus bicara';

  static const String homeWeekTitle = 'Perasaanmu seminggu ini';
  static String homeWeekFilled(int filled, int total) =>
      '$filled dari $total hari terisi';
  static const String homeWeekEmpty =
      'Isi mood 2 hari dulu, ringkasannya muncul di sini.';
  static const String homeWeekAction = 'Lihat detail';

  static const String homeChartAverageLead = 'Rata-rata: ';
  static const String homeChartBestLead = '. Hari terbaik: ';

  static const String moodTitle = 'Mood Tracker';
  static const String moodBackTooltip = 'Kembali ke Beranda';
  static const String moodIntro =
      'Lihat bagaimana perasaanmu bergerak dari hari ke hari.';
  static const String moodRange7 = '7 hari';
  static const String moodRange30 = '30 hari';
  static const String moodAverage = 'Rata-rata';
  static const String moodBest = 'Terbaik';
  static const String moodFilled = 'Diisi';
  static String moodFilledValue(int filled, int total) => '$filled dari $total';

  // Isi mood langsung dari halaman ini bila hari ini belum diisi.
  static const String moodLogTitle = 'Gimana perasaanmu hari ini?';
  static const String moodLogHint = 'Pilih satu, nanti polanya ikut terlihat.';

  // Gelembung blob: ukuran sebanding jumlah hari tiap mood.
  static const String moodCloudTitle = 'Paling sering kamu rasakan';
  static String moodCloudTop1(String label) => 'Paling sering terasa $label.';
  static String moodCloudTop2(String first, String second) =>
      'Paling sering terasa $first dan $second.';
  static const String moodCloudMixed =
      'Perasaanmu cukup beragam, dan itu wajar.';
  static String moodLegendItem(String label, int days) => '$label · $days hari';
  static String moodCloudSemantics(String items) =>
      'Perasaan yang paling sering kamu rasakan: $items.';

  // Kartu refleksi: kalimat netral dari pola, tanpa menyimpulkan kondisi.
  static const String moodReflectionTitle = 'Catatan kecil untukmu';
  static const String moodInsightNotEnough =
      'Isi beberapa hari lagi, nanti polanya mulai terlihat.';
  static const String moodInsightLighter =
      'Beberapa hari terakhir terasa lebih ringan dari sebelumnya. '
      'Senang melihatnya.';
  static const String moodInsightHeavier =
      'Beberapa hari terakhir terasa lebih berat. Mau cerita sebentar?';
  static const String moodInsightSteady =
      'Perasaanmu relatif stabil belakangan ini.';
  static const String moodReflectionAction = 'Ceritakan ke RelaxMate';

  static const String moodTrendTitle = 'Naik turun perasaanmu';
  static const String moodTrendCaption =
      'Garis putus-putus menandai rata-rata. Hari tanpa catatan dilewati.';
  static const String moodCalendarTitle = 'Kalender perasaanmu';
  static const String moodCalendarCaption =
      'Warna lingkaran sesuai mood hari itu. Lingkaran kosong berarti belum '
      'diisi.';

  static const String moodHistoryTitle = 'Riwayat terakhir';
  static const String moodDisclaimer =
      'Ini gambaran perasaanmu, bukan diagnosis.';
  static const String moodEmptyTitle = 'Belum ada catatan';
  static const String moodEmptyBody =
      'Isi mood pertamamu di atas. Setelah 2 hari, polanya mulai terlihat.';
  static const String moodNoEntry = 'belum diisi';

  static String moodChartSemantics(int total, int filled) =>
      'Grafik suasana hati $total hari terakhir. $filled dari $total hari diisi.';
  static String moodChartDaySemantics(String day, String label) =>
      '$day: $label.';
  static String moodNoteDateTime(String day, String time) => '$day, $time';
}
