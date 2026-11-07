// Server tiruan untuk uji manual aplikasi tanpa backend (TASK-M021, diperluas di TASK-M022).
// Alat pengembangan saja; tidak ikut aplikasi. Tanpa dependensi, butuh Node.js.
//
//   node tool/mock_api.mjs <mode> [port]
//
// Mode cek versi (hanya melayani GET /api/v1/config):
//   ok            versi minimum 0.0.1 -> aplikasi lanjut
//   old           versi minimum 9.0.0 -> layar "Perbarui aplikasi"
//   slow          menjawab setelah 10 detik -> pemeriksaan habis waktu, aplikasi lanjut
//   error         503 dengan amplop galat -> aplikasi lanjut
//   unauthorized  401 tanpa amplop -> aplikasi lanjut
//
// Mode auth (melayani /config, /auth/*, /me, dan /consent dengan data di memori; hilang saat berhenti):
//   auth          akun contoh (semua sandi: Password123):
//                   verified@example.test    sudah terverifikasi
//                   unverified@example.test  belum terverifikasi
//                   inactive@example.test    login ditolak 403 account_inactive
//                 Pembantu pengembangan (buka di peramban atau curl, bukan bagian API):
//                   GET /__verify?email=...  tandai email terverifikasi (pengganti klik tautan email)
//                   GET /__expire            cabut semua token (uji 401 "sesi berakhir")
//                   GET /__reset             kembalikan data awal
//                   GET /__bump-ai?email=... consent AI wajib disetujui lagi (meniru kenaikan versi)
//                   GET /__bump-training?email=...  pilihan pelatihan wajib dijawab lagi
//                   GET /__fail-training     POST persetujuan pelatihan berikutnya dijawab 503 sekali
//                   GET /__fail-consent      GET /consent berikutnya dijawab 503 sekali
//                 Consent (API-M008 sampai M010): akun baru dan akun contoh belum menyetujui apa pun.
//                 Teks consent disalin dari config/relaxboss.php di repo web (hanya untuk uji).
//                 Chat (API-M012, M013): satu percakapan per akun, balasan tiruan berupa gema, 20 pesan/hari.
//                   GET /__fail-ai           POST pesan berikutnya: pesan tersimpan, lalu 503 ai_unavailable (sekali)
//                   GET /__slow-ai           POST pesan berikutnya dijawab setelah 25 detik (meniru timeout klien, sekali)
//                   GET /__close-day         POST pesan berikutnya: 409 conversation_closed, percakapan baru (sekali)
//                   GET /__set-sent?email=...&n=19  atur jumlah pesan terkirim hari ini (uji batas harian)
//                 Saran (TASK-M026): pesan berisi "saran profesional", "saran dukungan", atau "saran baru" dibalas
//                 dengan saran tindakan (recommend_professional, recommend_support, jenis tak dikenal).
//                 Krisis (TASK-M025): pesan berisi "uji krisis" dibalas Crisis Response tetap (is_crisis true)
//                 dan percakapan bertanda has_crisis. GET /crisis-contacts (API-M011) memuat satu kontak asli
//                 dan satu kontak bertanda dummy (tidak boleh tampil di build prod).
//                   GET /__contacts-v2       ganti isi daftar kontak (versi baru) untuk uji penyegaran cache
//                   GET /__contacts-v1       kembalikan daftar awal
//                 Riwayat (TASK-M027, API-M015 dan M016): GET /relaxmate/days (15 per halaman, kursor) dan
//                 GET /relaxmate/conversations/{id}/messages (30 per halaman, kursor). Percakapan hari ini
//                 ikut muncul di riwayat bila sudah berisi pesan, seperti server asli.
//                   GET /__seed-history?email=...&n=40  buat n hari lampau (tiap 4 hari berisi 40 pesan untuk uji
//                                            halaman pesan; tiap 5 hari berisi balasan krisis; tiap 6 hari ada
//                                            dua percakapan di hari yang sama)
//                   GET /__fail-history      GET riwayat (days atau messages) berikutnya dijawab 503 (sekali)
//                 Halaman /ketentuan dan /privasi disajikan sebagai teks tiruan.
//                 Batas tiruan: daftar 5/menit, login gagal 5/menit per email, kirim ulang 3/jam.
//
// Log hanya memuat metode, path, status, dan versi aplikasi (tidak ada token, email, atau isi pesan).
import { createHash, randomUUID } from 'node:crypto';
import http from 'node:http';

