import 'package:flutter/material.dart';

import 'auth/started.dart';
import 'auth/login.dart' as auth;
import 'Auth/daftar.dart';
import 'home/home.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => StartedPage(),
  '/auth/login': (context) => const auth.LoginPage(),
  '/auth/daftar': (context) => const daftarPage(),
  '/home': (context) => const HomePage(),
};
