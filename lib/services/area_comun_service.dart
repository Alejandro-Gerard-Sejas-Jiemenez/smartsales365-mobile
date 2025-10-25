import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/area_comun.dart';
import '../utils/config.dart';
import 'login_services.dart';

class AreaComunService {
  final LoginService _loginService = LoginService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _loginService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AreaComun>> fetchAreas() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/areas-comunes/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AreaComun.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar áreas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<AreaComun>> fetchAreasDisponibles(DateTime fecha) async {
    try {
      final headers = await _getAuthHeaders();
      final fechaStr = fecha.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse(
          '${Config.baseUrl}/areas-comunes/?fecha=$fechaStr&disponible=true',
        ),
        headers: headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AreaComun.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar áreas disponibles');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