const mode = process.argv[2] ?? 'ok';
const port = Number(process.argv[3] ?? 8001);

function send(res, status, body, headers = {}) {
  res.writeHead(status, { 'Content-Type': 'application/json', ...headers });
  res.end(body === undefined ? undefined : JSON.stringify(body));
}

function sendHtml(res, html) {
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(html);
}

function sendText(res, status, text) {
  res.writeHead(status, { 'Content-Type': 'text/plain; charset=utf-8' });
  res.end(text);
}

// ---------------------------------------------------------------- mode cek versi

function configOnly(req, res) {
  if (req.url !== '/api/v1/config') {
    return send(res, 404, { error: { code: 'not_found', message: 'Tidak ditemukan.' } });
  }

  switch (mode) {
    case 'old':
      return send(res, 200, { data: { min_app_version: '9.0.0' } });
    case 'slow':
      return setTimeout(() => send(res, 200, { data: { min_app_version: '9.0.0' } }), 10000);
    case 'error':
      return send(res, 503, { error: { code: 'ai_unavailable', message: 'Layanan sedang sibuk.' } });
    case 'unauthorized':
      return send(res, 401, { message: 'Unauthenticated.' });
    default:
      return send(res, 200, { data: { min_app_version: '0.0.1' } });
  }
}

// ---------------------------------------------------------------- mode auth

const PASSWORD_MIN = 8;
const EXAMPLE_PASSWORD = 'Password123';

let users = new Map(); // email -> { name, email, password, verified, active, resends: [timestamp] }
let tokens = new Map(); // token -> email
let tokenSeq = 0;
let hits = new Map(); // kunci -> [timestamp]
let failTrainingOnce = false;
let failConsentOnce = false;
let failAiOnce = false;
let slowAiOnce = false;
let closeDayOnce = false;
let failHistoryOnce = false;
let contactsVariant = 1; // 1 = daftar awal, 2 = daftar berubah (uji penyegaran cache)
let messageSeq = 100;

const CHAT_PER_DAY = 20;
const CHAT_MAX_CHARS = 2000;
const HISTORY_PER_PAGE = 15;
const MESSAGES_PER_PAGE = 30;
const MONTHS = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

function newUser(name, email, password, verified, active) {
  return { name, email, password, verified, active, resends: [], aiGranted: false, trainingChoice: null };
}

function resetData() {
  users = new Map();
  tokens = new Map();
  hits = new Map();
  failTrainingOnce = false;
  failConsentOnce = false;
  failAiOnce = false;
  slowAiOnce = false;
  closeDayOnce = false;
  failHistoryOnce = false;
  contactsVariant = 1;
  const seed = [
    ['Akun Terverifikasi', 'verified@example.test', true, true],
    ['Akun Belum Verifikasi', 'unverified@example.test', false, true],
    ['Akun Nonaktif', 'inactive@example.test', true, false],
  ];
  for (const [name, email, verified, active] of seed) {
    users.set(email, newUser(name, email, EXAMPLE_PASSWORD, verified, active));
  }
}
resetData();

/** Mencatat satu kejadian pada [key]; mengembalikan sisa detik bila melewati [max] dalam [windowMs]. */
function overLimit(key, max, windowMs, { record = true } = {}) {
  const now = Date.now();
  const list = (hits.get(key) ?? []).filter((t) => now - t < windowMs);
  if (list.length >= max) {
    hits.set(key, list);
    return Math.max(1, Math.ceil((list[0] + windowMs - now) / 1000));
  }
  if (record) {
    list.push(now);
  }
  hits.set(key, list);
  return 0;
}

function readJson(req) {
  return new Promise((resolve) => {
    const chunks = [];
    req.on('data', (c) => chunks.push(c));
    req.on('end', () => {
      try {
        const text = Buffer.concat(chunks).toString('utf8');
        resolve(text ? JSON.parse(text) : {});
      } catch {
        resolve({});
      }
    });
  });
}

function apiError(res, status, code, message, headers = {}, extra = {}) {
  return send(res, status, { error: { code, message }, ...extra }, headers);
}

function rateLimited(res, seconds, prefix) {
  return apiError(res, 429, 'rate_limited', `${prefix} Coba lagi dalam ${seconds} detik.`, {
    'Retry-After': String(seconds),
  });
}

