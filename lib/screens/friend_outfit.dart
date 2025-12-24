import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/outfit_item.dart';

class FriendProfileOutfit extends StatelessWidget {
  const FriendProfileOutfit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ===== TITLE =====
            const Text(
              'friend outfit',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // ===== CARD =====
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // ===== HEADER (back + logo) =====
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BackButtonCircle(
                          onPressed: () {}, // preview-safe
                        ),
                      ),
                      Image.asset(
                        'assets/MyWardrobe.png',
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== OUTFIT GRID =====
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: const [
                      OutfitItem('assets/shorts.png'),
                      OutfitItem('assets/sweater.png'),
                      OutfitItem('assets/jacket.png'),
                      OutfitItem('assets/socks.png'),
                      OutfitItem('assets/shoes.png'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
