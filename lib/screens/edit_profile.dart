import 'package:flutter/material.dart';
import '../widgets/back_button.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  // Delete button removed
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ===== FORM CARD =====
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: const Color(0xFFD01FE8),
                    width: 1.5,
                  ), // Purple border
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD01FE8), // Purple handle
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // New Username
                          const Text(
                            'new username',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            autofocus: true, // Show keyboard immediately
                            keyboardType: TextInputType
                                .visiblePassword, // No suggestions strip
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // New Description
                          const Text(
                            'new description',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType
                                .visiblePassword, // No suggestions strip
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Ready Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Return to My Outfits
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF8B00FF,
                                ), // Strong Purple
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Ready',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
