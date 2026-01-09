import 'dart:io';
import 'package:flutter/foundation.dart'; // IsWeb
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // For flipping
import 'package:path_provider/path_provider.dart'; // For temp file
import '../widgets/back_button.dart';
import 'clothing_categories.dart'; // To navigate on trash
import 'selected_clothing_item.dart'; // To navigate on save
import '../services/background_remover.dart';
import '../services/wardrobe_manager.dart';

class UploadPhotoScreen extends StatefulWidget {
  final String imagePath;

  const UploadPhotoScreen({super.key, required this.imagePath});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  bool _isIsolating = false;
  bool _isMirrored = false;
  late String _displayImagePath;
  final TextEditingController _brandController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayImagePath = widget.imagePath;
  }

  Future<void> _isolateImage() async {
    setState(() => _isIsolating = true);

    // Call our service
    final resultPath = await BackgroundRemover().removeBackground(
      _displayImagePath,
    );

    if (mounted) {
      setState(() {
        _isIsolating = false;
        if (resultPath != null) {
          _displayImagePath = resultPath;
        }
      });

      String message = kIsWeb
          ? 'Background removal simulated (Web fallback)'
          : (resultPath != widget.imagePath
                ? 'Subject Isolated!'
                : 'No subject found.');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  void _onDiscard() {
    // Return to "Selected Categories" i.e. ClothingCategoriesScreen
    // Since we are in a stack (Camera -> Upload), we might want to pop until we are back.
    // Or pushReplacement.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ClothingCategoriesScreen()),
      (route) => false, // Remove all previous routes
    );
    // Note: This resets nav stack. If user wants to keep history, popUntil might be better.
    // But "Return to selected categories" usually implies "Cancel everything".
  }

  void _onSave() async {
    // If mirrored, flip the file before saving/passing
    String finalPath = _displayImagePath; // Use current displayed image

    if (_isMirrored) {
      if (kIsWeb) {
        // Web flip not implemented for file (blob). Just pass state or skip.
        // For MVP we skip file flip on web.
        // For MVP we skip file flip on web.
      } else {
        // Native flip
        try {
          final bytes = await File(finalPath).readAsBytes();
          final originalImg = img.decodeImage(bytes);
          if (originalImg != null) {
            final flippedImg = img.copyFlip(
              originalImg,
              direction: img.FlipDirection.horizontal,
            );
            final encoded = img.encodePng(flippedImg);

            final tempDir = await getTemporaryDirectory();
            final flippedPath =
                '${tempDir.path}/flipped_${DateTime.now().millisecondsSinceEpoch}.png';
            await File(flippedPath).writeAsBytes(encoded);

            finalPath = flippedPath;
          }
        } catch (e) {
          print('Error flipping image: $e');
        }
      }
    }

    // If not web, persist to WardrobeManager
    if (!kIsWeb) {
      await WardrobeManager().init();
      final permPath = await WardrobeManager().saveImagePermanent(finalPath);
      finalPath = permPath; // Update path to point to permanent file
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectedClothingItemScreen(
            imagePath: finalPath,
            // Pass brand/comments if refactored. For now just image.
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ===== HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back (Return to Camera)
                  BackButtonCircle(onPressed: () => Navigator.pop(context)),

                  // Logo
                  Image.asset(
                    'assets/MyWardrobe.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),

                  // Trash (Discard)
                  GestureDetector(
                    onTap: _onDiscard,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 28,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ===== IMAGE AREA with MIRROR Toggle =====
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 300,
                      alignment: Alignment.center,
                      child: _isIsolating
                          ? const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF9C27B0),
                                ),
                                SizedBox(height: 16),
                                Text('Isolating clothing item...'),
                              ],
                            )
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(
                                _isMirrored ? 3.14159 : 0,
                              ),
                              child: _buildImage(),
                            ),
                    ),
                    // Mirror Button
                    if (!_isIsolating)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Isolate Button
                            FloatingActionButton.small(
                              heroTag: 'isolate_btn',
                              onPressed: _isolateImage,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.auto_fix_high,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Mirror Button
                            FloatingActionButton.small(
                              heroTag: 'mirror_btn',
                              onPressed: () {
                                setState(() {
                                  _isMirrored = !_isMirrored;
                                });
                              },
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.flip,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ===== BRAND INPUT =====
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFD01FE8),
                  ), // Purple border
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    hintText: 'brand',
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.close, color: Colors.black54),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 40),

              // Save Button (Not in screenshot but needed to proceed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save & Continue',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_displayImagePath.startsWith('assets/')) {
      return Image.asset(_displayImagePath, fit: BoxFit.contain);
    } else if (kIsWeb) {
      return Image.network(_displayImagePath, fit: BoxFit.contain);
    } else {
      return Image.file(File(_displayImagePath), fit: BoxFit.contain);
    }
  }
}
