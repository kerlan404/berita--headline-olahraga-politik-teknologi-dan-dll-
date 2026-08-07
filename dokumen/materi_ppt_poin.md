# 📊 MATERI PPT — REEDSFEED (Versi Poin-Poin)

> Dibuat untuk presentasi PowerPoint. Format: poin-poin (tanpa tabel).
> Diverifikasi langsung dari kode (`lib/`) dan dokumentasi proyek (`dokumen/`).

---

## 🎯 SLIDE 1 — JUDUL

- **REEDSFEED**
- Aplikasi Berita & Headline Multiplatform Berbasis Flutter
- Proyek Pengembangan Aplikasi Multiplatform
- Kelas XII RPL 2
- Tahun Ajaran 2025/2026

---

## 📛 SLIDE 2 — NAMA PROJEK

- **REEDSFEED** (ReedFeed — News & Headline Aggregator)
- Nama Aplikasi: REEDSFEED
- Platform: Multiplatform (Android, iOS, Web, Windows, macOS, Linux)
- Framework: Flutter / Dart
- Versi: 1.0.0+1
- Status: ✅ Selesai & Siap Presentasi

**Visi Proyek:**
- Membangun aplikasi berita real-time
- Pengalaman pengguna premium seperti ESPN App
- Cepat, visual menarik, mudah digunakan
- Berjalan di semua platform dari satu codebase

---

## 👨‍💻 SLIDE 3 — KELOMPOK & IDENTITAS

**Struktur Tim:**
- **Manajer Proyek** — Mochammad Rezy Alfarabi
  - Tanggung jawab: koordinasi, dokumentasi, presentasi
- **Developer** — Ahmad Fahmi
  - Tanggung jawab: pengembangan fitur, testing

**Identitas Kelompok:**
- Kelas: XII RPL 2 (Rekayasa Perangkat Lunak)
- Sekolah: SMK
- GitHub: github.com/kerlan404/berita--headline-olahraga-politik-teknologi-dan-dll-

---

## ⭐ SLIDE 4 — FITUR-FITUR APLIKASI (37+ Fitur)

**Fitur Utama:**
- 📰 **Berita Real-Time** — data dari NewsAPI.org
- 🏷️ **7 Kategori** — Semua, Olahraga, Teknologi, Bisnis, Hiburan, Kesehatan, Politik
- 🔍 **Pencarian Cepat** — debounce 500ms + riwayat pencarian
- 🔖 **Bookmark** — persisten di SQLite, swipe-to-delete + undo
- 🤖 **Analisis AI** — "REEDFEED Editor" (ringkasan, judul saran, poin kunci 5W+1H)
- 🌗 **Dark/Light Mode** — toggle tema + persist
- 📱 **Multiplatform** — 6 platform dari satu codebase
- 💾 **Offline Support** — cache 30 menit + fallback mock data

**Fitur UI/UX:**
- 🎨 Dark theme khas ESPN dengan aksen merah
- ✨ Animasi halus (staggered, parallax, transitions)
- 🔄 Infinite scroll
- 📊 Grid/List toggle
- 🚨 Breaking News banner auto-scroll
- 💫 Shimmer loading (skeleton)
- ⬆️ Scroll-to-top FAB
- 🖼️ Article Preview screen

**Fitur Teknis:**
- 🗄️ SQLite database (cache + bookmark)
- 🌐 CORS Proxy Node.js untuk akses API dari web
- 🔄 Auto-refresh setiap 6 jam
- 📤 Share artikel ke aplikasi lain
- ⚠️ Error handling yang graceful
- 🎭 Mock data engine (data dummy saat API gagal)
- 🔒 API key aman lewat file `.env`

---

## 🔄 SLIDE 5 — FLOWCHART FITUR UTAMA

**Alur Navigasi Aplikasi:**
- Splash Screen (logo RF + loading bar)
- Home Screen:
  - Category bar (7 kategori)
  - Breaking News banner
  - News list (Hero card + news cards)
  - Infinite scroll
- Percabangan ke 3 layar:
  - Search Mode (pencarian real-time)
  - Detail Screen (WebView + analisis AI)
  - Bookmark Screen (artikel tersimpan)

**Alur Data (network-first strategy):**
- User action (tap kategori / search / scroll)
- Provider (NewsListProvider / SearchProvider)
- Repository (network-first)
- NewsAPI.org (sukses) → cache ke SQLite
- Gagal → fallback ke cache SQLite / mock data
- Update state (notifyListeners)
- Rebuild UI

**Alur Bookmark:**
- Tap tombol bookmark
- BookmarkProvider.toggleBookmark()
- Jika belum di-bookmark → simpan ke SQLite
- Jika sudah → hapus dari SQLite
- Update badge counter di bottom nav

---

## 🎨 SLIDE 6 — DESAIN ANTARMUKA (UI/UX)

**Design System: "Gridiron Pulse" — terinspirasi ESPN App**

