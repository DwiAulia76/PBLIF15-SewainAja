import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../produk/product_card.dart';
import '../produk/product_detail_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounceTimer;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'icon': Icons.all_inclusive, 'value': ''},
    {
      'name': 'Elektronik',
      'icon': Icons.electrical_services,
      'value': 'Elektronik',
    },
    {'name': 'Fashion', 'icon': Icons.checkroom, 'value': 'Fashion'},
    {
      'name': 'Alat Rumah Tangga',
      'icon': Icons.home,
      'value': 'Alat Rumah Tangga',
    },
    {'name': 'Olahraga', 'icon': Icons.sports, 'value': 'Olahraga'},
    {'name': 'Hobi', 'icon': Icons.music_note, 'value': 'Hobi'},
    {
      'name': 'Kesehatan',
      'icon': Icons.health_and_safety,
      'value': 'Kesehatan',
    },
    {'name': 'Otomotif', 'icon': Icons.directions_car, 'value': 'Otomotif'},
  ];

  List<Map<String, dynamic>> _searchResults = [];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _fetchProducts();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty || query.length >= 2) {
        _performSearch(query);
      }
    });
  }

  Future<void> _fetchProducts({
    String keyword = '',
    String category = '',
  }) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _searchResults = [];
    });

    try {
      final queryParams = {
        'keyword': keyword,
        'category': category == 'Semua' ? '' : category,
      };

      final url = Uri.http(
        '10.0.2.2',
        '/admin_sewainaja/api/product/search_product.php',
        queryParams,
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final allProducts = List<Map<String, dynamic>>.from(data['data'] ?? []);

        final visibleProducts = allProducts.where((product) {
          final status = product['status']?.toString().toLowerCase();
          return status == 'tersedia' || status == 'available';
        }).toList();

        setState(() {
          _searchResults = visibleProducts;
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Tidak ada data ditemukan');
      }
    } on TimeoutException {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Permintaan waktu habis';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _performSearch(String query) {
    final category = _categories[_selectedCategoryIndex]['value'] as String;
    _fetchProducts(keyword: query, category: category);
  }

  void _filterByCategory(int index) {
    setState(() => _selectedCategoryIndex = index);
    final category = _categories[index]['value'] as String;
    _fetchProducts(keyword: _searchController.text, category: category);
  }

  void _navigateToProductDetail(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  String _getStatusLabel(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'tersedia' || normalized == 'available') {
      return 'Tersedia';
    } else if (normalized == 'disewa') {
      return 'Disewa';
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: _onSearchChanged,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: _categories.map((category) {
                return Tab(
                  child: Row(
                    children: [
                      Icon(category['icon'] as IconData, size: 18),
                      const SizedBox(width: 6),
                      Text(category['name'] as String),
                    ],
                  ),
                );
              }).toList(),
              onTap: _filterByCategory,
            ),
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchProducts(
                keyword: _searchController.text,
                category:
                    _categories[_selectedCategoryIndex]['value'] as String,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ditemukan hasil untuk pencarian ini',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Coba kata kunci lain atau kategori berbeda',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return ProductCard(
          product: product,
          onTap: () => _navigateToProductDetail(product),
        );
      },
    );
  }
}
