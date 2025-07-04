import 'package:flutter/material.dart';
import 'routes.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cek status login saat aplikasi dimulai
  final isLoggedIn = await AuthService.isLoggedIn();

  runApp(SewainAjaApp(initialRoute: isLoggedIn ? '/home' : '/'));
}

class SewainAjaApp extends StatelessWidget {
  final String initialRoute;

  const SewainAjaApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SewainAja',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: appRoutes,
    );
  }
}
