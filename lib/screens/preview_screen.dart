import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // for XFile
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PreviewScreen extends StatefulWidget {
  final XFile imageFile; // Changed from String path to XFile

  const PreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isUploading = false;

  Future<void> _saveImageLocally() async {
    if (kIsWeb) {
      // On web we cannot save to "documents directory" easily.
      // We could trigger a download, but for now let's just show a message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local save not fully supported on Web yet.')),
      );
      Navigator.pop(context, widget.imageFile.path);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get the directory to save the file permanently
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(widget.imageFile.path);
      final newPath = path.join(directory.path, fileName);

      // Copy the file from cache to documents
      await widget.imageFile.saveTo(newPath);

      if (!mounted) return;
      
      // Return the local path
      Navigator.pop(context, newPath);

    } catch (e) {
      print('Error saving locally: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
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
                    onPressed: _saveImageLocally,
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
