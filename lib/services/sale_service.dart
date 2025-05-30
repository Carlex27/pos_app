import 'dart:convert';
import '../config.dart';
import 'authenticated_client.dart';
import 'package:intl/intl.dart';
import '../models/sale_response.dart';

/// Servicio para consumo de la API de Ventas usando cliente autenticado
class SaleService {
  final AuthenticatedClient _client;

  SaleService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todas las ventas
  Future<List<SaleResponse>> fetchAll() async {
    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/sales/findAll'),
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
    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/sales/details/\$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return SaleResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sale details for \$id: \${response.statusCode}');
    }
  }

  /// Obtiene los detalles de una venta por ID
  Future<List<SaleResponse>> fetchByDay(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/sales/by-date')
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
    final int year = date.year;
    final int month = date.month;

    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/sales/by-month')
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


}
