import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../payment/detail_transaksi.dart'; // Pastikan path ini benar

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {
        'id': 'TRX004',
        'productName': 'Lighting Studio Professional',
        'startDate': DateTime.now().subtract(const Duration(days: 2)),
        'endDate': DateTime.now(),
        'totalPrice': 450000.0,
        'status': 'disewa',
        'imageUrl': 'https://via.placeholder.com/300x150.png?text=LIGHT',
      },
      {
        'id': 'TRX005',
        'productName': 'Camera DSLR Kit',
        'startDate': DateTime.now().subtract(const Duration(days: 5)),
        'endDate': DateTime.now().add(const Duration(days: 2)),
        'totalPrice': 325000.0,
        'status': 'selesai',
        'imageUrl': 'https://via.placeholder.com/300x150.png?text=CAMERA',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // TAMBAHKAN INI
        title: const Text('Riwayat Penyewaan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF4A90E2),
      ),
      backgroundColor: const Color(0xFFF0F7FF),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildTransactionCard(context, transactions[index]);
        },
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final start = transaction['startDate'] as DateTime;
    final end = transaction['endDate'] as DateTime;
    final now = DateTime.now();

    final dateRange =
        '${DateFormat('d MMM yyyy, HH:mm').format(start)} - ${DateFormat('d MMM yyyy, HH:mm').format(end)}';
    final totalPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(transaction['totalPrice']);

    final statusLabel = transaction['status'];
    final statusColor = statusLabel.toLowerCase() == 'selesai'
        ? Colors.green
        : const Color(0xFFFFA000);
    final bgColor = statusLabel.toLowerCase() == 'selesai'
        ? Colors.green.shade50
        : const Color(0xFFFFF8E1);

    String timeInfo = '';
    Color timeColor = Colors.grey.shade700;
    String pesanPengembalian = '';

    if (statusLabel.toLowerCase() == 'disewa') {
      if (now.isAfter(end)) {
        timeInfo = 'Terlambat: ${now.difference(end).inDays} hari';
        timeColor = Colors.red;
        pesanPengembalian =
            'Segera kembalikan produk untuk menghindari denda tambahan!';
      } else {
        final remaining = end.difference(now);
        timeInfo = 'Sisa: ${remaining.inDays}d ${remaining.inHours % 24}j';
        timeColor = Colors.blue;

        final isSameDay =
            now.year == end.year &&
            now.month == end.month &&
            now.day == end.day;
        final batasJam5 = DateTime(end.year, end.month, end.day, 17, 0);

        if (isSameDay) {
          if (now.isBefore(batasJam5)) {
            pesanPengembalian = 'Harap kembalikan hari ini sebelum pukul 17.00';
          } else {
            pesanPengembalian = 'Kembalikan besok sebelum pukul 09.00';
          }
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${transaction['id']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
            child: Image.network(
              transaction['imageUrl'] ?? '',
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 140,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Gambar tidak tersedia',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['productName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateRange,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (timeInfo.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        now.isAfter(end)
                            ? Icons.warning_amber
                            : Icons.access_time,
                        size: 16,
                        color: timeColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeInfo,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: timeColor,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Harga:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      totalPrice,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (pesanPengembalian.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Colors.orange.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pesanPengembalian,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      final duration = end.difference(start).inDays;

                      final productDetail = {
                        'name': transaction['productName'],
                        'image': transaction['imageUrl'],
                        'price':
                            'Rp ${NumberFormat('#,###').format(transaction['totalPrice'] / duration)}/hari',
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerRentalDetailScreen(
                            transactionId: transaction['id'],
                            product: productDetail,
                            startDate: start,
                            endDate: end,
                            totalPrice: transaction['totalPrice'],
                            status: transaction['status'] == 'selesai'
                                ? 'Selesai'
                                : 'Sedang Berjalan',
                            renterName: 'Nama Penyewa',
                            renterPhone: '081234567890',
                            renterAddress: 'Alamat Penyewa',
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFBBDEFB),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Lihat Detail Transaksi',
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
