import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/back_button.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OneOutfitScreen extends StatefulWidget {
  final Map<String, dynamic> outfitData;
  final String? outfitId;

  const OneOutfitScreen({super.key, required this.outfitData, this.outfitId});

  @override
  State<OneOutfitScreen> createState() => _OneOutfitScreenState();
}

class _OneOutfitScreenState extends State<OneOutfitScreen> {
  // Initial suggestions (keep hardcoded for now or fetch from somewhere else)
  final List<String> suggestedItems = [
    'assets/zoe-vshirt.png',
    'assets/zoe-poukamiso.png',
    'assets/zoe-hat.png',
  ];

  List<String> get currentItems {
    final items = widget.outfitData['items'];
    if (items is List) {
      return List<String>.from(items);
    }
    return [];
  }

  Future<double> _calculateTotalPrice(List<String> items) async {
    double total = 0.0;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || items.isEmpty) return 0.0;

    final wardrobeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wardrobe');

    // Query 1 by 1 for simplicity (batching whereIn limited to 10)
    for (var path in items) {
       final snapshot = await wardrobeRef.where('imageUrl', isEqualTo: path).limit(1).get();
       if (snapshot.docs.isNotEmpty) {
           final data = snapshot.docs.first.data();
           total += (data['price'] as num?)?.toDouble() ?? 0.0;
       }
    }
    return total;
  }

  void _moveItemToOutfit(String itemPath) {
    // TODO: Implement Firestore Update
    setState(() {
      suggestedItems.remove(itemPath);
      if (widget.outfitData['items'] == null) {
         widget.outfitData['items'] = <String>[];
      }
      (widget.outfitData['items'] as List).add(itemPath);
    });
  }

  void _removeItemFromOutfit(String itemPath) {
      // TODO: Implement Firestore Update
    setState(() {
       (widget.outfitData['items'] as List).remove(itemPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final outfit = widget.outfitData;

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
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(
                                        context,
                                        'deleted',
                                      ); // Return result
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

              // ===== TITLE =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit['title'] ?? 'Outfit',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<double>(
                      future: _calculateTotalPrice(currentItems),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return Text(
                          'Total Value: \$${snapshot.data!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF9C27B0),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ===== OUTFIT ITEMS GRID (Top) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: currentItems.isEmpty
                    ? const Text(
                        'No items in this outfit yet.',
                        style: TextStyle(color: Colors.grey),
                      )
                    : Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.start,
                        children: currentItems
                            .map(
                              (path) =>
                                  _buildClothingItem(path, canDelete: true),
                            )
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
                        child: _buildClothingItem(path, canDelete: false),
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

  Widget _buildClothingItem(String imagePath, {required bool canDelete}) {
    return GestureDetector(
      onLongPress: canDelete ? () => _removeItemFromOutfit(imagePath) : null,
      child: Container(
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
            child: _buildImage(imagePath),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else if (kIsWeb) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.amber)),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.red),
          );
        },
      );
    }
  }
}
