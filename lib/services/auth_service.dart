import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/api_constants.dart';
import '../utils/local_storage.dart';

class AuthService {
  static Future<User> login(String email, String password) async {
    try {
      print('Intentando login con URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.login}');
      // Asegurarnos de enviar los headers correctos y el body en el formato correcto
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'correo': email,
          'password': password,
        }),
      );

      print('URL de la petición: ${response.request?.url}');
      print('Método: ${response.request?.method}');
      print('Headers: ${response.request?.headers}');
      print('Código de estado: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      // Decodificar y validar la respuesta
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
        print('Respuesta decodificada: $responseData');
      } catch (e) {
        print('Error al decodificar la respuesta: $e');
        throw Exception('Error al procesar la respuesta del servidor');
      }

      if (response.statusCode == 200) {
        print('Datos recibidos del login: $responseData');
        
        // Validar y extraer el token de forma segura
        final dynamic accessToken = responseData['access'];
        if (accessToken == null) {
          print('Token no encontrado en la respuesta: $responseData');
          throw Exception('No se recibió el token de acceso');
        }
        
        final String token = accessToken.toString();
        print('Token extraído: $token');
        await LocalStorage.saveToken(token);
        print('Token guardado: $token');
        
        // En Django REST framework JWT, el usuario generalmente viene en el payload del token
        // o necesitas hacer una llamada adicional para obtener los datos del usuario
        print('Obteniendo perfil del usuario...');
        final userResponse = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/api/acceso_seguridad/perfil/'),
          headers: ApiHeaders.getHeaders(token: token),
        );
        
        print('Respuesta del perfil - Status: ${userResponse.statusCode}');
        print('Respuesta del perfil - Body: ${userResponse.body}');
        
        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          print('Datos del usuario recibidos: $userData');
          
          // Ajustar los datos para que coincidan con el modelo User
          final userDataMapped = {
            'id': userData['id'],
            'email': userData['correo'],
            'full_name': '${userData['nombre'] ?? ''} ${userData['apellido'] ?? ''}'.trim(),
            'role': userData['rol']?.toString().toUpperCase() ?? 
                    (userData['is_superuser'] == true ? 'ADMIN' : 'CLIENTE'),
            'is_active': userData['is_active'] ?? true,
            'cliente_id': userData['cliente']?['id'], // Guardamos el ID del cliente si existe
          };
          
          final user = User.fromJson(userDataMapped);
          await LocalStorage.saveUser(userDataMapped);
          return user;
        } else {
          throw Exception('Error al obtener datos del usuario');
        }
      } else {
        print('Error en la respuesta del servidor: ${response.statusCode}');
        Map<String, dynamic>? error;
        try {
          error = json.decode(response.body) as Map<String, dynamic>;
          print('Error decodificado: $error');
        } catch (e) {
          print('No se pudo decodificar el error: $e');
        }
        throw Exception(error?['detail'] ?? 'Error al iniciar sesión (${response.statusCode})');
      }
    } catch (e) {
      print('Error durante el proceso de login: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<bool> isAdmin() async {
    try {
      final userData = await LocalStorage.getUser();
      return userData?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This will remove all stored data
  }
}