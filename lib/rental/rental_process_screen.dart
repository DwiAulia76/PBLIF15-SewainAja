import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../payment/payment_screen.dart';

class RentalProcessScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const RentalProcessScreen({super.key, required this.product});

  @override
  State<RentalProcessScreen> createState() => _RentalProcessScreenState();
}

class _RentalProcessScreenState extends State<RentalProcessScreen> {
  DateTime? _rentalStartDate;
  DateTime? _rentalEndDate;
  bool _isProcessing = false;

  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate
        ? DateTime.now()
        : (_rentalStartDate != null
              ? _rentalStartDate!.add(const Duration(days: 2))
              : DateTime.now().add(const Duration(days: 2)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _rentalStartDate = picked;
          _rentalEndDate = null;
        } else {
          _rentalEndDate = picked;
        }
      });
    }
  }

  Future<void> _processRental() async {
    if (_rentalStartDate == null || _rentalEndDate == null) {
      _showMessage('Silakan pilih tanggal mulai dan selesai');
      return;
    }

    if (_rentalEndDate!.difference(_rentalStartDate!).inDays < 2) {
      _showMessage('Durasi sewa minimal 2 hari');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        _showMessage('Silakan login terlebih dahulu');
        return;
      }

      // Mengambil harga dari format decimal
      final double price = double.parse(
        widget.product['price_per_day'].toString(),
      );
      final int days = _rentalEndDate!.difference(_rentalStartDate!).inDays;
      final double totalPrice = days * price;

      final String productId = widget.product['id'].toString();
      final String startDate = _rentalStartDate!.toIso8601String();
      final String endDate = _rentalEndDate!.toIso8601String();

      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/admin_sewainaja/api/transactions/store_transaction.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'start_date': startDate,
          'end_date': endDate,
          'total_price': totalPrice,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == 'success') {
          final String transactionId = data['transaction_id'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                product: widget.product,
                startDate: _rentalStartDate!,
                endDate: _rentalEndDate!,
                rentalId: transactionId,
                totalPrice: totalPrice,
              ),
            ),
          );
        } else {
          String errorMsg = data['message'] ?? 'Gagal menyimpan transaksi';
          _showMessage(errorMsg);
        }
      } else {
        _showMessage('Terjadi kesalahan server (${response.statusCode})');
      }
    } catch (e) {
      _showMessage('Koneksi gagal: Pastikan Anda terhubung ke internet');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  double _calculateTotalPrice() {
    if (_rentalStartDate == null || _rentalEndDate == null) return 0.0;

    final double price = double.parse(
      widget.product['price_per_day'].toString(),
    );
    final int days = _rentalEndDate!.difference(_rentalStartDate!).inDays;
    return days * price;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Fungsi untuk mendapatkan URL gambar yang benar
  String _getImageUrl() {
    if (widget.product['image'] == null || widget.product['image'].isEmpty) {
      return '';
    }

    String imagePath = widget.product['image'];

    // Perbaikan 1: Hapus bagian awal yang tidak perlu
    if (imagePath.startsWith('uploads/')) {
      imagePath = imagePath.replaceFirst('uploads/', '');
    }

    // Perbaikan 2: Hapus duplikasi 'uploads'
    if (imagePath.contains('uploads/uploads')) {
      imagePath = imagePath.replaceFirst('uploads/', '');
    }

    // Perbaikan 3: Tambahkan path dasar
    String basePath = 'http://10.0.2.2/admin_sewainaja/uploads/';

    // Perbaikan 4: Handle karakter khusus
    imagePath = Uri.encodeFull(imagePath);

    return basePath + imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = _calculateTotalPrice();
    final String hargaFormatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalPrice);

    final int? rentalDays = _rentalStartDate != null && _rentalEndDate != null
        ? _rentalEndDate!.difference(_rentalStartDate!).inDays
        : null;

    final double price = double.parse(
      widget.product['price_per_day'].toString(),
    );
    final String pricePerDay = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);

    final String imageUrl = _getImageUrl();
    print("Image URL: $imageUrl"); // Untuk debugging

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur Penyewaan'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product card with image
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Product image
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildProductImage(imageUrl),
                    ),
                    const SizedBox(width: 16),

                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product['name'] ?? 'Nama Produk',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  pricePerDay,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/hari',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (widget.product['category'] != null)
                            Text(
                              'Kategori: ${widget.product['category']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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

            // Date pickers
            _buildDateField(
              label: 'Tanggal Mulai Sewa',
              isStartDate: true,
              date: _rentalStartDate,
            ),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'Tanggal Selesai Sewa',
              isStartDate: false,
              date: _rentalEndDate,
            ),

            const SizedBox(height: 24),

            // Price summary card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (rentalDays != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Biaya Sewa',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            '$rentalDays hari × $pricePerDay',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Biaya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hargaFormatted,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Barang wajib dikembalikan sebelum pukul 17.00 WIB di hari terakhir sewa',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processRental,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Lanjutkan ke Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }

    try {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } catch (e) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
    }
  }

  Widget _buildDateField({
    required String label,
    required bool isStartDate,
    required DateTime? date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(isStartDate),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: date == null ? Colors.grey[500] : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  date == null
                      ? 'Pilih Tanggal'
                      : DateFormat('dd MMMM yyyy').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    color: date == null ? Colors.grey[500] : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
