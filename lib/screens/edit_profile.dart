import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
              'edit profile',
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== FORM =====
                    const EditProfileForm(),
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
