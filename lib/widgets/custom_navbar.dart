import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true, // Menampilkan label untuk yang aktif
          showUnselectedLabels: false, // Hanya label aktif yang ditampilkan
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          // Menambahkan tinggi minimum
          iconSize: 26,
          // Menghilangkan efek hover dan animasi
          enableFeedback: false,
          mouseCursor: SystemMouseCursors.basic,
          items: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(1, Icons.search_outlined, Icons.search, 'Search'),
            _buildNavItem(
              2,
              Icons.shopping_cart_outlined,
              Icons.shopping_cart,
              'Cart',
            ),
            _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}
