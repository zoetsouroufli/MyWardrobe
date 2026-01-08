import 'package:flutter/material.dart';
import '../widgets/outfit_view.dart';

class FriendOutfitScreen extends StatelessWidget {
  const FriendOutfitScreen({super.key});

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
                child: const OutfitView(
                  isOwner: false,        // ❌ όχι δικό μου
                  showAddSection: false, // ❌ όχι Add
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
