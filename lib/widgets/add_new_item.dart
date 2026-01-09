import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../screens/camera_screen.dart';
import '../screens/upload_photo.dart';

class AddNewItemButton extends StatelessWidget {
  const AddNewItemButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final cameras = await availableCameras();
          if (context.mounted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CameraScreen(cameras: cameras)),
            );

            if (result != null && context.mounted) {
              // Navigate to UploadPhotoScreen for "isolation" and details entry
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadPhotoScreen(imagePath: result),
                ),
              );
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
