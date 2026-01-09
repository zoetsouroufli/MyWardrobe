import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/color_palette_picker.dart';
import 'my_outfits.dart'; // To access globalOutfits

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

  void _saveOutfit() {
    if (_nameController.text.isEmpty) {
      // Optional: Show error or assume default
      // But user said "grapso outfit description and outfit-name kai meta patao enter"
      // We can enforce it or not. Let's enforce name at least implicitly or allow empty.
    }

    // Create new outfit
    final newOutfit = {
      'color': _selectedColor,
      'title': _nameController.text.isEmpty
          ? 'New Outfit'
          : _nameController.text,
      'subtitle': _descController.text,
      'likes': 0,
      'items': [widget.imagePath],
      'isLink': true, // Make it openable
    };

    setState(() {
      globalOutfits.add(newOutfit);
    });

    // Navigate back to MyOutfits or just pop.
    // User said: "na emfanizetai kai sto my_outfits page" which implies we go there or user goes there later.
    // Usually "Done" -> Pop is enough, user can navigate. Or we can pushReplacement to main.
    // Let's pop until we are back or just pop once.
    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('New outfit created!')));
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
