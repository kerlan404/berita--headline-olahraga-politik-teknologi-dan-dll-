PROJECT CHARTER

PEMBUATAN APLIKASI BERITA & HEADLINE MULTIPLATFORM
REEDSFEED BERBASIS FLUTTER

Judul Proyek : Aplikasi Berita & Headline Multiplatform REEDSFEED
              (ReedFeed - SportsNews & Headline Aggregator)
Nomor Proyek : [Isi Nomor Proyek]
Tanggal      : 20 Maret 2024
Projek Sponsor : [Kosongkan]
Manajer Proyek : Mochammad Rezy Alfarabi

---

## 1. Tujuan (Objectives)

### 1.1 Tujuan Umum
Membangun aplikasi berita multiplatform berbasis Flutter yang menyajikan **headline terkini** secara cepat, visual menarik (terinspirasi ESPN), dan mudah digunakan — baik di HP Android, iOS, web (Chrome), maupun desktop.

### 1.2 Tujuan Khusus
1. **Memenuhi Tugas Proyek Sekolah** — Menyelesaikan proyek pengembangan aplikasi multiplatform sebagai bagian dari kurikulum dan penilaian akhir.
2. **Integrasi API Real-time** — Menampilkan berita terbaru dari NewsAPI.org dengan 7 kategori (Semua, Olahraga, Teknologi, Bisnis, Hiburan, Kesehatan, Politik).
3. **Fitur Interaktif Lengkap** — Menyediakan bookmark, pencarian, share artikel, WebView, dark/light theme, dan AI article analysis.
4. **Multiplatform** — Aplikasi berjalan di Android, iOS, Web, Windows, Linux, dan macOS dari satu codebase.
5. **Pengalaman Pengguna Premium** — Dark theme khas ESPN, infinite scroll, hero card, animasi transisi, dan loading shimmer.
6. **Kinerja & Stabilitas** — Error handling graceful, caching offline 30 menit dengan SQLite, dan fallback mock data saat API tidak tersedia.
7. **Portofolio & Presentasi** — Menghasilkan dokumentasi lengkap, laporan akademis terstruktur, dan aplikasi siap demo sebagai portofolio.

---

## 2. Ruang Lingkup (Scope)

### 2.1 In-Scope (Fitur yang Diimplementasikan)

| Fitur | Status | Keterangan |
|-------|--------|------------|
| ✅ Home Screen dengan infinite scroll list | **SELESAI** | List + Grid view, hero card pertama |
| ✅ 7 Kategori berita | **SELESAI** | Semua, Olahraga, Teknologi, Bisnis, Hiburan, Kesehatan, Politik |
| ✅ Detail artikel dengan WebView | **SELESAI** | WebView + ringkasan artikel + info detail |
| ✅ Pencarian berita real-time | **SELESAI** | Debounce 500ms, infinite scroll hasil cari |
| ✅ Bookmark / Simpan artikel | **SELESAI** | Persisten dengan SQLite, swipe hapus |
| ✅ Share artikel | **SELESAI** | Menggunakan share_plus |
| ✅ Breaking News Banner | **SELESAI** | ESPN-style auto-scroll ticker |
| ✅ AI Article Analysis | **SELESAI** | OpenAI API + Local Engine fallback |
| ✅ Dark/Light Theme Toggle | **SELESAI** | Persistent dengan SharedPreferences |
| ✅ Splash Screen animasi | **SELESAI** | Logo + loading bar + fade transition |
| ✅ Ikon aplikasi custom (Kompas) | **SELESAI** | Flutter launcher icons |
| ✅ Cache offline 30 menit | **SELESAI** | SQLite dengan TTL |
| ✅ CORS Proxy Server | **SELESAI** | Node.js zero-dependency proxy untuk web |
| ✅ Halaman Profil | **SELESAI** | Stats, info fitur, theme toggle |
| ✅ Mock data fallback | **SELESAI** | Data dummy untuk 6 kategori |

### 2.2 Out-of-Scope (Tidak Termasuk Versi Saat Ini)
- ❌ Login / Autentikasi pengguna
- ❌ Notifikasi push (FCM)
- ❌ Komentar / Forum diskusi
- ❌ Mode offline penuh (download artikel)
- ❌ Video player / konten multimedia
- ❌ Multiple bahasa (hanya Bahasa Indonesia)
- ❌ Widget Android/iOS homescreen
- ❌ Integrasi media sosial (login with Google, dll)

