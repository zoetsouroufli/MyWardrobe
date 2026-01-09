import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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

          if (!context.mounted) return;

          // Choice Dialog (From Remote)
          final source = await showDialog<ImageSource>(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: const Text('Add Photo'),
              children: [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, ImageSource.camera),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 8),
                        Text('Take Photo'),
                      ],
                    ),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 8),
                        Text('Pick from Gallery'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          if (source == null) return;

          String? imagePath;

          if (source == ImageSource.camera) {
            final cameras = await availableCameras();
            if (!context.mounted) return;
            // ignore: use_build_context_synchronously
            imagePath = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CameraScreen(cameras: cameras)),
            );
          } else {
            // Gallery
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (pickedFile != null) {
              imagePath = pickedFile.path;
            }
          }

          if (imagePath != null && context.mounted) {
            // Navigate directly to UploadPhotoScreen (From Local HEAD)
            // We ignore the remote's Category Picker because UploadPhotoScreen handles it
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadPhotoScreen(imagePath: imagePath!),
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
