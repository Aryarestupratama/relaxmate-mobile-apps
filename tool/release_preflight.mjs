#!/usr/bin/env node
// Preflight build rilis (TASK-M043, RULE-M048). Pemeriksaan statis sebelum `flutter build`;
// tidak membangun aplikasi. Dijalankan dari akar proyek:
//
//   node tool/release_preflight.mjs                       # sebelum build
//   node tool/release_preflight.mjs --artifact <berkas>   # sesudah build: periksa tanda tangan .aab/.apk
//
// Keluar dengan kode 1 bila ada yang GAGAL. Audit privasi (`tool/privacy_audit.mjs`) ikut dijalankan.
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { isAbsolute, relative, resolve } from 'node:path';

const results = [];
const add = (status, name, detail = '') => results.push({ status, name, detail });
const check = (name, ok, detail = '') => add(ok ? 'LOLOS' : 'GAGAL', name, ok ? '' : detail);
const read = (p) => (existsSync(p) ? readFileSync(p, 'utf8') : '');
const run = (cmd, args) => spawnSync(cmd, args, { encoding: 'utf8' });

const args = process.argv.slice(2);
const artifactAt = args.indexOf('--artifact');
const artifact = artifactAt >= 0 ? args[artifactAt + 1] : null;
const root = process.cwd();

// 1. Audit privasi statis.
const audit = run(process.execPath, ['tool/privacy_audit.mjs']);
check('audit privasi (tool/privacy_audit.mjs) lolos semua', audit.status === 0, (audit.stdout || audit.stderr || '').trim().split('\n').slice(-3).join(' | '));

// 2. Kunci tanda tangan: ada, lengkap, di luar repo, tidak dilacak git.
const kpPath = 'android/key.properties';
const kp = {};
for (const line of read(kpPath).split('\n')) {
  const m = line.match(/^\s*([A-Za-z]+)\s*=\s*(.*?)\s*$/);
  if (m) kp[m[1]] = m[2];
}
check('android/key.properties ada', existsSync(kpPath), 'buat berkas ini (lihat docs/Deploy-Checklist.md); tanpa itu build rilis memakai kunci debug');
const keys = ['storeFile', 'storePassword', 'keyAlias', 'keyPassword'];
const missing = keys.filter((k) => !kp[k]);
check('key.properties berisi storeFile, storePassword, keyAlias, keyPassword', existsSync(kpPath) && missing.length === 0, `kurang: ${missing.join(', ')}`);
if (kp.storeFile) {
  const store = resolve(root, 'android/app', kp.storeFile);
  check('berkas keystore ada', existsSync(store), 'storeFile tidak menunjuk berkas yang ada');
  const rel = relative(root, store);
  check('keystore berada di luar folder proyek', rel.startsWith('..') || isAbsolute(rel), 'pindahkan keystore keluar dari repo');
  check('storeFile berupa path mutlak', isAbsolute(kp.storeFile), 'pakai path mutlak agar tidak bergantung folder kerja');
}
const git = run('git', ['ls-files', '--', 'android/key.properties', '*.jks', '*.keystore']);
check('key.properties dan keystore tidak dilacak git', git.status !== 0 || git.stdout.trim() === '', `dilacak: ${git.stdout.trim()}`);
const ignore = `${read('.gitignore')}\n${read('android/.gitignore')}`;
check('.gitignore mengecualikan key.properties dan *.jks', /key\.properties/.test(ignore) && /\*\.jks/.test(ignore));

// 3. Konfigurasi Gradle rilis.
const gradle = read('android/app/build.gradle.kts').replace(/\/\/.*$/gm, '');
const release = (gradle.match(/release\s*\{[\s\S]*?\n {8}\}/) || [''])[0];
check('release: isDebuggable = false', /isDebuggable\s*=\s*false/.test(release));
check('release: R8 aktif (isMinifyEnabled = true)', /isMinifyEnabled\s*=\s*true/.test(release));
check('release: isShrinkResources = true', /isShrinkResources\s*=\s*true/.test(release));
check('release: memakai signingConfig "release" bila key.properties ada', /getByName\("release"\)/.test(release));
check('proguard-rules.pro ada', existsSync('android/app/proguard-rules.pro'));
check('applicationId bukan bawaan Flutter (com.example)', !/applicationId\s*=\s*"com\.example/.test(gradle));

// 4. Kontak bantuan bawaan (RULE-M048).
let contacts = null;
try {
  contacts = JSON.parse(read('assets/crisis/crisis_contacts.json'));
} catch {
  contacts = null;
}
const list = Array.isArray(contacts?.contacts) ? contacts.contacts : [];
check('kontak bawaan terbaca dan tidak kosong', list.length > 0, 'assets/crisis/crisis_contacts.json');
check('kontak bawaan: tiap entri punya nama dan nomor', list.every((c) => c.name && c.phone));
check('kontak bawaan: tanpa entri dummy', list.every((c) => c.dummy !== true), 'ganti kontak dummy dengan kontak terverifikasi');

// 5. Versi (informasi).
const pub = read('pubspec.yaml').match(/^version:\s*(\S+)/m);
add('INFO', 'versi di pubspec.yaml', pub ? pub[1] : 'tidak terbaca');

// 6. Opsional: tanda tangan artefak hasil build.
if (artifact) {
  check('artefak ada', existsSync(artifact), artifact);
  if (existsSync(artifact)) {
    const js = run('jarsigner', ['-verify', '-verbose', '-certs', artifact]);
    if (js.error) {
      add('LEWAT', 'tanda tangan artefak', 'jarsigner tidak ditemukan; pakai folder bin JDK Android Studio');
    } else {
      const out = `${js.stdout}\n${js.stderr}`;
      check('artefak bertanda tangan', /jar verified|sm\s/.test(out), out.split('\n').slice(-3).join(' | '));
      check('artefak TIDAK bertanda tangan kunci debug', !/Android Debug/i.test(out), 'build memakai kunci debug; cek key.properties');
    }
  }
}

let failed = 0;
for (const r of results) {
  if (r.status === 'GAGAL') failed += 1;
  console.log(`${r.status.padEnd(5)}  ${r.name}${r.detail ? `  -> ${r.detail}` : ''}`);
}
const ok = results.filter((r) => r.status === 'LOLOS').length;
console.log(`\n${ok} lolos, ${failed} gagal dari ${results.filter((r) => r.status !== 'INFO').length} pemeriksaan.`);
process.exit(failed > 0 ? 1 : 0);