### 2.3 Platform yang Didukung

| Platform | Dukungan | Catatan |
|----------|----------|---------|
| 📱 Android | ✅ **Full** | Target API 21+, teruji di Infinix X6858 |
| 🍏 iOS | ✅ **Full** | Belum diuji fisik, kompiler OK |
| 🌐 Web (Chrome) | ✅ **Full** | CORS proxy dibutuhkan untuk NewsAPI |
| 💻 Windows | ✅ **Full** | sqflite_common_ffi |
| 🐧 Linux | ✅ **Full** | sqflite_common_ffi |
| 🍎 macOS | ✅ **Full** | sqflite_common_ffi |

---

## 3. Anggota Kelompok (Tim Proyek)

> 📝 **Catatan:** Bagian ini bisa diisi sendiri oleh user.

| Peran | Nama | Tanggung Jawab |
|-------|------|----------------|
| **Manajer Proyek / Dokumentasi** | Mochammad Rezy Alfarabi | Koordinasi, laporan, presentasi, dokumen |
| **UI/UX Developer** | [Isi Nama] | Semua widget & screen, styling, animasi |
| **Data/API Developer** | [Isi Nama] | Service API, model, repository, error handling |
| **Integrasi & QA** | [Isi Nama] | Testing, debugging, deployment |

> *Jika tim hanya 2-3 orang, beberapa peran bisa digabung.*

### Struktur Komunikasi Tim
- **GitHub Repository:** `github.com/kerlan404/berita--headline-olahraga-politik-teknologi-dan-dll-`
- **Branch Strategy:** Setiap anggota punya branch fitur, merge ke `main` setelah review
- **Sinkronisasi:** Minimal seminggu sekali cek progres bersama

---

## 4. Jadwal (Schedule)

### 4.1 Timeline Milestone

| Fase | Deskripsi | Status | Durasi |
|------|-----------|--------|--------|
| 🏗️ **M0: Fondasi** | Dokumen (PRD, Desain, Integrasi, Roadmap) | ✅ **SELESAI** | 1 minggu |
| 📱 **M1: MVP** | Setup Flutter, Home, Kategori, WebView, Search, Ikon | ✅ **SELESAI** | 3 minggu |
| 🔧 **M2: Stabilisasi** | Error handling, caching, testing, bersihkan warning | ✅ **SELESAI** | 2 minggu |
| 🚀 **M3: Fitur Lanjutan** | Bookmark, Theme toggle, AI Analysis, Breaking News, Profil | ✅ **SELESAI** | 3 minggu |
| 🎯 **M4: Finalisasi** | Perbaikan bug (10 problem), git history cleanup, final testing | ✅ **SELESAI** | 1 minggu |
| 📢 **M5: Presentasi** | Persiapan demo, slide, laporan | ⏳ **SEGERA** | 1 minggu |

### 4.2 Detail Per-Milestone

| Fitur | Timeline Mulai | Timeline Selesai | PIC |
|-------|---------------|------------------|-----|
| Setup project & struktur folder | M1-1 | M1-2 | Data/API |
| Home Screen + Kategori | M1-2 | M1-4 | UI/UX |
| Detail Screen + WebView | M1-3 | M1-5 | UI/UX |
| Search + Pagination | M1-4 | M1-6 | Integrasi |
| Ikon Aplikasi | M1-5 | M1-7 | UI/UX |
| Error Handling + Mock Data | M2-1 | M2-3 | Data/API |
| Caching SQLite | M2-2 | M2-4 | Data/API |
| Bookmark | M3-1 | M3-2 | Semua |
| Dark/Light Theme | M3-2 | M3-3 | UI/UX |
| AI Analysis | M3-3 | M3-5 | Data/API |
| Breaking News | M3-4 | M3-5 | UI/UX |
| CORS Proxy | M3-5 | M3-6 | Integrasi |
| Perbaikan 10 Problem | M4-1 | M4-3 | Semua |
| Git History Cleanup | M4-3 | M4-4 | Data/API |
| **Presentasi & Laporan** | **M5-1** | **M5-2** | **Manajer Proyek** |

---

