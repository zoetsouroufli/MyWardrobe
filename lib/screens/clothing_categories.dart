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

              // Debug buttons removed (Accepted Remote Change)
              const SizedBox(height: 30),

              // ===== STREAM BUILDER FOR CATEGORIES =====
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseAuth.instance.currentUser != null
                    ? FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('wardrobe')
                          // Removed orderBy to ensure docs without dateAdded are included (Legacy Data Fix)
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
                  
                  // Sort client-side to handle missing dateAdded fields
                  docs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    
                    final dateA = (dataA['dateAdded'] as Timestamp?)?.toDate();
                    final dateB = (dataB['dateAdded'] as Timestamp?)?.toDate();
                    
                    if (dateA == null && dateB == null) return 0;
                    if (dateA == null) return 1; // Null at bottom
                    if (dateB == null) return -1;
                    
                    return dateB.compareTo(dateA); // Descending
                  });

                  // Group items by category dynamically
                  final Map<String, List<Map<String, dynamic>>> groupedItems = {};
                  
                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    String category = (data['category'] ?? 'Other').toString().trim();
                    if (category.isEmpty) category = 'Other';
                    
                    // Normalize standard categories to Title Case if needed, 
                    // or just keep as is. For better UX, let's Capitalize start.
                    if (category.length > 1) {
                      category = category[0].toUpperCase() + category.substring(1);
                    } else {
                      category = category.toUpperCase();
                    }

                    if (!groupedItems.containsKey(category)) {
                      groupedItems[category] = [];
                    }
                    
                    groupedItems[category]!.add({
                      'imageUrl': data['imageUrl'],
                      'id': doc.id,
                      'data': data,
                    });
                  }

                  // Define standard order
                  final standardOrder = [
                    'Pants', 'T-Shirts', 'Hoodies', 'Jackets', 
                    'Socks', 'Shoes', 'Accessories'
                  ];
                  
                  // Sort categories: Standard ones first, then alphabetical others
                  final sortedKeys = groupedItems.keys.toList()..sort((a, b) {
                     final indexA = standardOrder.indexOf(a); // Loose matching?
                     final indexB = standardOrder.indexOf(b);
                     
                     if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
                     if (indexA != -1) return -1;
                     if (indexB != -1) return 1;
                     return a.compareTo(b);
                  });

                  return Column(
                    children: sortedKeys.map((category) {
                      return CategoryDropdownTile(
                        title: category,
                        items: groupedItems[category]!,
                      );
                    }).toList(),
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
