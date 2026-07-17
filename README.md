<div align="center">
  <br>
  <img src="assets/icon/app_icon.png" alt="SportsFeed Logo" width="120" height="120" style="border-radius: 20px;">
  <br>
  <h1>📰 SPORTSFEED</h1>
  <p><strong>Berita & Headline Terkini</strong></p>
  <p>
    Aplikasi berita multi-platform yang dibangun dengan <strong>Flutter</strong> — 
    menyajikan headline terkini dari berbagai kategori dalam gaya visual <strong>ESPN</strong> 
    yang tegas, cepat, dan nyaman dibaca.
  </p>
  
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.44.6-02569B?style=flat-square&logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-3.12.2-0175C2?style=flat-square&logo=dart" alt="Dart">
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue?style=flat-square" alt="Platform">
    <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
    <img src="https://img.shields.io/badge/Status-Active-success?style=flat-square" alt="Status">
  </p>
  
  <br>
</div>

---

## 📋 Daftar Isi

- [✨ Fitur Unggulan](#-fitur-unggulan)
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
      <h3>📰 Berita Real-Time</h3>
      <p>Headline terkini dari berbagai kategori. Data real-time dari <strong>NewsAPI</strong> dengan infinite scroll & pull-to-refresh.</p>
    </td>
    <td width="50%">
      <h3>🏷️ Kategori Berita</h3>
      <p>Navigasi kategori cepat via <strong>sidebar drawer</strong> — Olahraga, Teknologi, Bisnis, Hiburan, Kesehatan, dan Semua.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🔍 Pencarian Cepat</h3>
      <p>Cari berita berdasarkan kata kunci dengan <strong>debounce 500ms</strong> — hasil muncul real-time saat mengetik.</p>
    </td>
    <td width="50%">
      <h3>💾 Bookmark</h3>
      <p>Simpan artikel favorit dengan animasi hati ❤️. <strong>Swipe-to-delete</strong> di halaman tersimpan.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>📱 Grid / List Toggle</h3>
      <p>Ganti tampilan berita antara <strong>list view</strong> (dengan hero card + parallax) dan <strong>grid view</strong> (2 kolom kompak).</p>
    </td>
    <td width="50%">
      <h3>🌐 WebView Built-in</h3>
      <p>Baca artikel lengkap dalam aplikasi via <strong>WebView</strong> dengan progress bar, error handling, dan fallback browser.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🎬 Parallax Hero Card</h3>
      <p>Efek <strong>parallax</strong> pada gambar headline — image bergerak 15% lebih lambat dari card saat di-scroll, menciptakan ilusi depth 3D.</p>
    </td>
    <td width="50%">
      <h3>⬆️ Scroll-to-Top FAB</h3>
      <p>Floating Action Button muncul otomatis saat scroll > 300px. Klik untuk kembali ke atas dengan animasi smooth.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🎭 Staggered Animation</h3>
      <p>Animasi list yang muncul satu per satu (staggered) dengan efek fade + slide — memberikan pengalaman scroll yang premium.</p>
    </td>
    <td width="50%">
      <h3>🌙 Dark Theme ESPN</h3>
      <p>Tema gelap khas ESPN dengan aksen merah (<code>#D50000</code>), card gelap (<code>#1E1E1E</code>), dan tipografi tebal yang nyaman di mata.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>📤 Share Berita</h3>
      <p>Bagikan berita ke aplikasi lain via <strong>Share Plus</strong> — judul + link artikel langsung terkirim.</p>
    </td>
    <td width="50%">
      <h3>📱 Multi-Platform</h3>
      <p>Berjalan di <strong>Android, iOS, Web, Windows, macOS, dan Linux</strong> — satu codebase untuk semua platform.</p>
    </td>
  </tr>
</table>

---

## 📸 Tampilan Aplikasi

```
┌──────────────────────────────────────────────┐
│               📱 APPS OVERVIEW                │
├──────────────────────────────────────────────┤
│                                              │
│  ┌──────┐  ┌──────────┐  ┌──────────┐       │
│  │SPLASH│  │   HOME   │  │  GRID    │       │
│  │  ✨  │  │ ┌──────┐ │  │ ┌──┐ ┌──┐│       │
│  │FEED  │  │ │📷 HERO│ │  │ │📷│ │📷││       │
│  │      │  │ │parallax│ │  │ └──┘ └──┘│       │
│  └──────┘  │ ├───────┤ │  │ ┌──┐ ┌──┐│       │
│            │ │📷 card│ │  │ │📷│ │📷││       │
│  ┌──────┐  │ ├───────┤ │  │ └──┘ └──┘│       │
│  │DETAIL│  │ │📷 card│ │  └──────────┘       │
│  │      │  │ └───────┘ │                      │
│  │ 🌐   │  └──────────┘  ┌──────────┐       │
│  │WebView│               │ BOOKMARK │        │
│  └──────┘                │ ❤️ ❤️ ❤️  │       │
│                          │ ← swipe ❌ │      │
│  ┌─────────┐             └──────────┘       │
│  │ SEARCH  │                                 │
│  │ 🔍 ...  │             ┌──────────┐       │
│  │ Hasil   │             │ PROFILE  │        │
│  │ hasil   │             │ 👤 Info  │       │
│  └─────────┘             └──────────┘       │
│                                              │
│  ┌────── Bottom Navigation Bar ──────────┐   │
│  │ 🏠 Home │ 🔍 Cari │ 📑 Simpan │ 👤 Profil│
│  └────────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

---

## 🏗️ Arsitektur Project

Aplikasi ini mengikuti arsitektur berlapis yang rapi dan terstruktur:

```
┌─────────────────────────────────────────────────┐
│                   SCREENS (UI)                    │
│  Splash → Home → Detail → Search → Bookmark     │
│               ↓ ↑          ↓ ↑        ↓          │
├─────────────────────────────────────────────────┤
│                PROVIDERS (State)                  │
│   NewsListProvider · SearchProvider · Bookmark   │
│               ↓ ↑                               │
├─────────────────────────────────────────────────┤
│              REPOSITORIES (Data Layer)             │
│              NewsRepository                      │
│               ↓ ↑                               │
├─────────────────────────────────────────────────┤
│                SERVICES (API)                     │
│              NewsApiService                      │
│               ↓ ↑                               │
├─────────────────────────────────────────────────┤
│               MODELS (Data)                      │
│              NewsArticle                         │
└─────────────────────────────────────────────────┘
```

**Prinsip alur data:** `Screen → Provider → Repository → Service (HTTP) → Model`

- **Tidak ada** pemanggilan API langsung dari widget/screen
- **Semua** state error, loading, kosong di-handle oleh Provider
- **Mapping** kategori & error dilakukan di Repository, bukan UI

---

## 🛠️ Tech Stack

| Kategori | Teknologi | Kegunaan |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) 3.44.6 | UI multi-platform |
| **Bahasa** | [Dart](https://dart.dev) 3.12.2 | Logic & structure |
| **State Management** | [Provider](https://pub.dev/packages/provider) | State management reaktif |
| **HTTP Client** | [http](https://pub.dev/packages/http) | REST API calls |
| **API Berita** | [NewsAPI](https://newsapi.org) | Sumber data berita |
| **Cache Gambar** | [cached_network_image](https://pub.dev/packages/cached_network_image) | Loading & caching gambar |
| **WebView** | [webview_flutter](https://pub.dev/packages/webview_flutter) | Baca artikel in-app |
| **Share** | [share_plus](https://pub.dev/packages/share_plus) | Bagikan berita |
| **URL Launcher** | [url_launcher](https://pub.dev/packages/url_launcher) | Buka link eksternal |
| **Env Variables** | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | API key management |
| **Animasi Loading** | [shimmer](https://pub.dev/packages/shimmer) | Skeleton loading effect |
| **Format Tanggal** | [intl](https://pub.dev/packages/intl) | Format waktu relatif |
| **Ikon Aplikasi** | [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) | Generate icon multi-resolusi |

---

## 🚀 Cara Menjalankan

### 📋 Prasyarat

| Kebutuhan | Versi Minimum |
|---|---|
| Flutter SDK | `3.12.2` |
| Dart SDK | `3.12.2` (bundled with Flutter) |
| Android SDK | API level 21+ |
| News API Key | [Daftar gratis](https://newsapi.org) |

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

#### 3️⃣ Install Dependencies

```bash
flutter clean
flutter pub get
```

#### 4️⃣ Generate App Icons (opsional)

```bash
dart run flutter_launcher_icons
```

#### 5️⃣ Jalankan Aplikasi

```bash
# Android (HP/Emulator)
flutter run -d android

# iOS (Simulator/Device — butuh Mac)
flutter run -d ios

# Web Browser
flutter run -d web

# Desktop
flutter run -d windows   # Windows
flutter run -d macos     # macOS
flutter run -d linux     # Linux
```

#### 6️⃣ Build Production

```bash
flutter build apk --release           # Android APK
flutter build appbundle --release     # Android AppBundle
flutter build ios --release           # iOS IPA
flutter build web                     # Web
```

---

## 📁 Struktur Folder Lengkap

```
📦 berita--headline-olahraga-politik-teknologi-dan-dll-
├── 📁 lib/                            # 📱 Source code utama
│   ├── 📄 main.dart                    # Entry point aplikasi
│   ├── 📄 app.dart                     # MaterialApp + Provider setup
│   │
│   ├── 📁 core/                        # ⚙️ Konfigurasi inti
│   │   ├── 📁 constants/
│   │   │   └── api_constants.dart      # Base URL, kategori, mapping
│   │   ├── 📁 theme/
│   │   │   └── app_theme.dart          # Dark theme ESPN (warna, tipografi)
│   │   └── 📁 utils/
│   │       ├── date_formatter.dart     # Format waktu relatif ("2 jam lalu")
│   │       └── route_transitions.dart  # Animasi navigasi + staggered list
│   │
│   ├── 📁 data/                        # 📊 Lapisan data
│   │   ├── 📁 models/
│   │   │   └── news_article.dart       # Model berita + fromJson/toJson
│   │   ├── 📁 services/
│   │   │   └── news_api_service.dart   # HTTP calls ke NewsAPI
│   │   └── 📁 repositories/
│   │       └── news_repository.dart    # Mapping data & error handling
│   │
│   ├── 📁 providers/                   # 🗂️ State management
│   │   ├── news_list_provider.dart     # List berita + pagination
│   │   ├── search_provider.dart        # Pencarian + debounce
│   │   └── bookmark_provider.dart      # Bookmark ❤️
│   │
│   ├── 📁 screens/                     # 🖥️ Halaman aplikasi
│   │   ├── 📁 splash/
│   │   │   └── splash_screen.dart      # Splash dengan animasi fade + slide
│   │   ├── 📁 main/
│   │   │   └── main_shell.dart         # Bottom Navigation Bar shell
│   │   ├── 📁 home/
│   │   │   └── home_screen.dart        # Beranda (list/grid + kategori + FAB)
│   │   ├── 📁 search/
│   │   │   └── search_screen.dart      # Pencarian dengan debounce
│   │   ├── 📁 detail/
│   │   │   └── detail_screen.dart      # WebView artikel + share
│   │   ├── 📁 bookmark/
│   │   │   └── bookmark_screen.dart    # Artikel tersimpan + swipe-delete
│   │   └── 📁 profile/
│   │       └── profile_screen.dart     # Profil & info aplikasi
│   │
│   └── 📁 widgets/                     # 🧩 Widget reusable
│       ├── news_card.dart              # Card list (gambar kiri, teks kanan)
│       ├── news_hero_card.dart         # Hero card (gambar besar + parallax)
│       ├── bookmark_button.dart        # Tombol hati dengan animasi bounce
│       ├── empty_state.dart            # State kosong
│       ├── error_retry_widget.dart     # State error + tombol retry
│       ├── loading_indicator.dart      # Spinner loading
│       └── shimmer_loading.dart        # Skeleton loading (list & grid)
│
├── 📁 android/                         # 🤖 Konfigurasi Android
├── 📁 ios/                             # 🍎 Konfigurasi iOS
├── 📁 web/                             # 🌐 Konfigurasi Web
├── 📁 windows/                         # 🪟 Konfigurasi Windows
├── 📁 macos/                           # 💻 Konfigurasi macOS
├── 📁 linux/                           # 🐧 Konfigurasi Linux
├── 📁 assets/
│   ├── 📁 icon/
│   │   └── app_icon.png                # Ikon aplikasi sumber
│   └── 📄 .env                         # Environment variables (TIDAK di-commit)
│
├── 📁 dokumen/                         # 📚 Dokumentasi project
│   ├── prd.md                          # Product Requirements Document
│   ├── desain.md                       # Panduan desain UI/UX
│   ├── integrasi.md                    # Panduan teknis integrasi
│   └── roadmap.md                      # Roadmap pengembangan
│
├── 📄 pubspec.yaml                     # Dependencies & konfigurasi
├── 📄 analysis_options.yaml            # Lint rules
├── 📄 .gitignore                       # Git ignore rules
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
  cached_network_image: ^3.4.1
  
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
┌──────────┐    FadeThrough    ┌─────────────────────────────────────┐
│  SPLASH  │ ────────────────→ │           MAIN SHELL                │
│  Screen  │     (2.5 detik)   │  ┌─ BottomNavigationBar ─────────┐  │
└──────────┘                   │  │ 🏠 🔍 📑 👤                   │  │
                               │  └───────────────────────────────┘  │
                               │         │   │    │     │            │
                               │    ┌────┘   │    │     └──────┐     │
                               │    ▼        ▼    ▼            ▼     │
                               │ ┌──────┐ ┌──────┐ ┌────────┐ ┌───┐ │
                               │ │ HOME │ │SEARCH│ │BOOKMARK│ │PROF│ │
                               │ └──┬───┘ └──┬───┘ └───┬────┘ └───┘ │
                               │    │        │         │            │
                               │    │  push   │  push   │            │
                               │    └────┬────┘         │            │
                               │         ▼              │            │
                               │    ┌──────────┐       │            │
                               │    │  DETAIL  │ ←─────┘            │
                               │    │ (WebView)│                    │
                               │    └──────────┘                    │
                               └─────────────────────────────────────┘
```

---

## 📱 Cara Menggunakan

### Home Screen
| Aksi | Hasil |
|---|---|
| 🔽 **Scroll ke bawah** | Infinite scroll — berita baru termuat otomatis |
| ⬆️ **Scroll > 300px** | FAB ↑ muncul, tap untuk kembali ke atas |
| 👆 **Tap card berita** | Buka detail artikel via WebView |
| 🏠 **Tap kategori di sidebar** | Buka menu → pilih kategori berita |
| 📋 **Tap icon grid/list** | Ganti tampilan antara list dan grid |
| 🔄 **Pull-to-refresh** | Muat ulang berita terbaru |
| ❤️ **Tap icon hati** | Simpan / hapus bookmark artikel |

### Search Screen
| Aksi | Hasil |
|---|---|
| 🔍 **Ketik kata kunci** | Pencarian real-time dengan debounce |
| ❌ **Tap icon clear** | Hapus hasil pencarian |
| 👆 **Tap hasil** | Buka detail artikel |

### Bookmark Screen
| Aksi | Hasil |
|---|---|
| ❤️ **Lihat artikel tersimpan** | Semua artikel yang di-bookmark |
| ⬅️ **Swipe ke kiri** | Hapus bookmark |
| 🗑️ **Tap icon hapus semua** | Konfirmasi → hapus semua bookmark |

### Detail Screen (WebView)
| Aksi | Hasil |
|---|---|
| ❤️ **Tap hati di AppBar** | Bookmark artikel ini |
| 📤 **Tap share** | Bagikan ke aplikasi lain |
| 🌐 **Tap buka browser** | Buka artikel di browser eksternal |
| 🔄 **Tap retry** | Muat ulang WebView jika error |

---

## 🔧 Konfigurasi

### Mengubah Tema

Edit `lib/core/theme/app_theme.dart`:

```dart
static const Color primaryAccent = Color(0xFFD50000);  // Ganti warna aksen
static const Color background = Color(0xFF121212);       // Ganti background
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
  // Tambah kategori baru di sini
  'Sains': 'science',
};
```

### Mengubah API

Edit file `.env`:

```env
NEWS_API_KEY=your_new_key
NEWS_API_BASE_URL=https://newsapi.org/v2  # Ganti ke API lain jika perlu
```

### Mengubah Ikon Aplikasi

1. Ganti `assets/icon/app_icon.png` (1024×1024)
2. Jalankan `dart run flutter_launcher_icons`
3. Rebuild aplikasi

---

## 🐛 Troubleshooting

| Masalah | Solusi |
|---|---|
| **Build error terkait NDK** | Pastikan path project tidak mengandung karakter Unicode/Spasi. Pindahkan ke `C:\projects\` |
| **"No issues found" tapi API error** | Cek `NEWS_API_KEY` di `.env` — pastikan valid & belum expired |
| **Gambar tidak muncul** | Cek koneksi internet. `CachedNetworkImage` akan otomatis handle cache |
| **WebView blank putih** | Pastikan AndroidManifest.xml punya `<uses-permission android:name="android.permission.INTERNET"/>` |
| **`flutter pub get` error** | Coba `flutter clean && flutter pub get` |
| **Infinite scroll berhenti** | Cek response API — `pageSize` mungkin perlu disesuaikan |
| **Keyboard muncul otomatis** | Ini adalah efek `IndexedStack` + autofocus. Sudah diperbaiki dengan menghapus `autofocus` |
| **Error build "kotlin"** | Upgrade `share_plus` ke versi terbaru & set `android.builtInKotlin=true` di `gradle.properties` |

### ⚡ Komands Berguna

```bash
flutter analyze            # Cek kualitas kode
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

- Ikuti struktur folder yang sudah ada (lihat [Struktur Folder](#-struktur-folder-lengkap))
- Gunakan **Provider** untuk state management, jangan setState berlebihan
- Semua widget pakai `const` constructor jika memungkinkan
- Ikuti palet warna di `app_theme.dart` — jangan hardcode warna
- Pastikan `flutter analyze` tidak ada error sebelum commit

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
[![Repo](https://img.shields.io/badge/Repo-berita--headline--olahraga-blue?style=for-the-badge)](https://github.com/kerlan404/berita--headline-olahraga-politik-teknologi-dan-dll-)

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
    <sub>Last updated: 2026-07-17</sub>
  </p>
  <br>
</div>
