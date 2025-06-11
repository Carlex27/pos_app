import 'dart:convert';
import 'package:pos_app/models/department/department.dart';

import '../config.dart';
import 'authenticated_client.dart';
import '../models/user/user.dart';
import '../models/user/user_registration.dart';

/// Servicio para consumo de la API de Productos usando cliente autenticado
class DepartmentService {
  final AuthenticatedClient _client;

  DepartmentService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todos los usuarios
  Future<List<Department>> fetchAll() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/departments/findAll'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Department.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching departments: ${response.statusCode}');
    }
  }

  Future<List<Department>> search(String query) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/departments/search')
          .replace(queryParameters: {'query': query}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Department.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching products: ${response.statusCode}');
    }
  }

  Future<String> create(Department department) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.post(
      Uri.parse('$baseUrl/api/departments/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(department.toJson()),
    );
    if (response.statusCode == 200) {
      return "Departamento creado correctamente";
    } else {
      throw Exception('Error creating user: ${response.statusCode}');
    }
  }


  /// Elimina un producto por ID
  Future<void> delete(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/departments/delete/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting department: ${response.statusCode}');
    }
  }

  Future<String> update(Department department, int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.post(
      Uri.parse('$baseUrl/api/department/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(department.toJson()),
    );
    if (response.statusCode == 200) {
      return "department actualizado correctamente";
    } else {
      throw Exception('Error creating department: ${response.statusCode}');
    }
  }

}
