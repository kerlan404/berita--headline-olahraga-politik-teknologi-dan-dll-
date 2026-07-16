# Roadmap - Aplikasi Berita & Headline
**Tipe proyek:** Tugas sekolah, dikerjakan kelompok kecil (2-3 orang)
**Model waktu:** Berbasis milestone (bukan tanggal kaku), karena deadline belum pasti
**Dokumen terkait:** `prd.md`, `desain.md`, `integrasi.md`

Tujuan dokumen ini: memberi arah jelas "abis ini ngerjain apa" untuk tim dan AI, plus menyiapkan jalur menuju presentasi/laporan sekolah — bukan cuma bikin fitur terus-terusan tanpa arah.

---

## 1. Fase Pengembangan (Milestone)

### Milestone 0 — Fondasi (Selesai ✅)
- `prd.md`, `desain.md`, `integrasi.md` sudah dibuat.
- **Output:** dokumen acuan tim, semua anggota paham scope & desain sebelum ngoding.

### Milestone 1 — MVP (Minimum Viable Product)
Fokus: fitur inti bisa jalan, belum perlu sempurna.
- [ ] Setup project Flutter + struktur folder (`integrasi.md` Section 1)
- [ ] Home screen: list berita + kategori (Olahraga/Teknologi/Bisnis) + infinite scroll
- [ ] Detail berita via WebView
- [ ] Pencarian berita
- [ ] Ikon aplikasi custom terpasang
- [ ] Bisa dijalankan & ditest di HP fisik
- **Definisi selesai:** semua checklist di `prd.md` Section 6 tercentang.

### Milestone 2 — Stabilisasi
Fokus: bikin MVP nggak gampang error, enak dipakai.
- [ ] Error handling lengkap (no internet, API gagal, data kosong) — sesuai `integrasi.md` Section 2.5
- [ ] Uji di lebih dari 1 HP (kalau bisa beda ukuran layar/merek)
- [ ] Bersihkan warning dari `flutter analyze`
- [ ] Review UI dibanding `desain.md` — pastikan konsisten (warna, spacing, font)
- **Definisi selesai:** checklist "Siap Ditest User" di `integrasi.md` Section 7 tercentang.

### Milestone 3 — Persiapan Presentasi & Laporan *(prioritas kalian sekarang)*
Detail lengkap ada di Section 3 dan Section 4 dokumen ini.

### Milestone 4 — Pengembangan Lanjutan *(opsional, kalau masih ada waktu setelah Milestone 3)*
Ide fitur tambahan yang bisa dikerjakan bertahap, urut dari yang paling gampang & paling menambah nilai presentasi:
- [ ] Bookmark/simpan berita favorit (local storage pakai `shared_preferences`)
- [ ] Dark/Light theme toggle
- [ ] Kategori tambahan (Hiburan, Kesehatan, dst)
- [ ] Share berita ke aplikasi lain (`share_plus`)
- [ ] Widget "Breaking News" banner di atas Home (mirip ESPN "Live" badge)
- [ ] Mode offline sederhana (cache list terakhir yang dibuka)

> Aturan: jangan mulai Milestone 4 sebelum Milestone 2 & 3 selesai. Fitur baru yang menumpuk di atas aplikasi yang belum stabil akan menyulitkan presentasi & demo.

---

## 2. Pembagian Tugas Tim (2-3 Orang)

Karena tim kecil, pembagian berbasis **layer**, bukan per-fitur, supaya tidak saling tunggu dan gampang digabung (merge) di Git.

| Peran | Tanggung Jawab | Referensi Dokumen |
|---|---|---|
| **A — UI/UX Developer** | Semua widget & screen (Home, Search, Detail), styling sesuai `desain.md`, ikon aplikasi | `desain.md` |
| **B — Data/API Developer** | Service API, model data, repository, mapping kategori, error handling | `integrasi.md` Section 2 |
| **C — Integrasi & QA** *(kalau ada 3 orang, kalau cuma 2 orang tugas ini dibagi ke A & B)* | Menghubungkan UI ↔ Provider ↔ Repository, testing di HP, dokumentasi/laporan | `integrasi.md` Section 3-5, dokumen ini Section 3-4 |

**Rekomendasi kerja tim kecil:**
- Pakai **Git branch per orang** (`feature/ui-home`, `feature/api-service`, dst), lalu merge ke `main` setelah dites masing-masing.
- Sepakati dulu bentuk **model data** (`NewsArticle`) dan **struktur folder** di awal (sudah ada di `integrasi.md`) supaya A dan B bisa kerja paralel tanpa saling nunggu.
- Sinkron rutin (walau nggak ada deadline) — misal tiap beberapa hari sekali cek progres bareng, biar nggak ada yang stuck lama tanpa ketahuan.

