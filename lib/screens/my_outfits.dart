import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/outfit_list_card.dart';
import '../widgets/edit_profile_button.dart';

class MyOutfitsScreen extends StatelessWidget {
  const MyOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      bottomNavigationBar: const BottomNav(selectedIndex: 2), // ❤️ tab
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ===== TITLE =====
            const Text(
              'my outfits',
              style: TextStyle(fontSize: 18, color: Colors.grey),
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
                    // ===== LOGO =====
                    Image.asset(
                      'assets/MyWardrobe.png',
                      height: 48,
                    ),

                    const SizedBox(height: 12),

                    // ===== EDIT PROFILE =====
                    const EditProfileButton(),

                    const SizedBox(height: 16),

                    // ===== SECTION TITLE =====
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Η ΖΩΗ ΚΑΙ ΤΑ OUTFITS ΤΗΣ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ===== LIST =====
                    Expanded(
                      child: ListView(
                        children: const [
                          OutfitListCard(
                            color: Colors.purple,
                            title: 'outfit to go for coffee',
                            subtitle: 'casual with jeans and a small leather bag',
                            likes: 14,
                          ),
                          OutfitListCard(
                            color: Colors.orange,
                            title: 'outfit to go for coffee',
                            subtitle: 'simple with black pants',
                            likes: 12,
                          ),
                          OutfitListCard(
                            color: Colors.indigo,
                            title: 'monday morning fit',
                            subtitle: 'comfort before coffee',
                            likes: 10,
                          ),
                        ],
                      ),
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
