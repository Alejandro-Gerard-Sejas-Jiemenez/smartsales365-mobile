import 'dart:convert';
import 'package:condominium_app/utils/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  final String _baseUrl = Config.baseUrl;

  Future<bool> login(String correo, String password) async {
    final url = Uri.parse('$_baseUrl/cuenta/token/');
    print('📡 Intentando login a: $url');
    int retries = 3;

    for (int i = 0; i < retries; i++) {
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'correo': correo, 'password': password}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(data);
          if (data.containsKey('access')) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt_token', data['access']);
            // Puedes guardar info de usuario si lo necesitas: data['usuario']
            return true;
          } else {
            print("❌ No se encontró el token en la respuesta.");
            return false;
          }
        } else if (response.statusCode == 401) {
          print("❌ Credenciales inválidas");
          return false;
        } else if (response.statusCode == 423) {
          print("❌ Usuario bloqueado o debe recuperar contraseña");
          return false;
        } else {
          print(url);
          print("❌ Error al hacer login: ${response.statusCode}");
          return false;
        }
      } catch (e) {
        print("⏳ Backend aún no responde. Intento ${i + 1} de $retries");
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    print("❌ No se pudo conectar con el servidor.");
    return false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }
}
