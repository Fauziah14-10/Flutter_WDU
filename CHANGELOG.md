# Changelog

Semua perubahan penting pada proyek Flutter ini akan dicatat dalam file ini.

Format penulisan mengikuti:
- Keep a Changelog (https://keepachangelog.com/en/1.1.0/)
- Semantic Versioning (https://semver.org/)

---

## [Belum Dirilis]
### Ditambahkan
- 

### Diubah
- 

### Diperbaiki
- 

---

## [1.1.0] - 23 Februari 2026
### Ditambahkan
- Halaman daftar survei di dalam dashboard (`lib/pages`)
- Pemetaan model survei dari API (`lib/models`)
- Service API untuk survei dan autentikasi (`lib/service`)
- Komponen UI yang dapat digunakan ulang (`lib/widgets`)
- Helper penyimpanan lokal (`lib/utils`)
- Penambahan aset gambar untuk branding (`assets/images`)

### Diubah
- Refactor struktur service API
- Perbaikan navigasi antar halaman
- Penyesuaian layout dashboard untuk Web

### Diperbaiki
- Tombol tidak muncul pada versi Web
- Masalah pemetaan endpoint API
- State tidak ter-update setelah menerima respons API

---

## [1.0.0] - 20 Februari 2026
### Ditambahkan
- Setup awal proyek Flutter
- Halaman login
- Halaman dashboard
- Integrasi API menggunakan HTTP
- Penyimpanan token menggunakan SharedPreferences
- Dukungan build Web, Windows, macOS, dan Linux

### Diperbaiki
- Kesalahan parsing JSON
- Masalah overflow tampilan pada Web
