import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'jurnal_service.dart';

class ProfileService {
  String _fotoKeyFor(String username) => 'foto_profil_$username';

  Future<void> simpanPathFoto(String username, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fotoKeyFor(username), path);
  }

  Future<String?> ambilPathFoto(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fotoKeyFor(username));
  }

  /// Backup semua jurnal 1 username jadi String JSON (untuk disimpan ke file/share).
  Future<String> backupJson(String username) async {
    final jurnalService = JurnalService();
    final entries = await jurnalService.getEntries(username);
    return jsonEncode({
      'username': username,
      'entries': entries.map((e) => e.toJson()).toList(),
    });
  }

  /// Restore dari String JSON hasil backup.
  Future<void> restoreJson(String username, String jsonStr) async {
    final jurnalService = JurnalService();
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final list = data['entries'] as List<dynamic>;
    final entries = list.map((e) => JurnalEntry.fromJson(e as Map<String, dynamic>)).toList();
    await jurnalService.restoreEntries(username, entries);
  }
}
