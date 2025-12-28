import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/clothing_image_card.dart';
import '../widgets/clothing_property_row.dart';
import '../widgets/add_actions_bar.dart';

class SelectedClothingItemScreen extends StatelessWidget {
  final String imagePath;

  const SelectedClothingItemScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            const Text(
              'selected piece of clothing',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 16),

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

                    // ===== IMAGE =====
                    ClothingImageCard(imagePath: imagePath),

                    const SizedBox(height: 24),

                    // ===== PROPERTIES =====
                    const ClothingPropertyRow(
                      label: 'Colour',
                      value: 'olive-green',
                      secondaryValue: 'pink',
                      isColor: true,
                    ),
                    const ClothingPropertyRow(
                      label: 'Size',
                      value: 'S',
                    ),
                    const ClothingPropertyRow(
                      label: 'Brand',
                      value: 'Zara',
                    ),
                    const ClothingPropertyRow(
                      label: 'Number of times worn',
                      value: '2',
                      hasCounter: true,
                    ),

                    const Spacer(),

                    // ===== ACTIONS =====
                    const AddActionsBar(),
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
