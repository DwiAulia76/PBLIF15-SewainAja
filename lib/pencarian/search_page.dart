import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  TabController? _tabController; // Ubah menjadi nullable

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

  // Data dummy produk
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Kamera DSLR Profesional',
      'price': 'Rp 100K/hari',
      'image': 'https://i.imgur.com/fHyEMsl.jpg',
      'rating': 4.8,
      'sold': 120,
      'category': 'Elektronik',
    },
    {
      'name': 'Blender Philips HR2115',
      'price': 'Rp 30K/hari',
      'image': 'https://i.imgur.com/5X3mJtC.jpg',
      'rating': 4.5,
      'sold': 85,
      'category': 'Alat Rumah Tangga',
    },
    {
      'name': 'Sepatu Lari Nike Air Zoom',
      'price': 'Rp 50K/hari',
      'image': 'https://i.imgur.com/2bziZbX.jpg',
      'rating': 4.7,
      'sold': 200,
      'category': 'Olahraga',
    },
    {
      'name': 'Tas Ransel Travel',
      'price': 'Rp 40K/hari',
      'image': 'https://i.imgur.com/Jf4w6Yr.jpg',
      'rating': 4.6,
      'sold': 150,
      'category': 'Fashion',
    },
    {
      'name': 'Setrika Uap Panasonic',
      'price': 'Rp 25K/hari',
      'image': 'https://i.imgur.com/8tQ6b3U.jpg',
      'rating': 4.4,
      'sold': 95,
      'category': 'Alat Rumah Tangga',
    },
    {
      'name': 'Kamera Mirrorless Sony A7',
      'price': 'Rp 120K/hari',
      'image': 'https://i.imgur.com/3tQ0yYj.jpg',
      'rating': 4.9,
      'sold': 75,
      'category': 'Elektronik',
    },
    {
      'name': 'Gitar Akustik Yamaha',
      'price': 'Rp 60K/hari',
      'image': 'https://i.imgur.com/7W0gK9p.jpg',
      'rating': 4.7,
      'sold': 45,
      'category': 'Hobi',
    },
    {
      'name': 'Treadmill Elektrik',
      'price': 'Rp 80K/hari',
      'image': 'https://i.imgur.com/9d7aN8T.jpg',
      'rating': 4.6,
      'sold': 30,
      'category': 'Olahraga',
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _searchResults = List.from(_products);

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
        _searchResults = List.from(_products);
      } else {
        _searchResults = _products
            .where(
              (item) =>
                  item['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  item['category'].toString().toLowerCase().contains(
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
        _searchResults = List.from(_products);
      } else {
        String selectedCategory = _categories[index]['name'] as String;
        _searchResults = _products
            .where((item) => item['category'] == selectedCategory)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika tab controller belum siap
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
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product['image'] as String,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          // Detail Produk
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  product['price'] as String,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      product['rating'].toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Terjual ${product['sold']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
}
