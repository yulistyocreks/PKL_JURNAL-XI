import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_screen.dart';
import 'pengaturan_screen.dart';
import 'statistik_screen.dart';
import 'register_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _authService = AuthService();
  final _profileService = ProfileService();
  String? _username;
  String? _fotoPath;
  int? _jumlahAkun;
  bool _tampilJumlahAkun = false;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final username = await _authService.getLoggedInUsername();
    if (username == null) return;
    final foto = await _profileService.ambilPathFoto(username);
    if (!mounted) return;
    setState(() {
      _username = username;
      _fotoPath = foto;
    });
  }

  Future<void> _gantiFoto() async {
    final picker = ImagePicker();
    final XFile? gambar = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (gambar == null || _username == null) return;
    await _profileService.simpanPathFoto(_username!, gambar.path);
    setState(() => _fotoPath = gambar.path);
  }

  Future<void> _tapJudulProfil() async {
    if (_jumlahAkun == null) {
      final jumlah = await _authService.jumlahAkunTerdaftar();
      if (!mounted) return;
      setState(() => _jumlahAkun = jumlah);
    }
    setState(() => _tampilJumlahAkun = !_tampilJumlahAkun);
  }

  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );
    if (konfirmasi != true) return;
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          onTap: _tapJudulProfil,
          child: const Text('Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        if (_tampilJumlahAkun && _jumlahAkun != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('$_jumlahAkun akun terdaftar di perangkat ini',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(height: 20),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _fotoPath != null ? FileImage(File(_fotoPath!)) : null,
                child: _fotoPath == null ? const Icon(Icons.person, size: 40) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _gantiFoto,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text(_username ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistik PKL'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (_username != null) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => StatistikScreen(username: _username!)));
              }
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (_username != null) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => PengaturanScreen(username: _username!)));
              }
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Tambah Akun'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('Versi ${appVersion}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ),
      ],
    );
  }
}
