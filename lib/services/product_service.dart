import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
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
  /// Metodo search para buscar productos por nombre o SKU o marca
  Future<List<Product>> search(String query) async {
    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/products/search')
          .replace(queryParameters: {'query': query}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching products: \${response.statusCode}');
    }
  }

  /// Actualiza un producto existente
  Future<void> updateProductWithOptionalImage({
    required int id,
    required String sku,
    required String nombre,
    required String marca,
    required double gradosAlcohol,
    required String tamanio,
    required double precioNormal,
    required double precioMayoreo,
    required int stock,
    File? imageFile, // puede ser null
  }) async {
    final uri = Uri.parse('$kApiBaseUrl/api/products/update')
        .replace(queryParameters: {'id': id.toString()});

    final request = http.MultipartRequest('PUT', uri);

    request.fields['sku'] = sku;
    request.fields['nombre'] = nombre;
    request.fields['marca'] = marca;
    request.fields['gradosAlcohol'] = gradosAlcohol.toString();
    request.fields['tamanio'] = tamanio;
    request.fields['precioNormal'] = precioNormal.toString();
    request.fields['precioMayoreo'] = precioMayoreo.toString();
    request.fields['stock'] = stock.toString();

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('imagen', imageFile.path));
    }

    final headers = await _client.getAuthHeaders();
    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Error actualizando producto: ${response.statusCode}');
    }
  }


  /// Elimina un producto por ID
  Future<void> delete(int id) async {
    final response = await _client.delete(
      Uri.parse('$kApiBaseUrl/api/products/delete/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting product: \${response.statusCode}');
    }
  }
  /// Obtiene la URL completa de la imagen de un producto
  String getImageUrl(String filename) {
    return '$kApiBaseUrl/images/$filename';
  }

  /// Envía un producto con imagen usando multipart/form-data
  Future<void> uploadProductWithImage({
    required String sku,
    required String nombre,
    required String marca,
    required double gradosAlcohol,
    required String tamanio,
    required double precioNormal,
    required double precioMayoreo,
    required int stock,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$kApiBaseUrl/api/products/create');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(await _client.getAuthHeaders());

    request.fields['sku'] = sku;
    request.fields['nombre'] = nombre;
    request.fields['marca'] = marca;
    request.fields['gradosAlcohol'] = gradosAlcohol.toString();
    request.fields['tamanio'] = tamanio;
    request.fields['precioNormal'] = precioNormal.toString();
    request.fields['precioMayoreo'] = precioMayoreo.toString();
    request.fields['stock'] = stock.toString();

    request.files.add(await http.MultipartFile.fromPath('imagen', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Error uploading product: ${response.body}');
    }
  }


}
