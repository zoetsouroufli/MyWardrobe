import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/add_new_item.dart';

class ClothingCategoriesScreen extends StatelessWidget {
  const ClothingCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      bottomNavigationBar: const BottomNav(selectedIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ===== TITLE =====
            const Text(
              'clothing categories',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // ===== CARD =====
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Logo
                    Image.asset(
                      'assets/MyWardrobe.png',
                      height: 48,
                    ),

                    const SizedBox(height: 20),

                    // Add new item
                    const AddNewItemButton(),

                    const SizedBox(height: 20),

                    // Categories
                    const CategoryDropdownTile(title: 'Pants'),
                    const CategoryDropdownTile(title: 'T-Shirts'),
                    const CategoryDropdownTile(title: 'Hoodies'),
                    const CategoryDropdownTile(title: 'Jackets'),
                    const CategoryDropdownTile(title: 'Socks'),
                    const CategoryDropdownTile(title: 'Shoes'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
