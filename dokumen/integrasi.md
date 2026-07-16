# Integrasi.md - Panduan Pengembangan, Perbaikan Bug, & Testing di HP

Dokumen ini adalah panduan teknis agar AI/developer konsisten saat: (1) menambah fitur baru, (2) memperbaiki error/problem, dan (3) menjalankan/testing aplikasi langsung di HP fisik beserta ikon aplikasi.

---

## 1. Struktur Project (Wajib Diikuti)

```
lib/
├── main.dart
├── app.dart                     # MaterialApp + ThemeData (app_theme.dart dipakai di sini)
├── core/
│   ├── theme/
│   │   └── app_theme.dart       # Semua warna & tipografi dari desain.md didefinisikan di sini
│   ├── constants/
│   │   └── api_constants.dart   # Base URL, API key (dari .env), nama kategori
│   └── utils/
│       └── date_formatter.dart  # Format waktu relatif ("2 jam lalu")
├── data/
│   ├── models/
│   │   └── news_article.dart    # Model data berita (dari response API)
│   ├── services/
│   │   └── news_api_service.dart# Semua pemanggilan http ke News API
│   └── repositories/
│       └── news_repository.dart # Layer antara service & UI (mapping error, dsb)
├── providers/ (atau bloc/)
│   ├── news_list_provider.dart  # State list berita + pagination
│   └── search_provider.dart     # State pencarian
├── screens/
│   ├── home/
│   │   └── home_screen.dart
│   ├── search/
│   │   └── search_screen.dart
│   └── detail/
│       └── detail_screen.dart
└── widgets/
    ├── news_card.dart
    ├── news_hero_card.dart
    ├── category_tab_bar.dart
    ├── loading_indicator.dart
    ├── empty_state.dart
    └── error_retry_widget.dart
```

**Aturan:** Jangan taruh logic pemanggilan API langsung di dalam widget/screen. Alurnya selalu:
`Screen → Provider/Bloc → Repository → Service (http) → Model`

---

## 2. Integrasi API Berita

### 2.1 Pemilihan API
Gunakan **NewsAPI.org** sebagai default (gratis untuk pengembangan). Alternatif: GNews API, Currents API — struktur endpoint mirip, tinggal ganti di `api_constants.dart` dan `news_article.dart` (mapping field bisa beda nama).

### 2.2 Konfigurasi API Key (Jangan Hardcode)
1. Tambahkan package `flutter_dotenv`.
2. Buat file `.env` di root project (dan tambahkan ke `.gitignore`):
   ```
   NEWS_API_KEY=isi_api_key_disini
   NEWS_API_BASE_URL=https://newsapi.org/v2
   ```
3. Load di `main.dart` sebelum `runApp()`:
   ```dart
   await dotenv.load(fileName: ".env");
   ```
4. Akses via `dotenv.env['NEWS_API_KEY']`.

### 2.3 Endpoint yang Dipakai
| Fitur | Endpoint contoh (NewsAPI.org) | Parameter penting |
|---|---|---|
| List berita per kategori | `/v2/top-headlines` | `category`, `page`, `pageSize`, `apiKey` |
| Pencarian | `/v2/everything` | `q`, `page`, `pageSize`, `apiKey` |

### 2.4 Mapping Kategori
API biasanya pakai key bahasa Inggris (`sports`, `technology`, `business`). Buat mapping tetap di `api_constants.dart`:
```dart
const categoryMap = {
  'Olahraga': 'sports',
  'Teknologi': 'technology',
  'Bisnis': 'business',
};
```
Jangan ubah label UI (`desain.md`) hanya karena API pakai bahasa Inggris — mapping dilakukan di layer data, bukan di UI.

### 2.5 Error Handling (Wajib untuk Semua Request)
Setiap pemanggilan API harus menangani minimal 4 kondisi:
1. **Sukses** → parse data, tampilkan.
2. **Tidak ada internet** → tampilkan `ErrorRetryWidget` dengan pesan "Periksa koneksi internet Anda".
3. **Response error / rate limit (4xx/5xx)** → tampilkan pesan sesuai status, log error ke console untuk debugging.
4. **Data kosong** → tampilkan `EmptyState`, bukan layar putih/kosong tanpa keterangan.

Gunakan `try-catch` di level Repository, bukan di UI, dan lempar exception custom (misal `NetworkException`, `ApiException`) agar Provider bisa menampilkan pesan yang sesuai.

---

## 3. Alur Menambah Fitur Baru