function validation(res, errors) {
  const first = Object.values(errors)[0][0];
  return apiError(res, 422, 'validation_failed', first, {}, { errors });
}

function userSummary(user) {
  return { name: user.name, email: user.email, email_verified: user.verified };
}

const CONSENT_TEXTS = {
  ai: {
    title: 'Sebelum bercerita ke RelaxMate',
    text:
      'RelaxMate adalah teman bicara berbasis AI, bukan psikolog atau layanan medis. Pesanmu dan jurusanmu (bila kamu isi) dikirim ke penyedia AI pihak ketiga untuk dibalas, tanpa nama, email, atau kampusmu. Pengelola RelaxBoss dapat meninjau isi percakapan tanpa identitasmu untuk menjaga kualitas dan keselamatan. Jangan bagikan data yang sangat pribadi seperti alamat atau nomor identitas. Dengan melanjutkan, kamu menyetujui hal ini.',
    version: 1,
  },
  training: {
    question: 'Bolehkah percakapan dan hasil asesmenmu dipakai untuk melatih model AI di masa depan?',
    text:
      'Datanya diekspor tanpa nama, email, jurusan, dan kampus, dan termasuk percakapan yang menyentuh topik sensitif seperti menyakiti diri. Pilihanmu tidak memengaruhi akses ke fitur apa pun dan bisa kamu ubah kapan saja di pengaturan akun. Data yang sudah diekspor tidak bisa ditarik kembali.',
    version: 1,
  },
};

function consentState(user) {
  const answered = user.trainingChoice === 'granted' || user.trainingChoice === 'denied';
  return {
    ai: { granted: user.aiGranted, accepted_version: user.aiGranted ? 1 : null, required_version: 1 },
    training: {
      choice: user.trainingChoice,
      answered,
      accepted_version: answered ? 1 : null,
      required_version: 1,
    },
    complete: user.aiGranted && answered,
  };
}

function chatOf(user) {
  if (!user.chat) {
    user.chat = { id: randomUUID(), messages: [], sent: 0, hasCrisis: false, createdAt: new Date() };
  }
  return user.chat;
}

function chatMessage(role, content, isCrisis = false, suggestion = null, at = new Date()) {
  messageSeq += 1;
  return {
    id: messageSeq,
    role,
    content,
    time: `${String((at.getUTCHours() + 7) % 24).padStart(2, '0')}.${String(at.getUTCMinutes()).padStart(2, '0')} WIB`,
    is_crisis: isCrisis,
    suggestion,
    created_at: at.toISOString(),
  };
}

// ---- Riwayat (TASK-M027)

const pad2 = (n) => String(n).padStart(2, '0');

/** Kunci hari percakapan: WIB dikurangi jam batas 04.00 (sama dengan DailyConversationResolver). */
function dayKeyOf(date) {
  return new Date(date.getTime() + 3 * 3600 * 1000).toISOString().slice(0, 10);
}

/** "6 November 2026, 14.30 WIB" (sama dengan ChatPresenter::dateLabel di web). */
function dateLabelOf(date) {
  const wib = new Date(date.getTime() + 7 * 3600 * 1000);
  return `${wib.getUTCDate()} ${MONTHS[wib.getUTCMonth()]} ${wib.getUTCFullYear()}, ${pad2(wib.getUTCHours())}.${pad2(wib.getUTCMinutes())} WIB`;
}

function encodeCursor(offset) {
  return Buffer.from(JSON.stringify({ o: offset })).toString('base64url');
}

function decodeCursor(value) {
  if (!value) return 0;
  try {
    const offset = JSON.parse(Buffer.from(value, 'base64url').toString('utf8')).o;
    return Number.isInteger(offset) && offset >= 0 ? offset : 0;
  } catch {
    return 0;
  }
}

/** Percakapan yang sudah berisi pesan, terbaru dulu (hari ini ikut bila sudah berisi). */
function historyOf(user) {
  const all = [...(user.pastChats ?? [])];
  if (user.chat && user.chat.messages.length > 0) {
    all.push(user.chat);
  }
  return all.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
}

