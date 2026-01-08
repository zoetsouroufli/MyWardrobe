import 'package:flutter/material.dart';
import '../widgets/back_button.dart';

class FriendProfileOutfit extends StatelessWidget {
  const FriendProfileOutfit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header with back button and logo
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BackButtonCircle(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Image.asset(
                    'assets/MyWardrobe.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Outfit Items Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
                  children: [
                    _buildClothingItem('assets/jeans.png.avif'),
                    _buildClothingItem('assets/tshirt.png.jpg'),
                    _buildClothingItem('assets/outfit_sneakers.jpg'),
                    _buildClothingItem('assets/sweater2.png.jpg'),
                    _buildClothingItem('assets/outfit_jacket.jpg'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItem(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.checkroom, size: 40, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}
