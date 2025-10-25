import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reserva.dart';
import '../utils/config.dart';
import 'login_services.dart';

class ReservaService {
  final LoginService _loginService = LoginService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _loginService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Reserva>> fetchReservas() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/reservas/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reserva.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al cargar reservas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Reserva> createReserva(Reserva reserva) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/reservas/'),
        headers: headers,
        body: jsonEncode(reserva.toJson()),
      );
      if (response.statusCode == 201) {
        return Reserva.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        print('Error response: ${response.body}');
        throw Exception('Error al crear reserva');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> cancelarReserva(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/reservas/$id/'),
        headers: headers,
        body: jsonEncode({'estado': 'cancelada'}),
      );
      if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode != 200) {
        throw Exception('Error al cancelar reserva');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteReserva(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/reservas/$id/'),
        headers: headers,
      );
      if (response.statusCode == 401) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode != 204) {
        throw Exception('Error al eliminar reserva');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
