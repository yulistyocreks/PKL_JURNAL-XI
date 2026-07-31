import 'package:flutter/material.dart';
import '../main.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Icon(Icons.menu_book_rounded, size: 34, color: scheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('XI JURNAL PKL', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          Center(child: Text('Versi $appVersion', style: TextStyle(color: Colors.grey.shade600))),
          const SizedBox(height: 6),
          const Center(child: Text('Dibuat oleh yulistyocreks')),
          const SizedBox(height: 24),
          const Text('Riwayat Update', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('• v2.0.11 — Pencarian, filter, ekspor PDF, backup & restore, statistik, feedback WhatsApp'),
          const SizedBox(height: 4),
          const Text('• v1.9.0 — Foto profil dari galeri, swipe navigasi, jumlah akun'),
          const SizedBox(height: 4),
          const Text('• v1.0.0 — Rilis awal'),
        ],
      ),
    );
  }
}
