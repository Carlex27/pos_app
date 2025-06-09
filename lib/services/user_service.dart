import 'dart:convert';
import '../config.dart';
import 'authenticated_client.dart';
import '../models/user/user.dart';
import '../models/user/user_registration.dart';

/// Servicio para consumo de la API de Productos usando cliente autenticado
class UserService {
  final AuthenticatedClient _client;

  UserService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todos los usuarios
  Future<List<User>> fetchAll() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/user/all'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching products: ${response.statusCode}');
    }
  }

  Future<String> create(UserRegistration user) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/sign-up'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return "Usuario creado correctamente";
    } else {
      throw Exception('Error creating user: ${response.statusCode}');
    }
  }


  /// Metodo search para buscar usuarios por nombre o rol
  Future<List<User>> search(String query) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/user/search')
          .replace(queryParameters: {'q': query}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching products: ${response.statusCode}');
    }
  }

  /// Elimina un producto por ID
  Future<void> delete(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/user/delete/id/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting product: ${response.statusCode}');
    }
  }

  Future<String> update(UserRegistration user, int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.post(
      Uri.parse('$baseUrl/api/user/update')
      .replace(queryParameters: {'id': id.toString()}),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return "Usuario actualizado correctamente";
    } else {
      throw Exception('Error creating user: ${response.statusCode}');
    }
  }

}
