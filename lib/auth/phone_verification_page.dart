import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'dart:math';

class PhoneVerificationPage extends StatefulWidget {
  final int userId;

  const PhoneVerificationPage({super.key, required this.userId});

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _debugOtp;

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _errorMessage = 'Nomor HP wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Untuk pengujian: generate OTP acak 6 digit
    final random = Random();
    final debugOtp = (100000 + random.nextInt(900000))
        .toString(); // Generate angka antara 100000 hingga 999999
    setState(() {
      _debugOtp = debugOtp;
    });

    // Tampilkan di log
    print('DEBUG OTP: $debugOtp');

    // Navigasi ke halaman verifikasi OTP dengan membawa OTP debug
    // Beri sedikit delay agar loading terlihat (opsional)
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/auth/daftar/otp-verification',
      arguments: {
        'userId': widget.userId, // Sudah bertipe int
        'phone': _phoneController.text,
        'debugOtp': debugOtp, // Kirim OTP debug
      },
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Nomor HP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Nomor HP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Contoh: 081234567890',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            if (_debugOtp != null)
              Text(
                'OTP (DEBUG): $_debugOtp',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
