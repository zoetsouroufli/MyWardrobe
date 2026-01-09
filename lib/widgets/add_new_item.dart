import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/camera_screen.dart';
import '../services/firestore_service.dart';

class AddNewItemButton extends StatelessWidget {
  const AddNewItemButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Check if user is logged in
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to add items')),
            );
            return;
          }

          final cameras = await availableCameras();
          if (!context.mounted) return;
          
          final imageUrl = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CameraScreen(cameras: cameras)),
          );

          if (imageUrl != null && context.mounted) {
            // Show Category Picker Dialog
            String? selectedCategory = await showDialog<String>(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Text('Select Category'),
                  children: [
                    'Pants',
                    'T-Shirts',
                    'Hoodies',
                    'Jackets',
                    'Socks',
                    'Shoes'
                  ].map((category) {
                    return SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, category),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(category, style: const TextStyle(fontSize: 16)),
                      ),
                    );
                  }).toList(),
                );
              },
            );

            if (selectedCategory != null && context.mounted) {
              // Save to Firestore
              try {
                await FirestoreService().addClothingItem({
                  'imageUrl': imageUrl,
                  'category': selectedCategory,
                  'dateAdded': FieldValue.serverTimestamp(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item added successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save item: $e')),
                );
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C27B0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'add new item',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
