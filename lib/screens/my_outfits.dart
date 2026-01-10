import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/smooth_page_route.dart';
import 'edit_profile.dart';
import 'one_outfit.dart';
import 'home_screen.dart';
import 'stats.dart';
import 'clothing_categories.dart';

class MyOutfitsScreen extends StatefulWidget {
  const MyOutfitsScreen({super.key});

  @override
  State<MyOutfitsScreen> createState() => _MyOutfitsScreenState();
}

class _MyOutfitsScreenState extends State<MyOutfitsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNav(
        selectedIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          Widget screen;
          switch (index) {
            case 0:
              screen = const HomeScreen();
              break;
            case 1:
              screen = const StatsScreen();
              break;
            case 3:
              screen = const ClothingCategoriesScreen();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
            context,
            SmoothPageRoute(page: screen),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ===== LOGO =====
                Image.asset(
                  'assets/MyWardrobe.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 30),

                // ===== EDIT PROFILE BUTTONS =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Edit Profile Text Button
                    GestureDetector(
                      onTap: () {
                        print('Edit profile tapped');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF3E5F5,
                          ), // More visible purple-grey
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black, // Explicit BLACK
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Arrow Button
                    GestureDetector(
                      onTap: () {
                        print('Profile options tapped');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF3E5F5,
                          ), // More visible purple-grey
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 24,
                          color: Colors.black, // Explicit BLACK
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== SECTION TITLE & SUBTITLE =====
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseAuth.instance.currentUser != null
                      ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots()
                      : const Stream.empty(),
                  builder: (context, snapshot) {
                    String username = 'My Username';
                    String description = 'My description';
                    String? avatarUrl;

                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      if (data.containsKey('username') &&
                          data['username'].toString().isNotEmpty) {
                        username = data['username'];
                      }
                      if (data.containsKey('description') &&
                          data['description'].toString().isNotEmpty) {
                        description = data['description'];
                      }
                      avatarUrl = data['avatarUrl'];
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          40,
                        ), // Slightly smaller radius
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24, // Smaller avatar 24
                            backgroundColor: Colors.grey[200],
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 24,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12), // Tighter gap
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 16, // Smaller font
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 13, // Smaller font
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ===== OUTFIT LIST STREAM =====
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseAuth.instance.currentUser != null
                      ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('outfits')
                            .orderBy('dateAdded', descending: true)
                            .snapshots()
                      : const Stream.empty(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            const Text('No outfits yet!'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await FirestoreService().seedMyOutfits();
                              },
                              child: const Text('Load Sample Outfits'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final outfit = doc.data() as Map<String, dynamic>;
                        final colorValue =
                            outfit['color'] as int? ?? 0xFFCCCCCC;

                        return _OutfitCard(
                          color: Color(colorValue),
                          title: outfit['title'] ?? 'Outfit',
                          subtitle: outfit['subtitle'] ?? '',
                          likes: outfit['likes'] ?? 0,
                          onTap: () async {
                            // Navigate to OneOutfitScreen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OneOutfitScreen(
                                  outfitData: outfit,
                                  outfitId: doc.id,
                                ),
                              ),
                            );

                            // Check if deleted
                            if (result == 'deleted') {
                              // Delete from firestore
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('outfits')
                                  .doc(doc.id)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Outfit deleted')),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final int likes;
  final VoidCallback? onTap;

  const _OutfitCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.likes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9C27B0).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Colored Block
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(12),
            color: color,
          ),

          // Middle Text & Button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Open Button
                  GestureDetector(
                    onTap: () {
                      if (onTap != null) {
                        onTap!();
                      } else {
                        print('Open outfit: $title');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'open',
                        style: TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Likes
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, size: 20, color: Colors.black),
                const SizedBox(height: 2),
                Text(
                  '$likes',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
