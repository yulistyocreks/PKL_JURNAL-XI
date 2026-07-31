import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyAccounts = 'accounts';
  static const _keyLastUsername = 'last_username';
  static const _keyLoggedInUsername = 'logged_in_username';
  static const _keyIngatSaya = 'ingat_saya';

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

  Future<String?> getLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastUsername);
  }

  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInUsername);
  }

  /// Dipakai splash screen: kalau true, langsung ke Home tanpa login ulang.
  Future<bool> getIngatSaya() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIngatSaya) ?? false;
  }

  Future<int> jumlahAkunTerdaftar() async {
    final accounts = await _getAccounts();
    return accounts.length;
  }

  Future<bool> register(String username, String password) async {
    final accounts = await _getAccounts();
    if (accounts.containsKey(username)) return false;
    accounts[username] = password;
    await _saveAccounts(accounts);
    return true;
  }

  Future<bool> accountExists(String username) async {
    final accounts = await _getAccounts();
    return accounts.containsKey(username);
  }

  Future<bool> login(String username, String password, {bool ingatSaya = false}) async {
    final accounts = await _getAccounts();
    if (accounts[username] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastUsername, username);
      await prefs.setString(_keyLoggedInUsername, username);
      await prefs.setBool(_keyIngatSaya, ingatSaya);
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
    await prefs.setBool(_keyIngatSaya, false);
  }
}
