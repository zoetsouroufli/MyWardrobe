import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/add_new_item.dart';
// import '../services/firestore_service.dart'; // Unused

import '../services/wardrobe_manager.dart'; // Added import for WardrobeManager
import 'home_screen.dart';
import 'stats.dart';
import 'my_outfits.dart';

class ClothingCategoriesScreen extends StatefulWidget {
  const ClothingCategoriesScreen({super.key});

  @override
  State<ClothingCategoriesScreen> createState() =>
      _ClothingCategoriesScreenState();
}

class _ClothingCategoriesScreenState extends State<ClothingCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    _initWardrobe();
  }

  Future<void> _initWardrobe() async {
    await WardrobeManager().init();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar removed to eliminate gap
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

              // Debug buttons removed
              const SizedBox(height: 30),

              // ===== STREAM BUILDER FOR CATEGORIES =====
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseAuth.instance.currentUser != null
                    ? FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('wardrobe')
                          .orderBy('dateAdded', descending: true)
                          .snapshots()
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Show empty tiles if no data
                    return Column(
                      children: const [
                        CategoryDropdownTile(title: 'Pants'),
                        CategoryDropdownTile(title: 'T-Shirts'),
                        CategoryDropdownTile(title: 'Hoodies'),
                        CategoryDropdownTile(title: 'Jackets'),
                        CategoryDropdownTile(title: 'Socks'),
                        CategoryDropdownTile(title: 'Shoes'),
                        CategoryDropdownTile(title: 'Accessories'),
                      ],
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // Helper function to filter by category
                  List<Map<String, dynamic>> getItemsFor(String category) {
                    final remote = docs
                        .where(
                          (doc) =>
                              (doc.data()
                                  as Map<String, dynamic>)['category'] ==
                              category,
                        )
                        .map(
                          (doc) => {
                            'imageUrl':
                                (doc.data()
                                    as Map<String, dynamic>)['imageUrl'],
                            'id': doc.id,
                            'data': doc.data(),
                          },
                        )
                        .toList();

                    return remote;
                  }

                  return Column(
                    children: [
                      CategoryDropdownTile(
                        title: 'Pants',
                        items: getItemsFor('Pants'),
                      ),
                      CategoryDropdownTile(
                        title: 'T-Shirts',
                        items: getItemsFor('T-Shirts'),
                      ),
                      CategoryDropdownTile(
                        title: 'Hoodies',
                        items: getItemsFor('Hoodies'),
                      ),
                      CategoryDropdownTile(
                        title: 'Jackets',
                        items: getItemsFor('Jackets'),
                      ),
                      CategoryDropdownTile(
                        title: 'Socks',
                        items: getItemsFor('Socks'),
                      ),
                      CategoryDropdownTile(
                        title: 'Shoes',
                        items: getItemsFor('Shoes'),
                      ),
                      CategoryDropdownTile(
                        title: 'Accessories',
                        items: getItemsFor('Accessories'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
