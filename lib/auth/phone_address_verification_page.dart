import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhoneAddressVerificationPage extends StatefulWidget {
  final int userId;

  const PhoneAddressVerificationPage({super.key, required this.userId});

  @override
  State<PhoneAddressVerificationPage> createState() =>
      _PhoneAddressVerificationPageState();
}

class _PhoneAddressVerificationPageState
    extends State<PhoneAddressVerificationPage> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _debugOtp;

  Future<void> _sendOtpAndSaveData() async {
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (phone.isEmpty || address.isEmpty) {
      setState(() => _errorMessage = 'Nomor HP dan Alamat wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final otp = (100000 + Random().nextInt(900000)).toString();
    _debugOtp = otp;

    try {
      final headers = {'Content-Type': 'application/json'};

      final phoneResponse = await http.post(
        Uri.parse(
          'http://10.0.2.2/admin_sewainaja/api/register/update_phone.php',
        ),
        headers: headers,
        body: jsonEncode({'user_id': widget.userId, 'phone': phone}),
      );

      final addressResponse = await http.post(
        Uri.parse(
          'http://10.0.2.2/admin_sewainaja/api/register/store_address.php',
        ),
        headers: headers,
        body: jsonEncode({'user_id': widget.userId, 'address': address}),
      );

      final otpResponse = await http.post(
        Uri.parse('http://10.0.2.2/admin_sewainaja/api/register/store_otp.php'),
        headers: headers,
        body: jsonEncode({
          'user_id': widget.userId,
          'phone': phone,
          'otp_code': otp,
        }),
      );

      final success =
          (jsonDecode(phoneResponse.body)['success'] == true) &&
          (jsonDecode(addressResponse.body)['success'] == true) &&
          (jsonDecode(otpResponse.body)['success'] == true);

      if (!success) {
        setState(
          () => _errorMessage = 'Gagal menyimpan data. Silakan coba lagi.',
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/auth/daftar/otp-verification',
        arguments: {
          'userId': widget.userId,
          'phone': phone,
          'address': address,
          'debugOtp': otp,
        },
      );
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ),
        ),
        child: Stack(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Color(0xFF0052CC),
                minHeight: 2,
              ),
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 64,
                      color: Color(0xFF0052CC),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Verifikasi Nomor HP & Alamat',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0052CC),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Masukkan nomor handphone dan alamat lengkap untuk menerima OTP',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Nomor Handphone',
                                hintText: 'Contoh: 081234567890',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _addressController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Alamat Lengkap',
                                hintText: 'Contoh: Jl. Melati No. 7, Batam',
                              ),
                              keyboardType: TextInputType.streetAddress,
                            ),
                            const SizedBox(height: 16),
                            if (_errorMessage != null)
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            if (_debugOtp != null)
                              Text(
                                'OTP (Debug): $_debugOtp',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtpAndSaveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Kirim OTP',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
