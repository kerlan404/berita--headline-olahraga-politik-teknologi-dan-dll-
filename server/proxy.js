/**
 * REEDSFEED — CORS Proxy Server
 * ──────────────────────────────────────────
 * Mengatasi CORS block NewsAPI.org di Flutter Web.
 * 
 * Cara pakai:
 *   1. Pastikan Node.js terinstall (https://nodejs.org)
 *   2. Buka terminal di folder project
 *   3. Jalankan: node server/proxy.js
 *   4. Buka REEDSFEED di Chrome → data real dari NewsAPI!
 *
 * Zero external dependencies — cuma pake built-in Node.js modules.
 */

const http = require('http');
const https = require('https');

const PORT = process.env.PORT || 4000;
const API_BASE = 'https://newsapi.org';
const API_PATH = '/v2';

const server = http.createServer((req, res) => {
  // ── CORS Headers ──
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Access-Control-Max-Age', '86400');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // ── Forward to NewsAPI ──
  const apiUrl = `${API_BASE}${API_PATH}${req.url}`;

  console.log(`[${new Date().toLocaleTimeString()}] ➜ ${req.url}`);

  https.get(apiUrl, (apiRes) => {
    let data = '';
    apiRes.on('data', (chunk) => { data += chunk; });
    apiRes.on('end', () => {
      res.writeHead(apiRes.statusCode, {
        'Content-Type': 'application/json',
      });
      res.end(data);

      if (apiRes.statusCode === 200) {
        try {
          const parsed = JSON.parse(data);
          const totalResults = parsed.totalResults ?? '?';
          console.log(`  ✓ ${apiRes.statusCode} | ${totalResults} articles`);
        } catch {
          console.log(`  ✓ ${apiRes.statusCode} | response OK`);
        }
      } else {
        console.log(`  ✗ ${apiRes.statusCode} | ${data.slice(0, 100)}`);
      }
    });
  }).on('error', (err) => {
    console.error(`  ✗ ERROR: ${err.message}`);
    res.writeHead(502, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'error',
      message: `Proxy error: ${err.message}`,
    }));
  });
});

server.listen(PORT, () => {
  console.log('');
  console.log('╔══════════════════════════════════════════════╗');
  console.log('║     🌐 REEDSFEED CORS Proxy Server         ║');
  console.log('╠══════════════════════════════════════════════╣');
  console.log(`║  Local:   http://localhost:${PORT}              ║`);
  console.log(`║  Proxy →  ${API_BASE}${API_PATH}  ║`);
  console.log('╠══════════════════════════════════════════════╣');
  console.log('║  Tekan Ctrl+C untuk berhenti               ║');
  console.log('╚══════════════════════════════════════════════╝');
  console.log('');
});
