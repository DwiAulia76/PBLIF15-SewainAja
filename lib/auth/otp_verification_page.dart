import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class OtpVerificationPage extends StatefulWidget {
  final int userId;
  final String phone;
  final String? debugOtp;

  const OtpVerificationPage({
    super.key,
    required this.userId,
    required this.phone,
    this.debugOtp,
  });

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      setState(() => _errorMessage = 'OTP wajib diisi');
      return;
    }

    // Verifikasi OTP secara lokal (debug mode)
    if (widget.debugOtp != null) {
      if (_otpController.text == widget.debugOtp) {
        // OTP benar, lanjut ke halaman berikutnya
        Navigator.pushNamed(
          context,
          '/auth/daftar/address',
          arguments: widget.userId,
        );
      } else {
        setState(() => _errorMessage = 'OTP tidak valid');
      }
      return;
    } else {
      // Jika tidak ada debugOtp, maka kita tidak bisa verifikasi (seharusnya tidak terjadi dalam mode debug)
      setState(() => _errorMessage = 'OTP debug tidak tersedia');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
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
            Text(
              'Masukkan kode OTP yang dikirim ke ${widget.phone}',
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.debugOtp != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'OTP: ${widget.debugOtp}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '6 digit OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verifikasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
