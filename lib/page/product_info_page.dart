import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';

class ProductInfoPage extends StatelessWidget {
  const ProductInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios),
        actions: const [
          Icon(Icons.share),
          SizedBox(width: 10),
          Icon(Icons.more_vert),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Image.network(
            'https://www.static-src.com/wcsstore/Indraprastha/images/catalog/full//96/MTA-14534461/polytron_polytron_pemanggang_oven_30_ltr_pvg_3003_-_hitam-_full01_d1h08zxk.jpg',
            height: 200,
            fit: BoxFit.contain,
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sewa oven merek polytron harian/mingguan\nCocok untuk pemula & UMKM | Siap pakai langsung!',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Rp. 100.000',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Icon(Icons.star_border, color: Colors.orange, size: 20),
                    Icon(Icons.star_border, color: Colors.orange, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: const CustomNavBar(),
    );
  }
}
