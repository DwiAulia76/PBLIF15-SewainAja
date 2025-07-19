import 'package:flutter/material.dart';
import 'package:sewainaja/home/home.dart';
import 'package:sewainaja/history/history_screen.dart';
import 'package:sewainaja/widgets/custom_navbar.dart';
import 'package:sewainaja/profil/profil.dart';
import 'package:sewainaja/notification/notification_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const HistoryScreen(),
    const LoanCalendarPage(),
    const ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
