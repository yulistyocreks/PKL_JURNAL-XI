import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/jurnal_service.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final _authService = AuthService();
  final _jurnalService = JurnalService();
  final _aktivitasController = TextEditingController();

  String? _username;
  List<JurnalEntry> _entries = [];
  bool _loading = true;
  bool _saving = false;

  final _tanggalHariIni = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final username = await _authService.getLoggedInUsername();
    if (username == null) return;
    final entries = await _jurnalService.getEntries(username);
    if (!mounted) return;
    setState(() {
      _username = username;
      _entries = entries;
      _loading = false;
    });
  }

  String get _tanggalHariIniText {
    try {
      return _tanggalHariIni.format(DateTime.now());
    } catch (_) {
      // Fallback jika locale id_ID belum ter-load.
      return DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    }
  }

  Future<void> _simpan() async {
    final aktivitas = _aktivitasController.text.trim();
    if (aktivitas.isEmpty || _username == null) return;

    setState(() => _saving = true);
    await _jurnalService.addEntry(_username!, aktivitas, _tanggalHariIniText);
    final entries = await _jurnalService.getEntries(_username!);

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _saving = false;
      _aktivitasController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aktivitas berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hariKeBerikutnya = _entries.length + 1;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Aktivitas PKL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(label: Text('Hari ke-$hariKeBerikutnya')),
                    const SizedBox(width: 8),
                    Flexible(child: Text(_tanggalHariIniText)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _aktivitasController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Tulis aktivitas hari ini',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _simpan,
                    icon: _saving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Riwayat Jurnal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Belum ada aktivitas yang dicatat.'),
          )
        else
          ..._entries.reversed.map(
            (e) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${e.hariKe}')),
                title: Text(e.tanggal),
                subtitle: Text(e.aktivitas),
              ),
            ),
          ),
      ],
    );
  }
}
