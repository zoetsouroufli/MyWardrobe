import 'package:flutter/material.dart';
import '../widgets/back_button.dart';

class OneOutfitScreen extends StatefulWidget {
  const OneOutfitScreen({super.key});

  @override
  State<OneOutfitScreen> createState() => _OneOutfitScreenState();
}

class _OneOutfitScreenState extends State<OneOutfitScreen> {
  // Initial current items
  final List<String> currentItems = [
    'assets/zoe-shorts.png',
    'assets/zoe-stripespullover.png',
    'assets/zoe-jeanjacket.png',
    'assets/zoe-socks.png',
    'assets/zoe-ballerinas.png',
  ];

  // Initial suggested items
  final List<String> suggestedItems = [
    'assets/zoe-vshirt.png',
    'assets/zoe-poukamiso.png',
    'assets/zoe-hat.png',
  ];

  void _moveItemToOutfit(String itemPath) {
    setState(() {
      suggestedItems.remove(itemPath);
      currentItems.add(itemPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.black,
                          size: 28,
                        ),
                        onPressed: () {
                          // Show delete confirmation dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text('Delete Outfit'),
                                content: const Text(
                                  'Are you sure you want to delete this outfit?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                      ); // Close dialog (No)
                                    },
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(
                                        context,
                                        'deleted',
                                      ); // Return 'deleted' to previous screen (Yes)
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ===== OUTFIT ITEMS GRID (Top) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.start,
                  children: currentItems
                      .map((path) => _buildClothingItem(path))
                      .toList(),
                ),
              ),

              const SizedBox(height: 30),

              // ===== ADD SECTION DIVIDER =====
              if (suggestedItems.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 1.5,
                        width: double.infinity,
                        color: const Color(
                          0xFFD01FE8,
                        ).withOpacity(0.5), // Light purple line
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ===== ADD ITEMS GRID (Bottom) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.start,
                    children: suggestedItems.map((path) {
                      return GestureDetector(
                        onTap: () => _moveItemToOutfit(path),
                        child: _buildClothingItem(path),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClothingItem(String imagePath) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }
}
