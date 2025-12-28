import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/outfit_checkbox_row.dart';

class AddToOutfitScreen extends StatelessWidget {
  final String imagePath;

  const AddToOutfitScreen({
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

            // ===== TITLE =====
            const Text(
              'add to outfit',
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
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== OUTFITS LIST =====
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: const [
                            SizedBox(height: 8),

                            OutfitCheckboxRow(title: 'Θα γίνει χαμός'),
                            OutfitCheckboxRow(title: 'Κολωνάκι'),
                            OutfitCheckboxRow(title: 'Δεν είμαι φασαία'),
                            OutfitCheckboxRow(title: 'Σχολή'),
                            OutfitCheckboxRow(title: 'Όλα ήταν στα απλά'),

                            Spacer(),

                            // ===== ENTER BUTTON =====
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(
                                    Colors.deepPurpleAccent,
                                  ),
                                  padding: MaterialStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                                child: Text(
                                  'Enter',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
