#!/usr/bin/env node
// Audit privasi perangkat (TASK-M040, RULE-M040, RULE-M048). Pemeriksaan statis atas kode
// dan manifest; tidak membangun aplikasi. Dijalankan dari akar proyek:
//
//   node tool/privacy_audit.mjs
//
// Keluar dengan kode 1 bila ada pemeriksaan gagal. Dipakai ulang sebagai bagian preflight
// rilis (TASK-M043). Pemeriksaan pada APK hasil build (manifest akhir) ada di docs/progress.md.
import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { join } from 'node:path';

const results = [];
const check = (name, ok, detail = '') => results.push({ name, ok, detail });

// Berkas yang hilang dibaca sebagai teks kosong sehingga pemeriksaannya gagal, bukan crash.
const read = (p) => (existsSync(p) ? readFileSync(p, 'utf8') : '');
const walk = (dir, ext) => {
  if (!existsSync(dir)) return [];
  return readdirSync(dir).flatMap((n) => {
    const p = join(dir, n);
    return statSync(p).isDirectory() ? walk(p, ext) : p.endsWith(ext) ? [p] : [];
  });
};
const stripXmlComments = (s) => s.replace(/<!--[\s\S]*?-->/g, '');
const stripCodeComments = (s) => s.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '');

const dartFiles = walk('lib', '.dart');
const ktFiles = walk('android/app/src/main/kotlin', '.kt');

