# 📰 SportsFeed - Aplikasi Berita Flutter

Aplikasi mobile berita multi-platform yang dibangun dengan **Flutter** untuk menampilkan headline terkini dari berbagai kategori seperti olahraga, politik, teknologi, dan lainnya. Aplikasi ini menggunakan **NewsAPI** untuk mendapatkan data berita real-time.

## 🎯 Fitur Utama

- ✅ **Tampilan Berita Real-Time** - Mengambil berita terbaru dari News API
- ✅ **Multiple Platform** - Berjalan di Android, iOS, Web, Windows, macOS, dan Linux
- ✅ **Kategori Berita** - Olahraga, Politik, Teknologi, dan kategori lainnya
- ✅ **Pencarian Berita** - Cari berita berdasarkan keyword
- ✅ **Cache Gambar** - Gambar di-cache untuk performa lebih baik
- ✅ **WebView Integration** - Baca artikel lengkap dalam aplikasi
- ✅ **Dark Theme** - Tema gelap untuk kenyamanan mata
- ✅ **Share Berita** - Bagikan berita ke media sosial
- ✅ **Loading Shimmer** - Animasi loading yang smooth
- ✅ **URL Launcher** - Buka link di browser atau dalam aplikasi

---

## 📁 Struktur Project

```
berita--headline-olahraga-politik-teknologi-dan-dll-/
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   ├── app.dart                           # Konfigurasi MaterialApp dan Provider setup
│   ├── screens/                           # Halaman-halaman aplikasi
│   │   ├── splash/
│   │   │   └── splash_screen.dart        # Splash screen (loading awal)
│   │   ├── home/
│   │   │   └── home_screen.dart          # Halaman utama daftar berita
│   │   ├── detail/
│   │   │   └── article_detail_screen.dart # Halaman detail artikel
│   │   ├── search/
│   │   │   └── search_screen.dart        # Halaman pencarian berita
│   │   └── webview/
│   │       └── article_webview_screen.dart # WebView untuk membaca artikel
│   ├── providers/                        # State management dengan Provider
│   │   ├── news_list_provider.dart       # Provider untuk daftar berita
│   │   └── search_provider.dart          # Provider untuk fitur pencarian
│   ├── models/                           # Data models
│   │   ├── news.dart                     # Model berita
│   │   ├── news_response.dart            # Model response API
│   │   └── article.dart                  # Model artikel
│   ├── services/                         # API dan layanan eksternal
│   │   ├── news_service.dart             # Service untuk API NewsAPI
│   │   └── api_constants.dart            # Konstanta API
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart            # Tema aplikasi (Dark theme)
│   │   └── constants/
│   │       └── app_constants.dart        # Konstanta aplikasi
│   ├── widgets/                          # Reusable widgets
│   │   ├── news_card.dart                # Widget kartu berita
│   │   ├── news_shimmer.dart             # Widget loading shimmer
│   │   ├── custom_app_bar.dart           # Custom AppBar
│   │   └── error_widget.dart             # Widget untuk error state
│   ├── utils/                            # Utility functions
│   │   ├── date_formatter.dart           # Format tanggal
│   │   ├── string_utils.dart             # Utility string
│   │   └── logger.dart                   # Logging utility
│   └── config/
│       └── environment.dart              # Konfigurasi environment
├── assets/
│   └── icon/
│       └── app_icon.png                  # Icon aplikasi
├── android/                              # Konfigurasi Android
├── ios/                                  # Konfigurasi iOS
├── web/                                  # Konfigurasi Web
├── windows/                              # Konfigurasi Windows
├── macos/                                # Konfigurasi macOS
├── linux/                                # Konfigurasi Linux
├── test/                                 # Unit dan Widget tests
├── .env                                  # Environment variables
├── .gitignore                            # Git ignore rules
├── pubspec.yaml                          # Dependencies dan project config
├── pubspec.lock                          # Lock file untuk dependencies
├── analysis_options.yaml                 # Lint rules
└── README.md                             # File ini
```

---

## 🛠️ Tech Stack

| Teknologi | Deskripsi |
|-----------|-----------|
| **Flutter** | Framework UI multi-platform |
| **Dart** | Bahasa pemrograman |
| **Provider** | State management |
| **HTTP** | Package untuk HTTP requests |
| **News API** | Source data berita |
| **Cached Network Image** | Cache gambar dari network |
| **WebView Flutter** | Menampilkan web content dalam app |
| **Flutter DotEnv** | Load environment variables |
| **Intl** | Internationalization & formatting |
| **URL Launcher** | Membuka URL eksternal |
| **Shimmer** | Loading animation |
| **Share Plus** | Share functionality |

---

## 📋 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2              # State management
  http: ^1.2.1                  # HTTP requests
  cached_network_image: ^3.3.1  # Image caching
  webview_flutter: ^4.7.0       # WebView
  flutter_dotenv: ^5.1.0        # .env file support
  intl: ^0.19.0                 # Date formatting
  url_launcher: ^6.3.0          # Open URLs
  shimmer: ^3.0.0               # Loading animation
  share_plus: ^10.0.0           # Share content
