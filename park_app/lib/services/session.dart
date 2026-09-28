import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _tokenKey = 'jwt_token';

  static String? token;
  static String? role;
  static String? username;
  static DateTime? expiresAt;

  static bool get isAdmin => role == 'ADMIN';

  static bool get isValid => token != null && expiresAt != null && expiresAt!.isAfter(DateTime.now());

  static Future<void> save(String jwt) async {
    _apply(jwt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, jwt);
  }

  static Future<bool> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString(_tokenKey);
    if (jwt == null || jwt.isEmpty) return false;
    try {
      _apply(jwt);
    } catch (_) {
      await clear();
      return false;
    }
    if (!isValid) {
      await clear();
      return false;
    }
    return true;
  }

  static Future<void> clear() async {
    token = null;
    role = null;
    username = null;
    expiresAt = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static void _apply(String jwt) {
    final parts = jwt.split('.');
    final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, dynamic>;
    token = jwt;
    role = payload['role'] as String?;
    username = payload['sub'] as String?;
    final exp = payload['exp'];
    expiresAt = exp is int ? DateTime.fromMillisecondsSinceEpoch(exp * 1000) : null;
  }
}
