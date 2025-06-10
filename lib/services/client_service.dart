import 'dart:convert';
import 'package:pos_app/models/client/client.dart';
import 'package:pos_app/models/department/department.dart';

import '../config.dart';
import 'authenticated_client.dart';
import '../models/user/user.dart';
import '../models/user/user_registration.dart';

/// Servicio para consumo de la API de Productos usando cliente autenticado
class ClientService {
  final AuthenticatedClient _client;

  ClientService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todos los usuarios
  Future<List<Client>> fetchAll() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/client/findAll'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Client.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching Client: ${response.statusCode}');
    }
  }

  Future<List<Client>> search(String query) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/client/search')
          .replace(queryParameters: {'query': query}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Client.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching products: ${response.statusCode}');
    }
  }

  Future<String> create(Client client) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.post(
      Uri.parse('$baseUrl/api/client/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );
    if (response.statusCode == 200) {
      return "Departamento creado correctamente";
    } else {
      throw Exception('Error creating Client: ${response.statusCode}');
    }
  }


  /// Elimina un producto por ID
  Future<void> delete(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/client/delete/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting Client: ${response.statusCode}');
    }
  }

  Future<String> update(Client client) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.post(
      Uri.parse('$baseUrl/api/client/update')
          .replace(queryParameters: {'id': client.id.toString()}),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );
    if (response.statusCode == 200) {
      return "Client actualizado correctamente";
    } else {
      throw Exception('Error creating Client: ${response.statusCode}');
    }
  }

}
