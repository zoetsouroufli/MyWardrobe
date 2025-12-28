import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/stat_card.dart';
import '../widgets/least_most_card.dart';
import '../widgets/donut_chart_placeholder.dart';
import '../widgets/bar_chart_placeholder.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      bottomNavigationBar: const BottomNav(selectedIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              const Text(
                'stats',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              Image.asset(
                'assets/MyWardrobe.png',
                height: 48,
              ),

              const SizedBox(height: 24),

              // ===== TOP SECTION =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: DonutChartPlaceholder()),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        LeastMostCard(
                          title: 'Least worn',
                          item: 'Shirt',
                          times: 2,
                          imagePath: 'assets/shirt.png',
                        ),
                        SizedBox(height: 16),
                        LeastMostCard(
                          title: 'Most worn',
                          item: 'Trousers',
                          times: 20,
                          imagePath: 'assets/pants.png',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ===== MIDDLE =====
              Row(
                children: const [
                  Expanded(
                    child: StatCard(
                      title: 'Average spent',
                      value: '100\$ / month',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Total items',
                      value: '30',
                      big: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const StatCard(
                title: 'Total wardrobe value',
                value: '1500\$',
                icon: Icons.circle,
              ),

              const SizedBox(height: 16),

              const StatCard(
                title: 'Clothes by colour',
                icon: Icons.palette,
              ),

              const SizedBox(height: 16),

              const BarChartPlaceholder(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