function seedHistory(user, n) {
  user.pastChats = [];
  for (let i = 1; i <= n; i += 1) {
    const start = new Date(Date.now() - i * 24 * 3600 * 1000);
    start.setUTCHours(3, 30, 0, 0); // 10.30 WIB
    const sessions = i % 6 === 0 ? 2 : 1;
    for (let k = 0; k < sessions; k += 1) {
      const at = new Date(start.getTime() + k * 8 * 3600 * 1000);
      const turns = i % 4 === 0 ? 20 : 1 + (i % 3);
      const crisis = i % 5 === 0 && k === 0;
      const messages = [];
      for (let t = 0; t < turns; t += 1) {
        const when = new Date(at.getTime() + t * 60 * 1000);
        messages.push(chatMessage('user', `Cerita ke-${t + 1} dari hari lampau ${i}${sessions > 1 ? ` (sesi ${k + 1})` : ''}`, false, null, when));
        const lastOfCrisis = crisis && t === turns - 1;
        messages.push(chatMessage('assistant', lastOfCrisis ? CRISIS_TEXT : `Aku mendengarmu (balasan ${t + 1}).`, lastOfCrisis, lastOfCrisis ? { type: 'escalate_crisis', priority: 1, dismissible: false } : null, new Date(when.getTime() + 20 * 1000)));
      }
      user.pastChats.push({ id: randomUUID(), messages, sent: turns, hasCrisis: crisis, createdAt: at });
    }
  }
}

// Sama dengan App\\Support\\CrisisResponse::TEXT di repo web (teks tetap, bukan keluaran AI).
const CRISIS_TEXT = 'Aku mendengarmu, dan aku senang kamu mau bercerita. Kamu tidak harus menghadapi ini sendirian. Kalau kamu berpikir untuk menyakiti dirimu sendiri, tolong hubungi bantuan sekarang atau minta seseorang yang kamu percaya menemanimu.';

// Saran tindakan tiruan (TASK-M026): kata pemicu di pesan pengguna.
//   "saran profesional" -> recommend_professional (prioritas 2, bisa ditutup)
//   "saran dukungan"    -> recommend_support (prioritas 3, bisa ditutup)
//   "saran baru"        -> jenis tak dikenal (harus diabaikan klien)
function suggestionFor(content) {
  const text = content.toLowerCase();
  if (text.includes('saran profesional')) return { type: 'recommend_professional', priority: 2, dismissible: true };
  if (text.includes('saran dukungan')) return { type: 'recommend_support', priority: 3, dismissible: true };
  if (text.includes('saran baru')) return { type: 'jenis_baru_dari_server', priority: 2, dismissible: true };
  return null;
}

function crisisContacts() {
  const contacts = [
    { name: 'Healing119.id (Kementerian Kesehatan)', phone: '119 ext 8', url: 'https://www.healing119.id', note: 'Layanan konseling gratis, 24 jam.', dummy: false },
    { name: 'Kontak Contoh (dummy)', phone: '021 0000 0000', url: null, note: 'Hanya untuk uji. Tidak boleh tampil di build prod.', dummy: true },
  ];
  if (contactsVariant === 2) {
    contacts.push({ name: 'Layanan Baru Contoh', phone: '+62 812 3456 789', url: 'https://example.test/bantuan', note: 'Muncul setelah daftar berubah.', dummy: false });
  }
  const version = createHash('sha1').update(JSON.stringify(contacts)).digest('hex').slice(0, 12);
  return { version, contacts };
}

function chatLimits(chat) {
  return {
    message_max_chars: CHAT_MAX_CHARS,
    per_day: CHAT_PER_DAY,
    remaining_today: Math.max(0, CHAT_PER_DAY - chat.sent),
  };
}

// Pengguna harus terverifikasi dan consent lengkap, seperti middleware api.verified dan ai.consent.
function chatUser(req, res) {
  const user = authedUser(req, res);
  if (!user) return undefined;
  if (!user.verified) {
    apiError(res, 403, 'unverified', 'Verifikasi emailmu dulu, ya. Cek kotak masukmu.');
    return undefined;
  }
  if (!consentState(user).complete) {
    apiError(res, 403, 'consent_required', 'Setujui dulu persetujuan terbaru untuk lanjut bercerita.');
    return undefined;
  }
  return user;
}

function issueToken(user) {
  for (const [token, email] of tokens) {
    if (email === user.email) {
      tokens.delete(token); // satu token per perangkat (ADR-M10)
    }
  }
  const token = `mock-token-${++tokenSeq}`;
  tokens.set(token, user.email);
  return {
    token,
    token_type: 'Bearer',
    expires_at: new Date(Date.now() + 60 * 24 * 3600 * 1000).toISOString(),
    user: userSummary(user),
  };
}

