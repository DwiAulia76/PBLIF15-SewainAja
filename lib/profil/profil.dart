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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId != null) {
        final uri = Uri.parse(
          'http://10.0.2.2/admin_sewainaja/api/get_user.php?user_id=$userId',
        );

        debugPrint("Fetching user data from: $uri");

        final response = await http.get(uri);

        debugPrint("Response status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            setState(() {
              userData = data['data'];
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage = data['message'] ?? 'Failed to load user data';
              isLoading = false;
            });
          }
        } else {
          throw Exception(
            'Failed to load user. Status code: ${response.statusCode}',
          );
        }
      } else {
        setState(() {
          errorMessage = 'User ID not found. Please login again.';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        errorMessage = 'Connection error: $e';
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
        title: const Text(
          "Profil",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: logout,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : userData == null
          ? const Center(child: Text("User data not available"))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          userData!['name'] ?? 'No name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userData!['email'] ?? 'No email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Profile Details
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.phone,
                          title: "No. HP",
                          value: userData!['phone']?.toString() ?? '-',
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildListTile(
                          icon: Icons.location_on,
                          title: "Alamat",
                          value: userData!['address']?.toString() ?? '-',
                        ),
                        if (userData?['nik'] != null) ...[
                          const Divider(height: 1, indent: 60),
                          _buildListTile(
                            icon: Icons.credit_card,
                            title: "NIK",
                            value: userData!['nik']?.toString() ?? '-',
                          ),
                        ],
                        if (userData?['identity_status'] != null) ...[
                          const Divider(height: 1, indent: 60),
                          _buildListTile(
                            icon: Icons.verified,
                            title: "Status Verifikasi",
                            value: userData!['identity_status'] == 'verified'
                                ? "Terverifikasi"
                                : "Belum terverifikasi",
                            valueColor:
                                userData!['identity_status'] == 'verified'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: valueColor ?? Colors.black,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      minVerticalPadding: 0,
    );
  }
}
