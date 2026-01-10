import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/clothes_by_type_pie.dart';
import '../widgets/least_most_card.dart';
import '../widgets/MonthlySpendingChart.dart';
import '../widgets/barchart.dart';
import '../widgets/info_bar.dart';
import '../widgets/card_decoration.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseAuth.instance.currentUser != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('wardrobe')
                  .snapshots()
              : const Stream.empty(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            // 1. Total Items
            final totalItems = docs.length;

            // 2. Category Counts & Aggregation
            final categoryCounts = <String, int>{};
            double totalValue = 0;
            final colorCounts = <String, int>{}; // String keys for color names
            List<Map<String, dynamic>> allItems = [];
            final monthlySpending = <int, double>{};

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final cat = data['category'] as String? ?? 'Other';
              categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;

              final price = (data['price'] as num?)?.toDouble() ?? 0;
              totalValue += price;

              final monthAdded = (data['monthAdded'] as int?) ?? 0;
              if (monthAdded >= 1 && monthAdded <= 12) {
                monthlySpending[monthAdded] = (monthlySpending[monthAdded] ?? 0) + price;
              }

              // Use colorName for aggregation to group properly
              final colorName = data['colorName'] as String?;
              if (colorName != null && colorName.isNotEmpty) {
                 colorCounts[colorName] = (colorCounts[colorName] ?? 0) + 1;
              } else {
                 final color = (data['primaryColor'] as int?) ?? 0;
                 if (color != 0) {
                    // Fallback to "Unknown" or skip if raw int isn't mappable easily
                 }
              }

              allItems.add(data);
            }

            // 3. Least/Most Worn
            allItems.sort((a, b) {
              final wornA = (a['timesWorn'] as num?)?.toInt() ?? 0;
              final wornB = (b['timesWorn'] as num?)?.toInt() ?? 0;
              return wornA.compareTo(wornB);
            });

            final leastWorn = allItems.isNotEmpty ? allItems.first : null;
            final mostWorn = allItems.isNotEmpty ? allItems.last : null;

            // 4. Favourite Colour
            String favColorName = '-';
            int maxCount = 0;
            colorCounts.forEach((colorName, count) {
              if (count > maxCount) {
                 maxCount = count;
                 favColorName = colorName;
              }
            });
            
            // Helper to get Color object from name
            Color _getColor(String name) {
                switch (name.toLowerCase()) {
                  case 'red': return Colors.red;
                  case 'blue': return Colors.blue;
                  case 'black': return Colors.black;
                  case 'white': return Colors.grey.shade400;
                  case 'green': return Colors.green;
                  case 'yellow': return Colors.yellow;
                  case 'grey': return Colors.grey;
                  case 'purple': return Colors.purple;
                  case 'pink': return Colors.pink;
                  case 'orange': return Colors.orange;
                  case 'brown': return Colors.brown;
                  default: return Colors.transparent;
                }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/MyWardrobe.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  /// PIE + RIGHT CARDS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClothingTypePie(categoryCounts: categoryCounts),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: LeastMostColumn(
                          leastWorn: leastWorn,
                          mostWorn: mostWorn,
                          totalItems: totalItems,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// INFO BARS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: cardDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Favourite colour'),
                        if (favColorName != '-' && _getColor(favColorName) != Colors.transparent)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _getColor(favColorName),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          )
                        else
                          Text(favColorName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoBar(
                    title: 'Total Wardrobe Value',
                    value: '${totalValue.toStringAsFixed(0)}€',
                    valueColor: Colors.purple,
                  ),

                  const SizedBox(height: 20),

                  /// LINE CHART
                  MonthlySpendChart(monthlySpending: monthlySpending),

                  const SizedBox(height: 20),

                  /// BAR CHART
                  ClothesByColorBarChart(colorCounts: colorCounts),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
