import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  const PaymentScreen({
    Key? key,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _paymentProof;
  bool _isUploading = false;
  final Color _primaryColor = const Color(0xFF0052CC);
  final Color _lightBlue = const Color(0xFFE3F2FD);

  Future<void> _uploadPaymentProof() async {
    setState(() => _isUploading = true);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _paymentProof = File(pickedFile.path);
          _isUploading = false;
        });
      } else {
        setState(() => _isUploading = false);
      }
    } on PlatformException catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.endDate.difference(widget.startDate);
    final days = duration.inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductCard(),
            const SizedBox(height: 20),
            _buildPaymentDetail(days),
            const SizedBox(height: 24),
            _buildBankInfo(),
            const SizedBox(height: 16),
            _buildUploadSection(),
            const SizedBox(height: 32),
            _PaymentButton(
              text: 'Konfirmasi Pembayaran',
              onPressed: _paymentProof == null
                  ? null
                  : () {
                      final transactionId =
                          'TRX-${DateTime.now().millisecondsSinceEpoch}';
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessScreen(
                            product: widget.product,
                            startDate: widget.startDate,
                            endDate: widget.endDate,
                            totalPrice: widget.totalPrice,
                            transactionId: transactionId,
                          ),
                        ),
                      );
                    },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.product['image'] ?? 'https://via.placeholder.com/80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product['price'] ?? 0}/hari',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(widget.startDate)} - ${DateFormat('dd MMM yyyy').format(widget.endDate)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetail(int days) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildPriceRow(
              'Harga Sewa',
              '${widget.product['price'] ?? 0}/hari',
            ),
            const SizedBox(height: 12),
            _buildPriceRow('Durasi Sewa', '$days hari'),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            _buildPriceRow(
              'Total Pembayaran',
              'Rp${NumberFormat('#,###').format(widget.totalPrice)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Transfer Bank',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: _primaryColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _primaryColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBankInfoRow('Nama Bank', 'Bank Central Asia (BCA)'),
                const SizedBox(height: 10),
                _buildBankInfoRow('Nomor Rekening', '1234 5678 9012'),
                const SizedBox(height: 10),
                _buildBankInfoRow('Atas Nama', 'SewainAja Official'),
                const SizedBox(height: 10),
                _buildBankInfoRow(
                  'Jumlah Transfer',
                  'Rp${NumberFormat('#,###').format(widget.totalPrice)}',
                ),
                const SizedBox(height: 10),
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
        Text(
          'Unggah Bukti Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _uploadPaymentProof,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _primaryColor.withOpacity(0.5),
                width: 1.5,
              ),
              color: Colors.grey[50],
            ),
            child: Center(
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _paymentProof == null
                          ? [
                              Icon(
                                Icons.cloud_upload,
                                size: 40,
                                color: _primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Klik untuk mengunggah bukti transfer',
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Format: JPG, PNG (maks. 5MB)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ]
                          : [
                              const Icon(
                                Icons.check_circle,
                                size: 40,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Bukti pembayaran berhasil diunggah',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _paymentProof!.path.split('/').last,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                    ),
            ),
          ),
        ),
        if (_paymentProof != null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                'Klik kotak di atas untuk mengubah bukti pembayaran',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBankInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
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
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            fontWeight: FontWeight.bold,
            color: isTotal ? _primaryColor : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _PaymentButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PaymentButton({required this.text, this.onPressed});

  @override
  State<_PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<_PaymentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final Color primaryColor = const Color(0xFF0052CC);
    final Color hoverColor = const Color(0xFF0045A8);
    final Color buttonColor = isEnabled
        ? (_isHovered ? hoverColor : primaryColor)
        : Colors.grey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? _onTapDown : null,
        onTapUp: isEnabled ? _onTapUp : null,
        onTapCancel: isEnabled ? _onTapCancel : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
