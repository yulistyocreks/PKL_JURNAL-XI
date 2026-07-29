import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Semua data akun disimpan secara offline di perangkat memakai SharedPreferences.
class AuthService {
  static const _keyAccounts = 'accounts'; // Map<username, password> (json)
  static const _keyLastUsername = 'last_username';
  static const _keyLoggedInUsername = 'logged_in_username';

  Future<Map<String, String>> _getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAccounts);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> _saveAccounts(Map<String, String> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccounts, jsonEncode(accounts));
  }

  /// Username yang terisi otomatis berdasarkan login terakhir.
  Future<String?> getLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastUsername);
  }

  /// Username yang sedang login (sesi aktif). Null jika sudah logout.
  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInUsername);
  }

  Future<bool> register(String username, String password) async {
    final accounts = await _getAccounts();
    if (accounts.containsKey(username)) {
      return false; // username sudah dipakai
    }
    accounts[username] = password;
    await _saveAccounts(accounts);
    return true;
  }

  Future<bool> accountExists(String username) async {
    final accounts = await _getAccounts();
    return accounts.containsKey(username);
  }

  Future<bool> login(String username, String password) async {
    final accounts = await _getAccounts();
    if (accounts[username] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastUsername, username);
      await prefs.setString(_keyLoggedInUsername, username);
      return true;
    }
    return false;
  }

  Future<bool> resetPassword(String username, String newPassword) async {
    final accounts = await _getAccounts();
    if (!accounts.containsKey(username)) return false;
    accounts[username] = newPassword;
    await _saveAccounts(accounts);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedInUsername);
  }
}
