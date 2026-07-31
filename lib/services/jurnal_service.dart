import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JurnalEntry {
  final String id;
  final int hariKe;
  final String tanggalIso; // yyyy-MM-dd, supaya gampang di-filter/sort
  final String aktivitas;

  JurnalEntry({
    required this.id,
    required this.hariKe,
    required this.tanggalIso,
    required this.aktivitas,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'hariKe': hariKe,
        'tanggalIso': tanggalIso,
        'aktivitas': aktivitas,
      };

  factory JurnalEntry.fromJson(Map<String, dynamic> json) => JurnalEntry(
        id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
        hariKe: json['hariKe'] as int,
        tanggalIso: json['tanggalIso'] as String,
        aktivitas: json['aktivitas'] as String,
      );

  JurnalEntry copyWith({int? hariKe, String? tanggalIso, String? aktivitas}) {
    return JurnalEntry(
      id: id,
      hariKe: hariKe ?? this.hariKe,
      tanggalIso: tanggalIso ?? this.tanggalIso,
      aktivitas: aktivitas ?? this.aktivitas,
    );
  }
}

/// Jurnal aktivitas disimpan per-username, semua offline di perangkat.
class JurnalService {
  String _keyFor(String username) => 'jurnal_$username';

  Future<List<JurnalEntry>> getEntries(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(username));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final entries = list.map((e) => JurnalEntry.fromJson(e as Map<String, dynamic>)).toList();
    entries.sort((a, b) => b.tanggalIso.compareTo(a.tanggalIso));
    return entries;
  }

  Future<void> _saveAll(String username, List<JurnalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(username),
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<JurnalEntry> addEntry(
    String username,
    String aktivitas,
    String tanggalIso, {
    int? hariKeManual,
  }) async {
    final entries = await getEntries(username);
    final hariKe = hariKeManual ?? (entries.length + 1);
    final entry = JurnalEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      hariKe: hariKe,
      tanggalIso: tanggalIso,
      aktivitas: aktivitas,
    );
    entries.add(entry);
    await _saveAll(username, entries);
    return entry;
  }

  Future<void> updateEntry(String username, JurnalEntry updated) async {
    final entries = await getEntries(username);
    final idx = entries.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;
    entries[idx] = updated;
    await _saveAll(username, entries);
  }

  Future<void> deleteEntry(String username, String id) async {
    final entries = await getEntries(username);
    entries.removeWhere((e) => e.id == id);
    await _saveAll(username, entries);
  }

  Future<void> deleteAll(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(username));
  }

  Future<void> restoreEntries(String username, List<JurnalEntry> entries) async {
    await _saveAll(username, entries);
  }

  // Auto-save draft (belum disimpan permanen sebagai entry)
  Future<void> simpanDraft(String username, String teks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_$username', teks);
  }

  Future<String?> ambilDraft(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('draft_$username');
  }

  Future<void> hapusDraft(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_$username');
  }
}
