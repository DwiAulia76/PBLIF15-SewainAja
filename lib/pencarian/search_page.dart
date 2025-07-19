import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../produk/product_card.dart';
import '../produk/product_detail_screen.dart';

class SearchPage extends StatefulWidget {
  final String? initialCategoryValue;
  const SearchPage({super.key, this.initialCategoryValue});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounceTimer;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'icon': Icons.all_inclusive, 'value': ''},
    {
      'name': 'Pesta & Acara',
      'icon': Icons.celebration,
      'value': 'Alat Pesta & Acara',
    },
    {
      'name': 'Bayi & Anak',
      'icon': Icons.child_friendly,
      'value': 'Perlengkapan Bayi & Anak',
    },
    {
      'name': 'Konstruksi',
      'icon': Icons.construction,
      'value': 'Alat Konstruksi & Perkakas',
    },
    {
      'name': 'Outdoor',
      'icon': Icons.terrain,
      'value': 'Perlengkapan Outdoor & Camping',
    },
    {
      'name': 'Elektronik',
      'icon': Icons.devices_other,
      'value': 'Elektronik Khusus',
    },
    {
      'name': 'Olahraga',
      'icon': Icons.fitness_center,
      'value': 'Peralatan Olahraga',
    },
    {
      'name': 'Perabot',
      'icon': Icons.chair,
      'value': 'Perabot Rumah Sementara',
    },
    {
      'name': 'Kebersihan',
      'icon': Icons.cleaning_services,
      'value': 'Alat Kebersihan & Perawatan',
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryValue != null) {
      final index = _categories.indexWhere(
        (cat) => cat['value'] == widget.initialCategoryValue,
      );
      if (index != -1) {
        _selectedCategoryIndex = index;
      }
    }
    _fetchProducts(category: _categories[_selectedCategoryIndex]['value']);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
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
      final queryParams = {'keyword': keyword, 'category': category};

      final url = Uri.http(
        '10.0.2.2',
        '/admin_sewainaja/api/product/search_product.php',
        queryParams,
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final allProducts = List<Map<String, dynamic>>.from(data['data'] ?? []);

        final available = allProducts.where((p) {
          final s = (p['status'] ?? '').toString().toLowerCase();
          return s == 'tersedia' || s == 'available';
        }).toList();

        final rented = allProducts.where((p) {
          final s = (p['status'] ?? '').toString().toLowerCase();
          return s == 'disewa' || s == 'rented';
        }).toList();

        setState(() {
          _searchResults = [...available, ...rented];
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data');
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

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              'Mencari produk...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Tidak ditemukan produk",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Coba kata kunci atau kategori berbeda",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
        final status = (product['status'] ?? '').toString().toLowerCase();
        final isAvailable = status == 'tersedia' || status == 'available';

        return Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: AbsorbPointer(
            absorbing: !isAvailable,
            child: ProductCard(
              product: product,
              onTap: () => _navigateToProductDetail(product),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
              border: InputBorder.none,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[500]),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: Colors.white,
            ),
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            onChanged: _onSearchChanged,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.blue[700]),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categories[index]['icon'],
                        size: 18,
                        color: isSelected ? Colors.white : Colors.blue[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _categories[index]['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _filterByCategory(index);
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }
}
