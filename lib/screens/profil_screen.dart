import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _authService = AuthService();
  String? _username;

  @override
  void initState() {
    super.initState();
    _muatUsername();
  }

  Future<void> _muatUsername() async {
    final username = await _authService.getLoggedInUsername();
    if (!mounted) return;
    setState(() => _username = username);
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        const Center(
          child: CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Username'),
            subtitle: Text(_username ?? '-'),
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) {
            final isDark = mode == ThemeMode.dark;
            return Card(
              child: SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Mode Gelap'),
                subtitle: Text(isDark ? 'Aktif' : 'Nonaktif'),
                value: isDark,
                onChanged: (value) {
                  simpanThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _logout,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}
