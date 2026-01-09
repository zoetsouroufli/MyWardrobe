import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // for XFile

class PreviewScreen extends StatefulWidget {
  final XFile imageFile; // Changed from String path to XFile

  const PreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isUploading = false;

  void _confirmImage() {
    Navigator.pop(context, widget.imageFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The image
          Positioned.fill(
            child: kIsWeb
                ? Image.network(widget.imageFile.path, fit: BoxFit.cover)
                : Image.file(File(widget.imageFile.path), fit: BoxFit.cover),
          ),

          // Loading Overlay
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Buttons overlay (Hide when uploading)
          if (!_isUploading)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Retake Button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.white24,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  // OK Button (Save)
                  TextButton(
                    onPressed: _confirmImage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
