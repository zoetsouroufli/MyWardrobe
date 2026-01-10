import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/selected_clothing_item.dart';

class CategoryDropdownTile extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items; // Changed from List<String> images

  const CategoryDropdownTile({
    super.key,
    required this.title,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9C27B0).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          iconColor: Colors.black54,
          collapsedIconColor: Colors.black54,
          childrenPadding: const EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: 12,
          ),
          children: [
            if (items.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final imagePath = item['imageUrl'] as String;
                  final itemId = item['id'] as String?;
                  final itemData = item['data'] as Map<String, dynamic>? ?? {};

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectedClothingItemScreen(
                            imagePath: imagePath,
                            itemId: itemId,     // Pass ID
                            initialData: itemData, // Pass Data
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (imagePath.startsWith('http') || imagePath.startsWith('blob:'))
                            ? Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                            )
                            : (imagePath.startsWith('assets/')
                                  ? Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    )
                                  : (kIsWeb 
                                      ? Image.network(
                                          imagePath, 
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                              const Center(child: Icon(Icons.broken_image, color: Colors.amber)),
                                        ) 
                                      : Image.file(
                                      File(imagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                              ),
                                            );
                                          },
                                    ))),
                      ),
                    ),
                  );
                },
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No items yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
