import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OwnerRentalDetailScreen extends StatelessWidget {
  final String transactionId;
  final Map<String, dynamic> product;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  final String? status;
  final String? paymentMethod;
  final String? renterName;
  final String? renterPhone;
  final String? renterAddress;

  const OwnerRentalDetailScreen({
    super.key,
    required this.transactionId,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.status,
    this.paymentMethod,
    this.renterName,
    this.renterPhone,
    this.renterAddress,
  });

  @override
  Widget build(BuildContext context) {
    final duration = endDate.difference(startDate);
    final days = duration.inDays;

    final actualStatus = status ?? 'Sedang Berjalan';
    final actualPaymentMethod = paymentMethod ?? 'Gopay';
    final actualRenterName = renterName ?? 'Budi Santoso';
    final actualRenterPhone = renterPhone ?? '081234567890';
    final actualRenterAddress =
        renterAddress ?? 'Jl. Merdeka No. 123, Jakarta Pusat';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penyewaan'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0052CC),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Transaksi
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0052CC),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('ID Transaksi', transactionId),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Tanggal Transaksi',
                      DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Status',
                      actualStatus,
                      valueColor: actualStatus == 'Selesai'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow('Metode Pembayaran', actualPaymentMethod),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Total Pembayaran',
                      'Rp${NumberFormat('#,###').format(totalPrice)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Detail Produk
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0052CC),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Image.network(
                              product['image'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product['price'] ?? 'Rp 0/hari',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Detail Penyewaan
            Card(
              elevation: 3,
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
                        color: Color(0xFF0052CC),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Mulai Sewa',
                      DateFormat('dd MMM yyyy, HH:mm').format(startDate),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Selesai Sewa',
                      DateFormat('dd MMM yyyy, HH:mm').format(endDate),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow('Durasi', '$days Hari'),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Total Harga',
                      'Rp${NumberFormat('#,###').format(totalPrice)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Informasi Penyewa
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Penyewa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0052CC),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nama', actualRenterName),
                    const SizedBox(height: 10),
                    _buildInfoRow('No. Telepon', actualRenterPhone),
                    const SizedBox(height: 10),
                    _buildInfoRow('Alamat', actualRenterAddress),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF0052CC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(fontSize: 16, color: Color(0xFF0052CC)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Aksi untuk menghubungi penyewa
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF0052CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hubungi Penyewa',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
