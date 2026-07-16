# Desain UI/UX - Aplikasi Berita & Headline
**Inspirasi:** ESPN App (mobile)
**Tujuan Dokumen:** Menjadi acuan tetap agar AI/developer tidak membuat desain yang ngaco atau tidak konsisten selama pengembangan.

---

## 1. Prinsip Desain (Gaya ESPN)

ESPN dikenal dengan:
- **Dark theme dominan** — background gelap agar konten (foto, video) menonjol, mengurangi kelelahan mata saat scroll lama.
- **Aksen warna berani** (merah/oranye) untuk elemen aktif, badge kategori, dan call-to-action.
- **Tipografi tebal & besar** untuk headline — judul berita adalah pusat perhatian, bukan dekorasi.
- **Card berbasis gambar besar** — thumbnail berita dominan, teks pendek dan padat.
- **Navigasi horizontal tab** untuk kategori/liga, cepat di-swipe.
- **Informasi padat tapi rapi** — waktu, sumber, kategori ditampilkan kecil namun jelas (label/badge).

Prinsip ini akan diterapkan dengan konteks "berita umum" (bukan hanya olahraga), tapi nuansa visualnya tetap mengikuti ESPN.

---

## 2. Palet Warna

| Nama | Hex | Penggunaan |
|---|---|---|
| Background utama | `#121212` | Background layar (dark) |
| Surface / Card | `#1E1E1E` | Background card berita |
| Primary Accent | `#D50000` | Tombol aktif, tab terpilih, badge "LIVE"/breaking |
| Secondary Accent | `#FF6D00` | Highlight sekunder (opsional, badge kategori tertentu) |
| Teks Utama | `#FFFFFF` | Judul berita |
| Teks Sekunder | `#B3B3B3` | Sumber, waktu, deskripsi |
| Divider/Border | `#2C2C2C` | Garis pemisah antar card/section |
| Success/Info | `#00C853` | Status koneksi/loading sukses (jarang dipakai) |

> Catatan: sediakan juga light theme opsional di masa depan, tapi **dark theme adalah default** karena sesuai identitas ESPN.

---

## 3. Tipografi

- Font: `Roboto Condensed` atau `Inter` (font system default Flutter juga boleh jika ingin hemat waktu build awal).
- Hierarki:
  - **Headline Card (list):** 16–18sp, bold, max 2 baris (ellipsis jika lebih).
  - **Headline Detail:** 20–22sp, bold.
  - **Body/Deskripsi:** 13–14sp, regular, warna teks sekunder.
  - **Label kategori/waktu:** 11–12sp, uppercase untuk kategori (mirip ESPN badge liga), warna aksen.

---

## 4. Struktur Layar

### 4.1 Home Screen
```
┌───────────────────────────────┐
│ [Logo App]         [🔍 Search]│  ← AppBar, background gelap
├───────────────────────────────┤
│ [Semua][Olahraga][Tekno][Bisnis]│ ← Tab kategori, horizontal scroll,
│                                 │   tab aktif diberi underline/pill merah
├───────────────────────────────┤
│ ┌─────────────────────────────┐│
│ │  [ Gambar besar 16:9 ]      ││ ← Card berita utama (hero card)
│ │  KATEGORI · 2 jam lalu       ││
│ │  Judul Berita Besar Tebal    ││
│ └─────────────────────────────┘│
│ ┌───────┐ Judul berita pendek  │ ← Card list biasa (gambar kecil kiri,
│ │ img   │ Sumber · waktu       │   teks di kanan)
│ └───────┘                      │
│ ┌───────┐ Judul berita...      │
│ │ img   │ Sumber · waktu       │
│ └───────┘                      │
│         ⟳ loading more...      │ ← Indicator infinite scroll
└───────────────────────────────┘
```

**Detail komponen:**
- Card pertama tiap kategori bisa dibuat "hero card" (gambar besar) untuk kesan headline utama, sisanya list card standar (gambar kiri, teks kanan).
- Tab kategori: pill/underline berwarna primary accent saat aktif, teks abu-abu saat tidak aktif.
- Badge kategori pada card: teks kecil uppercase warna aksen di atas judul.

### 4.2 Search Mode
- AppBar berubah menjadi search field aktif (ikon search di-tap → field muncul, keyboard auto-fokus).
- Real-time atau debounce 400–600ms saat user mengetik, lalu panggil API search.
- Hasil pencarian pakai card style sama dengan home (list card biasa, tanpa hero card).
- Empty state: ilustrasi/icon + teks "Tidak ada berita untuk '...'" di tengah layar.

### 4.3 Detail Screen (WebView)
```
┌───────────────────────────────┐
│ [←]   Judul Singkat   [⋮ Share]│ ← AppBar gelap, judul dipotong ellipsis
├───────────────────────────────┤
│                                 │
│         [ WebView Artikel ]    │
│                                 │
├───────────────────────────────┤
│   [ Buka di Browser ]          │ ← tombol fallback, muncul kalau perlu
└───────────────────────────────┘
```
- Loading progress bar tipis di bawah AppBar saat WebView memuat (bukan full-screen spinner, agar terasa cepat).
- Jika WebView error (no internet / gagal load), tampilkan pesan + tombol retry & tombol "buka di browser".

---

## 5. Komponen Reusable (Widget)

| Komponen | Deskripsi |
|---|---|
| `NewsCard` | Card list standar (gambar kiri, teks kanan) — dipakai di home & search |
| `NewsHeroCard` | Card besar untuk berita utama tiap kategori |
| `CategoryTabBar` | Tab horizontal scroll kategori |
| `SearchAppBar` | AppBar dengan mode toggle search |
| `LoadingIndicator` | Spinner kecil untuk infinite scroll & pull to refresh |
| `EmptyState` | Widget generik untuk state kosong (search kosong, no internet) |
| `ErrorRetryWidget` | Widget error + tombol retry, dipakai di semua layar yang fetch data |

Semua komponen dark-theme by default, gunakan warna dari tabel Section 2 secara konsisten (idealnya didefinisikan di satu file `app_theme.dart`, bukan hardcode warna di tiap widget).

---

## 6. Ikon Aplikasi

- Ikon app harus custom (bukan default Flutter), dengan gaya:
  - Background gelap atau merah aksen (`#D50000` atau `#121212`).
  - Simbol sederhana: misal huruf inisial app / ikon "play/headline" minimalis — hindari detail rumit karena ukuran kecil di homescreen.
- Format: PNG 1024x1024 sebagai source, di-generate ke semua ukuran via `flutter_launcher_icons` (lihat `integrasi.md` untuk langkah teknisnya).

---

## 7. Aturan Konsistensi (Wajib Diikuti AI/Developer)

1. **Jangan** memakai warna di luar palet Section 2 kecuali untuk state khusus (error merah beda tone boleh, tapi tetap dark theme).
2. **Jangan** membuat light theme sebagai default.
3. Semua card berita **wajib** pakai `cached_network_image` untuk gambar (jangan `Image.network` polos) — selain sesuai PRD, juga menjaga performa scroll.
4. Spacing konsisten: padding card 12–16px, jarak antar card 8–12px.
5. Semua teks judul di card **wajib** dibatasi max 2 baris dengan ellipsis, jangan biarkan card melebar tidak beraturan.