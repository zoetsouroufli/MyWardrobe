import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/widgets/card_decoration.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/clothing_type_pie.dart';
import '../widgets/barchart.dart';
import '../widgets/least_most_column.dart';
import '../widgets/info_bars.dart';
import '../widgets/MonthlySpendingChart.dart';
import 'home_screen.dart';
import 'my_outfits.dart';
import 'clothing_categories.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      bottomNavigationBar: BottomNav(
        selectedIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          Widget screen;
          switch (index) {
            case 0:
              screen = const HomeScreen();
              break;
            case 2:
              screen = const MyOutfitsScreen();
              break;
            case 3:
              screen = const ClothingCategoriesScreen();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => screen,
              transitionDuration: Duration.zero,
            ),
          );
        },
      ),
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

            // 2. Category Counts
            final categoryCounts = <String, int>{};
            double totalValue = 0;
            final colorCounts = <int, int>{};
            List<Map<String, dynamic>> allItems = [];

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final cat = data['category'] as String? ?? 'Other';
              categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;

              totalValue += (data['price'] as num?)?.toDouble() ?? 0;

              final color = (data['primaryColor'] as int?) ?? 0;
              if (color != 0) {
                 colorCounts[color] = (colorCounts[color] ?? 0) + 1;
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
            int favColorInt = 0;
            int maxCount = 0;
            colorCounts.forEach((color, count) {
              if (count > maxCount) {
                 maxCount = count;
                 favColorInt = color;
              }
            });

            return SingleChildScrollView(
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
                    children: [
                      Expanded(
                          flex: 3,
                          child:
                              ClothingTypePie(categoryCounts: categoryCounts)),
                      const SizedBox(width: 16),
                      Expanded(
                          flex: 2,
                          child: LeastMostColumn(
                            leastWorn: leastWorn,
                            mostWorn: mostWorn,
                            totalItems: totalItems,
                          )),
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
                        if (favColorInt != 0)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(favColorInt),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          )
                        else
                          const Text('-',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const MonthlySpendChart(),

                  const SizedBox(height: 20),

                  /// BAR CHART
                  const ClothesByColorBarChart(),

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
