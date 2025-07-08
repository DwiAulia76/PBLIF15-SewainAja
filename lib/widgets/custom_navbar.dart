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
          onTap: onTap, // Pastikan ini terhubung dengan benar
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          iconSize: 26,
          items: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(1, Icons.history_outlined, Icons.history, 'History'),
            _buildNavItem(
              2,
              Icons.shopping_cart_outlined,
              Icons.shopping_cart,
              'Cart',
            ),
            _buildNavItem(
              3,
              Icons.person_outlined,
              Icons.person,
              'Profile',
            ), // Indeks 3 untuk profil
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
    final isSelected = currentIndex == index;

    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.blue[700] : Colors.grey[400],
        ),
      ),
      label: label,
    );
  }
}
