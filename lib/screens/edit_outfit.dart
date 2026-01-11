import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/color_palette_picker.dart';
import '../utils/preview_styles.dart';

class EditOutfitScreen extends StatefulWidget {
  final String outfitId;
  final Map<String, dynamic> outfitData;

  const EditOutfitScreen({
    super.key,
    required this.outfitId,
    required this.outfitData,
  });

  @override
  State<EditOutfitScreen> createState() => _EditOutfitScreenState();
}

class _EditOutfitScreenState extends State<EditOutfitScreen> {
  late Color _selectedColor;
  late String _previewStyleType;
  late String _selectedGradient;
  late String? _selectedPattern; // null = no pattern
  late TextEditingController _descController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    
    // Initialize from existing outfit data
    _selectedColor = Color(widget.outfitData['color'] as int? ?? 0xFF9C27B0);
    _nameController = TextEditingController(text: widget.outfitData['title'] ?? '');
    _descController = TextEditingController(text: widget.outfitData['subtitle'] ?? '');
    
    // Initialize preview style
    final previewStyle = widget.outfitData['previewStyle'] as Map<String, dynamic>?;
    _previewStyleType = previewStyle?['type'] ?? 'color';
    _selectedGradient = previewStyle?['value'] ?? 'sunset';
    _selectedPattern = previewStyle?['pattern'] as String?; // Can be null
  }

  @override
  void dispose() {
    _descController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Color get _previewColor {
    // Get color from gradient if gradient is selected
    if (_previewStyleType == 'gradient') {
      final gradient = PreviewStyles.getGradient(_selectedGradient);
      if (gradient != null && gradient.colors.isNotEmpty) {
        return gradient.colors.first;
      }
    }
    // Otherwise use selected solid color
    return _selectedColor;
  }

  Future<void> _saveOutfit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updatedOutfit = {
      'color': _selectedColor.value,
      'previewStyle': {
        'type': _previewStyleType,
        'value': _previewStyleType == 'gradient' ? _selectedGradient : '',
        'pattern': _selectedPattern, // Can be null
      },
      'title': _nameController.text.isEmpty
          ? 'Outfit'
          : _nameController.text,
      'subtitle': _descController.text,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('outfits')
        .doc(widget.outfitId)
        .update(updatedOutfit);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit updated!')),
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

              // Handle bar visual
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // ===== PREVIEW STYLE SELECTOR =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStyleTab('Color', 'color'),
                  const SizedBox(width: 8),
                  _buildStyleTab('Gradient', 'gradient'),
                ],
              ),

              const SizedBox(height: 20),

              // ===== STYLE PICKER =====
              if (_previewStyleType == 'color')
                ColorPalettePicker(
                  selectedColor: _selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                )
              else
                _buildGradientPicker(),

              const SizedBox(height: 24),

              // ===== PATTERN OVERLAY (OPTIONAL) =====
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pattern Overlay (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildPatternPicker(),

              const SizedBox(height: 24),

              // ===== DESCRIPTION =====
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add a description for your outfit...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
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

              // ===== OUTFIT NAME =====
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Outfit Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter outfit name...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 40),

              // SAVE BUTTON
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
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleTab(String label, String type) {
    final isSelected = _previewStyleType == type;
    return GestureDetector(
      onTap: () => setState(() => _previewStyleType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: PreviewStyles.gradientIds.map((gradientId) {
        final isSelected = _selectedGradient == gradientId;
        return GestureDetector(
          onTap: () => setState(() => _selectedGradient = gradientId),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: PreviewStyles.getGradient(gradientId),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF9C27B0)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 28)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatternPicker() {
    final patterns = [null, 'stripes', 'dots', 'geometric', 'waves', 'chevron'];
    final patternNames = ['None', 'Stripes', 'Dots', 'Geometric', 'Waves', 'Chevron'];
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(patterns.length, (index) {
        final patternId = patterns[index];
        final isSelected = _selectedPattern == patternId;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedPattern = patternId),
          child: Container(
            width: 70,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF9C27B0)
                    : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (patternId == null)
                  const Icon(Icons.block, size: 32, color: Colors.grey)
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: PreviewStyles.buildPattern(
                      patternId, 
                      size: 50, 
                      color: _previewColor,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  patternNames[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
