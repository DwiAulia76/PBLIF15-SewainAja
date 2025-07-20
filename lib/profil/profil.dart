import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId != null) {
        final response = await http.post(
          Uri.parse(
            'http://10.0.2.2/admin_sewainaja/api/get_user.php',
          ), // Ganti URL sesuai backend kamu
          body: jsonEncode({'user_id': userId}),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            userData = data;
            isLoading = false;
          });
        } else {
          throw Exception('Gagal mengambil data pengguna');
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void logout() async {
    await AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/started', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text("Gagal memuat data pengguna"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      'assets/images/profile.png',
                    ), // ganti sesuai path
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData!['name'] ?? 'Nama tidak tersedia',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Email: ${userData!['email'] ?? '-'}"),
                  const SizedBox(height: 8),
                  Text("No HP: ${userData!['phone'] ?? '-'}"),
                  const SizedBox(height: 8),
                  Text("Alamat: ${userData!['address'] ?? '-'}"),
                ],
              ),
            ),
    );
  }
}
