import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // No emulador Android, localhost aponta para o próprio emulador.
  // Em celular físico, substitua pelo IP do computador na rede local.
  static String get baseUrl =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8080/api/v1'
          : 'http://127.0.0.1:8080/api/v1';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'), 
      headers: headers,
    );
  }

  /// Retorna o PDF do histórico do cliente autenticado.
  static Future<Uint8List> getRelatorioPdf() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Sua sessão expirou. Entre novamente para ver o relatório.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/estacionamentos/relatorio'),
      headers: {
        'Accept': 'application/pdf',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 401) {
      throw Exception('Sua sessão expirou. Entre novamente para ver o relatório.');
    }
    if (response.statusCode == 403) {
      throw Exception('Este relatório está disponível apenas para contas de cliente.');
    }
    if (response.statusCode != 200) {
      throw Exception('Não foi possível gerar o relatório (${response.statusCode}).');
    }
    final bytes = response.bodyBytes;
    if (bytes.length < 5 || bytes[0] != 0x25 || bytes[1] != 0x50 ||
        bytes[2] != 0x44 || bytes[3] != 0x46 || bytes[4] != 0x2D) {
      throw Exception('A API não retornou um PDF válido.');
    }
    return bytes;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