Saat diminta menambah fitur baru, ikuti urutan ini agar tidak asal-asalan:
1. **Cek PRD (`prd.md`)** — pastikan fitur selaras dengan tujuan aplikasi, atau update PRD dulu jika fitur benar-benar baru di luar scope awal.
2. **Cek Desain (`desain.md`)** — pastikan komponen UI baru mengikuti palet warna, tipografi, dan pola card/tab yang sudah ada. Jika perlu komponen baru, tambahkan ke tabel "Komponen Reusable".
3. **Implementasi mengikuti struktur folder Section 1** — model → service → repository → provider → screen/widget.
4. **Tes manual di HP** sebelum dianggap selesai (lihat Section 5).
5. **Update dokumen** (`prd.md`/`desain.md`) jika fitur mengubah scope atau menambah komponen visual baru — dokumen ini harus selalu jadi cerminan kondisi aplikasi terkini.

---

## 4. Alur Memperbaiki Error/Problem

1. **Reproduksi dulu** — pastikan error bisa diulang, catat langkah & pesan error/stack trace lengkap.
2. **Cari lokasi sesuai layer** — jika error data → cek `service`/`repository`; jika error tampilan → cek `widget`/`screen`; jika error state → cek `provider`.
3. **Cek log Flutter** — jalankan `flutter run` dan lihat console/`flutter logs`, atau gunakan DevTools untuk breakpoint jika perlu.
4. **Perbaiki di sumber masalah**, bukan menutupi gejala (misal jangan cuma bungkus dengan try-catch kosong tanpa menampilkan pesan ke user).
5. **Uji ulang skenario yang sama + skenario terkait** (misal: perbaikan di pagination → tes juga pull-to-refresh & pindah kategori, karena sama-sama pakai provider list).
6. Untuk error umum Flutter:
   - `RenderFlex overflow` → biasanya widget Row/Column tanpa `Expanded`/`Flexible`, cek `NewsCard`.
   - Gambar tidak muncul → cek `cached_network_image`, pastikan URL valid & ada `errorWidget`.
   - WebView blank → cek permission internet di `AndroidManifest.xml` (`<uses-permission android:name="android.permission.INTERNET"/>`) dan pastikan `webview_flutter` versi terbaru kompatibel dengan Android/iOS project.

---

## 5. Testing Langsung di HP

### 5.1 Persiapan Android (paling umum & cepat)
1. Aktifkan **Developer Options** di HP: Settings → About Phone → tap "Nomor Build" 7 kali.
2. Aktifkan **USB Debugging** di Developer Options.
3. Sambungkan HP ke komputer via USB kabel, izinkan popup "Allow USB Debugging" di HP.
4. Cek HP terdeteksi:
   ```
   flutter devices
   ```
   Pastikan nama HP muncul di daftar.
5. Jalankan aplikasi langsung ke HP:
   ```
   flutter run
   ```
   (Jika ada lebih dari satu device terdeteksi, pilih device HP saat diminta, atau pakai `flutter run -d <device_id>`.)

### 5.2 Build APK untuk Install Manual (Tanpa Kabel Terus Terhubung)
```
flutter build apk --release
```
File hasil ada di `build/app/outputs/flutter-apk/app-release.apk` — kirim/transfer ke HP lalu install manual (aktifkan "Install dari sumber tidak dikenal" jika diminta).

### 5.3 Testing di iOS (opsional, butuh Mac)
Perlu Xcode & akun Apple Developer (minimal free account untuk testing di device sendiri). Jalankan:
```
flutter run -d <device_id_ios>
```

---

## 6. Setup Ikon Aplikasi Custom

1. Siapkan gambar ikon `assets/icon/app_icon.png` (ukuran 1024x1024, sesuai gaya di `desain.md` Section 6).
2. Tambahkan dependency di `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1

   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon/app_icon.png"
     min_sdk_android: 21
   ```
3. Jalankan:
   ```
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```
4. Ikon otomatis ter-generate ke semua ukuran resolusi Android (`mipmap-*`) dan iOS (`AppIcon.appiconset`).
5. **Wajib rebuild aplikasi** setelah generate ikon (`flutter run` ulang) — ikon lama kadang masih ter-cache di launcher HP, kalau perlu uninstall dulu app versi lama lalu install ulang.
6. Ubah juga nama aplikasi yang muncul di homescreen HP:
   - Android: `android/app/src/main/AndroidManifest.xml` → atribut `android:label`.
   - iOS: `ios/Runner/Info.plist` → key `CFBundleDisplayName`.

---

## 7. Checklist Sebelum Dianggap "Siap Ditest User"

- [ ] `flutter analyze` tidak ada error/warning kritis.
- [ ] Aplikasi jalan mulus di `flutter run` ke HP fisik (bukan cuma emulator).
- [ ] Ikon custom sudah tampil di homescreen HP (bukan ikon default Flutter).
- [ ] Semua fitur di `prd.md` Section 6 (Kriteria Sukses) sudah dicoba manual satu per satu di HP.
- [ ] Kondisi tanpa internet & data kosong sudah dicoba (matikan wifi/data sebentar saat testing).