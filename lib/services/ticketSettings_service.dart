import 'dart:convert';
import 'package:pos_app/models/client/client.dart';
import 'package:pos_app/models/client/client_abonos.dart';
import 'package:pos_app/models/department/department.dart';
import 'package:pos_app/models/tickets/ticketSettings.dart';

import 'dart:convert';
import '../config.dart';
import 'authenticated_client.dart';
import '../models/user/user.dart';
import '../models/user/user_registration.dart';

/// Servicio para consumo de la API de Productos usando cliente autenticado
class TicketSettingsService {
  final AuthenticatedClient _client;

  TicketSettingsService({AuthenticatedClient? client})
      : _client = client ?? AuthenticatedClient();

  /// Obtiene todos los usuarios
  Future<TicketSettings> fetchAll() async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/ticketSettings/findAll'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return TicketSettings.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error fetching TicketSettings: ${response.statusCode}');
    }
  }

  Future<String> update(TicketSettings settings) async {
    final baseUrl = await getApiBaseUrl();
    final response = await _client.put(
      Uri.parse('$baseUrl/api/ticketSettings/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(settings.toJson()),
    );
    if (response.statusCode == 200) {
      return "TicketSettings actualizado correctamente";
    } else {
      throw Exception('Error updating TicketSettings: ${response.statusCode}');
    }
  }

}
