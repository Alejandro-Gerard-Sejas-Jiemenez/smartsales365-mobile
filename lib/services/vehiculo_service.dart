import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehiculo.dart';
import '../utils/config.dart';

class VehiculoService {
  final String baseUrl = Config.baseUrl + '/vehiculos/';

  Future<List<Vehiculo>> fetchVehiculos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Vehiculo.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar vehículos');
    }
  }

  Future<Vehiculo> createVehiculo(Vehiculo vehiculo) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vehiculo.toJson()),
    );
    if (response.statusCode == 201) {
      return Vehiculo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear vehículo');
    }
  }

  Future<Vehiculo> updateVehiculo(int id, Vehiculo vehiculo) async {
    final response = await http.put(
      Uri.parse('$baseUrl$id/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vehiculo.toJson()),
    );
    if (response.statusCode == 200) {
      return Vehiculo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar vehículo');
    }
  }

  Future<void> deleteVehiculo(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$id/'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar vehículo');
    }
  }
}