function authedUser(req, res) {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : '';
  const email = tokens.get(token);
  const user = email ? users.get(email) : undefined;
  if (!user) {
    apiError(res, 401, 'unauthenticated', 'Sesimu sudah berakhir. Silakan masuk lagi.');
    return undefined;
  }
  return user;
}

const EMAIL_SHAPE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

async function authApi(req, res, path) {
  const method = req.method;

  if (method === 'GET' && path === '/api/v1/config') {
    return send(res, 200, {
      data: { min_app_version: '0.0.1', crisis_contacts_version: 'mock00000000', features: { overlay: true } },
    });
  }

  if (method === 'POST' && path === '/api/v1/auth/register') {
    const wait = overLimit('register', 5, 60_000);
    if (wait > 0) {
      return rateLimited(res, wait, 'Terlalu banyak percobaan.');
    }
    const body = await readJson(req);
    const name = typeof body.name === 'string' ? body.name.trim() : '';
    const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
    const password = typeof body.password === 'string' ? body.password : '';
    const errors = {};
    if (!name) errors.name = ['Nama wajib diisi.'];
    else if (name.length > 100) errors.name = ['Nama maksimal 100 karakter.'];
    if (!email) errors.email = ['Email wajib diisi.'];
    else if (!EMAIL_SHAPE.test(email)) errors.email = ['Format email belum benar.'];
    else if (users.has(email)) errors.email = ['Email ini sudah terdaftar. Coba masuk, atau pakai email lain.'];
    if (!password) errors.password = ['Kata sandi wajib diisi.'];
    else if (password.length < PASSWORD_MIN) errors.password = [`Kata sandi minimal ${PASSWORD_MIN} karakter.`];
    if (body.terms !== true) errors.terms = ['Centang dulu bahwa kamu sudah membaca ketentuan.'];
    if (Object.keys(errors).length > 0) {
      return validation(res, errors);
    }
    const user = newUser(name, email, password, false, true);
    users.set(email, user);
    return send(res, 201, { data: { ...issueToken(user), email_sent: true } });
  }

  if (method === 'POST' && path === '/api/v1/auth/login') {
    const body = await readJson(req);
    const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
    const password = typeof body.password === 'string' ? body.password : '';
    const errors = {};
    if (!email) errors.email = ['Email wajib diisi.'];
    else if (!EMAIL_SHAPE.test(email)) errors.email = ['Format email belum benar.'];
    if (!password) errors.password = ['Kata sandi wajib diisi.'];
    if (Object.keys(errors).length > 0) {
      return validation(res, errors);
    }
    const key = `login:${email}`;
    const wait = overLimit(key, 5, 60_000, { record: false });
    if (wait > 0) {
      return rateLimited(res, wait, 'Terlalu banyak percobaan masuk.');
    }
    const user = users.get(email);
    if (!user || user.password !== password) {
      overLimit(key, 5, 60_000);
      return apiError(res, 401, 'invalid_credentials', 'Email atau kata sandi tidak cocok.');
    }
    hits.delete(key);
    if (!user.active) {
      return apiError(res, 403, 'account_inactive', 'Akunmu sedang dinonaktifkan. Hubungi kami bila menurutmu ini keliru.');
    }
    return send(res, 200, { data: issueToken(user) });
  }

  if (method === 'POST' && path === '/api/v1/auth/forgot-password') {
    const body = await readJson(req);
    const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
    if (!email) {
      return validation(res, { email: ['Email wajib diisi.'] });
    }
    if (!EMAIL_SHAPE.test(email)) {
      return validation(res, { email: ['Format email belum benar.'] });
    }
    return send(res, 200, {
      data: {
        message:
          'Jika email itu terdaftar, tautan untuk mengatur ulang kata sandi sudah dikirim. Cek kotak masukmu, ya.',
      },
    });
  }

  if (method === 'POST' && path === '/api/v1/auth/logout') {
    const user = authedUser(req, res);
    if (!user) return undefined;
    const header = req.headers.authorization ?? '';
    tokens.delete(header.slice(7));
    res.writeHead(204);
    return res.end();
  }

  if (method === 'POST' && path === '/api/v1/auth/resend-verification') {
    const user = authedUser(req, res);
    if (!user) return undefined;
    if (user.verified) {
      return send(res, 200, { data: { email_verified: true, email_sent: false } });
    }
    const wait = overLimit(`resend:${user.email}`, 3, 3600_000);
    if (wait > 0) {
      return apiError(res, 429, 'rate_limited', 'Kamu sudah meminta terlalu banyak email. Coba lagi nanti.');
    }
    return send(res, 200, { data: { email_verified: false, email_sent: true } });
  }

  if (method === 'GET' && path === '/api/v1/consent') {
    const user = authedUser(req, res);
    if (!user) return undefined;
    if (failConsentOnce) {
      failConsentOnce = false;
      return apiError(res, 503, 'server_error', 'Layanan sedang bermasalah. Coba lagi sebentar lagi.');
    }
    return send(res, 200, { data: { ...CONSENT_TEXTS, state: consentState(user) } });
  }

  if (method === 'POST' && path === '/api/v1/relaxmate/consent') {
    const user = authedUser(req, res);
    if (!user) return undefined;
    if (!user.verified) {
      return apiError(res, 403, 'unverified', 'Verifikasi emailmu dulu, ya. Cek kotak masukmu.');
    }
    user.aiGranted = true;
    return send(res, 200, { data: { consent: consentState(user) } });
  }

  if (method === 'POST' && path === '/api/v1/account/training-consent') {
    const user = authedUser(req, res);
    if (!user) return undefined;
    if (!user.verified) {
      return apiError(res, 403, 'unverified', 'Verifikasi emailmu dulu, ya. Cek kotak masukmu.');
    }
    if (failTrainingOnce) {
      failTrainingOnce = false;
      return apiError(res, 503, 'server_error', 'Layanan sedang bermasalah. Coba lagi sebentar lagi.');
    }
    const body = await readJson(req);
    if (body.choice === undefined || body.choice === null || body.choice === '') {
      return validation(res, { choice: ['Pilih salah satu dulu.'] });
    }
    if (body.choice !== 'granted' && body.choice !== 'denied') {
      return validation(res, { choice: ['Pilihan tidak valid. Coba lagi, ya.'] });
    }
    user.trainingChoice = body.choice;
    return send(res, 200, { data: { consent: consentState(user) } });
  }

  if (method === 'GET' && path === '/api/v1/relaxmate/today') {
    const user = chatUser(req, res);
    if (!user) return undefined;
    const chat = chatOf(user);
    const last = chat.messages[chat.messages.length - 1];
    return send(res, 200, {
      data: {
        conversation: { id: chat.id, has_crisis: chat.hasCrisis, day: new Date().toISOString().slice(0, 10), created_at: new Date().toISOString() },
        messages: chat.messages,
        unanswered: last !== undefined && last.role === 'user',
        limits: chatLimits(chat),
      },
    });
  }

  if (method === 'GET' && path === '/api/v1/relaxmate/days') {
    const user = chatUser(req, res);
    if (!user) return undefined;
    if (failHistoryOnce) {
      failHistoryOnce = false;
      return apiError(res, 503, 'http_error', 'Layanan sedang bermasalah. Coba lagi sebentar lagi.');
    }
    const offset = decodeCursor(new URL(req.url ?? '/', 'http://localhost').searchParams.get('cursor'));
    const all = historyOf(user);
    const page = all.slice(offset, offset + HISTORY_PER_PAGE);
    return send(res, 200, {
      data: {
        days: page.map((c) => ({ id: c.id, day: dayKeyOf(c.createdAt), label: dateLabelOf(c.createdAt), total_turns: Math.floor(c.messages.length / 2), has_crisis: c.hasCrisis })),
        next_cursor: offset + HISTORY_PER_PAGE < all.length ? encodeCursor(offset + HISTORY_PER_PAGE) : null,
      },
    });
  }

  const sendMatch = /^\/api\/v1\/relaxmate\/conversations\/([^/]+)\/messages$/.exec(path);
  if (method === 'GET' && sendMatch) {
    const user = chatUser(req, res);
    if (!user) return undefined;
    if (failHistoryOnce) {
      failHistoryOnce = false;
      return apiError(res, 503, 'http_error', 'Layanan sedang bermasalah. Coba lagi sebentar lagi.');
    }
    const target = historyOf(user).find((c) => c.id === sendMatch[1]);
    if (!target) {
      return apiError(res, 404, 'not_found', 'Yang kamu cari tidak ditemukan.');
    }
    const offset = decodeCursor(new URL(req.url ?? '/', 'http://localhost').searchParams.get('cursor'));
    return send(res, 200, {
      data: {
        conversation: { id: target.id, has_crisis: target.hasCrisis, label: dateLabelOf(target.createdAt) },
        messages: target.messages.slice(offset, offset + MESSAGES_PER_PAGE),
        next_cursor: offset + MESSAGES_PER_PAGE < target.messages.length ? encodeCursor(offset + MESSAGES_PER_PAGE) : null,
      },
    });
  }
  if (method === 'POST' && sendMatch) {
    const user = chatUser(req, res);
    if (!user) return undefined;
    const chat = chatOf(user);
    if (closeDayOnce) {
      closeDayOnce = false;
      user.chat = { id: randomUUID(), messages: [], sent: 0, hasCrisis: false, createdAt: new Date() };
      return apiError(res, 409, 'conversation_closed', 'Percakapan ini sudah berganti hari. Kita mulai yang baru, ya.');
    }
    if (sendMatch[1] !== chat.id) {
      return apiError(res, 404, 'not_found', 'Yang kamu cari tidak ditemukan.');
    }
    const body = await readJson(req);
    let target;

    if (body.retry === true) {
      const last = chat.messages[chat.messages.length - 1];
      if (!last || last.role !== 'user') {
        return apiError(res, 409, 'nothing_to_retry', 'Tidak ada pesan yang perlu dijawab ulang.');
      }
      target = last;
    } else {
      const content = typeof body.content === 'string' ? body.content.trim() : '';
      if (content === '' || content.length > CHAT_MAX_CHARS) {
        return apiError(res, 422, 'invalid_message', `Pesan tidak boleh kosong atau lebih dari ${CHAT_MAX_CHARS} karakter.`);
      }
      if (chat.sent >= CHAT_PER_DAY) {
        return apiError(res, 429, 'daily_limit', 'Batas pesan hari ini sudah tercapai. Kita lanjut lagi besok, ya.');
      }
      chat.sent += 1;
      target = chatMessage('user', content);
      chat.messages.push(target);
    }

    if (failAiOnce) {
      failAiOnce = false;
      return apiError(res, 503, 'ai_unavailable', 'RelaxMate sedang tidak bisa menjawab. Pesanmu aman, coba lagi sebentar lagi.');
    }
    if (slowAiOnce) {
      slowAiOnce = false;
      await new Promise((resolve) => setTimeout(resolve, 25000));
    }
    const crisis = target.content.toLowerCase().includes('uji krisis');
    if (crisis) {
      chat.hasCrisis = true;
    }
    const reply = crisis
      ? chatMessage('assistant', CRISIS_TEXT, true, { type: 'escalate_crisis', priority: 1, dismissible: false })
      : chatMessage('assistant', `Aku mendengarmu. Kamu bilang: "${target.content}"`, false, suggestionFor(target.content));
    chat.messages.push(reply);
    return send(res, 200, {
      data: { user_message: target, assistant_message: reply, has_crisis: chat.hasCrisis, remaining_today: chatLimits(chat).remaining_today },
    });
  }

  if (method === 'GET' && path === '/api/v1/crisis-contacts') {
    const user = authedUser(req, res);
    if (!user) return undefined;
    return send(res, 200, { data: crisisContacts() });
  }

  if (method === 'GET' && path === '/api/v1/me') {
    const user = authedUser(req, res);
    if (!user) return undefined;
    return send(res, 200, {
      data: {
        user: userSummary(user),
        consent: consentState(user),
        limits: { message_max_chars: 1000, chat_per_day: 20, chat_per_minute: 5 },
        crisis_contacts_version: 'mock00000000',
      },
    });
  }

  return apiError(res, 404, 'not_found', 'Yang kamu cari tidak ditemukan.');
}

