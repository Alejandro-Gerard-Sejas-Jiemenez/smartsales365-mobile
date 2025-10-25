import 'package:condominium_app/screens/homeResidente.dart';
import 'package:condominium_app/screens/login_screen.dart';
import 'package:condominium_app/screens/areas/consultarDisponibilidad_screen.dart';
import 'package:condominium_app/screens/areas/reservarArea_screen.dart';
import 'package:condominium_app/screens/areas/cancelarReserva_screen.dart';
import 'package:condominium_app/screens/ia/reconocimiento_facial_screen.dart';
import 'package:condominium_app/screens/ia/reconocimiento_placa_screen.dart';
import 'package:condominium_app/screens/ia/camera_preview_screen.dart';
import 'package:condominium_app/screens/servicios/generar_servicios_screen.dart';
import 'package:condominium_app/screens/servicios/consultar_servicios_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solo inicializa Stripe si NO es web
  Stripe.publishableKey =
      'pk_test_51SCTlD0SS1LFGLIhL9jWlhw7cTgF5qfZaziM3jBJEFgrOE9MCMs6nvnekjUofs8OoTPdvXXy7WsI5JAgRza3bDTH00FB3CcphL';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Condominium',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeResidente(),
        '/homeResidente': (context) => HomeResidente(),
        '/consultarDisponibilidadArea': (context) =>
            ConsultarDisponibilidadScreen(),
        '/reservarArea': (context) => ReservarAreaScreen(),
        '/cancelarReservaArea': (context) => CancelarReservaScreen(),
        '/ia/reconocimientoFacial': (context) => ReconocimientoFacialScreen(),
        '/ia/reconocimientoPlaca': (context) => ReconocimientoPlacaScreen(),
        '/ia/cameraPreview': (context) => CameraPreviewScreen(),
        '/facturas': (context) => GenerarServiciosScreen(),
        '/generar-servicios': (context) => GenerarServiciosScreen(),
        '/consultar-servicios': (context) => ConsultarServiciosScreen(),
      },
    );
  }
}
