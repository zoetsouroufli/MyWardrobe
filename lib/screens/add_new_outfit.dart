import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/color_palette_picker.dart';

class AddNewOutfitScreen extends StatefulWidget {
  final String imagePath; // Item to add to the new outfit

  const AddNewOutfitScreen({super.key, required this.imagePath});

  @override
  State<AddNewOutfitScreen> createState() => _AddNewOutfitScreenState();
}

class _AddNewOutfitScreenState extends State<AddNewOutfitScreen> {
  Color _selectedColor = const Color(0xFF9C27B0); // Default purple
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveOutfit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_nameController.text.isEmpty) {
      // Optional: Show error or assume default
    }

    final newOutfit = {
      'color': _selectedColor.value,
      'title': _nameController.text.isEmpty
          ? 'New Outfit'
          : _nameController.text,
      'subtitle': _descController.text,
      'likes': 0,
      'items': [widget.imagePath],
      'dateAdded': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('outfits')
        .add(newOutfit);

    if (mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('New outfit created!')));
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
            children: [
              const SizedBox(height: 12),

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
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Handle bar visual (Purple line)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // ===== PALETTE =====
              ColorPalettePicker(
                selectedColor: _selectedColor,
                onColorSelected: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
              ),

              const SizedBox(height: 24),

              // ===== DESCRIPTION =====
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'outfit-description',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF9C27B0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF9C27B0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF9C27B0),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== NAME CHIP =====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF9C27B0)),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'outfit-name',
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.close, size: 16),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 40),

              // DONE BUTTON (Enter)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveOutfit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
