import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/outfit_item.dart';

class SelectedCategoryScreen extends StatelessWidget {
  final String categoryTitle;

  const SelectedCategoryScreen({
    super.key,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ===== TITLE =====
            Text(
              categoryTitle.toLowerCase(),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // ===== CARD =====
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // ===== HEADER =====
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: BackButtonCircle(),
                        ),
                        Image.asset(
                          'assets/MyWardrobe.png',
                          height: 48,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== GRID =====
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        OutfitItem('assets/pants1.png'),
                        OutfitItem('assets/pants2.png'),
                        OutfitItem('assets/pants3.png'),
                        OutfitItem('assets/pants4.png'),
                        OutfitItem('assets/pants5.png'),
                        OutfitItem('assets/pants6.png'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
