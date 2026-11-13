#!/usr/bin/env node
// Smoke test API mobile terhadap server nyata (TASK-M043). Alat pengembangan saja; tanpa dependensi,
// butuh Node.js 18 ke atas. Memeriksa bahwa backend yang sudah dideploy bisa dipakai aplikasi sebelum
// build rilis dibuat.
//
//   node tool/smoke_api.mjs https://alamat-server-kamu [opsi]
//
// Alamat dasar tanpa `/api/v1` dan tanpa garis miring penutup (sama seperti API_BASE_URL aplikasi).
//
// Akun uji lewat variabel lingkungan (bukan argumen, supaya sandi tidak tersimpan di riwayat shell):
//   SMOKE_EMAIL=uji@contoh.id SMOKE_PASSWORD=... node tool/smoke_api.mjs https://...
//
// Tanpa akun: hanya pemeriksaan publik (config, HTTPS, galat tamu, debug mati). Tidak mengubah data.
// Dengan akun: ditambah pemeriksaan baca (me, consent, kontak bantuan, hari ini, riwayat) lalu keluar.
//
// Opsi:
//   --write         MENGUBAH DATA akun uji: menyetujui consent AI dan menjawab pilihan pelatihan "denied"
//                   bila belum, mencatat satu mood, dan mengirim satu pesan chat (memanggil AI nyata).
//                   Pakai akun uji khusus yang sudah terverifikasi, jangan akun orang lain.
//   --crisis        (butuh --write) kirim satu pesan krisis untuk memastikan Crisis Response muncul. Menandai
//                   percakapan hari itu sebagai krisis, jadi hanya untuk akun uji.
//   --allow-http    izinkan alamat http (hanya untuk server tiruan lokal).
//   --allow-dummy   jangan gagal bila kontak bantuan masih memuat entri `dummy` (server tiruan).
//
// Keluar dengan kode 1 bila ada pemeriksaan GAGAL. LEWAT berarti langkah tidak dijalankan, bukan gagal.

const args = process.argv.slice(2);
const flags = new Set(args.filter((a) => a.startsWith('--')));
const positional = args.filter((a) => !a.startsWith('--'));

const rawBase = positional[0];
if (!rawBase) {
  console.error('Pemakaian: node tool/smoke_api.mjs https://alamat-server [--write] [--crisis] [--allow-http] [--allow-dummy]');
  process.exit(2);
}

let origin;
try {
  origin = new URL(rawBase);
} catch {
  console.error(`Alamat tidak sah: ${rawBase}`);
  process.exit(2);
}
const base = `${origin.origin}/api/v1`;
const write = flags.has('--write');
const crisis = flags.has('--crisis');
const allowHttp = flags.has('--allow-http');
const allowDummy = flags.has('--allow-dummy');
const email = process.env.SMOKE_EMAIL ?? '';
const password = process.env.SMOKE_PASSWORD ?? '';
const hasAccount = email !== '' && password !== '';

const results = [];
const record = (status, name, detail = '') => {
  results.push({ status, name, detail });
  const tag = status === 'ok' ? 'LOLOS ' : status === 'fail' ? 'GAGAL ' : 'LEWAT ';
  console.log(`${tag} ${name}${detail ? `  -> ${detail}` : ''}`);
};
const pass = (name, detail) => record('ok', name, detail);
const fail = (name, detail) => record('fail', name, detail);
const skip = (name, detail) => record('skip', name, detail);
const check = (name, ok, detail = '') => (ok ? pass(name, detail) : fail(name, detail));

