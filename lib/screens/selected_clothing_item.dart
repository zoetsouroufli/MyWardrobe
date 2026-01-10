import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/color_palette_picker.dart';
import '../services/firestore_service.dart';
import '../services/wardrobe_manager.dart';
import 'add_new_outfit.dart';

class SelectedClothingItemScreen extends StatefulWidget {
  final String imagePath;
  final String? itemId;
  final Map<String, dynamic>? initialData;

  const SelectedClothingItemScreen({
    super.key,
    required this.imagePath,
    this.itemId,
    this.initialData,
  });

  @override
  State<SelectedClothingItemScreen> createState() =>
      _SelectedClothingItemScreenState();
}

class _SelectedClothingItemScreenState
    extends State<SelectedClothingItemScreen> {
  late String _size;
  late TextEditingController _brandController;
  late TextEditingController _colorNameController;
  late TextEditingController _priceController;
  late int _timesWorn;
  late int _primaryColorValue;
  // NEW FIELDS
  late String _category;
  late int _monthAdded;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _categories = ['Pants', 'T-Shirts', 'Hoodies', 'Jackets', 'Socks', 'Shoes', 'Accessories'];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};
    _size = data['size'] ?? 'M';
    _brandController = TextEditingController(text: data['brand'] ?? 'Unknown');
    _colorNameController = TextEditingController(text: data['colorName'] ?? '');
    _priceController = TextEditingController(
      text: (data['price'] as num?)?.toStringAsFixed(0) ?? '0',
    );
    _timesWorn = (data['timesWorn'] as num?)?.toInt() ?? 0;
    _primaryColorValue = (data['primaryColor'] as int?) ?? 0xFF000000;
    
    // Initialize New Fields
    _category = data['category'] ?? '-';
    _monthAdded = (data['monthAdded'] as int?) ?? 0;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _colorNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateField(Map<String, dynamic> changes) async {
    if (widget.itemId == null) return;
    try {
      await FirestoreService().updateClothingItem(widget.itemId!, changes);
      // Optional: Show subtle toast or indicator
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  Future<void> _updateItemsInOutfitStatus(bool status) async {
    if (widget.itemId == null) return;
    // Since we refactored code to update by ID, we can do it directly
    // But the previous helper was by Image Path. Ideally use ID.
    // For this screen we have ID.
    await FirestoreService().updateClothingItem(widget.itemId!, {
      'isInOutfit': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ===== HEADER =====
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BackButtonCircle(
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Image.asset(
                    'assets/MyWardrobe.png',
                    width: 150, // Matches other screens
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 28,
                        color: Colors.black,
                      ),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ===== MAIN IMAGE =====
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child:
                      (widget.imagePath.startsWith('http') ||
                          widget.imagePath.startsWith('blob:'))
                      ? Image.network(
                          widget.imagePath,
                          fit: BoxFit.contain, // Show full item
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                        )
                      : Image.asset(
                          widget.imagePath,
                          fit: BoxFit.contain, // Show full item
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              const SizedBox(height: 40),

              // ===== STATS ROWS =====

              // 0A. CATEGORY
              _buildStatRow(
                label: 'Category',
                content: GestureDetector(
                  onTap: () => _showCategoryPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 0B. MONTH ADDED
              _buildStatRow(
                label: 'Month Added',
                content: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _monthName(_monthAdded),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),


              // 1. COLOUR
              _buildStatRow(
                label: 'Colour',
                iconAsset:
                    'assets/colour-palette.png', // Keep asset if exists, else remove
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
                    onSubmitted: (value) {
                      _updateField({'colorName': value});
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. SIZE
              _buildStatRow(
                label: 'Size',
                content: GestureDetector(
                  onTap: () {
                    _showSizePicker(context);
                  },
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
                    onSubmitted: (value) {
                      _updateField({'brand': value});
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3B. PRICE
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
                    onSubmitted: (value) {
                      final price = double.tryParse(value) ?? 0.0;
                      _updateField({'price': price});
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. TIMES WORN
              _buildStatRow(
                label: 'Number of times worn',
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCounterButton(Icons.remove, () {
                      if (_timesWorn > 0) {
                        setState(() => _timesWorn--);
                        _updateField({'timesWorn': _timesWorn});
                      }
                    }),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_timesWorn',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildCounterButton(Icons.add, () {
                      setState(() => _timesWorn++);
                      _updateField({'timesWorn': _timesWorn});
                    }),
                  ],
                ),
              ),

              // Spacing restored
              const SizedBox(height: 20),

              // ===== ACTION BUTTONS =====
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      'Add to outfit',
                      const Color(0xFF9C27B0), // Unified Purple
                      () {
                        _showAddToOutfitModal(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      'Add to new outfit',
                      const Color(0xFF9C27B0), // Unified Purple
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddNewOutfitScreen(imagePath: widget.imagePath),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildColorChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: Colors.black)),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddToOutfitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final Set<String> selectedDocIds = {};

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              height: 400,
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // StreamBuilder List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseAuth.instance.currentUser != null
                          ? FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('outfits')
                                .orderBy('dateAdded', descending: true)
                                .snapshots()
                          : const Stream.empty(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return const Center(child: Text("No outfits found."));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final outfit = doc.data() as Map<String, dynamic>;
                            final title = outfit['title'] ?? 'Outfit';
                            final isSelected = selectedDocIds.contains(doc.id);

                            return CheckboxListTile(
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: isSelected,
                              activeColor: const Color(0xFF9C27B0),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.trailing,
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    selectedDocIds.add(doc.id);
                                  } else {
                                    selectedDocIds.remove(doc.id);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enter Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null && selectedDocIds.isNotEmpty) {
                          final batch = FirebaseFirestore.instance.batch();
                          for (var docId in selectedDocIds) {
                            final ref = FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('outfits')
                                .doc(docId);
                            batch.update(ref, {
                              'items': FieldValue.arrayUnion([
                                widget.imagePath,
                              ]),
                            });
                          }
                          await batch.commit();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to outfits!'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Enter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                  });
                  _updateField({'primaryColor': color.value});
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
                  setState(() {
                    _size = size;
                  });
                  _updateField({'size': size});
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _categories.map((cat) {
                return ListTile(
                  title: Text(
                    cat,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: _category == cat
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _category == cat
                          ? const Color(0xFF9C27B0)
                          : Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _category = cat;
                    });
                    _updateField({'category': cat});
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        if (widget.itemId != null) {
          // Cloud Delete
          await FirestoreService().deleteClothingItem(
            widget.itemId!,
            imageUrl: widget.imagePath,
          );
        } else {
          // Local Delete
          await WardrobeManager().deleteItem(widget.imagePath);
        }
        if (mounted) {
          Navigator.pop(context); // Return to previous screen
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Item deleted.')));
        }
      } catch (e) {
        print('Error deleting item: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
        }
      }
    }
  }

  String _monthName(int month) {
    const months = ['-', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month];
    }
    return '-';
  }
}
