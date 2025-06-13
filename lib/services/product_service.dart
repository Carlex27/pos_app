import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pos_app/models/product/product_Inventory_entry.dart';
import '../config.dart';
import 'authenticated_client.dart';

import '../models/product/product.dart';
import '../models/product/alta_product.dart';

/// Servicio para consumo de la API de Productos usando cliente autenticado
class ProductService {
  final AuthenticatedClient _client;

  ProductService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todos los productos
  Future<List<Product>> fetchAll() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/products/findAll'),
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
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/products/search')
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
  Future<List<ProductInventoryEntry>> fetchAllEntriesByProduct(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/inventory/entry/product')
          .replace(queryParameters: {'id': id.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ProductInventoryEntry.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching products entries: ${response.statusCode}');
    }
  }

  Future<double> getCostoInventarioPorProducto(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/products/costo/producto')
      .replace(queryParameters: {'id': id.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String responseBodyString = response.body;
      print('Total Balance Response body: $responseBodyString');

      try {
        final dynamic decodedBody = jsonDecode(responseBodyString);

        if (decodedBody is String) {
          final num? parsedNum = num.tryParse(decodedBody);
          if (parsedNum != null) {
            return parsedNum.toDouble();
          } else {
            print(
                'Error: Could not parse string value from JSON as a number: $decodedBody');
            throw Exception('Failed to parse total balance string from JSON');
          }
        } else if (decodedBody is num) {
          return decodedBody.toDouble();
        } else {
          print('Error: Unexpected JSON type for total balance: ${decodedBody
              .runtimeType}');
          throw Exception('Unexpected JSON type for total balance');
        }
      } catch (e) {
        print('Error decoding or parsing total balance JSON: $e');
        throw Exception('Failed to decode or parse total balance JSON');
      }
    } else {
      print('Error fetching Total Balance: ${response
          .statusCode}, Body: ${response.body}');
      throw Exception('Error fetching Total Balance: ${response.statusCode}');
    }
  }

  Future<double> getCostoInventarioTotal() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/products/costo/total'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String responseBodyString = response.body;
      print('Total Balance Response body: $responseBodyString');

      try {
        final dynamic decodedBody = jsonDecode(responseBodyString);

        if (decodedBody is String) {
          final num? parsedNum = num.tryParse(decodedBody);
          if (parsedNum != null) {
            return parsedNum.toDouble();
          } else {
            print(
                'Error: Could not parse string value from JSON as a number: $decodedBody');
            throw Exception('Failed to parse total balance string from JSON');
          }
        } else if (decodedBody is num) {
          return decodedBody.toDouble();
        } else {
          print('Error: Unexpected JSON type for total balance: ${decodedBody
              .runtimeType}');
          throw Exception('Unexpected JSON type for total balance');
        }
      } catch (e) {
        print('Error decoding or parsing total balance JSON: $e');
        throw Exception('Failed to decode or parse total balance JSON');
      }
    } else {
      print('Error fetching Total Balance: ${response
          .statusCode}, Body: ${response.body}');
      throw Exception('Error fetching Total Balance: ${response.statusCode}');
    }
  }


  Future<void> sendAltaProductos(List<AltaProduct> productos) async {
    final baseUrl = await getApiBaseUrl();
    final uri = Uri.parse('$baseUrl/api/products/altaProducto');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(productos.map((p) => p.toJson()).toList()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar productos: ${response.statusCode} ${response.body}');
    }
  }


  /// Actualiza un producto existente
  Future<void> updateProductWithOptionalImage({
    required int id,
    required String sku,
    required String nombre,
    required String departamento,
    required double precioCosto,
    required double precioVenta,
    required double precioMayoreo,
    required double precioUnidadVenta,
    required double precioUnidadMayoreo,
    required int unidadesPorPresentacion,
    required double stock,
    required int stockPorUnidad,
    required int stockMinimo,
    required int minimoMayoreo,
    File? imageFile, // puede ser null
  }) async {
    final baseUrl = await getApiBaseUrl();
    final uri = Uri.parse('$baseUrl/api/products/update')
        .replace(queryParameters: {'id': id.toString()});

    final request = http.MultipartRequest('PUT', uri);

    request.fields['sku'] = sku;
    request.fields['nombre'] = nombre;
    request.fields['departamento'] = departamento;
    request.fields['precioCosto'] = precioCosto.toString();
    request.fields['precioVenta'] = precioVenta.toString();
    request.fields['precioMayoreo'] = precioMayoreo.toString();
    request.fields['precioUnidadVenta'] = precioUnidadVenta.toString();
    request.fields['precioUnidadMayoreo'] = precioUnidadMayoreo.toString();
    request.fields['unidadesPorPresentacion'] = unidadesPorPresentacion.toString();
    request.fields['stock'] = stock.toString();
    request.fields['stockPorUnidad'] = stockPorUnidad.toString();
    request.fields['stockMinimo'] = stockMinimo.toString();
    request.fields['minimoMayoreo'] = minimoMayoreo.toString();

    // Si imageFile es null, no se agrega al request
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
    final baseUrl = await getApiBaseUrl();
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/products/delete/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting product: \${response.statusCode}');
    }
  }
  /// Obtiene la URL completa de la imagen de un producto
  Future<String> getImageUrl(String filename) async {
    final baseUrl = await getApiBaseUrl();
    return '$baseUrl/images/$filename';
  }

  /// Envía un producto con imagen usando multipart/form-data
  Future<void> uploadProductWithImage({
    required String sku,
    required String nombre,
    required String departamento,
    required double precioCosto,
    required double precioVenta,
    required double precioMayoreo,
    required double precioUnidadVenta,
    required double stock,
    required int stockMinimo,
    required int unidadesPorPresentacion,
    required String minimoMayoreo,
    required File imageFile,
  }) async {
    final baseUrl = await getApiBaseUrl();
    final uri = Uri.parse('$baseUrl/api/products/create');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(await _client.getAuthHeaders());

    request.fields['sku'] = sku;
    request.fields['nombre'] = nombre;
    request.fields['departamento'] = departamento;
    request.fields['precioCosto'] = precioCosto.toString();
    request.fields['precioVenta'] = precioVenta.toString();
    request.fields['precioMayoreo'] = precioMayoreo.toString();
    request.fields['precioUnidadVenta'] = precioUnidadVenta.toString();
    request.fields['stock'] = stock.toString();
    request.fields['stockMinimo'] = stockMinimo.toString();
    request.fields['unidadesPorPresentacion'] = unidadesPorPresentacion.toString();
    request.fields['minimoMayoreo'] = minimoMayoreo;


    request.files.add(await http.MultipartFile.fromPath('imagen', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Error uploading product: ${response.body}');
    }
  }

  Future<String> updateEntry(ProductInventoryEntry entry) async {
    int id = entry.id;
    print(entry.toJson());
    final baseUrl = await getApiBaseUrl();
    final response = await _client.put(
      Uri.parse('$baseUrl/api/inventory/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(entry.toJson()),
    );
    if (response.statusCode == 200) {
      return "Entrada actualizada correctamente";
    } else {
      throw Exception('Error creating entrada: ${response.statusCode}');
    }
  }

}
