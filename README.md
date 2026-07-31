XI JURNAL PKL

Aplikasi jurnal harian PKL berbasis Flutter. Semua data (akun & jurnal) tersimpan offline di perangkat memakai shared_preferences — tidak butuh internet untuk dipakai sehari-hari.

Versi saat ini: 2.0.11

Apa itu APK ini?

APK adalah file instalasi aplikasi Android — sama seperti file .exe di Windows, tapi untuk HP Android. File XI-JURNAL_PKL-arm64.apk yang dihasilkan dari repo ini bisa langsung diinstall di HP Android tanpa perlu Play Store, cukup download filenya lalu buka dari HP.

Setiap kali ada perubahan kode di branch main, GitHub Actions otomatis membangun ulang APK-nya (lihat bagian Cara Build APK di bawah).

Alur Aplikasi

Buka APK → Splash Screen (logo, 2.5 detik) → kalau "Ingat Saya" aktif langsung ke Home, kalau tidak masuk ke Login. Dari Login bisa ke Lupa Sandi (loading 3 detik → Ganti Password → kembali ke Login) atau Tambah Akun (daftar akun baru → kembali ke Login). Setelah login, masuk ke Home dengan 2 menu yang bisa dipindah dengan swipe kiri-kanan atau tap ikon bawah: Aktivitas PKL dan Profil.

Aktivitas PKL — hari ke- dan tanggal otomatis (bisa diedit manual), tulis aktivitas dengan auto-save, tombol Simpan, dan tombol Lihat Semua Riwayat yang membuka Riwayat Jurnal (layar penuh, bisa cari berdasarkan tanggal/kata kunci, filter Harian/Mingguan/Bulanan, edit tiap entri, hapus dengan konfirmasi, dan ekspor ke PDF).

Profil — foto profil (ganti dari galeri), tap tulisan "Profil" untuk lihat jumlah akun terdaftar, menu Statistik PKL, menu Pengaturan (Pengingat Harian, Backup & Restore data, Feedback yang membuka WhatsApp, dan Tentang Aplikasi), menu Tambah Akun, dan Logout.

Fitur Lengkap
•Splash screen dengan animasi
•Login dengan username otomatis terisi dari login terakhir
•Ingat Saya — sekali login, tidak perlu masukkan password lagi selama belum logout
•Tambah akun & lupa sandi (loading 3 detik → ganti password)
•Tema warna biru dengan toggle mode terang/gelap
•Aktivitas PKL: hari ke- dan tanggal otomatis (lanjut dari entri terakhir), bisa diedit manual, auto-save draft saat mengetik
•Riwayat jurnal layar penuh: pencarian, filter (harian/mingguan/bulanan), edit, hapus dengan konfirmasi
•Ekspor jurnal ke PDF
•Backup & restore data jurnal (simpan/muat file .json)
•Foto profil dari galeri HP
•3Jumlah akun terdaftar (tap judul "Profil")
•Statistik PKL (total hari, total jurnal)
•Feedback bug langsung ke WhatsApp
•Halaman Tentang Aplikasi (versi, pembuat, riwayat update)
•Semua data disimpan offline di perangkat
•Cara Menjalankan Lokal (opsional, untuk development)

Butuh Flutter SDK terpasang di komputer, lalu jalankan flutter pub get diikuti flutter run.

Cara Build APK (tanpa install Flutter di komputer)

Build APK dilakukan otomatis lewat GitHub Actions, jadi kamu tidak perlu install Flutter di laptop/HP:

Commit perubahan kode ke branch main
Buka tab Actions di repo GitHub ini
Tunggu proses build selesai (5–20 menit, tergantung apakah cache tersedia)
Kalau hasilnya centang hijau, klik run tersebut → scroll ke bawah → download di bagian Artifacts
Pilih XI-JURNAL_PKL-arm64.apk untuk HP modern (2018 ke atas), atau XI-JURNAL_PKL-armv7.apk untuk HP lawas
Cara Install APK di HP
Download file .apk dari Artifacts
Buka file itu dari HP (lewat notifikasi download atau File Manager)
Kalau muncul peringatan "sumber tidak dikenal", izinkan instalasi dari sumber tersebut (ini normal untuk APK di luar Play Store)
Tunggu proses install selesai, buka aplikasinya
Struktur Folder

lib/ berisi main.dart, folder screens/ (splash_screen.dart, login_screen.dart, register_screen.dart, forgot_password_screen.dart, reset_password_screen.dart, home_screen.dart, aktivitas_screen.dart, riwayat_screen.dart, profil_screen.dart, pengaturan_screen.dart, statistik_screen.dart, tentang_screen.dart), dan folder services/ (auth_service.dart, jurnal_service.dart, profile_service.dart). Ada juga .github/workflows/build.yml di root repo.

Rencana Ke Depan

Versi besar berikutnya (sekitar v2.5.0) direncanakan pindah dari penyimpanan lokal ke server Firebase, dengan dua peran pengguna: Admin (bisa melihat jurnal semua siswa) dan Pengguna (siswa PKL biasa, hanya melihat jurnal sendiri).
