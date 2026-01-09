import 'package:flutter/material.dart';
import 'screens/intro.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/friend_profile.dart';
import 'screens/friend_outfit.dart';
import 'screens/my_outfits.dart';
import 'screens/edit_profile.dart';
import 'screens/one_outfit.dart';
import 'screens/clothing_categories.dart';
// import 'screens/selected_category.dart';
import 'screens/selected_clothing_item.dart';
import 'screens/add_to_outfit.dart';
import 'screens/add_new_outfit.dart';
import 'screens/stats.dart';
import 'screens/camera_screen.dart';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyWardrobe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // ============================================
      // ΑΛΛΑΞΕ ΕΔΩ ΤΗΝ ΟΘΟΝΗ ΠΟΥ ΘΕΛΕΙΣ ΝΑ ΔΕΙΣ:
      // ============================================
      //home: const IntroScreen(),

      // Διαθέσιμες οθόνες (ξεκομμέντα αυτή που θέλεις):
      //home: const IntroScreen(),
      //home: const AuthScreen(),
      //home: const HomeScreen(),
      //home: const FriendProfileScreen(),
      //home: const FriendProfileOutfit(),
      //home: const MyOutfitsScreen(),
      //home: const EditProfileScreen(),
      //home: const OneOutfitScreen(),
      home: const ClothingCategoriesScreen(),
      //home: const SelectedCategoryScreen(categoryTitle: 'Pants'),
      //home: const SelectedClothingItemScreen(imagePath: 'assets/pants1.png'),
      //home: const AddToOutfitScreen(imagePath: 'assets/pants1.png'),
      //home: const AddNewOutfitScreen(),
      //home: const StatsScreen(),
    );
  }
}
