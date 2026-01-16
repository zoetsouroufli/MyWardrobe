import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/gradient_background.dart';
import '../widgets/fade_page_route.dart';
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
            Image.asset(
              'assets/MyWardrobe.png',
              width: 180,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

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
                Navigator.pushReplacement(context, FadePageRoute(page: screen));
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
                const Text(
                  'Type a username above to find friends.',
                  style: TextStyle(color: Colors.grey),
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
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final username = data['username'] ?? '';
              final imagePath =
                  data['avatarUrl'] ?? 'assets/friend1.jpg'; // fallback

              return _buildFriendAvatar(
                context,
                doc.id,
                imagePath,
                name,
                username,
              );
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
        final filteredDocs = docs
            .where((doc) => doc.id != FirebaseAuth.instance.currentUser?.uid)
            .toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No user found with that username.'));
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
              final imagePath =
                  'assets/friend1.jpg'; // Default for now query doesn't guarantee avatar

              return _buildFriendAvatar(
                context,
                doc.id,
                imagePath,
                username,
                username,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendAvatar(
    BuildContext context,
    String friendDocId,
    String imagePath,
    String name,
    String username,
  ) {
    return _FriendAvatarWidget(
      friendDocId: friendDocId,
      imagePath: imagePath,
      name: name,
      username: username,
    );
  }
}

// Separate StatefulWidget for friend avatar with hover effect
class _FriendAvatarWidget extends StatefulWidget {
  final String friendDocId;
  final String imagePath;
  final String name;
  final String username;

  const _FriendAvatarWidget({
    required this.friendDocId,
    required this.imagePath,
    required this.name,
    required this.username,
  });

  @override
  State<_FriendAvatarWidget> createState() => _FriendAvatarWidgetState();
}

class _FriendAvatarWidgetState extends State<_FriendAvatarWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendProfileScreen(
                friendDocId: widget.friendDocId,
                friendName: widget.name,
                friendUsername: widget.username,
                friendPhoto: widget.imagePath,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -4.0 : 0.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF9C27B0)
                  : Colors.grey.shade300,
              width: _isHovered ? 3 : 2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ClipOval(
            child: widget.imagePath.startsWith('http')
                ? Image.network(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  )
                : Image.asset(
                    widget.imagePath,
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
      ),
    );
  }
}
