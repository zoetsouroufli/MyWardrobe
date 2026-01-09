import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // for XFile
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreviewScreen extends StatefulWidget {
  final XFile imageFile; // Changed from String path to XFile

  const PreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isUploading = false;

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = path.basename(widget.imageFile.path);
      // Need auth to get uid, can fallback to 'anonymous' if needed, but we have auth now
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      final ref = FirebaseStorage.instance.ref().child('uploads/$uid/$fileName');
      
      // Universally compatible: read as bytes
      final bytes = await widget.imageFile.readAsBytes();
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      await ref.putData(bytes, metadata);
      final downloadUrl = await ref.getDownloadURL();

      if (!mounted) return;
      
      // Return the cloud URL
      Navigator.pop(context, downloadUrl);

    } catch (e) {
      print('Error uploading: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
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
              child: const Center(
                child: CircularProgressIndicator(),
              ),
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
                    child: const Icon(Icons.close, color: Colors.white, size: 30),
                  ),

                  // OK Button (Save)
                  TextButton(
                    onPressed: _uploadImage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.check, color: Colors.black, size: 30),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