```

---

## 🚀 Cara Menjalankan Aplikasi

### Prerequisite (Persyaratan Awal)

1. **Flutter SDK** (v3.12.2 atau lebih tinggi)
2. **Dart SDK** (sudah included dengan Flutter)
3. **News API Key** - Daftar gratis di [newsapi.org](https://newsapi.org)
4. **Android Studio / Xcode** (untuk development)
5. **Git** untuk clone repository

### Step 1: Clone Repository

```bash
git clone https://github.com/kerlan404/berita--headline-olahraga-politik-teknologi-dan-dll-.git
cd berita--headline-olahraga-politik-teknologi-dan-dll-
```

### Step 2: Setup Environment Variables

Buat atau edit file `.env` di root project:

```env
NEWS_API_KEY=your_api_key_here
NEWS_API_BASE_URL=https://newsapi.org/v2
```

**Cara mendapatkan API Key:**
1. Buka https://newsapi.org
2. Sign up atau login
3. Copy API key dari dashboard
4. Paste ke `.env` file

### Step 3: Install Dependencies

```bash
flutter clean
flutter pub get
```

### Step 4: Generate App Icons (Optional)

```bash
flutter pub run flutter_launcher_icons
```

### Step 5: Run Aplikasi

#### Di Android Emulator/Device:
```bash
flutter run -d android
# atau untuk build APK
flutter build apk --release
```

#### Di iOS Simulator/Device:
```bash
flutter run -d ios
# atau untuk build IPA
flutter build ios --release
```

#### Di Web Browser:
```bash
flutter run -d web
# atau untuk build production
flutter build web
```

#### Di Windows:
```bash
flutter run -d windows
```

#### Di macOS:
```bash
flutter run -d macos
```

#### Di Linux:
```bash
flutter run -d linux
```

### Step 6: Verify Devices

```bash
flutter devices
```

---

## 📱 Cara Menggunakan Aplikasi

### Home Screen
1. Aplikasi akan menampilkan splash screen selama 2-3 detik
2. Halaman utama menampilkan daftar berita terbaru
3. Scroll ke bawah untuk memuat berita lebih banyak
4. Tap pada kartu berita untuk melihat detail

### Search Berita
1. Tap icon search di AppBar
2. Ketik keyword berita yang dicari
3. Hasil pencarian akan ditampilkan secara real-time

### Baca Artikel Lengkap
1. Tap pada berita untuk membuka detail screen
2. Tap tombol "Baca Selengkapnya" untuk membuka artikel di WebView
3. Gunakan tombol back untuk kembali

### Share Berita
1. Di detail screen, tap tombol share
2. Pilih app untuk membagikan berita

---

## 🔧 Konfigurasi Tambahan

### Mengubah Tema
Edit file `lib/core/theme/app_theme.dart`:
```dart
static final darkTheme = ThemeData(
  // Customize theme di sini
);
```

### Menambah Kategori Berita
Edit file `lib/services/news_service.dart` dan tambahkan kategori baru:
```dart
Future<List<Article>> fetchNewsByCategory(String category) async {
  // Tambahkan kategori baru sesuai NewsAPI documentation
}
```

### Mengubah URL Base API
Edit file `.env`:
```env
NEWS_API_BASE_URL=https://newsapi.org/v2  # Base URL API
```

---

## 🐛 Troubleshooting

| Masalah | Solusi |
|---------|--------|
| **API Key tidak valid** | Pastikan API key sudah dicopy dengan benar di `.env` |
| **Error loading images** | Pastikan koneksi internet stabil |
| **App crash saat run** | Coba `flutter clean` kemudian `flutter pub get` |
| **WebView error** | Update WebView ke versi terbaru: `flutter pub upgrade` |
| **Build error Android** | Update Android SDK ke API level 21+ |
| **iOS build error** | Jalankan `cd ios && pod update && cd ..` |

---

## 📚 Resources & Dokumentasi

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [News API Documentation](https://newsapi.org/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [HTTP Package](https://pub.dev/packages/http)

---

## 📝 Tips Pengembangan

### Best Practices
- Selalu gunakan Provider untuk state management
- Pisahkan UI dan business logic
- Gunakan meaningful variable names
- Comment code yang kompleks
- Test setiap fitur sebelum commit

### Development Commands Berguna

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Build profiling
flutter run --profile

# Build release
flutter run --release

# Generate docs
dart doc

# Check dependencies
flutter pub outdated
```

---

## 🤝 Kontribusi

Untuk berkontribusi:

1. Fork repository ini
2. Buat branch feature (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

---

## 📄 Lisensi

Project ini dilisensikan di bawah MIT License - lihat file [LICENSE](LICENSE) untuk detail.

---

## 👨‍💻 Author

**kerlan404**
- GitHub: [@kerlan404](https://github.com/kerlan404)
- Repository: [berita--headline-olahraga-politik-teknologi-dan-dll-](https://github.com/kerlan404/berita--headline-olahraga-politik-teknologi-dan-dll-)

---

## 🎉 Terima Kasih

- [News API](https://newsapi.org) - Untuk menyediakan API berita
- [Flutter Team](https://flutter.dev) - Untuk framework yang luar biasa
- Semua contributors yang telah membantu project ini

---

**Dibuat dengan ❤️ oleh kerlan404**

Last Updated: 2026-07-16
