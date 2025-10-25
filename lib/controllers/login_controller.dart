import 'package:condominium_app/services/login_services.dart';

class LoginController {
  /// Realiza el login y retorna true si es exitoso, false si no.
  /// Lanza una excepción si hay error de conexión.
  Future<bool> login(String user, String password) async {
    final loginService = LoginService();
    try {
      final success = await loginService.login(user, password);
      return success;
    } catch (e) {
      rethrow;
    }
  }
}
