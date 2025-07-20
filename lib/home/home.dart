import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../pencarian/search_page.dart';
import '../produk/product_detail_screen.dart'; // Import untuk ProductDetailScreen
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.celebration,
      'label': 'Pesta & Acara',
      'value': 'Alat Pesta & Acara',
    },
    {
      'icon': Icons.child_friendly,
      'label': 'Bayi & Anak',
      'value': 'Perlengkapan Bayi & Anak',
    },
    {
      'icon': Icons.construction,
      'label': 'Konstruksi',
      'value': 'Alat Konstruksi & Perkakas',
    },
    {
      'icon': Icons.terrain,
      'label': 'Outdoor',
      'value': 'Perlengkapan Outdoor & Camping',
    },
    {
      'icon': Icons.devices_other,
      'label': 'Elektronik',
      'value': 'Elektronik Khusus',
    },
    {
      'icon': Icons.fitness_center,
      'label': 'Olahraga',
      'value': 'Peralatan Olahraga',
    },
    {'icon': Icons.bed, 'label': 'Perabot', 'value': 'Perabot Rumah Sementara'},
    {
      'icon': Icons.cleaning_services,
      'label': 'Kebersihan',
      'value': 'Alat Kebersihan & Perawatan',
    },
  ];

  String formatRupiah(dynamic value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    if (value is String) {
      value = double.tryParse(value) ?? 0;
    }
    return formatter.format(value);
  }

  List<Map<String, dynamic>> _recommendedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    final url = Uri.http('10.0.2.2', '/admin_sewainaja/api/recommendation.php');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        final List<Map<String, dynamic>> products =
            List<Map<String, dynamic>>.from(data['data']);
        setState(() {
          _recommendedProducts = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _recommendedProducts = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _recommendedProducts = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildWelcomeHeader(),
              const SizedBox(height: 24),

              // Search field
              _buildSearchField(context),
              const SizedBox(height: 28),

              // Categories section
              _buildSectionTitle('Kategori'),
              const SizedBox(height: 16),
              _buildCategoryGrid(),
              const SizedBox(height: 28),

              // Recommendations section
              _buildRecommendationHeader(context),
              const SizedBox(height: 8),
              _buildRecommendationGrid(crossAxisCount),
            ],
          ),
        ),
      ),
    );
  }

  // Welcome header widget
  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, Selamat Datang!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Apa yang kamu butuhkan hari ini?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
      ],
    );
  }

  // Search field widget
  Widget _buildSearchField(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Category grid widget
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchPage(
                  initialCategoryValue: categories[index]['value'],
                ),
              ),
            ),
            splashColor: Colors.blue[100],
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categories[index]['icon'],
                      color: Colors.blue[700],
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      categories[index]['label'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Recommendation header widget
  Widget _buildRecommendationHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Rekomendasi'),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Lihat Semua',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Recommendation grid widget
  Widget _buildRecommendationGrid(int crossAxisCount) {
    return _isLoading
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 2,
              ),
            ),
          )
        : _recommendedProducts.isEmpty
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text(
              'Tidak ada rekomendasi saat ini',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          )
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _recommendedProducts.length,
            itemBuilder: (context, index) {
              final item = _recommendedProducts[index];
              return _buildProductCard(item);
            },
          );
  }

  // Product card widget
  Widget _buildProductCard(Map<String, dynamic> item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigasi ke halaman detail produk
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: item),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child:
                      item['image_url'] != null &&
                          item['image_url'].toString().isNotEmpty
                      ? Image.network(
                          item['image_url'],

                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImageErrorPlaceholder();
                          },
                        )
                      : _buildImageErrorPlaceholder(),
                ),
              ),

              // Product info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['name'] ?? 'Nama Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatRupiah(item['price_per_day'])} / hari',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Image placeholder widget
  Widget _buildImageErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: Colors.grey[400], size: 36),
          const SizedBox(height: 4),
          Text(
            'Gagal memuat gambar',
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: Colors.grey[800],
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
