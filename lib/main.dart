import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'layouts/customer_layout.dart';
import 'layouts/admin_layout.dart';
import 'utils/app_colors.dart';
import 'utils/stripe_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Stripe con la clave pública
  Stripe.publishableKey = StripeConfig.publishableKey;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartSales 365',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const CustomerLayout(),
        '/cart': (context) => const CartScreen(),
        '/admin/dashboard': (context) => AdminLayout(
          child: DashboardScreen(),
        ),
      },
    );
  }
}
