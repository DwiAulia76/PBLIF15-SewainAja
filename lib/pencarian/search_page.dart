import 'package:flutter/material.dart';
import '../data/dummy_products.dart';
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
  TabController? _tabController;

  // Daftar kategori
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'icon': Icons.all_inclusive},
    {'name': 'Elektronik', 'icon': Icons.electrical_services},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Alat Rumah Tangga', 'icon': Icons.home},
    {'name': 'Olahraga', 'icon': Icons.sports},
    {'name': 'Hobi', 'icon': Icons.music_note},
    {'name': 'Kesehatan', 'icon': Icons.health_and_safety},
    {'name': 'Otomotif', 'icon': Icons.directions_car},
  ];

  List<Map<String, dynamic>> _searchResults = [];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _searchResults = List.from(dummyProducts);

    // Otomatis fokus ke search field saat halaman terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = List.from(dummyProducts);
      } else {
        _searchResults = dummyProducts
            .where(
              (product) =>
                  (product['name'] as String).toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  (product['category'] as String).toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  void _filterByCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      if (index == 0) {
        // Semua kategori
        _searchResults = List.from(dummyProducts);
      } else {
        String selectedCategory = _categories[index]['name'] as String;
        _searchResults = dummyProducts
            .where((product) => product['category'] == selectedCategory)
            .toList();
      }
    });
  }

  void _navigateToProductDetail(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            onChanged: _performSearch,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Kategori
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

          // Hasil Pencarian
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
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
