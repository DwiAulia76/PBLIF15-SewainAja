import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(const SewainAjaApp());
}

class SewainAjaApp extends StatelessWidget {
  const SewainAjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SewainAja',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