**Prinsip Desain:**
- Dark theme dominan (background #121212)
- Aksen warna berani (merah #CC0000)
- Tipografi tebal (Anton untuk headline)
- Card berbasis gambar dengan thumbnail dominan
- Navigasi horizontal (tab kategori scroll)
- Informasi padat (waktu, sumber, kategori jelas)

**Palet Warna:**
- Background utama: #121212
- Surface/Card: #1E1E1E
- Primary accent: #CC0000
- Teks utama: #FFFFFF
- Teks sekunder: #B3B3B3
- Divider/Border: #2C2C2C

**Typography:**
- Display: Anton 64px (hero text)
- Headline: Anton 24–40px (judul berita)
- Body: Inter 16–18px (deskripsi)
- Label: Archivo Narrow 12–14px (kategori, waktu)

**Animasi & Transitions:**
- Page transition 350ms (easeOutCubic)
- Tab switch 300ms
- Staggered list 400ms per item
- Parallax hero real-time
- Shimmer loading 1.5s

**Layar yang Ada:**
- Splash (glow + logo RF)
- Home (hero parallax + breaking news)
- Article Preview
- Detail (WebView + panel AI)
- Bookmark
- Profile (stats + theme toggle)

---

## 🛠️ SLIDE 7 — TEKNOLOGI YANG DIGUNAKAN

**Framework & Bahasa:**
- Flutter — framework UI cross-platform
- Dart — bahasa pemrograman

**Dependencies (14 package):**
- `provider` — state management
- `http` — HTTP client untuk API
- `sqflite` + `sqflite_common_ffi` — database (mobile + desktop)
- `webview_flutter` — baca artikel in-app
- `cached_network_image` — caching gambar
- `shared_preferences` — penyimpanan preferensi
- `share_plus` — share artikel
- `flutter_dotenv` — manajemen API key
- `google_fonts` — custom fonts
- `shimmer` — skeleton loading
- `intl` — format tanggal/waktu
- `url_launcher` — buka link eksternal
- `path` — path manipulation

**External Services:**
- NewsAPI.org — sumber data berita real-time
- OpenAI API — analisis artikel dengan AI
- SQLite — database lokal (cache & bookmark)
- Node.js — CORS Proxy Server (zero-dependency)

**Arsitektur Aplikasi:**
- Layered architecture: Screen → Provider → Repository → Service → Model
- 29 file Dart, ±4.500 baris kode
- Conditional import untuk database multi-platform

---

## 📸 SLIDE 8 — SCREENSHOT HASIL

> ⚠️ **Catatan:** Folder `assets/screenshots/` masih kosong — screenshot asli belum diambil. Dokumen PPT baru punya mockup ASCII.

**Layar yang perlu di-screenshot:**
- Splash Screen (logo RF glow + loading bar)
- Home Screen (category bar + breaking news + hero card)
- Search Mode (hasil real-time + riwayat pencarian)
- Article Preview (hero image + deskripsi)
- Detail Screen (WebView + panel analisis AI)
- Bookmark Screen (daftar tersimpan + swipe delete)
- Profile Screen (statistik + theme toggle)

**Cara:**
- Jalankan `flutter run -d chrome` atau di HP Android
- Ambil screenshot tiap layar
- Simpan ke `assets/screenshots/`
- Tempel di slide presentasi

---

## 🐛 SLIDE 9 — BUG & PENANGANAN

**Status: 0 critical, 0 high — semua sudah diperbaiki** ✅

**Bug yang Ditemukan & Diperbaiki:**
- `Colors.grey[850]` null (High) → diganti `AppTheme.surface`
- Race condition pagination (Medium) → token-based request discard
- Provider crash `context.read<>()` (High) → MultiProvider pindah ke main.dart
- TweenSequence error (Medium) → hapus CurvedAnimation
- API key invalid (Medium) → auto-fallback ke mock data
- WebView error (Medium) → error page + retry + browser fallback
- SQLite crash di Web (Medium) → markUnavailable()
- Gradle JVM OOM (Medium) → kurangi ukuran heap
- Path Unicode gagal build (Low) → copy ke path ASCII
- API key bocor di git history (High) → filter-branch + force push

**Kualitas Kode:**
- `dart analyze`: 0 error, 0 warning
- 29 file Dart
- 14 dependencies
- ±4.500 baris kode

**Known Issues (belum kritis, masih terbuka):**
- Belum ada unit test
- HomeScreen ±850 baris — perlu refactor
- iOS belum diuji di perangkat fisik
- Web butuh CORS proxy aktif

---

## ✅ SLIDE 10 — KESIMPULAN

**Pencapaian:**
- ✅ 37+ fitur (melebihi target PRD)
- ✅ 6 platform didukung (Android, iOS, Web, Windows, macOS, Linux)
- ✅ Design system "Gridiron Pulse" terinspirasi ESPN
- ✅ Performance: infinite scroll, shimmer, parallax
- ✅ Offline: cache SQLite 30 menit + bookmark persisten
- ✅ AI integration: OpenAI + local fallback
- ✅ Error handling graceful di semua skenario
- ✅ Code quality: 0 error, 0 warning

**Teknologi Utama:**
- Framework: Flutter / Dart
- State management: Provider
- Database: SQLite (sqflite)
- API: NewsAPI.org + OpenAI API
- Design: custom dark theme ESPN-inspired

**Manfaat bagi Pengguna:**
- Akses berita cepat dari 7 kategori
- Pengalaman membaca nyaman dengan dark theme
- Bisa dipakai di semua perangkat
- Baca offline dengan cache otomatis
- Pahami berita cepat dengan analisis AI

**Manfaat bagi Pengembang:**
- Penguasaan Flutter cross-platform
- Arsitektur berlapis (Clean Architecture)
- Integrasi API & database
- Error handling & testing
- Portofolio lengkap

**Statistik Akhir:**
- Total file Dart: 29
- Dependencies: 14 package
- Total fitur: 37+
- Platform: 6
- Kategori berita: 7
- Bug critical: 0
- Code quality: 0 error
- Status: **SIAP DEMO**

**Penutup:**
> "REEDFEED bukan sekadar aplikasi berita — ini demonstrasi kemampuan Flutter dalam membangun aplikasi production-ready yang indah, cepat, dan cross-platform."

**Terima Kasih**
- GitHub: github.com/kerlan404/berita--headline-olahraga-politik-teknologi-dan-dll-
- Kelas XII RPL 2
- Tahun 2025/2026
