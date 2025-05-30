import 'dart:convert';
import 'package:pos_app/models/resume_dashboard.dart';
import 'package:pos_app/models/resume_ventas.dart';

import '../config.dart';
import 'authenticated_client.dart';

import 'package:intl/intl.dart';

/// Servicio para consumo de la API de Productos usando cliente autenticado
class ResumeService {
  final AuthenticatedClient _client;

  ResumeService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene el resumen de ventas del día actual
  Future<ResumeVentas> fetchResumeVentasByDay(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/resume/ResumeVentas')
          .replace(queryParameters: {'date': formattedDate}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ResumeVentas.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching sales for date: ${response.statusCode}');
    }
  }

  /// Obtiene el resumen del dashboard del día actual
  Future<ResumeDashboard> fetchResumeDashboardByDay(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/resume/ResumeDashboard')
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
    final int year = date.year;
    final int month = date.month;

    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/resume/ResumeVentasByMonth')
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
    final int year = date.year;
    final int month = date.month;

    final response = await _client.get(
      Uri.parse('$kApiBaseUrl/api/resume/ResumeDashboardByMonth')
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
