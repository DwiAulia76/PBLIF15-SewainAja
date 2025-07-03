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
      appBar: AppBar(
        title: const Text('Verifikasi Identitas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lengkapi Data Identitas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nikController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIK',
                  hintText: '16 digit NIK',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
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
                decoration: const InputDecoration(
                  labelText: 'Tipe Identitas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Unggah Foto Identitas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pilih File'),
              ),
              const SizedBox(height: 10),
              if (_identityFile != null)
                Image.file(_identityFile!, height: 200),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadIdentity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Selesai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
