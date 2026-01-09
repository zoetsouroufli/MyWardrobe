import 'package:flutter/material.dart';
import 'package:my_app/widgets/card_decoration.dart';
import 'least_most_card.dart';

class LeastMostColumn extends StatelessWidget {
  const LeastMostColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        LeastMostCard(
          title: 'Least worn',
          item: 'Shirt',
          times: 2,
          imagePath: 'assets/tshirt.png.jpg',
        ),
        SizedBox(height: 12),
        LeastMostCard(
          title: 'Most worn',
          item: 'Trousers',
          times: 20,
          imagePath: 'assets/pants-1.jpg',
        ),
           SizedBox(height: 12),
          LeastMostCard(
            title: 'Total items',
            item: 'Items',
            times: 30,
            imagePath: 'assets/pants-1.jpg'
    ),

      
      ],
    );
  }
}
