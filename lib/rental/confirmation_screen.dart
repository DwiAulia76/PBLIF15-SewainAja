import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sewainaja/payment/payment_screen.dart'; // Sesuaikan dengan nama aplikasi Anda

class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final DateTime startDate;
  final DateTime endDate;

  const ConfirmationScreen({
    super.key,
    required this.product,
    required this.startDate,
    required this.endDate,
  });

  double _calculateTotalPrice() {
    final priceString =
        product['price']?.replaceAll('Rp', '')?.replaceAll('/hari', '') ?? '0';
    final pricePerDay = double.tryParse(priceString) ?? 0.0;

    final duration = endDate.difference(startDate);
    final days = duration.inDays;
    final hours = duration.inHours;

    final totalDays = days + (hours % 24 > 0 ? 1 : 0);
    return pricePerDay * totalDays;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();
    final duration = endDate.difference(startDate);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Penyewaan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                            product['price'] ?? 'Rp 0/hari',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Penyewaan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      'Durasi',
                      '$days hari $hours jam $minutes menit',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPriceRow(
                      'Harga Sewa',
                      product['price'] ?? 'Rp 0/hari',
                    ),
                    const SizedBox(height: 12),
                    _buildPriceRow('Durasi Sewa', '$days hari'),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildPriceRow(
                      'Total Pembayaran',
                      'Rp${NumberFormat('#,###').format(totalPrice)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      product: product,
                      startDate: startDate,
                      endDate: endDate,
                      totalPrice: totalPrice,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPriceRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }
}
