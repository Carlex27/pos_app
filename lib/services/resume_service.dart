import 'dart:convert';
import 'package:pos_app/models/cortes/corte.dart';
import 'package:pos_app/models/resume/resume_dashboard.dart';
import 'package:pos_app/models/resume/resume_ventas.dart';

import '../config.dart';
import 'authenticated_client.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:typed_data';

/// Servicio para consumo de la API de Productos usando cliente autenticado
class ResumeService {
  final AuthenticatedClient _client;

  ResumeService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene el resumen de ventas del día actual
  Future<ResumeVentas> fetchResumeVentasByDay(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await _client.get(
      Uri.parse('$baseUrl/api/resume/ResumeVentas')
          .replace(queryParameters: {'date': formattedDate}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ResumeVentas.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sales for date: ${response.statusCode}');
    }
  }

  Future<String> pdfCorte(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/resume/pdf/corte')
          .replace(queryParameters: {'date': DateFormat('yyyy-MM-dd').format(date)}),
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
  Future<String> printCorte(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/resume/print/corte')
      .replace(queryParameters: {'date': DateFormat('yyyy-MM-dd').format(date)}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return "Ticket impreso correctamente";
    } else {
      throw Exception('Error fetching TicketSettings: ${response.statusCode}');
    }
  }

  Future<Corte> fetchCorteByDay(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await _client.get(
      Uri.parse('$baseUrl/api/resume/corte/day')
          .replace(queryParameters: {'date': formattedDate}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Corte.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sales for date: ${response.statusCode}');
    }
  }

  /// Obtiene el resumen del dashboard del día actual
  Future<ResumeDashboard> fetchResumeDashboardByDay(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await _client.get(
      Uri.parse('$baseUrl/api/resume/ResumeDashboard')
          .replace(queryParameters: {'date': formattedDate}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ResumeDashboard.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sales for date: ${response.statusCode}');
    }
  }


  /// Obtiene el resumen de ventas de un mes específico
  Future<ResumeVentas> fetchResumeVentasByMonth(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final int year = date.year;
    final int month = date.month;

    final response = await _client.get(
      Uri.parse('$baseUrl/api/resume/ResumeVentasByMonth')
          .replace(queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ResumeVentas.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sales for $month/$year: ${response.statusCode}');
    }
  }

  /// Obtiene el resumen del dashboard de un mes específico
  Future<ResumeDashboard> fetchResumeDashboardByMonth(DateTime date) async {
    final baseUrl = await getApiBaseUrl();
    final int year = date.year;
    final int month = date.month;

    final response = await _client.get(
      Uri.parse('$baseUrl/api/resume/ResumeDashboardByMonth')
          .replace(queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ResumeDashboard.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sales for $month/$year: ${response.statusCode}');
    }
  }
}
