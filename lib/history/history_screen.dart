import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTransactionHistory();
  }

  Future<void> fetchTransactionHistory() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User ID tidak ditemukan';
      });
      return;
    }

    try {
      final url = Uri.parse(
        'http://10.0.2.2/admin_sewainaja/api/history.php?user_id=$userId',
      );

      debugPrint('Fetching data from: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        // Handle jika API mengembalikan error message
        if (decodedBody is Map && decodedBody.containsKey('message')) {
          throw Exception(decodedBody['message']);
        }

        // Pastikan response adalah List
        if (decodedBody is List) {
          setState(() {
            _transactions = decodedBody.cast<Map<String, dynamic>>();
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          throw Exception('Format data tidak valid');
        }
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penyewaan'),
        backgroundColor: const Color(0xFF4A90E2),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF0F7FF),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchTransactionHistory,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const Center(child: Text('Belum ada riwayat penyewaan.'));
    }

    return ListView.builder(
      itemCount: _transactions.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) =>
          _buildTransactionCard(_transactions[index]),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> data) {
    // Tangani kemungkinan format tanggal tidak valid
    DateTime? start, end;
    String dateRange = 'Tanggal tidak valid';

    try {
      start = DateTime.parse(data['start_date']);
      end = DateTime.parse(data['end_date']);
      dateRange =
          '${DateFormat('d MMM yyyy').format(start)} - ${DateFormat('d MMM yyyy').format(end)}';
    } catch (e) {
      debugPrint('Error parsing date: $e');
    }

    final totalPrice = double.tryParse(data['total_price'].toString()) ?? 0;

    final status = data['status']?.toString()?.toLowerCase() ?? 'unknown';
    final statusColor = status == 'selesai' ? Colors.green : Colors.orange;
    final bgColor = status == 'selesai'
        ? Colors.green.shade50
        : Colors.orange.shade50;

    // Debug URL gambar
    final imageUrl = data['image']?.toString() ?? '';
    debugPrint('Image URL: $imageUrl');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.grey.shade300)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
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
                Text('ID: ${data['id']}', style: const TextStyle(fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Gambar dengan placeholder dan loading
          _buildProductImage(imageUrl),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['product_name']?.toString() ?? 'Nama Produk',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 6),
                    Text(dateRange, style: const TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Harga:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(totalPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    // Tambahkan URL encoding untuk karakter khusus
    final encodedUrl = Uri.encodeFull(imageUrl);
    debugPrint('Encoded Image URL: $encodedUrl');

    return Image.network(
      encodedUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 150,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        debugPrint('Error loading image: $encodedUrl');
        return _buildImagePlaceholder();
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40, color: Colors.grey[500]),
          const SizedBox(height: 8),
          Text(
            'Gambar tidak tersedia',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
