import 'package:flutter/material.dart';
import '../services/jurnal_service.dart';

class StatistikScreen extends StatefulWidget {
  final String username;
  const StatistikScreen({super.key, required this.username});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  final _jurnalService = JurnalService();
  int _totalJurnal = 0;
  int _totalHari = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final entries = await _jurnalService.getEntries(widget.username);
    if (!mounted) return;
    setState(() {
      _totalJurnal = entries.length;
      _totalHari = entries.isEmpty ? 0 : entries.map((e) => e.hariKe).reduce((a, b) => a > b ? a : b);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik PKL')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatCard(label: 'Total Hari PKL', value: '$_totalHari hari'),
                const SizedBox(height: 12),
                _StatCard(label: 'Total Jurnal Ditulis', value: '$_totalJurnal entri'),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}
