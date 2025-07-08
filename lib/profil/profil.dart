import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // HAPUS Scaffold di sini karena sudah ada di MainLayout
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildUserInfo(),
            _buildStatsSection(),
            _buildMenuOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Profile picture
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1887&q=80',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.blue[300],
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sarah Johnson',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Penyewa Aktif',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _navigateToEditProfile(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'sarah.j@example.com'),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.phone, '+62 812 3456 7890'),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.location_on, 'Jl. Sudirman No. 123, Jakarta'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, height: 1.4),
            key: ValueKey('info_$text'), // Key untuk debugging
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('12', 'Transaksi', Colors.blue),
          _buildStatItem('8.7', 'Rating', Colors.orange),
          _buildStatItem('98%', 'Selesai', Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          key: ValueKey('stat_$label'), // Key untuk debugging
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          key: ValueKey('label_$label'), // Key untuk debugging
        ),
      ],
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuOption(Icons.history, 'Riwayat Transaksi', context),
          _buildDivider(),
          _buildMenuOption(Icons.star_border, 'Ulasan Saya', context),
          _buildDivider(),
          _buildMenuOption(Icons.payment, 'Metode Pembayaran', context),
          _buildDivider(),
          _buildMenuOption(Icons.help_outline, 'Bantuan', context),
          _buildDivider(),
          _buildMenuOption(Icons.settings, 'Pengaturan', context),
          _buildDivider(),
          _buildMenuOption(Icons.logout, 'Keluar', context, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    IconData icon,
    String title,
    BuildContext context, {
    bool isLogout = false,
  }) {
    return ListTile(
      key: ValueKey('menu_$title'), // Key untuk debugging
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: isLogout ? Colors.red : Colors.grey[500],
      ),
      onTap: () => _handleMenuTap(context, title, isLogout),
    );
  }

  void _handleMenuTap(BuildContext context, String title, bool isLogout) {
    if (isLogout) {
      _showLogoutDialog(context);
    } else {
      // Untuk sementara, tampilkan snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu $title diklik'),
          duration: const Duration(seconds: 1),
        ),
      );

      // Tambahkan navigasi sesuai menu nanti
      /*
      switch (title) {
        case 'Riwayat Transaksi':
          Navigator.pushNamed(context, '/history');
          break;
        // ... lainnya
      }
      */
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anda telah keluar'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // Untuk sementara, tampilkan snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit profile diklik'),
        duration: Duration(seconds: 1),
      ),
    );

    // Navigator.pushNamed(context, '/edit-profile');
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
    );
  }
}
