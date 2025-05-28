import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'authenticated_client.dart';

import '../models/SaleDto.dart';
import '../models/sale_response.dart';

/// Servicio para consumo de la API de Ventas usando cliente autenticado
class SaleService {
  final AuthenticatedClient _client;

  SaleService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todas las ventas
  Future<List<SaleResponse>> fetchAll() async {
    final response = await _client.get(
      Uri.parse('\$kApiBaseUrl/sales/findAll'),
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
      Uri.parse('\$kApiBaseUrl/sales/details/\$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return SaleResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sale details for \$id: \${response.statusCode}');
    }
  }

  /// Crea una nueva venta
  Future<SaleResponse> create(SaleDto saleDto) async {
    final response = await _client.post(
      Uri.parse('\$kApiBaseUrl/sales/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(saleDto.toJson()),
    );
    if (response.statusCode == 200) {
      return SaleResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error creating sale: \${response.statusCode}');
    }
  }

  /// Elimina una venta por ID
  Future<void> delete(int id) async {
    final response = await _client.delete(
      Uri.parse('\$kApiBaseUrl/sales/delete/\$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting sale: \${response.statusCode}');
    }
  }
}
