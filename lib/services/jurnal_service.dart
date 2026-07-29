import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JurnalEntry {
  final int hariKe;
  final String tanggal;
  final String aktivitas;

  JurnalEntry({
    required this.hariKe,
    required this.tanggal,
    required this.aktivitas,
  });

  Map<String, dynamic> toJson() => {
        'hariKe': hariKe,
        'tanggal': tanggal,
        'aktivitas': aktivitas,
      };

  factory JurnalEntry.fromJson(Map<String, dynamic> json) => JurnalEntry(
        hariKe: json['hariKe'] as int,
        tanggal: json['tanggal'] as String,
        aktivitas: json['aktivitas'] as String,
      );
}

/// Jurnal aktivitas disimpan per-username, semua offline di perangkat.
class JurnalService {
  String _keyFor(String username) => 'jurnal_$username';

  Future<List<JurnalEntry>> getEntries(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(username));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => JurnalEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<JurnalEntry> addEntry(String username, String aktivitas, String tanggal) async {
    final entries = await getEntries(username);
    final hariKe = entries.length + 1;
    final entry = JurnalEntry(hariKe: hariKe, tanggal: tanggal, aktivitas: aktivitas);
    entries.add(entry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(username),
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
    return entry;
  }
}
