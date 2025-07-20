import 'package:flutter/material.dart';
import 'auth/started.dart';
import 'auth/login.dart' as auth;
import 'auth/daftar.dart';
import 'auth/phone_address_verification_page.dart';
import 'auth/otp_verification_page.dart';
import 'auth/identity_upload_page.dart';
import 'main_layout.dart';
import 'rental/rental_process_screen.dart';
import 'rental/confirmation_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const StartedPage(),
  '/started': (context) => const StartedPage(),
  '/auth/login': (context) => const auth.LoginPage(),
  '/auth/daftar': (context) => const DaftarPage(),

  // Halaman input HP + alamat
  '/auth/daftar/phone-address-verification': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as int;
    return PhoneAddressVerificationPage(userId: args);
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

  '/auth/daftar/identity-upload': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as int;
    return IdentityUploadPage(userId: args);
  },

  '/main': (context) => const MainLayout(),

  // Proses penyewaan
  '/rental/process': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return RentalProcessScreen(product: args['product']);
  },

  // Konfirmasi penyewaan
  '/rental/confirmation': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ConfirmationScreen(
      product: args['product'],
      startDate: args['startDate'],
      endDate: args['endDate'],
      rentalId: args['rentalId'],
    );
  },
};