## 5. Biaya (Budget/Cost)

### 5.1 Biaya Development (Non-Operasional)

| Item | Biaya | Keterangan |
|------|-------|------------|
| 💻 Laptop/PC Development | Rp 0 (sudah dimiliki) | - |
| 📱 HP Android Testing | Rp 0 (milik sendiri) | Infinix X6858 |
| 🍏 Mac untuk iOS Build | Rp 0 (milik sendiri / lab sekolah) | - |
| ☕ Internet selama development | Rp 0 (milik sendiri) | - |
| **Total Development** | **Rp 0** | Semua alat sudah ada |

### 5.2 Biaya Layanan (Operasional)

| Layanan | Biaya | Gratis Sampai | Catatan |
|---------|-------|---------------|---------|
| NewsAPI.org | **Gratis** 🆓 | 100 request/hari (development) | Cukup untuk testing & demo |
| GitHub Repository | **Gratis** 🆓 | Publik / unlimited | Untuk source code |
| OpenAI API (AI Analysis) | **Gratis** 🆓 | $5 free credit (akun baru) | Fallback ke local engine jika habis |
| Flutter / Dart SDK | **Gratis** 🆓 | Open source | - |
| Node.js (CORS Proxy) | **Gratis** 🆓 | Open source | Zero dependency |
| **Total Operasional** | **Rp 0** | - | Semua gratis tier |

### 5.3 Estimasi Biaya Jika Naik ke Production

| Item | Estimasi/Bulan | Catatan |
|------|----------------|---------|
| NewsAPI (Developer -> Basic) | $0/mo (gratis) -> $499/mo | Jika butuh >100 req/hari |
| OpenAI API | ~$5-20/bulan | Jika AI Analysis aktif untuk banyak user |
| Hosting / Server (opsional) | ~$5-10/bulan | Untuk deploy web + CORS proxy |
| Domain Kustom | ~$10-15/tahun | opsional |

---

## 6. Risiko (Risks)

### 6.1 Matriks Risiko

| ID | Risiko | Probabilitas | Dampak | Mitigasi |
|----|--------|-------------|--------|----------|
| R1 | **NewsAPI Rate Limit** (100 req/hari) | 🟡 **Sedang** | 🔴 **Tinggi** | Mock data fallback otomatis, caching 30 menit dengan SQLite |
| R2 | **API Key terekspos di GitHub** | 🔴 **Tinggi** | 🔴 **Tinggi** | ✅ **SUDAH DIPERBAIKI** — .env di gitignore, git filter-branch hapus dari history |
| R3 | **OpenAI API Quota Habis** | 🟡 **Sedang** | 🟡 **Sedang** | ✅ Local engine fallback bekerja otomatis tanpa crash |
| R4 | **CORS Block di Web** (NewsAPI) | 🔴 **Tinggi** | 🔴 **Tinggi** | ✅ CORS Proxy Node.js berfungsi, fallback mock data jika proxy mati |
| R5 | **Path Unicode (Jepang) build gagal** | 🟢 **Rendah** | 🟡 **Sedang** | ✅ Copy project ke path ASCII, atau rename folder |
| R6 | **WebView Gagal Load** (artikel berat) | 🟡 **Sedang** | 🟡 **Sedang** | ✅ Error page + Muat Ulang + Buka di Browser eksternal |
| R7 | **SQLite tidak support Web** | 🟡 **Sedang** | 🟡 **Sedang** | ✅ `markUnavailable()` menonaktifkan cache di web, fallback graceful |
| R8 | **Konflik kode tim** (merge Git) | 🟢 **Rendah** | 🟢 **Rendah** | Branch per fitur, komunikasi rutin |
| R9 | **Null safety crash** (Colors.grey[850]) | 🟢 **Rendah** | 🔴 **Tinggi** | ✅ **SUDAH DIPERBAIKI** — diganti dengan AppTheme.surface |
| R10 | **Race condition pagination** | 🟡 **Sedang** | 🟡 **Sedang** | ✅ **SUDAH DIPERBAIKI** — _requestId token-based discard |

### 6.2 Risk Register (Status Saat Ini)

