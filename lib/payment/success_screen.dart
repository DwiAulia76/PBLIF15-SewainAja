import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_transaksi.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String transactionId;

  const SuccessScreen({
    super.key,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final duration = endDate.difference(startDate);
    final days = duration.inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0052CC),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ID Transaksi: $transactionId',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildProductCard(days),
            const SizedBox(height: 24),
            _buildDetailCard(),
            const SizedBox(height: 32),
            _buildHomeButton(context),
            const SizedBox(height: 16),
            _buildDetailButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(int days) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['image'] ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Nama Produk',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${days} hari',
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              'Mulai Sewa',
              DateFormat('dd MMM yyyy, HH:mm').format(startDate),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Selesai Sewa',
              DateFormat('dd MMM yyyy, HH:mm').format(endDate),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Total Pembayaran',
              'Rp${NumberFormat('#,###').format(totalPrice)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0052CC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      },

      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: const Color(0xFF0052CC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Kembali ke Beranda',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OwnerRentalDetailScreen(
              transactionId: transactionId,
              product: product,
              startDate: startDate,
              endDate: endDate,
              totalPrice: totalPrice,
            ),
          ),
        );
      },
      child: const Text(
        'Lihat Detail Transaksi',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF0052CC),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