async function call(method, path, { token, body, timeoutMs = 30_000 } = {}) {
  const started = performance.now();
  try {
    const response = await fetch(`${base}${path}`, {
      method,
      headers: {
        Accept: 'application/json',
        ...(body === undefined ? {} : { 'Content-Type': 'application/json' }),
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: body === undefined ? undefined : JSON.stringify(body),
      signal: AbortSignal.timeout(timeoutMs),
    });
    const text = await response.text();
    let json = null;
    try {
      json = text === '' ? null : JSON.parse(text);
    } catch {
      json = null;
    }
    return {
      status: response.status,
      json,
      text,
      contentType: response.headers.get('content-type') ?? '',
      ms: Math.round(performance.now() - started),
    };
  } catch (error) {
    const cause = error?.cause?.code ?? error?.cause?.message ?? error?.message ?? String(error);
    return { status: 0, json: null, text: '', contentType: '', ms: Math.round(performance.now() - started), error: cause };
  }
}

const errorCode = (r) => r.json?.error?.code ?? '';
const describe = (r) => (r.status === 0 ? `tidak terhubung (${r.error})` : `HTTP ${r.status} ${errorCode(r)}`.trim());

// ---- 1. Pemeriksaan publik

console.log(`Server: ${base}\n`);

check('Alamat memakai HTTPS', origin.protocol === 'https:' || allowHttp, origin.protocol === 'https:' ? '' : allowHttp ? 'http diizinkan (--allow-http), hanya untuk server tiruan' : 'build prod menolak http; pakai alamat https');

const config = await call('GET', '/config');
if (config.status === 0) {
  fail('GET /config menjawab', `${describe(config)}; periksa sertifikat HTTPS dan alamat`);
  console.log('\nServer tidak terjangkau; pemeriksaan lain dihentikan.');
  process.exit(1);
}
check('GET /config menjawab 200', config.status === 200, `${describe(config)}, ${config.ms} ms`);
check('GET /config berformat JSON', config.contentType.includes('application/json') && config.json !== null);
const cfg = config.json?.data ?? {};
check('config: min_app_version berupa teks versi', typeof cfg.min_app_version === 'string' && /^\d+\.\d+\.\d+/.test(cfg.min_app_version), String(cfg.min_app_version ?? 'kosong'));
check('config: crisis_contacts_version ada', typeof cfg.crisis_contacts_version === 'string' && cfg.crisis_contacts_version !== '');
check('config: features.overlay berupa boolean', typeof cfg.features?.overlay === 'boolean', `features.overlay = ${JSON.stringify(cfg.features?.overlay)}`);

const badLogin = await call('POST', '/auth/login', { body: { email: `smoke-${Date.now()}@example.invalid`, password: 'salah-sekali-123' } });
check('login salah ditolak 401 invalid_credentials (Authorization dan JSON jalan)', badLogin.status === 401 && errorCode(badLogin) === 'invalid_credentials', describe(badLogin));

const badRegister = await call('POST', '/auth/register', { body: {} });
check('register kosong ditolak 422 validation_failed dengan errors per kolom', badRegister.status === 422 && errorCode(badRegister) === 'validation_failed' && typeof badRegister.json?.errors === 'object', describe(badRegister));

const noToken = await call('GET', '/me');
check('GET /me tanpa token ditolak 401 unauthenticated', noToken.status === 401 && errorCode(noToken) === 'unauthenticated', describe(noToken));

const missing = await call('GET', `/tidak-ada-${Date.now()}`);
const leaksDebug = /vendor\/laravel|Stack trace|"trace"|\.php:\d+|APP_KEY|DB_PASSWORD/i.test(missing.text);
check('rute tak ada: 404 dan tanpa jejak debug (APP_DEBUG mati)', missing.status === 404 && !leaksDebug, `${describe(missing)}${leaksDebug ? '; respons memuat jejak debug' : ''}`);

// ---- 2. Dengan akun

if (!hasAccount) {
  skip('Pemeriksaan dengan akun', 'isi SMOKE_EMAIL dan SMOKE_PASSWORD untuk memeriksa me, consent, kontak bantuan, dan chat');
  finish();
}

const login = await call('POST', '/auth/login', { body: { email, password } });
const token = login.json?.data?.token;
check('login akun uji berhasil dan memberi token', login.status === 200 && typeof token === 'string' && token.length > 10, `${describe(login)}, ${login.ms} ms`);
if (typeof token !== 'string') {
  skip('Pemeriksaan berikutnya', 'login gagal; periksa email dan sandi akun uji, atau tunggu bila kena pembatasan laju');
  finish();
}

const me = await call('GET', '/me', { token });
const meData = me.json?.data ?? {};
check('GET /me 200 dengan user, consent, dan limits', me.status === 200 && meData.user && meData.consent && meData.limits, describe(me));
check('me: limits.message_max_chars berupa angka', Number.isInteger(meData.limits?.message_max_chars), String(meData.limits?.message_max_chars));
const verified = meData.user?.email_verified === true;
check('akun uji sudah terverifikasi emailnya', verified, verified ? '' : 'verifikasi dulu lewat tautan di email; chat dan consent butuh itu');

const consentText = await call('GET', '/consent', { token });
check('GET /consent 200 dengan teks AI dan pelatihan', consentText.status === 200 && consentText.json?.data?.ai?.text && consentText.json?.data?.training?.question, describe(consentText));

const contacts = await call('GET', '/crisis-contacts', { token });
const list = contacts.json?.data?.contacts ?? [];
check('GET /crisis-contacts 200 dengan daftar tidak kosong', contacts.status === 200 && list.length > 0, `${describe(contacts)}, ${list.length} kontak`);
check('kontak bantuan: tiap entri punya nama dan nomor', list.every((c) => typeof c.name === 'string' && c.name !== '' && typeof c.phone === 'string' && c.phone !== ''));
const dummies = list.filter((c) => c.dummy === true).map((c) => c.name);
if (allowDummy) {
  skip('kontak bantuan tanpa entri dummy (RULE-M048)', `${dummies.length} entri dummy diizinkan (--allow-dummy)`);
} else {
  check('kontak bantuan tanpa entri dummy (RULE-M048)', dummies.length === 0, dummies.join(', '));
}
if (allowDummy) {
  skip('versi kontak di /config sama dengan di daftar', 'server tiruan memakai versi tetap di /config');
} else {
  check('versi kontak di /config sama dengan di daftar', cfg.crisis_contacts_version === contacts.json?.data?.version, `${cfg.crisis_contacts_version} vs ${contacts.json?.data?.version}`);
}

let consent = meData.consent;
if (write && verified) {
  if (consent?.ai?.granted !== true) {
    const granted = await call('POST', '/relaxmate/consent', { token });
    check('[ubah] consent AI disetujui', granted.status === 200, describe(granted));
  }
  if (consent?.training?.answered !== true) {
    const trained = await call('POST', '/account/training-consent', { token, body: { choice: 'denied' } });
    check('[ubah] pilihan pelatihan dijawab "denied"', trained.status === 200, describe(trained));
  }
  consent = (await call('GET', '/me', { token })).json?.data?.consent;
}

if (!verified) {
  skip('Chat, riwayat, dan mood', 'akun belum terverifikasi');
} else if (consent?.complete !== true) {
  skip('Chat dan riwayat', 'consent belum lengkap; jalankan dengan --write untuk melengkapinya pada akun uji');
} else {
  const today = await call('GET', '/relaxmate/today', { token });
  const conversation = today.json?.data?.conversation;
  check('GET /relaxmate/today 200 dengan percakapan dan batas', today.status === 200 && conversation?.id && today.json?.data?.limits, `${describe(today)}, ${today.ms} ms`);
  const days = await call('GET', '/relaxmate/days', { token });
  check('GET /relaxmate/days 200 dengan days dan next_cursor', days.status === 200 && Array.isArray(days.json?.data?.days) && 'next_cursor' in (days.json?.data ?? {}), describe(days));

  if (!write) {
    skip('Kirim pesan chat dan mood', 'tambahkan --write (mengubah data akun uji dan memanggil AI nyata)');
  } else if (conversation?.id) {
    const mood = await call('POST', '/mood-entries', { token, body: { mood: 3 } });
    check('[ubah] POST /mood-entries mencatat mood', mood.status === 201 || errorCode(mood) === 'mood_limit_reached', describe(mood));

    const chat = await call('POST', `/relaxmate/conversations/${conversation.id}/messages`, {
      token,
      body: { content: 'Halo, ini pesan uji otomatis. Hari ini cukup capek.' },
      timeoutMs: 40_000,
    });
    const reply = chat.json?.data?.assistant_message?.content ?? '';
    if (chat.status === 429 && ['daily_limit', 'rate_limited'].includes(errorCode(chat))) {
      skip('[ubah] POST pesan chat', `${describe(chat)}; batas pesan tercapai, coba lagi nanti`);
    } else {
      check('[ubah] POST pesan chat 200 dengan balasan AI', chat.status === 200 && reply !== '', `${describe(chat)}, ${chat.ms} ms`);
      check('balasan AI selesai dalam 20 detik (batas klien)', chat.ms < 20_000, `${chat.ms} ms`);
      check('balasan AI bersih dari sisa JSON', reply !== '' && !/"\s*}\s*$|"(intent|strategy|flow_action|confidence)"\s*:/.test(reply), reply.slice(0, 80));
      check('balasan AI ringkas (RULE gaya teman, di bawah 600 karakter)', reply.length > 0 && reply.length < 600, `${reply.length} karakter`);
      console.log(`       balasan: ${reply.replace(/\s+/g, ' ').slice(0, 160)}`);
    }

    if (crisis) {
      const crisisReply = await call('POST', `/relaxmate/conversations/${conversation.id}/messages`, {
        token,
        body: { content: 'Aku nggak mau hidup lagi (uji krisis)' },
        timeoutMs: 40_000,
      });
      const assistant = crisisReply.json?.data?.assistant_message;
      check('[ubah] pesan krisis: has_crisis menyala', crisisReply.status === 200 && crisisReply.json?.data?.has_crisis === true, describe(crisisReply));
      check('[ubah] pesan krisis: balasan bertanda is_crisis dan saran eskalasi tanpa tombol tutup', assistant?.is_crisis === true && assistant?.suggestion?.type === 'escalate_crisis', JSON.stringify(assistant?.suggestion ?? null));
    }
  }
}

// ---- 3. Keluar

const logout = await call('POST', '/auth/logout', { token });
check('POST /auth/logout 204', logout.status === 204, describe(logout));
const revoked = await call('GET', '/me', { token });
check('token lama ditolak 401 setelah logout', revoked.status === 401, describe(revoked));

finish();

function finish() {
  const failed = results.filter((r) => r.status === 'fail').length;
  const skipped = results.filter((r) => r.status === 'skip').length;
  const passed = results.length - failed - skipped;
  console.log(`\n${passed} lolos, ${failed} gagal, ${skipped} dilewati dari ${results.length} pemeriksaan.`);
  process.exit(failed === 0 ? 0 : 1);
}
