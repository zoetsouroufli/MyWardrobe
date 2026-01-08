import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/clothing_type_pie.dart';
import '../widgets/barchart.dart';
import '../widgets/least_most_column.dart';
import '../widgets/info_bars.dart';
import '../widgets/MonthlySpendingChart.dart';


class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      bottomNavigationBar: BottomNav(
        selectedIndex: 1,
        onTap: (index) => print('Bottom nav tapped: $index'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text('stats', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Image.asset('assets/MyWardrobe.png', height: 46),
              const SizedBox(height: 24),

              /// PIE + RIGHT CARDS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Expanded(flex: 3, child: ClothingTypePie()),
                  SizedBox(width: 16),
                  Expanded(flex: 2, child: LeastMostColumn()),
                ],
              ),

              const SizedBox(height: 20),

              /// INFO BARS
              const InfoBar(
                title: 'Favourite colour',
                value: 'Black',
                valueColor: Colors.black,
              ),
              const SizedBox(height: 12),
              const InfoBar(
                title: 'Total Wardrobe Value',
                value: '2000€',
                valueColor: Colors.purple,
              ),

              const SizedBox(height: 20),

              /// LINE CHART
              const MonthlySpendChart(),

              const SizedBox(height: 20),

              /// BAR CHART
              const ClothesByColorBarChart(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