function devHelpers(req, res, url) {
  if (url.pathname === '/__verify') {
    const email = (url.searchParams.get('email') ?? '').toLowerCase();
    const user = users.get(email);
    if (!user) {
      sendText(res, 404, `Tidak ada akun ${email}`);
      return true;
    }
    user.verified = true;
    sendText(res, 200, `Email ${email} ditandai terverifikasi.`);
    return true;
  }
  if (url.pathname === '/__expire') {
    tokens = new Map();
    sendText(res, 200, 'Semua token dicabut. Permintaan berikutnya dari aplikasi akan 401.');
    return true;
  }
  if (url.pathname === '/__bump-ai' || url.pathname === '/__bump-training') {
    const email = (url.searchParams.get('email') ?? '').toLowerCase();
    const user = users.get(email);
    if (!user) {
      sendText(res, 404, `Tidak ada akun ${email}`);
      return true;
    }
    if (url.pathname === '/__bump-ai') {
      user.aiGranted = false;
    } else {
      user.trainingChoice = null;
    }
    sendText(res, 200, `Consent ${email} diperbarui: ${JSON.stringify(consentState(user))}`);
    return true;
  }
  if (url.pathname === '/__fail-ai' || url.pathname === '/__slow-ai' || url.pathname === '/__close-day') {
    if (url.pathname === '/__fail-ai') failAiOnce = true;
    if (url.pathname === '/__slow-ai') slowAiOnce = true;
    if (url.pathname === '/__close-day') closeDayOnce = true;
    sendText(res, 200, `${url.pathname} aktif untuk permintaan POST pesan berikutnya (sekali).`);
    return true;
  }
  if (url.pathname === '/__set-sent') {
    const email = (url.searchParams.get('email') ?? '').toLowerCase();
    const user = users.get(email);
    if (!user) {
      sendText(res, 404, `Tidak ada akun ${email}`);
      return true;
    }
    chatOf(user).sent = Number(url.searchParams.get('n') ?? 0);
    sendText(res, 200, `Pesan terkirim ${email}: ${chatOf(user).sent}`);
    return true;
  }
  if (url.pathname === '/__seed-history') {
    const email = (url.searchParams.get('email') ?? '').toLowerCase();
    const user = users.get(email);
    if (!user) {
      sendText(res, 404, `Tidak ada akun ${email}`);
      return true;
    }
    const n = Math.min(Math.max(Number(url.searchParams.get('n') ?? 40), 0), 200);
    seedHistory(user, n);
    sendText(res, 200, `Riwayat ${email}: ${n} hari lampau, ${historyOf(user).length} percakapan.`);
    return true;
  }
  if (url.pathname === '/__fail-history') {
    failHistoryOnce = true;
    sendText(res, 200, 'GET riwayat (days atau messages) berikutnya akan dijawab 503 satu kali.');
    return true;
  }
  if (url.pathname === '/__fail-consent') {
    failConsentOnce = true;
    sendText(res, 200, 'GET /consent berikutnya akan dijawab 503 satu kali.');
    return true;
  }
  if (url.pathname === '/__fail-training') {
    failTrainingOnce = true;
    sendText(res, 200, 'POST persetujuan pelatihan berikutnya akan dijawab 503 satu kali.');
    return true;
  }
  if (url.pathname === '/__contacts-v1' || url.pathname === '/__contacts-v2') {
    contactsVariant = url.pathname === '/__contacts-v2' ? 2 : 1;
    sendText(res, 200, `Daftar kontak: varian ${contactsVariant}, versi ${crisisContacts().version}`);
    return true;
  }
  if (url.pathname === '/__reset') {
    resetData();
    sendText(res, 200, 'Data dikembalikan ke awal.');
    return true;
  }
  if (url.pathname === '/konsultasi') {
    sendHtml(res, '<h1>Konsultasi Profesional (halaman tiruan)</h1><p>Halaman asli ada di website RelaxBoss.</p>');
    return true;
  }
  if (url.pathname === '/ketentuan') {
    sendHtml(res, '<h1>Ketentuan (halaman tiruan)</h1><p>Teks asli ada di website RelaxBoss.</p>');
    return true;
  }
  if (url.pathname === '/privasi') {
    sendHtml(res, '<h1>Kebijakan Privasi (halaman tiruan)</h1><p>Teks asli ada di website RelaxBoss.</p>');
    return true;
  }
  return false;
}

// ---------------------------------------------------------------- server

http
  .createServer(async (req, res) => {
    const url = new URL(req.url ?? '/', 'http://localhost');
    res.on('finish', () => {
      console.log(`${req.method} ${url.pathname} -> ${res.statusCode} x-app-version=${req.headers['x-app-version']}`);
    });

    if (mode !== 'auth') {
      return configOnly(req, res);
    }

    if (devHelpers(req, res, url)) {
      return undefined;
    }
    if (url.pathname.startsWith('/api/v1/')) {
      return authApi(req, res, url.pathname);
    }
    return sendText(res, 404, 'Tidak ditemukan.');
  })
  .listen(port, '0.0.0.0', () => console.log(`mock api: mode=${mode} port=${port}`));
