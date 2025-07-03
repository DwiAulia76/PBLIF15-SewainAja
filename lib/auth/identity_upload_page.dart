import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // Di-comment untuk mode debug
// import 'dart:convert'; // Di-comment untuk mode debug
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class IdentityUploadPage extends StatefulWidget {
  final int userId;

  const IdentityUploadPage({super.key, required this.userId});

  @override
  _IdentityUploadPageState createState() => _IdentityUploadPageState();
}

class _IdentityUploadPageState extends State<IdentityUploadPage> {
  final _nikController = TextEditingController();
  String? _identityType;
  File? _identityFile;
  bool _isLoading = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _identityFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadIdentity() async {
    if (_nikController.text.isEmpty) {
      setState(() => _errorMessage = 'NIK wajib diisi');
      return;
    }
    if (!RegExp(r'^\d{16}$').hasMatch(_nikController.text)) {
      setState(() => _errorMessage = 'NIK harus 16 digit angka');
      return;
    }
    if (_identityType == null) {
      setState(() => _errorMessage = 'Pilih tipe identitas');
      return;
    }
    if (_identityFile == null) {
      setState(() => _errorMessage = 'Pilih file identitas');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // MODE DEBUG: Simulasi proses upload identitas
    await Future.delayed(const Duration(seconds: 2)); // Simulasi proses

    // Tampilkan informasi debug di console
    debugPrint('DEBUG: Identitas berhasil diunggah');
    debugPrint('User ID: ${widget.userId}');
    debugPrint('NIK: ${_nikController.text}');
    debugPrint('Tipe Identitas: $_identityType');
    debugPrint('File Path: ${_identityFile!.path}');

    // Navigasi ke home setelah simulasi berhasil
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (Route<dynamic> route) => false,
    );

    setState(() => _isLoading = false);

    /* KODE ASLI (DI-COMMENT)
    try {
      // Konversi gambar ke base64
      final bytes = await _identityFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/admin_sewainaja/api/register/upload_identity.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'nik': _nikController.text,
          'identity_type': _identityType,
          'identity_file': base64Image,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _errorMessage =
              responseData['message'] ?? 'Gagal mengunggah identitas';
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
                          Icons.perm_identity,
                          size: 40,
                          color: Color(0xFF0052CC),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Judul
                      const Text(
                        'Verifikasi Identitas',
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
                          'Lengkapi data identitas Anda untuk verifikasi',
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
                                'Data Identitas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Input NIK
                              TextField(
                                controller: _nikController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'NIK',
                                  hintText: '16 digit NIK',
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
                              const SizedBox(height: 20),

                              // Dropdown Tipe Identitas
                              DropdownButtonFormField<String>(
                                value: _identityType,
                                items: ['KTP', 'SIM'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _identityType = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Tipe Identitas',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Unggah Foto Identitas
                              const Text(
                                'Unggah Foto Identitas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF0052CC),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: Color(0xFF0052CC),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Pilih File'),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Preview gambar
                              if (_identityFile != null)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.file(
                                    _identityFile!,
                                    height: 200,
                                  ),
                                ),
                              const SizedBox(height: 16),

                              // Pesan error
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tombol Selesai
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _uploadIdentity,
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
                                  'Selesai',
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
