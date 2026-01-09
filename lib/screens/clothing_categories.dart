import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/add_new_item.dart';
import 'home_screen.dart';
import 'stats.dart';
import 'my_outfits.dart';
import '../services/wardrobe_manager.dart';

class ClothingCategoriesScreen extends StatefulWidget {
  const ClothingCategoriesScreen({super.key});

  @override
  State<ClothingCategoriesScreen> createState() =>
      _ClothingCategoriesScreenState();
}

class _ClothingCategoriesScreenState extends State<ClothingCategoriesScreen> {
  List<String> _userItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserItems();
  }

  Future<void> _loadUserItems() async {
    await WardrobeManager().init();
    if (mounted) {
      setState(() {
        _userItems = WardrobeManager().getItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNav(
        selectedIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          Widget screen;
          switch (index) {
            case 0:
              screen = const HomeScreen();
              break;
            case 1:
              screen = const StatsScreen();
              break;
            case 2:
              screen = const MyOutfitsScreen();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => screen,
              transitionDuration: Duration.zero,
            ),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ===== LOGO =====
              Image.asset(
                'assets/MyWardrobe.png',
                width: 180,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              // ===== ADD NEW ITEM BUTTON =====
              const AddNewItemButton(),

              const SizedBox(height: 30),

              // ===== USER UPLOADS =====
              if (_userItems.isNotEmpty)
                CategoryDropdownTile(title: 'My Uploads', images: _userItems),

              // ===== CATEGORIES =====
              const CategoryDropdownTile(
                title: 'Pants',
                images: [
                  'assets/pants-1.jpg',
                  'assets/pants-2.jpg',
                  'assets/pants-3.jpg',
                  'assets/pants-4.jpg',
                  'assets/pants-5.jpg',
                  'assets/pants-6.jpg',
                ],
              ),
              const CategoryDropdownTile(title: 'T-Shirts'),
              const CategoryDropdownTile(title: 'Hoodies'),
              const CategoryDropdownTile(title: 'Jackets'),
              const CategoryDropdownTile(title: 'Socks'),
              const CategoryDropdownTile(title: 'Shoes'),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
