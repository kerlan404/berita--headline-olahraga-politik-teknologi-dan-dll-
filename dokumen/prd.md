# PRD - Aplikasi Berita & Headline
**Codename:** SportsFeed (bebas diganti sesuai selera)
**Platform:** Mobile (Android & iOS) — Flutter
**Versi Dokumen:** 1.0
**Status:** Draft awal untuk kickoff project

---

## 1. Latar Belakang & Tujuan

Aplikasi ini adalah aplikasi berita/headline yang menampilkan daftar berita terbaru dari berbagai kategori (olahraga, teknologi, bisnis), dengan kemampuan pencarian. Inspirasi utama gaya visual & pengalaman pengguna adalah platform **ESPN** — tegas, cepat dibaca, berorientasi pada headline besar dan navigasi kategori yang jelas.

**Tujuan utama:**
1. Membangun aplikasi Flutter yang menampilkan berita real-time dari API eksternal.
2. Memberikan pengalaman membaca berita yang cepat, ringan, dan enak dipakai (mirip ESPN app).
3. Menyediakan struktur project yang rapi agar mudah dikembangkan (fitur baru) dan mudah di-debug.

**Non-tujuan (out of scope untuk versi awal):**
- Login/akun pengguna
- Notifikasi push
- Mode offline / caching artikel penuh
- Komentar / interaksi sosial

---

## 2. Target Pengguna

- Pengguna umum yang ingin membaca berita cepat sambil scroll (commuter, waktu istirahat).
- Penggemar olahraga yang ingin update cepat (karena gaya ESPN).
- Perangkat: Android (utama, minimum SDK 21) & iOS (opsional tahap awal).

---

## 3. Fitur (Sesuai Tabel Referensi)

### 3.1 Daftar Berita Terbaru (Infinite Scrolling / ListView)
- Menampilkan daftar berita terbaru dalam bentuk list/card.
- Scroll ke bawah otomatis memuat berita berikutnya (pagination/infinite scroll), tidak ada tombol "load more" manual.
- Setiap card menampilkan: gambar thumbnail, judul, sumber berita, kategori, waktu publish (relatif, misal "2 jam lalu").
- Loading indicator saat memuat halaman berikutnya (skeleton loading atau spinner di bawah list).
- Pull-to-refresh untuk memuat ulang berita terbaru dari atas.

### 3.2 Kategori Berita
- Kategori minimal: **Olahraga, Teknologi, Bisnis** (bisa ditambah: Umum/Terkini, Hiburan, Kesehatan — opsional).
- Navigasi kategori berupa tab horizontal scroll di atas (mirip ESPN: tab liga/kategori).
- Berpindah kategori akan memuat ulang list berita sesuai kategori yang dipilih.

### 3.3 Detail Berita (WebView)
- Saat card berita ditekan, buka halaman detail.
- Detail berita ditampilkan menggunakan **WebView** yang memuat URL artikel asli (bukan reader-mode custom di versi awal).
- Header detail menampilkan judul singkat, tombol back, tombol share, dan indikator loading saat WebView memuat halaman.
- Tombol "buka di browser" sebagai fallback jika WebView gagal memuat.

### 3.4 Pencarian Berita
- Search bar (bisa berupa ikon search di AppBar yang expand jadi search field, gaya ESPN).
- Pencarian berdasarkan keyword judul/deskripsi berita, memanggil endpoint search dari API.
- Hasil pencarian ditampilkan dalam format list yang sama dengan halaman utama, mendukung infinite scroll juga.
- Menampilkan state kosong ("Tidak ada hasil untuk 'xxx'") dan state error jika request gagal.

---

## 4. Teknologi (Wajib Sesuai Referensi)

| Kebutuhan | Package |
|---|---|
| HTTP request ke News API | `http` |
| Menampilkan artikel penuh | `webview_flutter` |
| Menampilkan gambar dari network dengan cache | `cached_network_image` |

**Tambahan yang direkomendasikan (opsional, dijelaskan alasannya di `integrasi.md`):**
- `flutter_launcher_icons` — untuk generate ikon aplikasi di Android/iOS.
- `provider` atau `flutter_bloc` — state management sederhana (pilih salah satu, lihat rekomendasi di integrasi.md).
- `intl` — format tanggal/waktu relatif ("2 jam lalu").
- `flutter_dotenv` — menyimpan API key agar tidak hardcode di source code.

**Sumber data berita (API):**
Belum ditentukan API final. Rekomendasi: **NewsAPI.org** (gratis untuk development, mendukung filter kategori & search) atau **GNews API** sebagai alternatif. Detail konfigurasi endpoint dijelaskan di `integrasi.md`.

---

## 5. Struktur Layar (High-Level)

1. **Splash Screen** — logo app singkat saat load pertama.
2. **Home Screen** — tab kategori + list berita infinite scroll + search icon di AppBar.
3. **Search Screen/Mode** — hasil pencarian dengan list yang sama.
4. **Detail Screen** — WebView artikel.

Detail visual & komponen ada di `desain.md`.

---

## 6. Kriteria Sukses (Definition of Done - versi awal)

- [ ] Aplikasi berhasil dijalankan di HP fisik (Android) via `flutter run`.
- [ ] List berita tampil dan infinite scroll bekerja tanpa freeze/lag.
- [ ] Berpindah kategori (Olahraga/Teknologi/Bisnis) menampilkan berita yang sesuai.
- [ ] Tap berita membuka WebView dengan artikel asli.
- [ ] Fitur pencarian mengembalikan hasil yang relevan.
- [ ] Ikon aplikasi custom sudah terpasang (bukan ikon default Flutter).
- [ ] Tidak ada error/exception yang crash saat penggunaan normal (list kosong, tidak ada internet, dsb ditangani dengan pesan error yang jelas).

---

## 7. Batasan & Risiko

- Rate limit API berita gratis biasanya terbatas (misal 100 request/hari) — perlu penanganan error & caching ringan di sisi state.
- WebView performa bisa bervariasi tergantung artikel sumber (iklan berat, dsb) — sediakan fallback "buka di browser".
- Nama kategori di API pihak ketiga mungkin berbeda format (`sports`, `technology`, `business`) — perlu mapping di layer data.