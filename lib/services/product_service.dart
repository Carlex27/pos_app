import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'authenticated_client.dart';

import '../models/product.dart';

/// Servicio para consumo de la API de Productos usando cliente autenticado
class ProductService {
  final AuthenticatedClient _client;

  ProductService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todos los productos
  Future<List<Product>> fetchAll() async {
    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/products/findAll'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching products: \${response.statusCode}');
    }
  }

  /// Crea un nuevo producto
  Future<Product> create(Product product) async {
    final response = await _client.post(
      Uri.parse('$kApiBaseUrl/api/products/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error creating product: \${response.statusCode}');
    }
  }

  /// Actualiza un producto existente
  Future<Product> update(Product product) async {
    final response = await _client.put(
      Uri.parse('$kApiBaseUrl/api/products/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error updating product: \${response.statusCode}');
    }
  }

  /// Elimina un producto por ID
  Future<void> delete(int id) async {
    final response = await _client.delete(
      Uri.parse('$kApiBaseUrl/api/products/delete/\$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting product: \${response.statusCode}');
    }
  }
}
