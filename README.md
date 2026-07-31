# XI JURNAL PKL

Aplikasi jurnal harian PKL berbasis Flutter. Semua data (akun & jurnal) tersimpan **offline** di perangkat memakai `shared_preferences` — tidak butuh internet untuk dipakai sehari-hari.

**Versi saat ini: 2.0.11**

## Apa itu APK ini?

APK adalah file instalasi aplikasi Android — sama seperti file `.exe` di Windows, tapi untuk HP Android. File `XI-JURNAL_PKL-arm64.apk` yang dihasilkan dari repo ini bisa langsung diinstall di HP Android tanpa perlu Play Store, cukup download filenya lalu buka dari HP.

Setiap kali ada perubahan kode di branch `main`, GitHub Actions otomatis membangun ulang APK-nya (lihat bagian **Cara Build APK** di bawah).

## Alur Aplikasi

```
Buka APK
   │
Splash Screen (logo, 2.5 detik)
   │
   ├─ Ingat Saya aktif? ──Ya──▶ langsung ke Home
   │
   Tidak
   │
   ▼
Login ──┬── Lupa Sandi → loading 3 detik → Ganti Password → kembali ke Login
        └── Tambah Akun → daftar akun baru → kembali ke Login
   │
   ▼
Home (bisa swipe kiri-kanan, atau tap ikon bawah)
 ┌────────────────┴────────────────┐
 │                                  │
Aktivitas PKL                    Profil
 │                                  │
 ├─ Hari ke- & tanggal otomatis    ├─ Foto profil (ganti dari galeri)
 │  (bisa diedit manual)           ├─ Tap "Profil" → lihat jumlah akun
 ├─ Tulis aktivitas (auto-save)    ├─ Statistik PKL
 ├─ Tombol Simpan                  ├─ Pengaturan
 └─ Lihat Semua Riwayat            │   ├─ Pengingat Harian
     │                             │   ├─ Backup & Restore data
     ▼                             │   ├─ Feedback → buka WhatsApp
   Riwayat Jurnal (layar penuh)    │   └─ Tentang Aplikasi
     ├─ Cari (tanggal/kata kunci)  ├─ Tambah Akun
     ├─ Filter (Harian/Mingguan/   └─ Logout
     │   Bulanan)
     ├─ Edit tiap entri
     ├─ Hapus (dengan konfirmasi)
     └─ Ekspor ke PDF
```

## Fitur Lengkap

- Splash screen dengan animasi
- Login dengan username otomatis terisi dari login terakhir
- **Ingat Saya** — sekali login, tidak perlu masukkan password lagi selama belum logout
- Tambah akun & lupa sandi (loading 3 detik → ganti password)
- Tema warna biru dengan toggle **mode terang/gelap**
- Aktivitas PKL: hari ke- dan tanggal otomatis (lanjut dari entri terakhir), bisa diedit manual, auto-save draft saat mengetik
- Riwayat jurnal layar penuh: pencarian, filter (harian/mingguan/bulanan), edit, hapus dengan konfirmasi
- Ekspor jurnal ke PDF
- Backup & restore data jurnal (simpan/muat file `.json`)
- Foto profil dari galeri HP
- Jumlah akun terdaftar (tap judul "Profil")
- Statistik PKL (total hari, total jurnal)
- Feedback bug langsung ke WhatsApp
- Halaman Tentang Aplikasi (versi, pembuat, riwayat update)
- Semua data disimpan **offline** di perangkat

## Cara Menjalankan Lokal (opsional, untuk development)

Butuh Flutter SDK terpasang di komputer:
```bash
flutter pub get
flutter run
```

## Cara Build APK (tanpa install Flutter di komputer)

Build APK dilakukan otomatis lewat GitHub Actions, jadi kamu **tidak perlu install Flutter di laptop/HP**:

1. Commit perubahan kode ke branch `main`
2. Buka tab **Actions** di repo GitHub ini
3. Tunggu proses build selesai (5–20 menit, tergantung apakah cache tersedia)
4. Kalau hasilnya centang hijau, klik run tersebut → scroll ke bawah → download di bagian **Artifacts**
5. Pilih **`XI-JURNAL_PKL-arm64.apk`** untuk HP modern (2018 ke atas), atau **`XI-JURNAL_PKL-armv7.apk`** untuk HP lawas

## Cara Install APK di HP

1. Download file `.apk` dari Artifacts
2. Buka file itu dari HP (lewat notifikasi download atau File Manager)
3. Kalau muncul peringatan "sumber tidak dikenal", izinkan instalasi dari sumber tersebut (ini normal untuk APK di luar Play Store)
4. Tunggu proses install selesai, buka aplikasinya

## Struktur Folder

```
lib/
  main.dart
  screens/
    splash_screen.dart
    login_screen.dart
    register_screen.dart
    forgot_password_screen.dart
    reset_password_screen.dart
    home_screen.dart
    aktivitas_screen.dart
    riwayat_screen.dart
    profil_screen.dart
    pengaturan_screen.dart
    statistik_screen.dart
    tentang_screen.dart
  services/
    auth_service.dart
    jurnal_service.dart
    profile_service.dart
.github/workflows/build.yml
```

## Rencana Ke Depan

Versi besar berikutnya (sekitar v2.5.0) direncanakan pindah dari penyimpanan lokal ke server Firebase, dengan dua peran pengguna: **Admin** (pembimbing/guru) dan **Pengguna** (siswa PKL).

### Kenapa Admin Bisa Melihat Jurnal Siswa?

Jurnal PKL secara fungsi memang dibuat untuk diperiksa oleh pembimbing — sama seperti jurnal PKL fisik yang selama ini ditulis tangan dan rutin ditandatangani pembimbing setiap minggu. Fitur Admin di aplikasi ini menggantikan proses itu secara digital, bukan menciptakan pengawasan baru yang sebelumnya tidak ada.

Data yang bisa dilihat Admin dibatasi hanya isi jurnal aktivitas PKL — bukan password siswa, bukan chat pribadi, dan bukan data lain di luar konteks laporan PKL.

### Risiko yang Harus Diwaspadai

Sistem seperti ini punya risiko nyata jika tidak dijaga dengan baik:

- Jika akun Admin dibajak (password bocor, phishing, dll), pembajak bisa melihat jurnal semua siswa sekaligus — ini risiko yang jauh lebih besar dibanding akun siswa biasa yang cuma menyimpan data sendiri.
- Karena itu, akun Admin **wajib** memakai keamanan berlapis (misalnya verifikasi dua langkah), dan jumlah akun Admin harus dibatasi seminim mungkin — idealnya hanya pembimbing yang benar-benar berwenang.
- Ke depannya, setiap akses Admin ke data siswa akan dicatat (log) — supaya kalau ada penyalahgunaan, bisa dilacak siapa yang membuka data siapa dan kapan.

Fitur ini akan dirancang dengan prinsip **akses seminimal mungkin** — Admin hanya bisa melihat, tidak bisa mengedit atau menghapus data siswa atas nama siswa tersebut.