```
🔴 HIGH    : 0 tersisa (semua sudah dimitigasi)
🟡 MEDIUM  : 3 (R1, R3, R4 — sudah ada mitigasi otomatis)
🟢 LOW     : 2 (R5, R8 — prosedural)
✅ CLOSED  : 4 (R2, R9, R10 + R6/R7 sudah dimitigasi)
```

---

## 7. Manfaat (Benefits)

### 7.1 Manfaat bagi Pengguna

| Manfaat | Detail |
|---------|--------|
| 📰 **Akses berita cepat** | Headline dari 7 kategori dalam satu aplikasi, update real-time |
| 🎨 **Pengalaman baca nyaman** | Dark theme khas ESPN, aksen merah elegan, tipografi jelas |
| 📱 **Multiplatform** | Satu aplikasi untuk HP, tablet, laptop, web — dari satu codebase |
| 🔍 **Pencarian powerful** | Temukan berita spesifik dengan search real-time + infinite scroll |
| 💾 **Baca offline** | Cache 30 menit + bookmark persisten — berita tetap bisa dibaca tanpa internet |
| 🤖 **Analisis AI** | REEDFEED Editor meringkas inti berita — pahami konteks dalam 30 detik |
| 🚨 **Breaking News** | Ticker auto-scroll seperti ESPN — tidak ketinggalan berita penting |
| 🌗 **Tema fleksibel** | Dark/Light theme toggle sesuai preferensi dan kondisi cahaya |

### 7.2 Manfaat bagi Pengembang (Tim)

| Manfaat | Detail |
|---------|--------|
| 🎯 **Penguasaan Flutter** | Praktik nyata: widget tree, state management, navigasi, animasi |
| 🏗️ **Arsitektur Bersih** | Layer terpisah: Screen → Provider → Repository → Service → Model |
| 🔌 **Integrasi API** | HTTP client, error handling, caching, CORS, rate limiting |
| 🧪 **Testing & Debugging** | flutter analyze, error handling, logging, fallback strategy |
| 📊 **Git & Kolaborasi** | Branch management, commit, force push, history cleanup |
| 📱 **Multiplatform Deployment** | Android APK, web Chrome, desktop — dari satu codebase |
| 🎓 **Portofolio** | Aplikasi lengkap dengan AI integration, cocok untuk presentasi sekolah |

---

## 8. Key Performance Indicators (KPI)

### 8.1 KPI Teknis

| KPI | Target | Cara Ukur | Status |
|-----|--------|-----------|--------|
| 🚀 **Waktu muat awal** | < 3 detik (data mock) | Stopwatch dari splash ke list muncul | ✅ |
| 📦 **Ukuran APK** | < 50 MB (release) | `flutter build apk --release` | ✅ |
| ⚡ **Infinite scroll** | < 1 detik muat halaman baru | Dari scroll trigger ke data muncul | ✅ |
| 🔄 **Pull-to-refresh** | < 3 detik refresh | Dari tarik ke data baru | ✅ |
| 🐛 **flutter analyze** | 0 error, 0 warning | `dart analyze lib/` | ✅ **(0 error, 0 warning, 6 info)** |
| 🔌 **CORS Proxy response** | < 2 detik | `curl -w %{time_total}` ke proxy | ✅ |
| 📱 **Jalan di HP fisik** | ≥ 1 HP Android | `flutter run` ke Infinix X6858 | ✅ |

### 8.2 KPI Fungsional

| Fitur | KPI | Target | Status |
|-------|-----|--------|--------|
| 🏠 **Home Screen** | Semua kategori muncul, scroll lancar | 7 kategori | ✅ |
| 📰 **Detail Artikel** | WebView load, info panel, AI analysis | Semua komponen tampil | ✅ |
| 🔍 **Search** | Hasil relevan, debounce, infinite scroll | Responsif | ✅ |
| 🔖 **Bookmark** | Save/delete persist, badge counter | Sesuai ekspektasi | ✅ |
| 🌗 **Theme** | Toggle + persistent | Dark default, light opsional | ✅ |
| 🤖 **AI Analysis** | Muncul saat detail, fallback graceful | Ada/tidak ada API key | ✅ |
| 🚨 **Breaking News** | Ticker scroll, dismissible | 3 artikel teratas | ✅ |
| 📱 **Multiplatform** | Jalan di Android + Chrome + Desktop | Semua platform | ✅ |

### 8.3 KPI Non-Teknis

