<div align="center">
  <br>
  <img src="assets/icon/app_icon.png" alt="REEDSFEED Logo" width="120" height="120" style="border-radius: 20px;">
  <br>
  <h1>📰 REEDSFEED</h1>
  <p><strong>Berita & Headline Terkini — Multi-Platform</strong></p>
  <p>
    Aplikasi berita multi-platform yang dibangun dengan <strong>Flutter</strong> —
    menyajikan headline terkini dari <strong>7 kategori</strong> dengan <strong>preview artikel</strong>,
    <strong>offline caching</strong>, <strong>animasi premium</strong>, dan <strong>bookmark persisten</strong>.
  </p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.44.6-02569B?style=flat-square&logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-3.12.2-0175C2?style=flat-square&logo=dart" alt="Dart">
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue?style=flat-square" alt="Platform">
    <img src="https://img.shields.io/badge/Storage-sqflite-orange?style=flat-square" alt="sqflite">
    <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
    <img src="https://img.shields.io/badge/Status-Active-success?style=flat-square" alt="Status">
    <img src="https://img.shields.io/badge/Icon-RF%20Logo-red?style=flat-square" alt="RF Icon">
  </p>

  <br>
</div>

---

## 📋 Daftar Isi

- [✨ Fitur Unggulan](#-fitur-unggulan)
- [🆕 Yang Baru](#-yang-baru)
- [📸 Tampilan Aplikasi](#-tampilan-aplikasi)
- [🏗️ Arsitektur Project](#️-arsitektur-project)
- [🛠️ Tech Stack](#️-tech-stack)
- [🚀 Cara Menjalankan](#-cara-menjalankan)
- [📁 Struktur Folder Lengkap](#-struktur-folder-lengkap)
- [📦 Dependencies](#-dependencies)
- [🧭 Alur Navigasi](#-alur-navigasi)
- [📱 Cara Menggunakan](#-cara-menggunakan)
- [🔧 Konfigurasi](#-konfigurasi)
- [🐛 Troubleshooting](#-troubleshooting)
- [🤝 Kontribusi](#-kontribusi)
- [📄 Lisensi](#-lisensi)

---

## ✨ Fitur Unggulan

<table>
  <tr>
    <td width="50%">
      <h3>📰 Preview Artikel</h3>
      <p>Tap berita → lihat <strong>preview informatif</strong> dulu (hero image, title, meta, deskripsi, konten) sebelum decide mau baca full artikel. Tombol <strong>"BACA LENGKAP"</strong> untuk ke WebView.</p>
    </td>
    <td width="50%">
      <h3>🏷️ 7 Kategori Berita</h3>
      <p>Navigasi kategori via <strong>horizontal scroll bar</strong> dengan arrow button di mobile. Ada <strong>7 kategori</strong>: Semua, Olahraga, Teknologi, Bisnis, Hiburan, Kesehatan, dan <strong>Politik</strong>.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🔍 Searchbar Terintegrasi</h3>
      <p>Searchbar langsung di halaman utama dengan <strong>debounce 500ms</strong>. Hasil real-time, tombol clear (X) otomatis muncul/hilang via <strong>ListenableBuilder</strong> — zero widget rebuild.</p>
    </td>
    <td width="50%">
      <h3>💾 Bookmark Persisten</h3>
      <p>Simpan artikel favorit ❤️ ke <strong>database sqflite</strong> — tetap ada meskipun aplikasi ditutup. Swipe-to-delete dengan <strong>undo snackbar</strong> (3 detik). Empty state premium dengan dekorasi dots.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🔄 Auto-Refresh Harian</h3>
      <p>Berita di-refresh otomatis setiap <strong>6 jam</strong>. Provider mencatat timestamp fetch terakhir — aplikasi tidak perlu fetch ulang jika masih fresh.</p>
    </td>
    <td width="50%">
      <h3>📱 Grid / List Toggle</h3>
      <p>Ganti tampilan antara <strong>list view</strong> (hero card + parallax depth 3D) dan <strong>grid view</strong> (2 kolom kompak + staggered animation).</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>📤 Offline Caching</h3>
      <p><strong>Network-first strategy</strong> — coba API dulu, gagal → fallback otomatis ke cache sqflite. Cache TTL <strong>30 menit</strong>. Desktop & mobile support via conditional imports. Web fallback graceful.</p>
    </td>
    <td width="50%">
      <h3>🌐 WebView Built-in</h3>
      <p>Baca artikel lengkap via <strong>WebView</strong> dengan progress bar, error handling, bookmark & share buttons, dan fallback browser eksternal.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🎬 Parallax Hero Card</h3>
      <p>Efek <strong>parallax</strong> pada gambar headline — image bergerak 15% lebih lambat dari card saat di-scroll, menciptakan ilusi depth 3D dramatis.</p>
    </td>
    <td width="50%">
      <h3>🎭 Staggered Animation</h3>
      <p>Animasi list yang muncul satu per satu dengan efek fade + slide (delay 80ms per item) — memberikan pengalaman scroll yang premium.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>✨ Splash Screen Premium</h3>
      <p>Splash dengan <strong>glow effect</strong>, logo 'RF' scale bounce + rotation, teks slide-up, dan gradient progress bar. Transisi <strong>FadeThrough</strong> ke halaman utama (2.8 detik).</p>
    </td>
    <td width="50%">
      <h3>🌙 Dark Theme ESPN</h3>
      <p>Tema gelap khas ESPN dengan aksen merah (<code>#D50000</code>), card gelap (<code>#1E1E1E</code>), dan tipografi tebal yang nyaman di mata sepanjang hari.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>💻 Multi-Platform</h3>
      <p>Berjalan di <strong>Android, iOS, Web, Windows, macOS, dan Linux</strong> — satu codebase untuk semua platform. Conditional import untuk database (sqflite native / FFI desktop / disabled web).</p>
    </td>
    <td width="50%">
      <h3>📤 Share Berita</h3>
      <p>Bagikan berita ke aplikasi lain via <strong>Share Plus</strong> (API terbaru) — judul + link artikel langsung terkirim ke WhatsApp, Telegram, dll.</p>
    </td>
  </tr>
</table>

---

## 🆕 Yang Baru

| Tanggal | Perubahan |
|---------|-----------|
| **Jul 2026** | **🎯 AI Editor REEDSFEED** — Sistem analisis artikel otomatis (OpenAI API + Local Engine) — ekstraksi judul saran, inti berita, poin kunci 5W+1H |
| **Jul 2026** | **🌙 Dark/Light Theme Toggle** — Beralih tema dengan animasi + persist ke SharedPreferences |
| **Jul 2026** | **📢 Breaking News Banner** — Banner berita teratas ala ESPN dengan dismiss & auto-scroll |
| **Jul 2026** | **🧭 Icon Kompas Baru** — Desain kompas dengan arah mata angin (U/S/T/B) + background merah gradien |
| **Jul 2026** | **🔐 CORS Proxy Server** — Node.js proxy untuk akses NewsAPI dari web (zero dependencies) |
| **Jul 2026** | **🔄 Fallback Mock Data** — Semua API call otomatis fallback ke mock data jika gagal — aplikasi tidak pernah kosong! |
| **Jul 2026** | **ℹ️ Panel Info Lengkap** — Penulis, sumber, domain, publikasi, estimasi baca, URL + copy di DetailScreen |
| **Jul 2026** | **Icon RF Baru** — Red gradient + 'RF' monogram, generate pake Python + Pillow, adaptive icon config |
| **Jul 2026** | **Article Preview Screen** — Tap berita lihat preview dulu (hero, title, author, deskripsi) sebelum buka WebView |
| **Jul 2026** | **Kategori Politik** — Kategori ke-7 dengan mock data realistik tentang politik Indonesia |
| **Jul 2026** | **Auto-Refresh** — Berita di-refresh otomatis setiap 6 jam |
| **Jul 2026** | **Provider Fix** — MultiProvider pindah ke main.dart — context.read<>() crash diperbaiki |

---

## 📸 Tampilan Aplikasi

```
┌──────────────────────────────────────────────────┐
│               📱 APPS OVERVIEW                    │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────┐  ┌──────────────┐  ┌──────────┐   │
│  │  SPLASH  │  │     HOME     │  │  GRID    │   │
│  │   ✨     │  │ 🏷️[Olah]~    │  │ ┌──┐ ┌──┐│   │
│  │  GLOW RF │  │ ┌──────────┐ │  │ │📷│ │📷││   │
│  │  Loading │  │ │📷 HERO   │ │  │ └──┘ └──┘│   │
│  └──────────┘  │ │ parallax │ │  │ ┌──┐ ┌──┐│   │
│                │ ├──────────┤ │  │ │📷│ │📷││   │
│  ┌──────────┐  │ │📷 card   │ │  │ └──┘ └──┘│   │
│  │ PREVIEW  │  │ ├──────────┤ │  └──────────┘   │
│  │ 📰 Hero  │  │ │📷 card   │ │                  │
│  │ Title    │  │ └──────────┘ │  ┌──────────┐   │
│  │ Author   │  └──────────────┘  │ BOOKMARK │   │
│  │ 📝 Desc  │                    │ ❤️ ❤️ ❤️  │   │
│  │ [BACA]   │                    │ ← swipe ❌ │   │
│  └────┬─────┘                    └──────────┘   │
│       │                                           │
│       ▼                                           │
│  ┌──────────┐                    ┌──────────┐   │
│  │  DETAIL  │                    │ PROFILE  │   │
│  │  🌐 Web  │                    │ 👤 Hero  │   │
│  │  View    │                    │ 📊 Stats │   │
│  │  ❤️ 📤   │                    │ 🏷️ Tech  │   │
│  └──────────┘                    └──────────┘   │
│                                                  │
│  ┌────────── Bottom Navigation Bar ──────────┐   │
│  │ 🏠 Home │ 📑 Simpan │ 👤 Profil           │   │
│  └────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
```

---

## 🏗️ Arsitektur Project

```
┌──────────────────────────────────────────────────┐
│                   SCREENS (UI)                     │
│  Splash → Home → ArticlePreview → Detail(WebView) │
│            → Bookmark → Profile                    │
│               ↓ ↑                                  │
├──────────────────────────────────────────────────┤
│                PROVIDERS (State)                   │
│   NewsListProvider · SearchProvider · Bookmark    │
│   (auto-refresh 6h)   (debounce)   (sqflite)     │
│               ↓ ↑                                │
├──────────────────────────────────────────────────┤
│              REPOSITORIES (Data Layer)              │
│              NewsRepository                       │
│        (network-first + cache fallback)           │
│               ↓ ↑                                │
├──────────────────────────────────────────────────┤
│              SERVICES (API + Cache)                │
│      NewsApiService (HTTP) · LocalDatabaseService  │
│       (mock data engine)    (sqflite + FFI)       │
│               ↓ ↑                                 │
├──────────────────────────────────────────────────┤
│               MODELS (Data)                       │
│              NewsArticle                          │
└──────────────────────────────────────────────────┘
```

**Alur Data:** `Screen → Provider → Repository → Service → Model`

**Strategi Caching:** Network-first
1. Coba fetch dari **NewsAPI** (via HTTP)
2. Jika berhasil → simpan ke **cache sqflite** (fire-and-forget)
3. Jika gagal (offline/error) → **fallback otomatis** ke cache lokal
4. Cache TTL **30 menit** — expired cache dibersihkan saat startup

**Multi-Platform Database:**
- **Android/iOS:** sqflite native
- **Windows/macOS/Linux:** sqflite_common_ffi
- **Web:** database dinonaktifkan graceful (no crash)

---

## 🛠️ Tech Stack

| Kategori | Teknologi | Kegunaan |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) 3.44.6 | UI multi-platform |
| **Bahasa** | [Dart](https://dart.dev) 3.12.2 | Logic & structure |
| **State Management** | [Provider](https://pub.dev/packages/provider) | State management reaktif |
| **HTTP Client** | [http](https://pub.dev/packages/http) | REST API calls (NewsAPI) |
| **API Berita** | [NewsAPI](https://newsapi.org) | Sumber data berita |
| **Local Database** | [sqflite](https://pub.dev/packages/sqflite) | Offline cache & bookmark persist |
| **Desktop DB** | [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) | Database di Windows/macOS/Linux |
| **Cache Gambar** | [cached_network_image](https://pub.dev/packages/cached_network_image) | Loading & caching gambar |
| **WebView** | [webview_flutter](https://pub.dev/packages/webview_flutter) | Baca artikel in-app |
| **Share** | [share_plus](https://pub.dev/packages/share_plus) | Bagikan berita (API terbaru) |
| **URL Launcher** | [url_launcher](https://pub.dev/packages/url_launcher) | Buka link eksternal |
| **Env Variables** | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | API key management |
| **Animasi Loading** | [shimmer](https://pub.dev/packages/shimmer) | Skeleton loading effect |
| **Format Tanggal** | [intl](https://pub.dev/packages/intl) | Format waktu relatif |
| **Ikon Generator** | [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) | Generate icon multi-resolusi |
| **Icon Design** | [Python + Pillow](https://python-pillow.org) | Generate app icon programmatically |

---

## 🚀 Cara Menjalankan

### 📋 Prasyarat

| Kebutuhan | Versi Minimum |
|---|---|
| Flutter SDK | `3.12.2` |
| Dart SDK | `3.12.2` (bundled with Flutter) |
| Android SDK | API level 21+ |
| News API Key | [Daftar gratis di newsapi.org](https://newsapi.org) |

> **⚠️ Penting:** Path project TIDAK boleh mengandung karakter Unicode/Spasi
> untuk Android build. Jika ada, copy ke `C:\projects\reedsfeed\` dulu.

### 🔧 Langkah-langkah

#### 1️⃣ Clone Repository

```bash
git clone https://github.com/kerlan404/berita--headline-olahraga-politik-teknologi-dan-dll-.git
cd berita--headline-olahraga-politik-teknologi-dan-dll-
```

#### 2️⃣ Setup Environment Variables

Buat file `.env` di root project:

```env
NEWS_API_KEY=your_api_key_here
NEWS_API_BASE_URL=https://newsapi.org/v2
```

> **Dapatkan API Key:**
> 1. Buka [newsapi.org](https://newsapi.org)
> 2. Register / Login
> 3. Copy API Key dari dashboard
> 4. Paste ke file `.env`

> **Mode Mock:** Biarkan `NEWS_API_KEY` kosong — aplikasi akan otomatis
> menggunakan **mock data engine** (data dummy realistik untuk semua kategori).

#### 3️⃣ Install Dependencies

```bash
flutter clean
flutter pub get
```

#### 4️⃣ Generate App Icons (opsional)

```bash
# Source icon sudah ada di assets/icon/app_icon.png
dart run flutter_launcher_icons
```

#### 5️⃣ Jalankan Aplikasi

```bash
# Android (HP/Emulator) — recommended
flutter run -d android

# Web Browser
flutter run -d web

# Windows Desktop
flutter run -d windows

# iOS (butuh Mac)
flutter run -d ios

# macOS / Linux
flutter run -d macos
flutter run -d linux
```

#### 6️⃣ Build Production

```bash
flutter build apk --release           # Android APK
flutter build appbundle --release     # Android AppBundle
flutter build ios --release           # iOS IPA (butuh Mac)
flutter build web                     # Web
flutter build windows                 # Windows (butuh Visual Studio)
```

---

## 📁 Struktur Folder Lengkap

```
📦 reedsfeed
├── 📁 lib/                            # 📱 Source code utama
│   ├── 📄 main.dart                    # Entry point — init DB, load .env
│   ├── 📄 app.dart                     # MaterialApp + MultiProvider
│   │
│   ├── 📁 core/                        # ⚙️ Konfigurasi inti
│   │   ├── 📁 constants/
│   │   │   └── api_constants.dart      # 7 kategori: Semua, Olahraga...Politik
│   │   ├── 📁 theme/
│   │   │   └── app_theme.dart          # Dark theme ESPN
│   │   └── 📁 utils/
│   │       ├── date_formatter.dart     # Format waktu relatif
│   │       ├── route_transitions.dart  # Animasi navigasi + staggered list
│   │       ├── db_init.dart            # Stub DB init (web — no-op)
│   │       └── db_init_native.dart     # FFI DB init (desktop — sqflite_common_ffi)
│   │
│   ├── 📁 data/                        # 📊 Lapisan data
│   │   ├── 📁 models/
│   │   │   └── news_article.dart       # Model dengan fromJson/toJson
│   │   ├── 📁 services/
│   │   │   ├── news_api_service.dart   # HTTP + mock data engine (7 kategori)
│   │   │   └── local_database_service.dart # sqflite: cache + bookmark
│   │   └── 📁 repositories/
│   │       └── news_repository.dart    # Network-first + cache fallback
│   │
│   ├── 📁 providers/                   # 🗂️ State management
│   │   ├── news_list_provider.dart     # Auto-refresh 6 jam + pagination
│   │   ├── search_provider.dart        # Pencarian + debounce
│   │   └── bookmark_provider.dart      # Bookmark persist ke sqflite
│   │
│   ├── 📁 screens/                     # 🖥️ Halaman aplikasi
│   │   ├── 📁 splash/
│   │   │   └── splash_screen.dart      # Splash + glow effect + RF logo
│   │   ├── 📁 main/
│   │   │   └── main_shell.dart         # Bottom Nav + tab transitions
│   │   ├── 📁 home/
│   │   │   └── home_screen.dart        # Beranda: scroll kategori, searchbar,
│   │   │                               #   grid/list toggle, parallax hero
│   │   ├── 📁 detail/
│   │   │   ├── article_preview_screen.dart # PREVIEW fitur BARU — lihat info
│   │   │   │                               #   artikel sebelum buka WebView
│   │   │   └── detail_screen.dart      # WebView artikel + share + bookmark
│   │   ├── 📁 bookmark/
│   │   │   └── bookmark_screen.dart    # Premium empty state + swipe delete
│   │   └── 📁 profile/
│   │       └── profile_screen.dart     # Premium UI + tech badges + stats
│   │
│   └── 📁 widgets/                     # 🧩 Widget reusable
│       ├── news_card.dart              # Card list (gambar kiri, teks kanan)
│       ├── news_hero_card.dart         # Hero card + parallax depth
│       ├── bookmark_button.dart        # Tombol hati + animasi bounce
│       ├── empty_state.dart            # State kosong
│       ├── error_retry_widget.dart     # Error + retry button
│       ├── loading_indicator.dart      # Spinner
│       └── shimmer_loading.dart        # Skeleton (list + grid variants)
│
├── 📁 android/                         # 🤖 Konfigurasi Android
├── 📁 ios/                             # 🍎 Konfigurasi iOS
├── 📁 web/                             # 🌐 Konfigurasi Web
├── 📁 windows/                         # 🪟 Konfigurasi Windows
├── 📁 macos/                           # 💻 Konfigurasi macOS
├── 📁 linux/                           # 🐧 Konfigurasi Linux
├── 📁 assets/
│   ├── 📁 icon/
│   │   └── app_icon.png                # RF icon (red gradient + RF logo)
│   ├── 📁 screenshots/
│   └── 📄 .env                         # Environment variables (TIDAK di-commit)
│
├── 📁 scripts/                         # 🔧 Utility scripts
│   └── generate_icon.py                # Generate app icon (Python + Pillow)
│
├── 📁 dokumen/                         # 📚 Dokumentasi project
│   ├── prd.md                          # Product Requirements Document
│   ├── desain.md                       # Panduan desain UI/UX
│   ├── integrasi.md                    # Panduan integrasi
│   ├── roadmap.md                      # Roadmap pengembangan
│   └── PROGRES.md                      # Progres tracking
│
├── 📄 pubspec.yaml                     # Dependencies & konfigurasi
├── 📄 analysis_options.yaml            # Lint rules
├── 📄 .gitignore                       # Git ignore
└── 📄 README.md                        # Ini! 👋
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.2

  # Networking & Data
  http: ^1.2.1
  cached_network_image: ^3.3.1

  # Local Database (Offline Cache + Bookmark Persist)
  sqflite: ^2.4.3
  sqflite_common_ffi: ^2.3.0    # Desktop DB support
  path: ^1.9.0

  # Features
  webview_flutter: ^4.7.0
  url_launcher: ^6.3.0
  share_plus: ^13.2.1
  flutter_dotenv: ^6.0.1

  # UI & Animations
  shimmer: ^3.0.0

  # Utilities
  intl: ^0.20.3
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.14.4
  flutter_lints: ^6.0.0
```

---

## 🧭 Alur Navigasi

```
🚀 Launch
    │
    ▼
┌──────────────────┐    FadeThrough     ┌──────────────────────────────────────┐
│     SPLASH       │ ──────────────────→ │            MAIN SHELL                │
│  ✨ Glow Effect  │      (2.8 detik)    │  ┌─ BottomNavigationBar ──────────┐  │
│  Scale + Rotate  │                     │  │ 🏠 Home │ 📑 Simpan │ 👤 Profil │  │
│  RF Logo + Load  │                     │  └────────────────────────────────┘  │
└──────────────────┘                     │         │            │              │
                                         │         │            │              │
                                         │  ┌──────┘            └──────┐       │
                                         │  ▼                          ▼       │
                                         │ ┌──────────┐          ┌──────────┐ │
                                         │ │   HOME   │          │ BOOKMARK │ │
                                         │ │🏷️ Kategori│         │ ❤️ saved  │ │
                                         │ │🔍 Search │          │ ⬅️ swipe  │ │
                                         │ └─────┬────┘          └──────────┘ │
                                         │       │                              │
                                         │       │ push(SlideRight)             │
                                         │       ▼                              │
                                         │  ┌──────────────────────┐           │
                                         │  │  ARTICLE PREVIEW     │ ◀── FITUR │
                                         │  │  🖼️ Hero Image      │    BARU!  │
                                         │  │  📝 Title + Author   │           │
                                         │  │  📄 Description      │           │
                                         │  │  📖 Konten Singkat   │           │
                                         │  └──────┬───────────────┘           │
                                         │         │                            │
                                         │    ┌────┴────┐                      │
                                         │    ▼         ▼                      │
                                         │ ┌────────┐ ┌──────────┐            │
                                         │ │BROWSER │ │  DETAIL  │            │
                                         │ │External │ │🌐 WebView│            │
                                         │ │(opsional)││❤️ bookmark│            │
                                         │ └────────┘ │📤 share   │            │
                                         │            └──────────┘            │
                                         │                                     │
                                         │  ┌──────────┐                      │
                                         │  │ PROFILE  │                      │
                                         │  │ 👤 Hero  │ 📊 Stats             │
                                         │  │ 🏷️ Tech  │ 📋 Info Cards        │
                                         │  └──────────┘                      │
                                         └──────────────────────────────────────┘
```

### Tab & Page Transitions

| Transisi | Animasi | Durasi |
|----------|---------|--------|
| **Tab ganti** (Nav Bar) | Fade-in + Scale-in (0.96→1.0) easeOutCubic | 350ms |
| **Buka artikel** (push) | SlideRight (0.3→0 offset) + Fade easeOutCubic | 350ms |
| **Splash → Main** | FadeThrough + Scale (0.95→1.0) | 300ms |
| **List items** (staggered) | Fade (0→1) + SlideUp (0.15→0 offset) per item | 600ms total |
| **Bookmark toggle** | Scale bounce (1.0→1.4→0.9→1.2→1.0) | 300ms |

---

## 📱 Cara Menggunakan

### Home Screen
| Aksi | Hasil |
|---|---|
| 🔽 **Scroll ke bawah** | Infinite scroll — berita baru termuat otomatis (pageSize 15) |
| ⬆️ **Scroll > 300px** | FAB ↑ muncul, tap untuk kembali ke atas |
| 👆 **Tap card berita** | Buka **ArticlePreview** — lihat info singkat dulu |
| 👆 **Tap "BACA LENGKAP"** | Buka artikel full via WebView |
| 👆 **Tap category pill** | Filter berita — 7 kategori tersedia |
| ➡️ **Tap arrow → / ←** | Scroll kategori ke kanan/kiri (mobile) |
| 🔢 **Tap icon grid/list** | Ganti tampilan list ↔ grid |
| 🔄 **Pull-to-refresh** | Muat ulang berita terbaru |
| ❤️ **Tap icon hati** | Simpan / hapus bookmark |
| 🔍 **Tap search icon** | Buka searchbar — cari real-time |
| ❌ **Tap X di searchbar** | Hapus query pencarian |

### Article Preview Screen (Fitur Baru!)
| Aksi | Hasil |
|---|---|
| 👆 **Scroll** | Scroll konten preview (hero, title, meta, deskripsi) |
| 👆 **Tap "BACA LENGKAP"** | Buka WebView artikel lengkap |
| 👆 **Tap "BUKA BROWSER"** | Buka artikel di browser eksternal |
| ❤️ **Tap bookmark** | Simpan artikel ini |
| 📤 **Tap share** | Bagikan ke aplikasi lain |
| 🔙 **Tap back** | Kembali ke daftar berita |

### Bookmark Screen
| Aksi | Hasil |
|---|---|
| ❤️ **Lihat artikel tersimpan** | Semua bookmark — persisten di database |
| ⬅️ **Swipe ke kiri** | Hapus bookmark dengan undo snackbar (3 detik) |
| 🗑️ **Tap hapus semua** | Konfirmasi → hapus semua bookmark |

### Profile Screen
| Aksi | Hasil |
|---|---|
| 👤 **Hero section** | RF logo, nama app, versi |
| 📊 **Statistik** | Jumlah bookmark, kategori, bahasa |
| 📋 **Info cards** | Premium gradient cards: fitur, tema, bookmark, cache |
| 🏷️ **Tech badges** | Flutter, Dart, Provider, SQFlite, NewsAPI, WebView |

---

## 🔧 Konfigurasi

### Mengubah Tema

Edit `lib/core/theme/app_theme.dart`:

```dart
static const Color primaryAccent = Color(0xFFD50000);  // Warna aksen
static const Color background = Color(0xFF121212);       // Background
```

### Menambah Kategori

Edit `lib/core/constants/api_constants.dart`:

```dart
static const Map<String, String> categoryMap = {
  'Semua': 'all',
  'Olahraga': 'sports',
  'Teknologi': 'technology',
  'Bisnis': 'business',
  'Hiburan': 'entertainment',
  'Kesehatan': 'health',
  'Politik': 'politics',
  // Tambah di sini:
  'Sains': 'science',
};
```

Kategori baru **otomatis muncul** di scroll bar tanpa perubahan lain.
Jangan lupa tambah icon di `_getCategoryIcon()` di `home_screen.dart`.

### Mengubah PageSize & Auto-Refresh

Edit `lib/providers/news_list_provider.dart`:

```dart
final int _pageSize = 15;            // Jumlah berita per halaman
static const Duration _autoRefreshDuration = Duration(hours: 6); // Interval refresh
```

### Mengubah Cache TTL

Edit `lib/data/services/local_database_service.dart`:

```dart
static const int _cacheTTL = 30 * 60 * 1000; // 30 menit
```

### Mengubah API

Edit file `.env`:

```env
NEWS_API_KEY=your_new_key
NEWS_API_BASE_URL=https://newsapi.org/v2
```

Kosongkan `NEWS_API_KEY` untuk mengaktifkan **Mock Mode** (data dummy).

### Mengubah Ikon Aplikasi

```bash
# 1. Generate icon baru (butuh Python + Pillow)
python scripts/generate_icon.py

# 2. Generate semua platform icons
dart run flutter_launcher_icons

# 3. Rebuild aplikasi
flutter run
```

---

## 🐛 Troubleshooting

| Masalah | Solusi |
|---|---|
| **Build error NDK** | Path project tidak boleh mengandung Unicode/Spasi → copy ke `C:\projects\` |
| **API error terus** | Cek `NEWS_API_KEY` di `.env` — atau kosongkan untuk Mock Mode |
| **Gambar tidak muncul** | Cek koneksi internet. CachedNetworkImage handle cache otomatis |
| **WebView blank putih** | Pastikan ada `<uses-permission android:name="android.permission.INTERNET"/>` di AndroidManifest |
| **`flutter pub get` error** | Coba `flutter clean && flutter pub get` |
| **Database error startup** | Hapus file `reedsfeed_cache.db` di direktori app |
| **Keyboard muncul otomatis** | Sudah diperbaiki — autofocus dihapus dari searchbar |
| **Aplikasi terasa berat** | Cek `dart analyze` — pastikan tidak ada print() statements |
| **dart:io error di Web** | Sudah diperbaiki dengan conditional import pattern |

### ⚡ Command Berguna

```bash
flutter analyze            # Cek kualitas kode — TARGET: 0 issues
dart format .              # Format otomatis
flutter test               # Jalankan unit test
flutter pub outdated       # Cek dependency usang
flutter pub upgrade        # Upgrade semua dependency
flutter build apk --release # Build APK produksi
flutter logs               # Lihat log runtime
```

---

## 🤝 Kontribusi

Kami sangat terbuka untuk kontribusi! 🎉

1. **Fork** repository ini
2. Buat **branch feature**:
   ```bash
   git checkout -b feature/KerenBanget
   ```
3. **Commit** perubahan Anda:
   ```bash
   git commit -m '✨ Menambahkan fitur keren banget'
   ```
4. **Push** ke branch:
   ```bash
   git push origin feature/KerenBanget
   ```
5. Buat **Pull Request**

### 📝 Style Guide

- Ikuti struktur folder yang sudah ada
- Gunakan **Provider** untuk state management
- Widget pakai `const` constructor jika memungkinkan
- Ikuti palet warna di `app_theme.dart`
- Pastikan `flutter analyze` — **No issues found** sebelum commit
- Jangan gunakan `print()` — gunakan `debugPrint()` dari `package:flutter/foundation.dart`

---

## 📄 Lisensi

```
MIT License

Copyright (c) 2026 kerlan404

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 👨‍💻 Author

**kerlan404**

[![GitHub](https://img.shields.io/badge/GitHub-kerlan404-181717?style=for-the-badge&logo=github)](https://github.com/kerlan404)
[![Repo](https://img.shields.io/badge/Repo-REEDSFEED-blue?style=for-the-badge)](https://github.com/kerlan404/berita--headline-olahraga-politik-teknologi-dan-dll-)

---

## 🙏 Credits

- **[NewsAPI](https://newsapi.org)** — Penyedia data berita
- **[Flutter Team](https://flutter.dev)** — Framework keren
- **[ESPN](https://espn.com)** — Inspirasi desain UI/UX
- **Semua kontributor** — Yang sudah membantu project ini

---

<div align="center">
  <br>
  <p>
    <strong>Dibuat dengan ❤️ oleh kerlan404</strong>
  </p>
  <p>
    <sub>Last updated: 2026-07-21</sub>
  </p>
  <br>
</div>
