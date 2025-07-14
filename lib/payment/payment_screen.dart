import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String rentalId;

  const PaymentScreen({
    Key? key,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.rentalId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _paymentProof;
  bool _isUploading = false;

  final Color _primaryColor = const Color(0xFF0052CC);
  final Color _lightBlue = const Color(0xFFE3F2FD);

  Future<void> _pickPaymentProof() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _paymentProof = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      _showError('Gagal memilih gambar: ${e.message}');
    }
  }

  Future<void> _submitPaymentProof() async {
    if (_paymentProof == null) {
      _showError('Silakan unggah bukti pembayaran terlebih dahulu.');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final base64Image = base64Encode(await _paymentProof!.readAsBytes());
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/admin_sewainaja/api/payment/store_payment.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'transaction_id': widget.rentalId,
          'amount': widget.totalPrice,
          'payment_method': 'Transfer Bank',
          'payment_proof': base64Image,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              product: widget.product,
              startDate: widget.startDate,
              endDate: widget.endDate,
              totalPrice: widget.totalPrice,
              transactionId: widget.rentalId,
              rentalId: widget.rentalId,
            ),
          ),
        );
      } else {
        _showError(data['message'] ?? 'Gagal menyimpan pembayaran.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan saat mengirim data: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.endDate.difference(widget.startDate).inDays;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductCard(),
            const SizedBox(height: 20),
            _buildPaymentDetail(days, formatter),
            const SizedBox(height: 20),
            _buildBankInfo(formatter),
            const SizedBox(height: 20),
            _buildUploadSection(),
            const SizedBox(height: 32),
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.product['image'] ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: _lightBlue,
                  child: Icon(Icons.image, color: _primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'] ?? 'Nama Produk',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${widget.product['price_per_day'] ?? widget.product['price']}/hari',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(widget.startDate)} - ${DateFormat('dd MMM yyyy').format(widget.endDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetail(int days, NumberFormat formatter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rincian Pembayaran', style: _sectionTitleStyle()),
            const SizedBox(height: 16),
            _buildPriceRow(
              'Harga Sewa',
              'Rp ${widget.product['price_per_day'] ?? widget.product['price']}/hari',
            ),
            _buildPriceRow('Durasi Sewa', '$days hari'),
            Divider(color: Colors.grey[300]),
            _buildPriceRow(
              'Total Pembayaran',
              formatter.format(widget.totalPrice),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo(NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informasi Transfer Bank', style: _sectionTitleStyle()),
        const SizedBox(height: 12),
        Card(
          color: _primaryColor.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _primaryColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBankInfoRow('Nama Bank', 'BCA'),
                _buildBankInfoRow('No. Rekening', '1234567890'),
                _buildBankInfoRow('Atas Nama', 'SewainAja Official'),
                _buildBankInfoRow(
                  'Jumlah Transfer',
                  formatter.format(widget.totalPrice),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Unggah Bukti Pembayaran', style: _sectionTitleStyle()),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickPaymentProof,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: _primaryColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: Center(
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : _paymentProof == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: _primaryColor,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Klik untuk unggah bukti transfer',
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Bukti berhasil diunggah',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    final isEnabled = _paymentProof != null && !_isUploading;
    return GestureDetector(
      onTap: isEnabled ? _submitPaymentProof : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isEnabled ? _primaryColor : Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Konfirmasi Pembayaran',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isTotal ? _primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _primaryColor,
    );
  }
}
