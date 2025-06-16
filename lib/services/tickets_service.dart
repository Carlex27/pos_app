
import '../config.dart';
import 'authenticated_client.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';



/// Servicio para consumo de la API de Productos usando cliente autenticado
class TicketService {
  final AuthenticatedClient _client;

  TicketService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// O
  Future<String> printSale(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/tickets/print/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return "Ticket impreso correctamente";
    } else {
      throw Exception('Error fetching TicketSettings: ${response.statusCode}');
    }
  }

  Future<String> printSaldos() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/tickets/print/saldos'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return "Ticket impreso correctamente";
    } else {
      throw Exception('Error fetching TicketSettings: ${response.statusCode}');
    }
  }

  /// Obtener el pdf de una venta
  Future<String> pdfSale(int id) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/tickets/pdf/sale/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/ticket_sale_$id.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await OpenFile.open(filePath);
      return 'PDF abierto desde: $filePath';
    } else {
      throw Exception('Error al obtener el ticket: ${response.statusCode}');
    }
  }

  Future<String> pdfsaldos() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/tickets/pdf/saldos'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/ticket_saldos.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await OpenFile.open(filePath);
      return 'PDF abierto desde: $filePath';

    } else {
      throw Exception('Error al obtener el ticket de saldos: ${response.statusCode}');
    }
  }

}
