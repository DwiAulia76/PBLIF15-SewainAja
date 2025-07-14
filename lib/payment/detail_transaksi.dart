import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OwnerRentalDetailScreen extends StatelessWidget {
  final String? rentalId; // optional
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
    this.rentalId,
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
    final days = endDate.difference(startDate).inDays;
    final actualStatus = status ?? 'Sedang Berjalan';
    final actualPaymentMethod = paymentMethod ?? 'Transfer Bank';
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              title: 'Informasi Transaksi',
              children: [
                if (rentalId != null)
                  _buildInfoRow('Rental ID', rentalId.toString()),
                _buildInfoRow('ID Transaksi', transactionId),
                _buildInfoRow(
                  'Tanggal Transaksi',
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                ),
                _buildInfoRow(
                  'Status',
                  actualStatus,
                  valueColor: actualStatus.toLowerCase().contains('selesai')
                      ? Colors.green
                      : Colors.orange,
                ),
                _buildInfoRow('Metode Pembayaran', actualPaymentMethod),
                _buildInfoRow(
                  'Total Pembayaran',
                  'Rp${NumberFormat('#,###').format(totalPrice)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Detail Produk',
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product['image'] ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
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
                          const SizedBox(height: 4),
                          Text(
                            product['price'] ?? '',
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
            const SizedBox(height: 16),
            _buildCard(
              title: 'Detail Penyewaan',
              children: [
                _buildInfoRow(
                  'Mulai Sewa',
                  DateFormat('dd MMM yyyy').format(startDate),
                ),
                _buildInfoRow(
                  'Selesai Sewa',
                  DateFormat('dd MMM yyyy').format(endDate),
                ),
                _buildInfoRow('Durasi', '$days Hari'),
                _buildInfoRow(
                  'Total Harga',
                  'Rp${NumberFormat('#,###').format(totalPrice)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Informasi Penyewa',
              children: [
                _buildInfoRow('Nama', actualRenterName),
                _buildInfoRow('No. Telepon', actualRenterPhone),
                _buildInfoRow('Alamat', actualRenterAddress),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0052CC)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                      // TODO: aksi menghubungi penyewa
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0052CC),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
