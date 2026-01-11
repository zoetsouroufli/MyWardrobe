import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/gradient_background.dart';
import '../widgets/fade_page_route.dart';
import 'edit_profile.dart';
import 'one_outfit.dart';
import '../utils/preview_styles.dart';
import 'home_screen.dart';
import 'stats.dart';
import 'clothing_categories.dart';
import 'edit_outfit.dart'; // Added this import

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
            FadePageRoute(page: screen),
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

                // ===== EDIT PROFILE BUTTON =====
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFDBDBDB),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 28,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                            letterSpacing: 0.1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w400,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Following counter
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseAuth.instance.currentUser != null
                                        ? FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth.instance.currentUser!.uid)
                                              .collection('friends')
                                              .snapshots()
                                        : const Stream.empty(),
                                    builder: (context, snapshot) {
                                      final friendCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                                      return Column(
                                        children: [
                                          Text(
                                            '$friendCount',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Following',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
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
                        final items = outfit['items'] is List
                            ? List<String>.from(outfit['items'])
                            : <String>[];
                        final previewStyle = outfit['previewStyle'] as Map<String, dynamic>?;

                        return _OutfitCard(
                          color: Color(colorValue),
                          title: outfit['title'] ?? 'Outfit',
                          subtitle: outfit['subtitle'] ?? '',
                          likes: outfit['likes'] ?? 0,
                          items: items,
                          previewStyle: previewStyle,
                          outfitId: doc.id,
                          outfitData: outfit,
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

class _OutfitCard extends StatefulWidget {
  final Color color;
  final String title;
  final String subtitle;
  final int likes;
  final List<String> items;
  final Map<String, dynamic>? previewStyle;
  final String outfitId;
  final Map<String, dynamic> outfitData;
  final VoidCallback? onTap;

  const _OutfitCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.likes,
    required this.items,
    required this.outfitId,
    required this.outfitData,
    this.previewStyle,
    this.onTap,
  });

  @override
  State<_OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<_OutfitCard> {
  bool _isHovered = false;

  Color get _themeColor {
    // Get color from gradient if present
    if (widget.previewStyle != null) {
      final type = widget.previewStyle!['type'] as String?;
      final value = widget.previewStyle!['value'] as String?;
      
      if (type == 'gradient' && value != null) {
        final gradient = PreviewStyles.getGradient(value);
        if (gradient != null && gradient.colors.isNotEmpty) {
          return gradient.colors.first; // Use first color from gradient
        }
      }
    }
    // Fallback to solid color
    return widget.color;
  }

  Widget _buildThumbnailGrid() {
    Widget backgroundWidget;
    
    // Check if there's a preview style
    if (widget.previewStyle != null) {
      final type = widget.previewStyle!['type'] as String?;
      final value = widget.previewStyle!['value'] as String?;

      if (type == 'gradient' && value != null) {
        final gradient = PreviewStyles.getGradient(value);
        if (gradient != null) {
          backgroundWidget = Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        } else {
          // Fallback
          backgroundWidget = Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }
      } else {
        // Solid color
        backgroundWidget = Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }

      // Check for pattern overlay
      final pattern = widget.previewStyle!['pattern'] as String?;
      if (pattern != null && pattern.isNotEmpty) {
        return Stack(
          children: [
            backgroundWidget,
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PreviewStyles.buildPattern(pattern, size: 90, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        );
      }
      
      return backgroundWidget;
    }

    // Fallback to colored block without icon
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF9C27B0).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isHovered ? 0.2 : 0.15),
                blurRadius: _isHovered ? 24 : 20,
                offset: Offset(0, _isHovered ? 10 : 8),
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
              // Left Thumbnail Grid
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildThumbnailGrid(),
              ),

              // Middle Text & Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // View and Edit Buttons
                      Row(
                        children: [
                          // View Button
                          GestureDetector(
                            onTap: () {
                              if (widget.onTap != null) {
                                widget.onTap!();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _themeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _themeColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _themeColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditOutfitScreen(
                                    outfitId: widget.outfitId,
                                    outfitData: widget.outfitData,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Likes Section
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _themeColor,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.likes}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
