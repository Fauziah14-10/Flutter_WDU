    # Changelog

Semua perubahan penting pada proyek Flutter ini akan dicatat dalam file ini.

Format penulisan mengikuti:
- Keep a Changelog (https://keepachangelog.com/en/1.1.0/)
- Semantic Versioning (https://semver.org/)

---

## [1.1.0] - 26 Februari 2026
### Ditambahkan
- Menambah project_tj page untuk melihat project client
- Menambahkan halaman detail_responden untuk monitoring dan analisis responden
- Merapihkan desain halaman add_question 


### Diubah
- 

## [1.1.0] - 25 Februari 2026
### Ditambahkan
- Menammbah paragraf, image dan add page di halaman add_question

### Diubah
- Mengubah sedikit desain dashboard dengan menambahkan page client
- Mengubah desain create survey page


## [1.1.0] - 24 Februari 2026
### Ditambahkan
- Halaman add_question untuk menambahkan pertanyaan ke dalam survei
- Halaman cek_edit_survey untuk melihat dan mengubah data survei 
- Halaman monitor_survey untuk memantau respon dan aktivitas pengisian survei
- Halaman add_question untuk menambah pertanyaan survey

### Diubah
- 

### Diperbaiki
- 

---

## [1.1.0] - 23 Februari 2026
### Ditambahkan
- Pemetaan model survei dari API (`lib/models`)
- Service API untuk survei dan autentikasi (`lib/service`)
- Komponen UI yang dapat digunakan ulang (`lib/widgets`)
- Penambahan aset gambar untuk branding (`assets/images`)
- Halaman province_target untuk menampilkan lokasi yang tersedia untuk target provinsi pengisi survey
- Halaman create survey untuk menginput kuisioner baru

### Diubah
- Refactor struktur service API
- Perbaikan navigasi antar halaman
- Penyesuaian layout dashboard untuk Web
- 

### Diperbaiki
- Masalah pemetaan endpoint API
- State tidak ter-update setelah menerima respons API

---

## [1.0.0] - 20 Februari 2026
### Ditambahkan
- Setup awal proyek Flutter
- Halaman login
- Halaman dashboard
- Helper penyimpanan lokal (`lib/utils`)
- Integrasi API menggunakan HTTP
- Penyimpanan token menggunakan SharedPreferences

### Diperbaiki
- Kesalahan parsing JSON
