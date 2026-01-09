import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/back_button.dart';
import 'clothing_categories.dart';
import 'selected_clothing_item.dart';
import '../services/background_remover.dart';
import '../services/firestore_service.dart';
import '../services/image_classifier.dart';

class UploadPhotoScreen extends StatefulWidget {
  final String imagePath;

  const UploadPhotoScreen({super.key, required this.imagePath});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  bool _isIsolating = false;
  bool _isMirrored = false;
  bool _isSaving = false;
  late String _displayImagePath;
  final TextEditingController _brandController = TextEditingController();

  String _selectedCategory = 'Pants';
  final List<String> _categories = [
    'Pants',
    'T-Shirts',
    'Hoodies',
    'Jackets',
    'Socks',
    'Shoes',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    _displayImagePath = widget.imagePath;
    _autoClassify();
  }

  Future<void> _autoClassify() async {
    if (kIsWeb) return;
    final category = await ImageClassifier().classifyImage(widget.imagePath);
    if (category != null && mounted) {
      setState(() {
        _selectedCategory = category;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Auto-detected: $category')));
    }
  }

  Future<void> _isolateImage() async {
    setState(() => _isIsolating = true);

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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ClothingCategoriesScreen()),
      (route) => false,
    );
  }

  void _onSave() async {
    setState(() => _isSaving = true);
    String finalPath = _displayImagePath;

    // 1. Flip if needed
    if (_isMirrored) {
      if (!kIsWeb) {
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

    // 2. Upload to Firebase Storage and Save to Firestore
    try {
      String imageUrl = finalPath;

      if (!kIsWeb) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }

        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(finalPath)}';
        final ref = FirebaseStorage.instance.ref().child(
          'users/${user.uid}/wardrobe/$fileName',
        );

        final file = File(finalPath);
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();

        // Save metadata to Firestore
        await FirestoreService().addClothingItem({
          'imageUrl': imageUrl,
          'category': _selectedCategory,
          'brand': _brandController.text,
          'dateAdded': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SelectedClothingItemScreen(imagePath: imageUrl),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
                  BackButtonCircle(onPressed: () => Navigator.pop(context)),
                  Image.asset(
                    'assets/MyWardrobe.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
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

              // ===== IMAGE =====
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 300,
                      alignment: Alignment.center,
                      child: _isIsolating || _isSaving
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF9C27B0),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isSaving
                                      ? 'Saving...'
                                      : 'Isolating clothing item...',
                                ),
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
                    if (!_isIsolating && !_isSaving)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                  border: Border.all(color: const Color(0xFFD01FE8)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    hintText: 'Brand',
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.close, color: Colors.black54),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== CATEGORY DROPDOWN =====
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFD01FE8)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: const Text('Select Category'),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ===== SAVE =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
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
