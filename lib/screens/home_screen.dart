import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/bottom_nav.dart';
import 'friend_profile.dart';
import 'my_outfits.dart';
import 'stats.dart';
import 'clothing_categories.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // MyWardrobe Logo
            Image.asset(
              'assets/MyWardrobe.png',
              width: 180,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 40),

            // Friend Avatars Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('friends')
                    .orderBy('friendId', descending: false) // Sort by ID to keep order roughly 1-16
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No friends yet!'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await FirestoreService().seedFriends();
                            },
                            child: const Text('Load Friends'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      itemCount: docs.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['name'] ?? 'Unknown';
                        final username = data['username'] ?? '';
                        final imagePath = data['avatarUrl'] ?? 'assets/friend1.jpg'; // fallback

                        return _buildFriendAvatar(context, doc.id, imagePath, name, username);
                      },
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation
            BottomNav(
              selectedIndex: 0,
              onTap: (index) {
                if (index == 0) return;
                Widget screen;
                switch (index) {
                  case 1:
                    screen = const StatsScreen();
                    break;
                  case 2:
                    screen = const MyOutfitsScreen();
                    break;
                  case 3:
                    screen = const ClothingCategoriesScreen();
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
          ],
        ),
      ),
    );
  }

  Widget _buildFriendAvatar(BuildContext context, String friendDocId, String imagePath, String name, String username) {
    return GestureDetector(
      onTap: () {
        print('Tapped on $name');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendProfileScreen(
              friendDocId: friendDocId,
              friendName: name,
              friendUsername: username,
              friendPhoto: imagePath,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: ClipOval(
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
