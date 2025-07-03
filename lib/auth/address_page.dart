import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressPage extends StatefulWidget {
  final int userId;

  const AddressPage({super.key, required this.userId});

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _saveAddress() async {
    if (_addressController.text.isEmpty) {
      setState(() => _errorMessage = 'Alamat wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/admin_sewainaja/api/register/update_address.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'address': _addressController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushNamed(
          context,
          '/auth/daftar/identity-upload',
          arguments: widget.userId,
        );
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Gagal menyimpan alamat';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Koneksi error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Lengkap'),
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
              'Masukkan Alamat Lengkap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Contoh: Jl. Merdeka No. 123, Jakarta Pusat',
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
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
