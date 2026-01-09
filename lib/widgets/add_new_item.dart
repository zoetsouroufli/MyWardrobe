import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/camera_screen.dart';
import '../screens/upload_photo.dart';
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

          final imagePath = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CameraScreen(cameras: cameras)),
          );

          if (imagePath != null && context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UploadPhotoScreen(imagePath: imagePath as String),
              ),
            );
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
