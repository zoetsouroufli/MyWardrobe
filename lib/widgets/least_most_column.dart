import 'package:flutter/material.dart';
import 'package:my_app/widgets/card_decoration.dart';
import 'least_most_card.dart';

class LeastMostColumn extends StatelessWidget {
  final Map<String, dynamic>? leastWorn;
  final Map<String, dynamic>? mostWorn;
  final int totalItems;

  const LeastMostColumn({
    super.key,
    this.leastWorn,
    this.mostWorn,
    this.totalItems = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leastWorn != null)
          LeastMostCard(
            title: 'Least worn',
            item: (leastWorn!['brand'] != null && leastWorn!['brand'].toString().isNotEmpty) ? leastWorn!['brand'] : 'Item',
            times: (leastWorn!['timesWorn'] as num?)?.toInt() ?? 0,
            imagePath: leastWorn!['imageUrl'] ?? '',
          )
        else
           const LeastMostCard(
            title: 'Least worn',
            item: '-',
            times: 0,
            imagePath: '', // Handle empty/null in Card if needed? Assuming Card handles empty path gracefully or we check
          ),
          
        const SizedBox(height: 12),
        
        if (mostWorn != null)
          LeastMostCard(
            title: 'Most worn',
            item: (mostWorn!['brand'] != null && mostWorn!['brand'].toString().isNotEmpty) ? mostWorn!['brand'] : 'Item',
            times: (mostWorn!['timesWorn'] as num?)?.toInt() ?? 0,
            imagePath: mostWorn!['imageUrl'] ?? '',
          )
         else
           const LeastMostCard(
            title: 'Most worn',
            item: '-',
            times: 0,
            imagePath: '',
          ),

        const SizedBox(height: 12),
        
        // Total Items Card - Reusing LeastMostCard layout but adapted
        // Or specific widget. Reusing for now as per design.
        LeastMostCard(
            title: 'Total items',
            item: 'Items',
            times: totalItems,
            imagePath: 'assets/tshirt.png.jpg' // Generic Icon or empty?
        ),
      ],
    );
  }
}
