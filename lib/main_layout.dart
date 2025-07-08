import 'package:flutter/material.dart';
import 'package:sewainaja/home/home.dart';
import 'package:sewainaja/history/history_screen.dart';
import 'package:sewainaja/widgets/custom_navbar.dart';
import 'package:sewainaja/profil/profil.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(), // Index 0
    const HistoryScreen(), // Index 1
    const CartPage(), // Index 2
    const ProfileScreen(), // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // HAPUS Scaffold di ProfileScreen jika ada
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Cart Page'));
  }
}
