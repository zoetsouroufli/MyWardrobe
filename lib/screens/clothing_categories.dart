import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/add_new_item.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';
import 'stats.dart';
import 'my_outfits.dart';

class ClothingCategoriesScreen extends StatelessWidget {
  const ClothingCategoriesScreen({super.key});

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

              TextButton(
                onPressed: () async {
                  try {
                    await FirestoreService().seedSampleData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sample data loaded!')),
                      );
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text(
                  'Load Sample Data',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

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
                  List<String> getImagesFor(String category) {
                    return docs
                        .where(
                          (doc) =>
                              (doc.data()
                                  as Map<String, dynamic>)['category'] ==
                              category,
                        )
                        .map(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['imageUrl']
                                  as String,
                        )
                        .toList();
                  }

                  return Column(
                    children: [
                      CategoryDropdownTile(
                        title: 'Pants',
                        images: getImagesFor('Pants'),
                      ),
                      CategoryDropdownTile(
                        title: 'T-Shirts',
                        images: getImagesFor('T-Shirts'),
                      ),
                      CategoryDropdownTile(
                        title: 'Hoodies',
                        images: getImagesFor('Hoodies'),
                      ),
                      CategoryDropdownTile(
                        title: 'Jackets',
                        images: getImagesFor('Jackets'),
                      ),
                      CategoryDropdownTile(
                        title: 'Socks',
                        images: getImagesFor('Socks'),
                      ),
                      CategoryDropdownTile(
                        title: 'Shoes',
                        images: getImagesFor('Shoes'),
                      ),
                      CategoryDropdownTile(
                        title: 'Accessories',
                        images: getImagesFor('Accessories'),
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
