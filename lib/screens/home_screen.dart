import 'package:flutter/material.dart';
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildFriendAvatar('assets/friend1.jpg', 'Friend 1'),
                    _buildFriendAvatar('assets/friend2.jpg', 'Friend 2'),
                    _buildFriendAvatar('assets/friend3.jpg', 'Friend 3'),
                    _buildFriendAvatar('assets/friend4.jpg', 'Friend 4'),
                    _buildFriendAvatar('assets/friend5.jpg', 'Friend 5'),
                    _buildFriendAvatar('assets/friend6.jpg', 'Friend 6'),
                    _buildFriendAvatar('assets/friend7.jpg', 'Friend 7'),
                    _buildFriendAvatar('assets/friend8.jpg', 'Friend 8'),
                    _buildFriendAvatar('assets/friend9.jpg', 'Friend 9'),
                    _buildFriendAvatar('assets/friend10.jpg', 'Friend 10'),
                    _buildFriendAvatar('assets/friend11.jpg', 'Friend 11'),
                    _buildFriendAvatar('assets/friend12.jpg', 'Friend 12'),
                    _buildFriendAvatar('assets/friend13.jpg', 'Friend 13'),
                    _buildFriendAvatar('assets/friend14.jpg', 'Friend 14'),
                    _buildFriendAvatar('assets/friend15.jpg', 'Friend 15'),
                    _buildFriendAvatar('assets/friend16.jpg', 'Friend 16'),
                  ],
                ),
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

  Widget _buildFriendAvatar(String imagePath, String name) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            print('Tapped on $name');

            // Navigate to Friend Profile for friend4 (babis heotis)
            if (imagePath == 'assets/friend4.jpg') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendProfileScreen(
                    friendName: 'babis heotis',
                    friendUsername: 'fashion-icon',
                    friendPhoto: 'assets/friend4.jpg',
                  ),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
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
      },
    );
  }
}
