import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/back_button.dart';
import '../widgets/color_palette_picker.dart';
import 'clothing_categories.dart';
import 'selected_clothing_item.dart';
import '../services/background_remover.dart';
import '../services/firestore_service.dart';
import '../services/image_classifier.dart';
import 'package:palette_generator/palette_generator.dart';
import '../utils/color_utils.dart';
import '../utils/color_mapping.dart';

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

  // Controllers & State
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _colorNameController =
      TextEditingController(); // Added

  String _size = 'M';
  int _primaryColorValue = 0xFF000000;

  final List<String> _sizes = [
    '-', // No Size option
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
  ]; // Copied logic

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
    // _autoClassify() removed. Manual only.
  }

  Future<void> _detectCategory([String? path]) async {
    if (kIsWeb) return;
    final targetPath = path ?? widget.imagePath;

    // Skip if classifying the same image again unless it's isolated which might give better results

    try {
      final category = await ImageClassifier().classifyImage(targetPath);
      if (category != null && mounted) {
        setState(() {
          _selectedCategory = category;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Auto-detected: $category')));
      }
    } catch (e) {
      print('Auto-classify error: $e');
    }
    // Removed _extractColor call
  }

  Future<void> _extractColor(String path) async {
    try {
      final imageProvider = kIsWeb
          ? NetworkImage(path)
          : FileImage(File(path)) as ImageProvider;

      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 20,
      );

      final dominantColor = paletteGenerator.dominantColor?.color;

      if (dominantColor != null && mounted) {
        setState(() {
          _primaryColorValue = dominantColor.value;
          _colorNameController.text = ColorUtils.getColorName(dominantColor);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Color detected: ${_colorNameController.text}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: dominantColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error extracting color: $e');
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
          // _autoClassify(resultPath); // Removed manual trigger after isolation
        }
      });

      String message = kIsWeb
          ? 'Background removal simulated (Web fallback)'
          : (resultPath != widget.imagePath
                ? 'Subject Isolated! Tap the Magic Wand to analyze.' // Message updated
                : 'No subject found.');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _priceController.dispose();
    _colorNameController.dispose();
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

    // 2. Direct Upload to Firebase (No Local Save)
    if (!kIsWeb) {
      try {
        // Upload to Firebase Storage
        final imageUrl = await FirestoreService().uploadImage(File(finalPath));

        // Add to Firestore
        // Get base color for analytics
        final colorName = _colorNameController.text.isNotEmpty 
            ? _colorNameController.text 
            : ColorMapping.findColorName(Color(_primaryColorValue)) ?? 'Unknown';
        final baseColor = ColorMapping.getBaseColorName(colorName);
        
        await FirestoreService().addClothingItem({
          'imageUrl': imageUrl,
          'category': _selectedCategory,
          'brand': _brandController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'timesWorn': 0, // Always 0 on creation
          'size': _size,
          'primaryColor': _primaryColorValue,
          'colorName': colorName,
          'baseColor': baseColor, // For analytics grouping
          'dateAdded': FieldValue.serverTimestamp(),
          // 'isSynced': true, // No longer needed if we don't save local unsynced items
        });

        print('Upload successful: $imageUrl');

        if (mounted) {
          // Navigate to categories
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ClothingCategoriesScreen(),
            ),
            (route) => false,
          );
        }
      } catch (uploadError) {
        print('Upload failed: $uploadError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $uploadError. Check internet.'),
            ),
          );
        }
      }
    } else {
      // Web handling if needed, or error
    }

    if (mounted) {
      setState(() => _isSaving = false);
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
                                Icons.cut,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton.small(
                              heroTag: 'cat_btn',
                              onPressed: () =>
                                  _detectCategory(_displayImagePath),
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.sell_outlined, // Tag icon
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton.small(
                              heroTag: 'color_btn',
                              onPressed: () => _extractColor(_displayImagePath),
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.palette_outlined, // Palette icon
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

              // ===== STATS ROWS (Standardized) =====

              // 1. COLOUR
              _buildStatRow(
                label: 'Colour',
                iconAsset: 'assets/colour-palette.png',
                content: GestureDetector(
                  onTap: () => _showColorPicker(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(_primaryColorValue),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 1B. COLOR NAME
              _buildStatRow(
                label: 'Color Name',
                content: Container(
                  width: 120,
                  alignment: Alignment.centerRight,
                  child: TextField(
                    controller: _colorNameController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'e.g. Black',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. SIZE
              _buildStatRow(
                label: 'Size',
                content: GestureDetector(
                  onTap: () => _showSizePicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _size,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. BRAND
              _buildStatRow(
                label: 'Brand',
                content: Container(
                  width: 120,
                  alignment: Alignment.centerRight,
                  child: TextField(
                    controller: _brandController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Enter brand',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. CATEGORY (Dropdown in row)
              _buildStatRow(
                label: 'Category',
                content: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isDense: true,
                    hint: const Text('Select'),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

              const SizedBox(height: 16),

              // 5. PRICE
              _buildStatRow(
                label: 'Price',
                content: Container(
                  width: 120,
                  alignment: Alignment.centerRight,
                  child: TextField(
                    controller: _priceController,
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '0',
                      suffixText: '€',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 40),

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

  // ===== HELPERS =====

  Widget _buildStatRow({
    required String label,
    required Widget content,
    String? iconAsset,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (iconAsset != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(iconAsset, width: 20, height: 20),
                ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          content,
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ColorPalettePicker(
                selectedColor: Color(_primaryColorValue),
                onColorSelected: (color) {
                  setState(() {
                    _primaryColorValue = color.value;
                    _colorNameController.text = ColorMapping.findColorName(color) ?? 'Custom';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSizePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _sizes.map((size) {
              return ListTile(
                title: Text(
                  size,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: _size == size
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _size == size
                        ? const Color(0xFF9C27B0)
                        : Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() => _size = size);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
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
