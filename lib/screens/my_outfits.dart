import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'edit_profile.dart';
import 'one_outfit.dart';
import 'home_screen.dart';
import 'stats.dart';
import 'clothing_categories.dart';

// Global variable to share outfits data across screens
List<Map<String, dynamic>> globalOutfits = [
  {
    'color': const Color(0xFFD01FE8),
    'title': 'outfit to go for coffee',
    'subtitle': 'maybe with red socks it would work better',
    'likes': 14,
    'items': [],
  },
  {
    'color': const Color(0xFFFF9800),
    'title': 'outfit to go to latraac',
    'subtitle': 'its May and the weather is nice',
    'likes': 12,
    'isLink': true,
    'items': [],
  },
  {
    'color': const Color(0xFF1A1A80),
    'title': 'monday morning fit',
    'subtitle': 'coolcoolcoolcoolcool',
    'likes': 10,
    'items': [],
  },
];

class MyOutfitsScreen extends StatefulWidget {
  const MyOutfitsScreen({super.key});

  @override
  State<MyOutfitsScreen> createState() => _MyOutfitsScreenState();
}

class _MyOutfitsScreenState extends State<MyOutfitsScreen> {
  // Use globalOutfits instead of local list

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
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => screen,
              transitionDuration: Duration.zero,
            ),
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

                const SizedBox(height: 40),

                // ===== SECTION TITLE & SUBTITLE =====
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'H ZOI KAI TA OUTFITS TIS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900, // Extra Bold
                          color: Colors.black, // Explicit BLACK
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'letsgooooo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ===== OUTFIT LIST =====
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: globalOutfits.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final outfit = globalOutfits[index];

                    return _OutfitCard(
                      color: outfit['color'],
                      title: outfit['title'],
                      subtitle: outfit['subtitle'],
                      likes: outfit['likes'],
                      onTap: () async {
                        if (outfit.containsKey('isLink') &&
                            outfit['isLink'] == true) {
                          // Navigate to OneOutfitScreen and wait for result
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OneOutfitScreen(outfitIndex: index),
                            ),
                          );

                          // Check if deleted
                          if (result == 'deleted') {
                            setState(() {
                              globalOutfits.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Outfit deleted')),
                            );
                          }
                        } else {
                          print('Open outfit: ${outfit['title']}');
                        }
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF9C27B0),
          width: 1.5,
        ), // Purple border
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
