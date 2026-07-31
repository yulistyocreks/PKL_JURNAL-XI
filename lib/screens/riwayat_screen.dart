import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../services/jurnal_service.dart';

class RiwayatScreen extends StatefulWidget {
  final String username;
  const RiwayatScreen({super.key, required this.username});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final _jurnalService = JurnalService();
  List<JurnalEntry> _semua = [];
  bool _loading = true;
  String _cari = '';
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final entries = await _jurnalService.getEntries(widget.username);
    if (!mounted) return;
    setState(() {
      _semua = entries;
      _loading = false;
    });
  }

  List<JurnalEntry> get _terfilter {
    final now = DateTime.now();
    return _semua.where((j) {
      final tgl = DateTime.parse(j.tanggalIso);
      final cocokCari = _cari.trim().isEmpty ||
          j.aktivitas.toLowerCase().contains(_cari.toLowerCase()) ||
          j.tanggalIso.contains(_cari);
      bool cocokFilter = true;
      if (_filter == 'Harian') {
        cocokFilter = tgl.year == now.year && tgl.month == now.month && tgl.day == now.day;
      } else if (_filter == 'Mingguan') {
        cocokFilter = now.difference(tgl).inDays <= 7;
      } else if (_filter == 'Bulanan') {
        cocokFilter = tgl.year == now.year && tgl.month == now.month;
      }
      return cocokCari && cocokFilter;
    }).toList();
  }

  Future<void> _hapus(JurnalEntry entry) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus jurnal ini?'),
        content: const Text('Data yang sudah dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (konfirmasi != true) return;
    await _jurnalService.deleteEntry(widget.username, entry.id);
    _muat();
  }

  Future<void> _editDialog(JurnalEntry entry) async {
    final controller = TextEditingController(text: entry.aktivitas);
    final hasil = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Hari ke-${entry.hariKe}'),
        content: TextField(controller: controller, maxLines: 4, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Simpan')),
        ],
      ),
    );
    if (hasil == null || hasil.trim().isEmpty) return;
    await _jurnalService.updateEntry(widget.username, entry.copyWith(aktivitas: hasil.trim()));
    _muat();
  }

  Future<void> _eksporPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(text: 'Jurnal PKL - ${widget.username}'),
          ..._terfilter.map(
            (j) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Hari ke-${j.hariKe} — ${j.tanggalIso}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(j.aktivitas),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/jurnal_pkl_${widget.username}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Jurnal PKL ${widget.username}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Jurnal'),
        actions: [
          IconButton(onPressed: _eksporPdf, icon: const Icon(Icons.picture_as_pdf), tooltip: 'Ekspor PDF'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari tanggal atau kata kunci...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _cari = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Wrap(
                    spacing: 6,
                    children: ['Semua', 'Harian', 'Mingguan', 'Bulanan'].map((f) {
                      final aktif = _filter == f;
                      return ChoiceChip(
                        label: Text(f),
                        selected: aktif,
                        onSelected: (_) => setState(() => _filter = f),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _terfilter.isEmpty
                      ? const Center(child: Text('Tidak ada jurnal yang cocok.'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _terfilter.length,
                          itemBuilder: (context, i) {
                            final j = _terfilter[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(child: Text('${j.hariKe}')),
                                title: Text(j.tanggalIso),
                                subtitle: Text(j.aktivitas),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editDialog(j)),
                                    IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _hapus(j)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
