import 'dart:convert';
import '../config.dart';
import 'authenticated_client.dart';
import 'package:intl/intl.dart';
import '../models/sales/sale_response.dart';

/// Servicio para consumo de la API de Ventas usando cliente autenticado
class SaleService {
  final AuthenticatedClient _client;

  SaleService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todas las ventas
  Future<List<SaleResponse>> fetchAll() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/sales/findAll'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SaleResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching sales: \${response.statusCode}');
    }
  }

  /// Obtiene los detalles de una venta por ID
  Future<SaleResponse> fetchById(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/sales/details/\$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return SaleResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sale details for \$id: \${response.statusCode}');
    }
  }

  /// Obtiene las ventas de un día específico
  Future<List<SaleResponse>> fetchByDay(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await _client.get(
      Uri.parse('$baseUrl/api/sales/by-date')
          .replace(queryParameters: {'date': formattedDate}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SaleResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching sales for date: ${response.statusCode}');
    }
  }
  /// Obtiene las ventas de un mes específico
  Future<List<SaleResponse>> fetchByMonth(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final int year = date.year;
    final int month = date.month;

    final response = await _client.get(
      Uri.parse('$baseUrl/api/sales/by-month')
          .replace(queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SaleResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching sales for $month/$year: ${response.statusCode}');
    }
  }

  /// Obtiene las ventas de un mes específico y cliente específico
  Future<List<SaleResponse>> fetchByMonthAndClient(DateTime date, int clientId) async {
    final baseUrl = await getApiBaseUrl();
    final int year = date.year;
    final int month = date.month;

    final response = await _client.get(
      Uri.parse('$baseUrl/api/sales/by-month/client')
          .replace(queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
        'clientId': clientId.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SaleResponse.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching sales for $month/$year: ${response.statusCode}');
    }
  }

}
