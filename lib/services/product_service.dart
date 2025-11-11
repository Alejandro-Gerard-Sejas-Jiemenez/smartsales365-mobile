import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/api_constants.dart';
import '../utils/local_storage.dart';

class ProductService {
  Future<List<Product>> getProducts() async {
    try {
      final token = await LocalStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.productos}'),
        headers: ApiHeaders.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMockProducts() async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        'id': 1,
        'name': 'Laptop Gamer',
        'description': 'Laptop de última generación para gaming',
        'price': 8999.99,
        'stock': 5,
        'image_url': 'https://via.placeholder.com/300',
        'category': 'Electrónicos',
      },
      {
        'id': 2,
        'name': 'Smartphone Premium',
        'description': 'Teléfono inteligente de alta gama',
        'price': 4999.99,
        'stock': 10,
        'image_url': 'https://via.placeholder.com/300',
        'category': 'Electrónicos',
      },
      {
        'id': 3,
        'name': 'Audífonos Inalámbricos',
        'description': 'Audífonos con cancelación de ruido',
        'price': 599.99,
        'stock': 15,
        'image_url': 'https://via.placeholder.com/300',
        'category': 'Accesorios',
      },
    ];
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    try {
      final token = await LocalStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.productos}$id/'),
        headers: ApiHeaders.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener el producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}