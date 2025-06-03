// En tu archivo config.dart
// const String kApiBaseUrl = 'http://100.118.244.96:8080';
// Reemplazar por:

import 'package:shared_preferences/shared_preferences.dart';

Future<String> getApiBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('api_base_url') ?? 'http://100.118.244.96:8080';
}
