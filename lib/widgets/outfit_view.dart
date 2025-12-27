import 'package:flutter/material.dart';
import '/widgets/back_button.dart';
import '/widgets/outfit_item.dart';

class OutfitView extends StatelessWidget {
  final bool isOwner;
  final bool showAddSection;
  final VoidCallback? onDelete;

  const OutfitView({
    super.key,
    required this.isOwner,
    required this.showAddSection,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== HEADER =====
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BackButtonCircle(),
            ),
            Image.asset(
              'assets/MyWardrobe.png',
              height: 48,
            ),
            if (isOwner)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ),
          ],
        ),

        const SizedBox(height: 24),

        // ===== OUTFIT GRID =====
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children:  [
            OutfitItem('assets/shorts.png'),
            OutfitItem('assets/sweater.png'),
            OutfitItem('assets/jacket.png'),
            OutfitItem('assets/socks.png'),
            OutfitItem('assets/shoes.png'),
          ],
        ),

        const SizedBox(height: 12),

          Divider(
                  thickness: 1.5,
                  height: 24,
                  color: Colors.deepPurpleAccent.withOpacity(0.5),
                ),

            const SizedBox(height: 8),


        if (showAddSection) ...[
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),

          // ===== ADD GRID =====
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children:[
              OutfitItem('assets/add1.png'),
              OutfitItem('assets/add2.png'),
              OutfitItem('assets/add3.png'),
            ],
          ),
        ],
      ],
    );
  }
}
