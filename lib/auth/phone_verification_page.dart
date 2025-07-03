import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'dart:math'; // Tambahkan ini untuk generate random OTP

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
        'userId': widget.userId,
        'phone': _phoneController.text,
        'debugOtp': debugOtp, // Kirim OTP debug
      },
    );

    setState(() => _isLoading = false);

    /* KODE ASLI (DI-COMMENT)
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/admin_sewainaja/api/register/send_otp.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'phone': _phoneController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushNamed(
          context,
          '/auth/daftar/otp-verification',
          arguments: {
            'userId': widget.userId,
            'phone': _phoneController.text,
            'debugOtp': responseData['otp_debug'],
          },
        );
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Gagal mengirim OTP';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Koneksi error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
    */
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
            // Progress indicator di atas
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Color(0xFF0052CC),
                minHeight: 2,
              ),

            // Tombol back di pojok kiri atas
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon visual
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone_android,
                          size: 40,
                          color: Color(0xFF0052CC),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Judul
                      const Text(
                        'Verifikasi Nomor HP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0052CC),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Deskripsi
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Masukkan nomor handphone Anda untuk menerima kode OTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Card untuk form input
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nomor Handphone',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Input field
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Contoh: 081234567890',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0052CC),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Pesan error dan debug OTP
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (_debugOtp != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'OTP (DEBUG): $_debugOtp',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tombol Kirim OTP
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Kirim OTP',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
