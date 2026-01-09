import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import 'my_outfits.dart';
import 'add_new_outfit.dart';

class SelectedClothingItemScreen extends StatefulWidget {
  final String imagePath;

  const SelectedClothingItemScreen({super.key, required this.imagePath});

  @override
  State<SelectedClothingItemScreen> createState() =>
      _SelectedClothingItemScreenState();
}

class _SelectedClothingItemScreenState
    extends State<SelectedClothingItemScreen> {
  String _size = 'S';
  final TextEditingController _brandController = TextEditingController(
    text: 'Zara',
  );
  int _timesWorn = 2;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
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
                  child: widget.imagePath.startsWith('http')
                      ? Image.network(
                          widget.imagePath,
                          fit: BoxFit.contain, // Show full item
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
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

              // ===== STATS ROWS =====

              // 1. COLOUR
              _buildStatRow(
                label: 'Colour',
                iconAsset: 'assets/colour-palette.png',
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildColorChip('green', Colors.green.shade800),
                    const SizedBox(width: 8),
                    _buildColorChip('grey', Colors.grey),
                  ],
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
                  width: 100,
                  alignment: Alignment.centerRight,
                  child: TextField(
                    controller: _brandController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
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
                      if (_timesWorn > 0) setState(() => _timesWorn--);
                    }),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$_timesWorn',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildCounterButton(Icons.add, () {
                      setState(() => _timesWorn++);
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
        final Set<int> selectedIndices = {};

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

                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: globalOutfits.length,
                      itemBuilder: (context, index) {
                        final outfit = globalOutfits[index];
                        final isSelected = selectedIndices.contains(index);

                        return CheckboxListTile(
                          title: Text(
                            outfit['title'],
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
                                selectedIndices.add(index);
                              } else {
                                selectedIndices.remove(index);
                              }
                            });
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
                      onPressed: () {
                        final selectedTitles = selectedIndices
                            .map((i) => globalOutfits[i]['title'])
                            .toList();
                        print('Added to outfits: $selectedTitles');
                        Navigator.pop(context);
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
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
