import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'token_storage.dart';

import 'dart:convert';

String _basicAuthHeader(String username, String password) {
  final credentials = '$username:$password';
  final encoded    = base64Encode(utf8.encode(credentials));
  return 'Basic $encoded';
}


class AuthService {
  final _client = http.Client();
  final _storage = TokenStorage();

  /// En lib/services/auth_service.dart

  /// Llama a /auth/refresh-token y devuelve el nuevo accessToken
  Future<String?> refreshToken() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return null;
    final baseUrl = await getApiBaseUrl();

    // Asume que tu endpoint espera la cookie de refresh; ajusta si usa header JSON
    final resp = await _client.get(
      Uri.parse('$baseUrl/auth/refresh-token'),
      headers: {
        'Cookie': 'refresh_token=$refreshToken',
      },
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      return body['access_token'] as String?;
    } else {
      // Token inválido o expirado: limpia el storage
      await _storage.deleteTokens();
      return null;
    }
  }


  Future<void> login(String username, String password) async {
    final authHeader = _basicAuthHeader(username, password);
    final baseUrl = await getApiBaseUrl();

    final resp = await _client.post(
      Uri.parse('$baseUrl/auth/sign-in'),
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json',
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('Error de autenticación: ${resp.statusCode}');
    }

    // 1. Leer el access token
    final body = jsonDecode(resp.body);
    final accessToken = body['access_token'] as String;
    await _storage.saveAccessToken(accessToken);

    // 2. Leer la cookie de refresh_token
    final setCookie = resp.headers['set-cookie'];
    if (setCookie != null) {
      final cookieParts = setCookie.split(';');
      final rtPart = cookieParts.firstWhere(
            (p) => p.trim().startsWith('refresh_token='),
        orElse: () => '',
      );
      if (rtPart.isNotEmpty) {
        final refreshToken = rtPart.split('=').sublist(1).join('=');
        await _storage.saveRefreshToken(refreshToken);
      }
    }
  }

  // Ahora sí, fuera de login, el getter:
  Future<String?> get accessToken async {
    return await _storage.readAccessToken();
  }

  Future<void> logout() async {
    await _storage.deleteTokens();
  }
}

