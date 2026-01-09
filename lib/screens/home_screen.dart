import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/bottom_nav.dart';
import 'friend_profile.dart';
import 'my_outfits.dart';
import 'stats.dart';
import 'clothing_categories.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // MyWardrobe Logo
            GestureDetector(
                onLongPress: () async {
                    // Secret way to seed data
                    await FirestoreService().seedDummyUser();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dummy User Added! Search for "testuser"')));
                },
                child: Image.asset(
                  'assets/MyWardrobe.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search username...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Friend Avatars Grid OR Search Results
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildFriendsList()
                  : _buildSearchResults(),
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

  Widget _buildFriendsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('friends')
          .orderBy('friendId', descending: false)
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
                const Text('Type a username above to find friends.', style: TextStyle(color: Colors.grey)),
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
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: _searchQuery)
          .where('username', isLessThan: '$_searchQuery\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
           print(snapshot.error);
          return const Center(child: Text('Error searching users.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        // Filter out self
        final filteredDocs = docs.where((doc) => doc.id != FirebaseAuth.instance.currentUser?.uid).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No user found with that username.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await FirestoreService().seedDummyUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Created "testuser"! Try searching again.')),
                    );
                    // Force rebuild/re-search if needed, but stream should handle it
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create "testuser"'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            itemCount: filteredDocs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final username = data['username'] ?? 'Unknown';
              // Use a placeholder if no avatar, or check if they have one
              // For search results, we usually just show username if we don't have avatars
              final imagePath = 'assets/friend1.jpg'; // Default for now query doesn't guarantee avatar

              return _buildFriendAvatar(context, doc.id, imagePath, username, username);
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendAvatar(BuildContext context, String friendDocId, String imagePath, String name, String username) {
    return GestureDetector(
      onTap: () {
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
