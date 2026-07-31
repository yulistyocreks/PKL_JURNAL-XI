import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/jurnal_service.dart';
import 'riwayat_screen.dart';

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
  bool _draftTersimpan = false;

  DateTime _tanggalDipilih = DateTime.now();
  int? _hariManual;
  bool _editManual = false;

  final _formatTanggal = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _muatData();
    _aktivitasController.addListener(_onTypingAutoSave);
  }

  @override
  void dispose() {
    _aktivitasController.removeListener(_onTypingAutoSave);
    _aktivitasController.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final username = await _authService.getLoggedInUsername();
    if (username == null) return;
    final entries = await _jurnalService.getEntries(username);
    final draft = await _jurnalService.ambilDraft(username);
    if (!mounted) return;
    setState(() {
      _username = username;
      _entries = entries;
      _loading = false;
      if (draft != null && draft.isNotEmpty) {
        _aktivitasController.text = draft;
      }
    });
  }

  String get _tanggalIso => DateFormat('yyyy-MM-dd').format(_tanggalDipilih);

  String get _tanggalText {
    try {
      return _formatTanggal.format(_tanggalDipilih);
    } catch (_) {
      return DateFormat('EEEE, d MMMM yyyy').format(_tanggalDipilih);
    }
  }

  int get _hariBerikutnya => _hariManual ?? (_entries.length + 1);

  void _onTypingAutoSave() {
    if (_username == null) return;
    _jurnalService.simpanDraft(_username!, _aktivitasController.text);
    setState(() => _draftTersimpan = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _draftTersimpan = false);
    });
  }

  Future<void> _pilihTanggalManual() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (hasil != null) setState(() => _tanggalDipilih = hasil);
  }

  Future<void> _simpan() async {
    final aktivitas = _aktivitasController.text.trim();
    if (aktivitas.isEmpty || _username == null) return;

    setState(() => _saving = true);
    await _jurnalService.addEntry(_username!, aktivitas, _tanggalIso, hariKeManual: _hariManual);
    await _jurnalService.hapusDraft(_username!);
    final entries = await _jurnalService.getEntries(_username!);

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _saving = false;
      _aktivitasController.clear();
      _hariManual = null;
      _editManual = false;
      _tanggalDipilih = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aktivitas berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Aktivitas PKL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (_draftTersimpan)
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 13, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('Tersimpan otomatis', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_editManual)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          initialValue: '$_hariBerikutnya',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Hari ke', isDense: true),
                          onChanged: (v) => _hariManual = int.tryParse(v),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pilihTanggalManual,
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: Text(DateFormat('d/M/yyyy').format(_tanggalDipilih)),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _editManual = false),
                        icon: const Icon(Icons.check, color: Colors.green),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Chip(label: Text('Hari ke-$_hariBerikutnya')),
                      const SizedBox(width: 8),
                      Flexible(child: Text(_tanggalText)),
                      IconButton(
                        onPressed: () => setState(() => _editManual = true),
                        icon: const Icon(Icons.edit, size: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _aktivitasController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Tulis aktivitas hari ini', alignLabelWithHint: true),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _simpan,
                    icon: _saving
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save),
                    label: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            if (_username == null) return;
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RiwayatScreen(username: _username!)),
            );
            _muatData();
          },
          icon: const Icon(Icons.history),
          label: const Text('Lihat Semua Riwayat'),
        ),
      ],
    );
  }
}
