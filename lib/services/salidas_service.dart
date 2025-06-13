import 'dart:convert';
import 'package:pos_app/models/salidas/salidas.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import 'authenticated_client.dart';


/// Servicio para consumo de la API de Productos usando cliente autenticado
class SalidasService {
  final AuthenticatedClient _client;

  SalidasService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todos los usuarios
  Future<List<Salidas>> fetchAll() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/salidas/findAll'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Salidas.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching departments: ${response.statusCode}');
    }
  }

  Future<List<Salidas>> fetchByMonth(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final int year = date.year;
    final int month = date.month;

    final response = await _client.get(
      Uri.parse('$baseUrl/api/salidas/by-month')
          .replace(queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Salidas.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching sales for $month/$year: ${response.statusCode}');
    }
  }

  Future<List<Salidas>> getSalidasByDate(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await _client.get(
      Uri.parse('$baseUrl/api/salidas/by-date')
          .replace(queryParameters: {'date': formattedDate}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Salidas.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching sales for date: ${response.statusCode}');
    }
  }


  Future<String> create(Salidas salidas) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.post(
      Uri.parse('$baseUrl/api/salidas/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(salidas.toJson()),
    );
    if (response.statusCode == 200) {
      return "Salida creado correctamente";
    } else {
      throw Exception('Error creating salida: ${response.statusCode}');
    }
  }


  /// Elimina un producto por ID
  Future<void> delete(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/salidas/delete/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting salida: ${response.statusCode}');
    }
  }

  Future<String> update(Salidas salida, int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.put(
      Uri.parse('$baseUrl/api/salidas/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(salida.toJson()),
    );
    if (response.statusCode == 200) {
      return "salida actualizado correctamente";
    } else {
      throw Exception('Error creating salida: ${response.statusCode}');
    }
  }

}