// 1. Tanpa log di Dart dan Kotlin.
const dartLog = /\b(print|debugPrint|debugPrintStack|dumpErrorToConsole)\s*\(|dart:developer|LogInterceptor/;
const dartHits = dartFiles.filter(
  (f) => f !== 'lib/bootstrap.dart' && dartLog.test(stripCodeComments(read(f))),
);
check('Dart tanpa print, debugPrint, dart:developer, LogInterceptor', dartHits.length === 0, dartHits.join(', '));
const bootstrap = stripCodeComments(read('lib/bootstrap.dart'));
check(
  'bootstrap membisukan log pada build rilis',
  /kReleaseMode/.test(bootstrap) && /debugPrint\s*=/.test(bootstrap) && /FlutterError\.onError\s*=/.test(bootstrap),
);
const ktHits = ktFiles.filter((f) => /\bLog\.[a-z]\(|println\(|Timber/.test(stripCodeComments(read(f))));
check('Kotlin tanpa Log, println, Timber', ktHits.length === 0, ktHits.join(', '));

// 2. Manifest utama.
const main = stripXmlComments(read('android/app/src/main/AndroidManifest.xml'));
check('allowBackup="false"', /android:allowBackup="false"/.test(main));
check('dataExtractionRules terpasang', /android:dataExtractionRules="@xml\/data_extraction_rules"/.test(main));
check('manifest utama tanpa usesCleartextTraffic', !/usesCleartextTraffic/.test(main));
check('tidak ada networkSecurityConfig yang melonggarkan', !/networkSecurityConfig/.test(main));
check('tidak ada android:debuggable di manifest', !/android:debuggable/.test(main));

const allowed = new Set([
  'INTERNET',
  'SYSTEM_ALERT_WINDOW',
  'POST_NOTIFICATIONS',
  'FOREGROUND_SERVICE',
  'FOREGROUND_SERVICE_SPECIAL_USE',
]);
const perms = [...main.matchAll(/<uses-permission[^>]*android:name="android\.permission\.([A-Z_]+)"/g)].map((m) => m[1]);
const extra = perms.filter((p) => !allowed.has(p));
check('izin hanya yang diperlukan (tanpa mikrofon, kamera, lokasi, kontak, penyimpanan)', extra.length === 0, extra.join(', '));
check('tanpa layanan aksesibilitas', !/BIND_ACCESSIBILITY_SERVICE|AccessibilityService/.test(main));

// 3. Cleartext hanya di flavor dev.
const cleartextIn = (p) => existsSync(p) && /usesCleartextTraffic="true"/.test(stripXmlComments(read(p)));
check('cleartext hanya di src/dev', cleartextIn('android/app/src/dev/AndroidManifest.xml'));
check(
  'debug, profile, dan prod tanpa cleartext',
  !cleartextIn('android/app/src/debug/AndroidManifest.xml') &&
    !cleartextIn('android/app/src/profile/AndroidManifest.xml') &&
    !cleartextIn('android/app/src/prod/AndroidManifest.xml'),
);
const config = read('lib/core/config/app_config.dart');
check('AppConfig menolak URL http untuk prod', /flavor\.isProd && uri\.scheme != 'https'/.test(config));

// 4. Aturan ekstraksi data (cadangan awan dan pindah perangkat).
const rules = stripXmlComments(read('android/app/src/main/res/xml/data_extraction_rules.xml'));
const domains = ['root', 'file', 'database', 'sharedpref', 'external'];
const sectionOk = (tag) => {
  const m = rules.match(new RegExp(`<${tag}>([\\s\\S]*?)</${tag}>`));
  return !!m && domains.every((d) => m[1].includes(`domain="${d}" path="."`));
};
check('data_extraction_rules mengecualikan semua domain (awan dan pindah perangkat)', sectionOk('cloud-backup') && sectionOk('device-transfer'));

// 5. Tanpa SDK analitik, pelaporan crash, atau penyimpanan berkas dan basis data.
const pubspec = read('pubspec.yaml').split(/^dev_dependencies:/m)[0];
const denied = /(firebase|sentry|crashlytics|analytics|amplitude|mixpanel|appsflyer|adjust_sdk|facebook|segment|bugsnag|datadog|path_provider|sqflite|drift|hive|isar|objectbox)/i;
const deps = pubspec.split('\n').filter((l) => /^\s{2}[a-z_0-9]+:/.test(l) && denied.test(l));
check('pubspec tanpa SDK analitik, crash, atau penyimpanan berkas dan basis data', deps.length === 0, deps.join(', '));
const fileIo = dartFiles.filter((f) => /\bFile\(|writeAsString|writeAsBytes|getApplicationDocuments|getTemporaryDirectory/.test(stripCodeComments(read(f))));
check('lib tanpa penulisan berkas', fileIo.length === 0, fileIo.join(', '));

// 6. Kunci shared_preferences hanya yang tercatat (tidak sensitif).
const constants = read('lib/core/config/app_constants.dart');
const keys = [...constants.matchAll(/static const String \w*Key\s*=\s*'([^']+)'/g)].map((m) => m[1]);
const okKey = /^(crisis_contacts_v1|settings_[a-z_]+_v1|overlay_[a-z_]+_v1|auth_token)$/;
const badKeys = keys.filter((k) => !okKey.test(k));
check('kunci penyimpanan hanya yang tercatat', keys.length > 0 && badKeys.length === 0, badKeys.join(', '));

// 7. Kolom input.
const chatBar = read('lib/features/chat/ui/chat_input_bar.dart');
check('kolom chat mematikan pembelajaran keyboard', /enableIMEPersonalizedLearning:\s*false/.test(chatBar));
const pw = read('lib/features/auth/ui/password_field.dart');
check('kolom sandi: obscure, tanpa autocorrect dan saran', /obscureText/.test(pw) && /autocorrect:\s*false/.test(pw) && /enableSuggestions:\s*false/.test(pw));

// 8. Overlay: tanpa jaringan dan tanpa mikrofon; notifikasi tersembunyi di layar kunci.
const overlayKt = walk('android/app/src/main/kotlin/id/my/relaxboss/relaxmate/overlay', '.kt').map(read).join('\n');
check('overlay tanpa kode jaringan', !/HttpURLConnection|java\.net\.|okhttp|URL\(/.test(overlayKt));
check('overlay tanpa mikrofon, kamera, atau AccessibilityService', !/AudioRecord|MediaRecorder|CameraManager|AccessibilityService/.test(overlayKt));
check('notifikasi layanan tersembunyi di layar kunci', /VISIBILITY_SECRET/.test(overlayKt));

// 9. Aset kontak bantuan tidak memuat kontak dummy.
const contacts = read('assets/crisis/crisis_contacts.json');
check('aset kontak bantuan tanpa kontak dummy', !/"dummy"\s*:\s*true/.test(contacts));

let failed = 0;
for (const r of results) {
  if (!r.ok) failed += 1;
  console.log(`${r.ok ? 'LOLOS ' : 'GAGAL '} ${r.name}${r.ok || !r.detail ? '' : `  -> ${r.detail}`}`);
}
console.log(`\n${results.length - failed} dari ${results.length} pemeriksaan lolos.`);
process.exit(failed === 0 ? 0 : 1);
