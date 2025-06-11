import 'dart:convert';
import 'package:pos_app/models/client/client.dart';
import 'package:pos_app/models/client/client_abonos.dart';
import 'package:pos_app/models/department/department.dart';

import 'dart:convert';
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

  Future<double> getTotalBalance() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/client/balance/total'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String responseBodyString = response.body;
      print('Total Balance Response body: $responseBodyString');

      try {
        // Intenta decodificar el JSON. Si el backend devuelve solo el número como cadena,
        // jsonDecode lo interpretará como una cadena.
        // Ej: si responseBodyString es "\"123.45\"", decodedBody será "123.45" (String)
        // Ej: si responseBodyString es "123.45" (sin comillas en el body), decodedBody será 123.45 (double o int)
        final dynamic decodedBody = jsonDecode(responseBodyString);

        if (decodedBody is String) {
          // Si el JSON decodificado es una cadena, intenta parsearla a num
          final num? parsedNum = num.tryParse(decodedBody);
          if (parsedNum != null) {
            return parsedNum.toDouble();
          } else {
            print('Error: Could not parse string value from JSON as a number: $decodedBody');
            throw Exception('Failed to parse total balance string from JSON');
          }
        } else if (decodedBody is num) {
          // Si el JSON decodificado ya es un número (int o double)
          return decodedBody.toDouble();
        } else {
          print('Error: Unexpected JSON type for total balance: ${decodedBody.runtimeType}');
          throw Exception('Unexpected JSON type for total balance');
        }
      } catch (e) {
        print('Error decoding or parsing total balance JSON: $e');
        throw Exception('Failed to decode or parse total balance JSON');
      }
    } else {
      print('Error fetching Total Balance: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Error fetching Total Balance: ${response.statusCode}');
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

  Future<List<ClientAbonos>> fetchAbonos(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/client/abonos/client')
          .replace(queryParameters: {'id': id.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ClientAbonos.fromJson(e)).toList();
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


  /// Elimina un cliente por ID
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

  Future<void> deleteAbono(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/client/abono/delete/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting abono: ${response.statusCode}');
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
