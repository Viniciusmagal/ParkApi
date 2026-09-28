import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session.dart';

class ApiException implements Exception {
  final int status;
  final String message;

  ApiException(this.status, this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _hostDefinido = String.fromEnvironment('API_BASE_URL');

  static String get host {
    if (_hostDefinido.isNotEmpty) return _hostDefinido;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8080';
    return 'http://127.0.0.1:8080';
  }

  static String get baseUrl => '$host/api/v1';

  static Map<String, String> _headers() {
    final token = Session.token ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException(0, 'Falha de conexão com a API. Verifique se o servidor está rodando.');
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) {
    return _send(() => http.post(Uri.parse('$baseUrl$endpoint'), headers: _headers(), body: jsonEncode(body)));
  }

  static Future<http.Response> get(String endpoint) {
    return _send(() => http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers()));
  }

  static Future<http.Response> put(String endpoint, [Map<String, dynamic>? body]) {
    return _send(() => http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        ));
  }

  static dynamic decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static dynamic check(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decode(response);
    }
    throw ApiException(response.statusCode, errorMessage(response));
  }

  static Future<dynamic> getJson(String endpoint) async => check(await get(endpoint));

  static Future<dynamic> postJson(String endpoint, Map<String, dynamic> body) async => check(await post(endpoint, body));

  static Future<dynamic> putJson(String endpoint, [Map<String, dynamic>? body]) async => check(await put(endpoint, body));

  static String errorMessage(http.Response response) {
    if (response.statusCode == 401) {
      return 'Sessão expirada. Faça login novamente.';
    }
    if (response.statusCode == 403) {
      return 'Você não tem permissão para esta operação.';
    }
    try {
      final data = decode(response);
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return errors.values.join('\n');
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
    } catch (_) {}
    return 'Erro inesperado (${response.statusCode}).';
  }

  static Future<Uint8List> getRelatorioPdf() async {
    final token = Session.token;
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
    if (response.statusCode == 404) {
      throw Exception('Você ainda não possui estacionamentos para gerar o relatório.');
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
}
