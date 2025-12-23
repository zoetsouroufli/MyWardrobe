import 'package:flutter/material.dart';
import '../widgets/friends_avatar.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = [
      'assets/f1.jpg',
      'assets/f2.jpg',
      'assets/f3.jpg',
      'assets/f4.jpg',
      'assets/f5.jpg',
      'assets/f6.jpg',
      'assets/f7.jpg',
      'assets/f8.jpg',
      'assets/f9.jpg',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo
            Center(
  child: Image.asset(
    'assets/MyWardrobe.png',
    height: 60,
  ),
),

            const SizedBox(height: 30),

            // Friends bubbles
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return FriendAvatar(imagePath: friends[index]);
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: const BottomNav(selectedIndex: 0),
    );
  }
}
