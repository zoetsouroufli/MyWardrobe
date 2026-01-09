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
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  Future<void> _loadWardrobe() async {
    await WardrobeManager().init();
    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  List<String> _getCategoryItems(
    String category, {
    List<String> defaults = const [],
  }) {
    if (!_isLoaded) return defaults;
    final userItems = WardrobeManager().getItemsByCategory(category);
    return [...defaults, ...userItems];
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

              // ===== CATEGORIES =====
              CategoryDropdownTile(
                title: 'Pants',
                images: _getCategoryItems(
                  'Pants',
                  defaults: [
                    'assets/pants-1.jpg',
                    'assets/pants-2.jpg',
                    'assets/pants-3.jpg',
                    'assets/pants-4.jpg',
                    'assets/pants-5.jpg',
                    'assets/pants-6.jpg',
                  ],
                ),
              ),
              CategoryDropdownTile(
                title: 'T-Shirts',
                images: _getCategoryItems('T-Shirts'),
              ),
              CategoryDropdownTile(
                title: 'Hoodies',
                images: _getCategoryItems('Hoodies'),
              ),
              CategoryDropdownTile(
                title: 'Jackets',
                images: _getCategoryItems('Jackets'),
              ),
              CategoryDropdownTile(
                title: 'Socks',
                images: _getCategoryItems('Socks'),
              ),
              CategoryDropdownTile(
                title: 'Shoes',
                images: _getCategoryItems('Shoes'),
              ),
              CategoryDropdownTile(
                title: 'Accessories',
                images: _getCategoryItems('Accessories'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
