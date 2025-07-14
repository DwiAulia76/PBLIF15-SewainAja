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

  // Fungsi memilih tanggal
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

  // Fungsi proses sewa
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

      // Ambil data yang diperlukan
      final String productId = widget.product['id'].toString();
      final String startDate = _rentalStartDate!.toIso8601String();
      final String endDate = _rentalEndDate!.toIso8601String();
      final int totalPrice = _calculateTotalPrice();

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
      if (response.statusCode == 200 && data['status'] == 'success') {
        final String transactionId = data['transaction_id'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              product: widget.product,
              startDate: _rentalStartDate!,
              endDate: _rentalEndDate!,
              rentalId: transactionId,
              totalPrice: totalPrice.toDouble(),
            ),
          ),
        );
      } else {
        _showMessage(data['message'] ?? 'Gagal menyimpan transaksi');
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // Menghitung total harga
  int _calculateTotalPrice() {
    if (_rentalStartDate == null || _rentalEndDate == null) return 0;

    final rawPrice = widget.product['price_per_day'] ?? widget.product['price'];
    final price = int.tryParse(rawPrice.toString()) ?? 0;
    final days = _rentalEndDate!.difference(_rentalStartDate!).inDays;

    return days * price;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final int totalPrice = _calculateTotalPrice();
    final String hargaFormatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalPrice);

    return Scaffold(
      appBar: AppBar(title: const Text('Atur Penyewaan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateCard('Tanggal Mulai Sewa', true, _rentalStartDate),
            _buildDateCard('Tanggal Selesai Sewa', false, _rentalEndDate),
            const SizedBox(height: 16),

            if (_rentalStartDate != null && _rentalEndDate != null)
              Text(
                'Total Harga (${_rentalEndDate!.difference(_rentalStartDate!).inDays} hari): $hargaFormatted',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 10),
            const Text(
              'Barang wajib dikembalikan maksimal pukul 17.00 WIB di hari terakhir sewa.',
              style: TextStyle(color: Colors.red),
            ),

            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processRental,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Lanjutkan ke Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(String title, bool isStart, DateTime? date) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          date == null
              ? 'Pilih Tanggal'
              : DateFormat('dd MMMM yyyy').format(date),
        ),
        onTap: () => _selectDate(isStart),
      ),
    );
  }
}
