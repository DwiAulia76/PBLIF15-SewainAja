import 'package:flutter/material.dart';
import '../widgets/product_item.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'searching',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('search', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),

            // Category: Stroller Baby
            _buildCategory('stroller baby', ['baby toys', 'baby toys', 'baby toys', 'baby toys', 'baby toys', 'baby toys']),
            
            // Category: Cooking Ware
            _buildCategory('cooking ware', ['pan', 'pan', 'pan', 'pan']),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<String> products) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: products.map((p) => ProductItem(name: p)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