---

## 3. Persiapan Presentasi (Demo)

### 3.1 Alur Demo yang Disarankan
1. **Buka dengan masalah/latar belakang** — kenapa bikin aplikasi berita (ambil dari `prd.md` Section 1).
2. **Tunjukkan alur utama secara langsung di HP:**
   - Buka app → tampil list berita + ikon custom kelihatan di homescreen (poin plus visual).
   - Scroll infinite scroll → tunjukkan berita nambah otomatis.
   - Pindah kategori (Olahraga → Teknologi → Bisnis).
   - Tap berita → WebView kebuka.
   - Pakai fitur search → tunjukkan hasil relevan.
3. **Tunjukkan penanganan error** (poin plus teknis) — misal matikan WiFi sebentar, tunjukkan pesan error yang rapi, bukan crash.
4. **Tutup dengan arsitektur singkat** — jelaskan alur `Screen → Provider → Repository → Service` pakai diagram sederhana, tunjukkan bahwa kode terstruktur rapi (bukan asal-asalan).
5. **Sebutkan potensi pengembangan** — ambil dari Milestone 4, tunjukkan tim sudah mikir ke depan.

### 3.2 Yang Perlu Disiapkan Sebelum Hari-H
- [ ] APK yang sudah di-build (`flutter build apk --release`) sebagai cadangan kalau demo langsung dari laptop/HP bermasalah.
- [ ] Screenshot tiap layar (Home, Search, Detail, Empty state, Error state) untuk slide/laporan.
- [ ] Skrip demo singkat ditulis & dilatih (biar nggak nge-blank pas presentasi).
- [ ] Backup: kalau internet di lokasi presentasi jelek/nggak ada, siapkan skenario alternatif (misal video rekaman demo sebagai cadangan).

---

## 4. Struktur Laporan Tertulis

Format berikut mengikuti struktur laporan tugas/proyek sekolah pada umumnya (bisa disesuaikan dengan format yang diminta guru/sekolah kalian):

**BAB I — Pendahuluan**
- Latar Belakang *(dari `prd.md` Section 1)*
- Rumusan Masalah
- Tujuan Proyek *(dari `prd.md` Section 1)*
- Manfaat

**BAB II — Landasan Teori**
- Pengenalan Flutter & Dart
- Penjelasan singkat teknologi yang dipakai: `http`, `webview_flutter`, `cached_network_image` *(dari `prd.md` Section 4)*
- Pengenalan REST API / News API yang digunakan

**BAB III — Analisis & Perancangan Sistem**
- Deskripsi Fitur *(dari `prd.md` Section 3)*
- Perancangan UI/UX *(dari `desain.md`, sertakan wireframe/screenshot)*
- Arsitektur Aplikasi *(dari `integrasi.md` Section 1, sertakan diagram struktur folder/alur data)*

**BAB IV — Implementasi & Pengujian**
- Implementasi tiap fitur (screenshot + potongan kode penting)
- Hasil pengujian (checklist dari `prd.md` Section 6 & `integrasi.md` Section 7 — tampilkan sebagai tabel "Fitur / Status / Keterangan")
- Kendala yang dihadapi & cara mengatasi *(ambil dari pengalaman nyata tim selama Milestone 1-2)*

**BAB V — Penutup**
- Kesimpulan
- Saran / Rencana Pengembangan Lanjutan *(dari Milestone 4 dokumen ini)*

**Lampiran**
- Link/QR code repository (jika ada)
- Screenshot tambahan
- Pembagian tugas tim *(dari Section 2 dokumen ini)*

---

## 5. Ringkasan Prioritas Saat Ini

Urutan kerja yang disarankan mulai sekarang:
1. Selesaikan sisa checklist **Milestone 1 (MVP)** jika belum 100%.
2. Selesaikan **Milestone 2 (Stabilisasi)** — jangan skip, karena demo yang error di depan kelas lebih merugikan daripada kekurangan fitur.
3. Mulai kerjakan **Milestone 3**: siapkan screenshot, skrip demo, dan mulai nyicil laporan pakai struktur Section 4 — bisa dikerjakan paralel dengan Milestone 2 oleh anggota tim yang berbeda.
4. Kalau masih ada waktu & laporan sudah aman, baru lirik **Milestone 4** untuk nambah nilai plus di presentasi.