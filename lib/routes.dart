import 'package:flutter/material.dart';
import 'auth/started.dart';
import 'auth/login.dart' as auth;
import 'auth/daftar.dart';
import 'auth/phone_verification_page.dart';
import 'auth/otp_verification_page.dart';
import 'auth/address_page.dart';
import 'auth/identity_upload_page.dart';
import 'main_layout.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/started': (context) =>
      const StartedPage(), // Pindahkan started ke rute terpisah
  '/auth/login': (context) => const auth.LoginPage(),
  '/auth/daftar': (context) => const DaftarPage(),
  '/auth/daftar/phone-verification': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as int;
    return PhoneVerificationPage(userId: args);
  },
  '/auth/daftar/otp-verification': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return OtpVerificationPage(
      userId: args['userId'],
      phone: args['phone'],
      debugOtp: args['debugOtp'],
    );
  },
  '/auth/daftar/address': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as int;
    return AddressPage(userId: args);
  },
  '/auth/daftar/identity-upload': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as int;
    return IdentityUploadPage(userId: args);
  },
  '/main': (context) =>
      const MainLayout(), // Jadikan MainLayout sebagai rute utama
};
