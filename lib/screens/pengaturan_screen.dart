import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/profile_service.dart';
import 'tentang_screen.dart';

class PengaturanScreen extends StatefulWidget {
  final String username;
  const PengaturanScreen({super.key, required this.username});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final _profileService = ProfileService();
  bool _pengingatAktif = true;

  Future<void> _bukaWhatsapp() async {
    const nomor = '6282139930366'; // format internasional tanpa '+'
    final uri = Uri.parse('https://wa.me/$nomor?text=${Uri.encodeComponent('Halo, saya mau kirim feedback/bug untuk aplikasi XI JURNAL PKL: ')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka WhatsApp')));
    }
  }

  Future<void> _backup() async {
    final jsonStr = await _profileService.backupJson(widget.username);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan backup jurnal',
      fileName: 'backup_jurnal_${widget.username}.json',
      bytes: Uint8List_from(jsonStr),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path != null ? 'Backup berhasil disimpan' : 'Backup dibatalkan')),
    );
  }

  Future<void> _restore() async {
    final hasil = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (hasil == null || hasil.files.single.path == null) return;
    final file = File(hasil.files.single.path!);
    final jsonStr = await file.readAsString();
    await _profileService.restoreJson(widget.username, jsonStr);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil di-restore')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active),
              title: const Text('Pengingat Harian'),
              subtitle: const Text('Notifikasi isi jurnal jam 19:00'),
              value: _pengingatAktif,
              onChanged: (v) => setState(() => _pengingatAktif = v),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup Data Jurnal'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _backup,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Data Jurnal'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _restore,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('Feedback (Kirim Bug ke WhatsApp)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _bukaWhatsapp,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Aplikasi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TentangScreen())),
            ),
          ),
        ],
      ),
    );
  }
}
