import 'dart:async';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import 'auth_service.dart';
import '../config.dart';

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final TokenStorage _storage;
  final AuthService _authService;

  AuthenticatedClient({
    http.Client? inner,
    TokenStorage? storage,
    AuthService? authService,
  })  : _inner = inner ?? http.Client(),
        _storage = storage ?? TokenStorage(),
        _authService = authService ?? AuthService();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Inyecta el token actual
    final token = await _storage.readAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 2. Ejecuta la petición
    final response = await _inner.send(request);

    // 3. Si expiró (401), intenta refresh y reintenta una vez
    if (response.statusCode == 401) {
      final didRefresh = await _tryRefreshToken();
      if (didRefresh) {
        // Cierra el stream original antes de reintentar
        await response.stream.drain();
        // Re-construye la petición
        final retryReq = _copyRequest(request);
        final newToken = await _storage.readAccessToken();
        if (newToken != null) {
          retryReq.headers['Authorization'] = 'Bearer $newToken';
        }
        return _inner.send(retryReq);
      }
    }

    return response;
  }

  /// Llama al endpoint de refresh y guarda el nuevo access_token
  Future<bool> _tryRefreshToken() async {
    try {
      final newToken = await _authService.refreshToken();
      if (newToken != null) {
        await _storage.saveAccessToken(newToken);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Copia la petición para reintentar (solo GET/POST/etc. con body en bytes)
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    final req = http.Request(request.method, request.url)
      ..headers.addAll(request.headers);
    if (request is http.Request && request.bodyBytes.isNotEmpty) {
      req.bodyBytes = request.bodyBytes;
    }
    return req;
  }
}