| KPI | Target | Metrik |
|-----|--------|--------|
| 📋 **Dokumentasi** | 6 dokumen lengkap | prd.md, desain.md, integrasi.md, roadmap.md, PROGRES.md, project_charter.md |
| 🎓 **Presentasi** | Demo mulus tanpa crash | Semua fitur utama bisa ditunjukkan dalam 5-10 menit |
| 📊 **Laporan** | Struktur 5 Bab | BAB I-V + lampiran |
| 👥 **Pembagian kerja** | Semua anggota kontribusi | Git commit history menunjukkan partisipasi |

### 8.4 KPI Kualitas Kode

| Metrik | Target | Metode | Status |
|--------|--------|--------|--------|
| Jumlah file Dart | < 35 file | `dir lib/*.dart /s` | ✅ 29 file |
| Baris kode (total) | < 5.000 baris | `cloc lib/` | ✅ ~4.500 baris |
| Dependencies | < 15 packages | `grep -c ^\\s+\\w+: pubspec.yaml` | ✅ 14 packages |
| Test coverage | Minimal ada test | `flutter test` | ⏳ Perlu ditambah |

---

## 9. Arsitektur Aplikasi (Ringkasan)

Untuk referensi cepat saat presentasi, berikut arsitektur aplikasi yang telah diimplementasikan:

```
┌──────────────────────────────────────────────┐
│                 UI LAYER                      │
│  Screens + Widgets + Animations              │
│  (home, detail, bookmark, profile, splash)    │
├──────────────────────────────────────────────┤
│              STATE LAYER                      │
│  Providers (ChangeNotifier + Provider pkg)     │
│  (NewsList, Search, Bookmark, Theme, Activity) │
├──────────────────────────────────────────────┤
│             DATA LAYER                        │
│  Repositories ─── Services ─── Models          │
│  (caching, error handling, mapping)            │
├──────────────────────────────────────────────┤
│          EXTERNAL SERVICES                    │
│  NewsAPI.org │ OpenAI API │ SQLite │ SharedPref  │
│  CORS Proxy (Node.js)                        │
└──────────────────────────────────────────────┘
```

**Teknologi Utama:**
- **Framework:** Flutter SDK ^3.12.2
- **State Management:** Provider ^6.1.2
- **HTTP Client:** http ^1.2.1
- **Database Lokal:** sqflite ^2.4.3
- **Penyimpanan:** shared_preferences ^2.2.3
- **WebView:** webview_flutter ^4.7.0
- **Gambar:** cached_network_image ^3.3.1
- **Animasi:** Shimmer ^3.0.0
- **Analisis AI:** OpenAI API (gpt-4o-mini) + Local Engine fallback
- **CORS Proxy:** Node.js (zero dependency)

---

## 10. Status Proyek Saat Ini

```
📊 PENCAPAIAN: 95% (Fitur inti selesai, dalam tahap finalisasi)

🥇 MILESTONE 0:  ✅ 100% - Dokumen fondasi
🥇 MILESTONE 1:  ✅ 100% - MVP semua fitur dasar
🥇 MILESTONE 2:  ✅ 100% - Stabilisasi & caching
🥇 MILESTONE 3:  ✅ 100% - Fitur lanjutan semua selesai
🥇 MILESTONE 4:  ✅ 100% - Perbaikan bug (10 problem resolved)
⏳ MILESTONE 5:  ⏳  0%  - Persiapan presentasi & laporan

🐛 KNOWN BUGS:   0 critical, 0 high, 0 medium, 0 low (semua resolved)
🔒 SECURITY:     API key removed from git history
📦 DEPLOY:       APK siap build, web siap deploy
```

---

> **Dokumen ini selesai dibuat berdasarkan analisis menyeluruh terhadap:**  
> - 29 file Dart di `lib/`  
> - 6 dokumen proyek di `dokumen/`  
> - 1 server Node.js (CORS proxy)  
> - Git history (10+ commit, branches, force push)  
> - Testing fisik di Infinix X6858 (Android) & Chrome

---

**Pengesahan Dokumen**

Mengetahui, Jakarta, 20 Maret 2024

| | |
|---|------|
| **Projek Sponsor** | **Manajer Proyek** |
| | |
| | |
| **.....................** | **Mochammad Rezy Alfarabi** |
