// Server tiruan untuk uji manual API client sebelum backend /api/v1 ada (TASK-M021).
// Alat pengembangan saja; tidak ikut aplikasi. Tanpa dependensi, butuh Node.js.
//
//   node tool/mock_api.mjs <mode> [port]
//
// Mode (hanya melayani GET /api/v1/config):
//   ok            versi minimum 0.0.1 -> aplikasi lanjut
//   old           versi minimum 9.0.0 -> layar "Perbarui aplikasi"
//   slow          menjawab setelah 10 detik -> pemeriksaan habis waktu, aplikasi lanjut
//   error         503 dengan amplop galat -> aplikasi lanjut
//   unauthorized  401 tanpa amplop -> aplikasi lanjut
//
// Log hanya memuat metode, path, dan versi aplikasi (tidak ada token atau isi pesan).
import http from 'node:http';

const mode = process.argv[2] ?? 'ok';
const port = Number(process.argv[3] ?? 8001);

function send(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

http
  .createServer((req, res) => {
    console.log(`${req.method} ${req.url} x-app-version=${req.headers['x-app-version']}`);

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
  })
  .listen(port, '0.0.0.0', () => console.log(`mock api: mode=${mode} port=${port}`));
