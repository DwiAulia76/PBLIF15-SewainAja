import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final DateTime startDate;
  final DateTime endDate;
  final int rentalId;

  const ConfirmationScreen({
    super.key,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.rentalId,
  });

  @override
  Widget build(BuildContext context) {
    final duration = endDate.difference(startDate).inDays;
    final priceString = product['price'].toString();
    final cleanPrice = priceString.replaceAll(RegExp(r'[^0-9]'), '');
    final dailyPrice = int.tryParse(cleanPrice) ?? 0;
    final totalPrice = duration * dailyPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Penyewaan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 50,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Penyewaan Berhasil!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ID Penyewaan: #$rentalId',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Silakan lakukan pembayaran untuk menyelesaikan proses penyewaan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Detail Penyewaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow('Produk', product['name'] ?? '-'),
                    const Divider(),
                    _buildDetailRow(
                      'Harga Per Hari',
                      product['price'] ?? 'Rp 0',
                    ),
                    const Divider(),
                    _buildDetailRow(
                      'Waktu Mulai',
                      DateFormat('dd MMMM yyyy HH:mm').format(startDate),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      'Waktu Selesai',
                      DateFormat('dd MMMM yyyy HH:mm').format(endDate),
                    ),
                    const Divider(),
                    _buildDetailRow('Durasi', '$duration hari'),
                    const Divider(),
                    _buildDetailRow(
                      'Total Pembayaran',
                      'Rp ${NumberFormat('#,###').format(totalPrice)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance,
                      color: Colors.blue,
                    ),
                    title: const Text('Transfer Bank'),
                    subtitle: const Text('BNI, BRI, Mandiri, BCA'),
                    trailing: Radio(
                      value: 1,
                      groupValue: 1,
                      onChanged: (value) {},
                    ),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.qr_code, color: Colors.green),
                    title: const Text('QRIS'),
                    subtitle: const Text('Semua e-wallet'),
                    trailing: Radio(
                      value: 2,
                      groupValue: 1,
                      onChanged: (value) {},
                    ),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(
                      Icons.credit_card,
                      color: Colors.orange,
                    ),
                    title: const Text('Kartu Kredit'),
                    subtitle: const Text('Visa, Mastercard'),
                    trailing: Radio(
                      value: 3,
                      groupValue: 1,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Proses pembayaran
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
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
