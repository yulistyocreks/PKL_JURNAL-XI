# Aktivitas PKL MU

Aplikasi jurnal harian PKL berbasis Flutter. Semua data (akun & jurnal) disimpan **offline** di perangkat memakai `shared_preferences`.

## Alur Aplikasi
1. Splash Screen (logo + nama app, 2.5 detik) → Login
2. Login → username otomatis terisi dari login terakhir
   - Lupa Sandi → loading 3 detik → Ganti Password → kembali ke Login
   - Tambah Akun → daftar akun baru → kembali ke Login
3. Home (2 menu bawah): Aktivitas PKL & Profil
   - Aktivitas PKL: hari ke-otomatis, tanggal otomatis, tulis aktivitas, simpan, riwayat jurnal
   - Profil: info username, tombol logout

## Cara Menjalankan Lokal
```bash
flutter pub get
flutter run
```

## Build APK via GitHub Actions
1. Push/commit folder ini ke repo GitHub kamu.
2. Buka tab **Actions** di GitHub, workflow "Build APK" akan otomatis jalan setiap push ke branch `main` (atau jalankan manual lewat "Run workflow").
3. Setelah selesai (centang hijau), unduh APK di bagian **Artifacts** hasil run tersebut.

> Catatan: workflow ini pakai Flutter 3.32.0, sesuai versi yang sudah pernah berhasil build di proyek Toko_On kamu sebelumnya.

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
    profil_screen.dart
  services/
    auth_service.dart
    jurnal_service.dart
.github/workflows/build.yml
```
