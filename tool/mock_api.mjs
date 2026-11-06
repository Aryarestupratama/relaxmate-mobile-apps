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
// Mode auth (melayani /config, /auth/*, dan /me dengan data di memori; hilang saat berhenti):
//   auth          akun contoh (semua sandi: Password123):
//                   verified@example.test    sudah terverifikasi
//                   unverified@example.test  belum terverifikasi
//                   inactive@example.test    login ditolak 403 account_inactive
//                 Pembantu pengembangan (buka di peramban atau curl, bukan bagian API):
//                   GET /__verify?email=...  tandai email terverifikasi (pengganti klik tautan email)
//                   GET /__expire            cabut semua token (uji 401 "sesi berakhir")
//                   GET /__reset             kembalikan data awal
//                 Halaman /ketentuan dan /privasi disajikan sebagai teks tiruan.
//                 Batas tiruan: daftar 5/menit, login gagal 5/menit per email, kirim ulang 3/jam.
//
// Log hanya memuat metode, path, status, dan versi aplikasi (tidak ada token, email, atau isi pesan).
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

function resetData() {
  users = new Map();
  tokens = new Map();
  hits = new Map();
  const seed = [
    ['Akun Terverifikasi', 'verified@example.test', true, true],
    ['Akun Belum Verifikasi', 'unverified@example.test', false, true],
    ['Akun Nonaktif', 'inactive@example.test', true, false],
  ];
  for (const [name, email, verified, active] of seed) {
    users.set(email, { name, email, password: EXAMPLE_PASSWORD, verified, active, resends: [] });
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
    const user = { name, email, password, verified: false, active: true, resends: [] };
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

  if (method === 'GET' && path === '/api/v1/me') {
    const user = authedUser(req, res);
    if (!user) return undefined;
    return send(res, 200, {
      data: {
        user: userSummary(user),
        consent: { complete: false },
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
  if (url.pathname === '/__reset') {
    resetData();
    sendText(res, 200, 'Data dikembalikan ke awal.');
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
