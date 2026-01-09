import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> seedDummyUser() async {
    try {
      // Create a dummy user in 'users' collection
      await _db.collection('users').doc('dummy_user_1').set({
        'username': 'testuser',
        'description': 'I am a test user for searching.',
        'email': 'test@example.com',
      });
      print('Dummy user created!');
    } catch (e) {
      print('Error seeding dummy user: $e');
    }
  }

  Future<void> addClothingItem(Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .add({
          ...data,
          // Default Schema Values
          'timesWorn': 0,
          'price': 0.0,
          'size': 'M', // Default
          'primaryColor': 0xFF000000, 
          'colorName': '',
          'isInOutfit': false,
        });
  }

  Future<void> seedSampleData() async {
    final wardrobeRef = _db
        .collection('users')
        .doc(uid)
        .collection('wardrobe');

    // Check if data already exists to avoid duplicates
    // We will check per category now to allow partial updates

    final batch = _db.batch();

    final sampleData = {
      'Pants': [
        'assets/pants-1.jpg',
        'assets/pants-2.jpg',
        'assets/pants-3.jpg',
        'assets/pants-4.jpg',
        'assets/pants-5.jpg',
        'assets/pants-6.jpg',
        'assets/zoe-shorts.png',
        'assets/jeans.png.avif',
      ],
      'Jackets': [
        'assets/clothing_jacket_green.jpg',
        'assets/outfit_jacket.jpg',
        'assets/zoe-jeanjacket.png',
      ],
      'Shoes': [
        'assets/clothing_sneakers.jpg',
        'assets/outfit_sneakers.jpg',
        'assets/zoe-ballerinas.png',
      ],
      'T-Shirts': [
        'assets/tshirt.png.jpg',
        'assets/zoe-poukamiso.png',
        'assets/zoe-vshirt.png',
      ],
      'Hoodies': [
        'assets/clothing_sweater_black.jpg',
        'assets/zoe-stripespullover.png',
        'assets/sweater2.png.jpg',
      ],
      'Socks': [
        'assets/zoe-socks.png',
      ],
      'Accessories': [
        'assets/zoe-hat.png',
        'assets/outfit_cap.jpg',
      ]
    };

    print('Seeding sample data for user $uid...');
    for (var entry in sampleData.entries) {
      final category = entry.key;
      final assets = entry.value;
      
      // Check if this category has items already
      final catSnapshot = await wardrobeRef
          .where('category', isEqualTo: category)
          .limit(1)
          .get();
          
      if (catSnapshot.docs.isEmpty) {
         print('Adding $category...');
         for (var assetPath in assets) {
           final docRef = wardrobeRef.doc();
           batch.set(docRef, {
             'imageUrl': assetPath,
             'category': category,
             'dateAdded': FieldValue.serverTimestamp(),
             'isSample': true,
           });
         }
      } else {
        print('Category $category already exists.');
      }
    }

    await batch.commit();
    print('Seeding complete.');
  }

  Future<void> clearWardrobe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final wardrobeRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe');
        
    final snapshot = await wardrobeRef.get();
    if (snapshot.docs.isEmpty) {
        print('Wardrobe already empty.');
        return;
    }

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('Wardrobe cleared.');
  }

  Future<void> seedFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final friendsRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('friends');

    // Check if friends already exist
    final snapshot = await friendsRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();

    // Map of specific friends (optional custom names)
    // friend4 is 'babis heotis'
    
    for (int i = 1; i <= 16; i++) {
      final docRef = friendsRef.doc();
      String name = 'Friend $i';
      String username = 'user$i';
      
      if (i == 4) {
        name = 'babis heotis';
        username = 'fashion-icon';
      }

      batch.set(docRef, {
        'name': name,
        'username': username,
        'avatarUrl': 'assets/friend$i.jpg',
        'friendId': 'friend_$i', // useful for referencing unique friends later
        'dateAdded': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> seedFriendOutfits(String friendDocId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final outfitsRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(friendDocId)
        .collection('outfits');

    final snapshot = await outfitsRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();

    final outfits = [
      {
        'color': 0xFFFF5252, // Colors.red
        'title': 'chill cinema outfit',
        'description': 'saw Vougonia in this outfit... do not wear again',
        'likes': 14,
      },
      {
        'color': 0xFF00BCD4, // Colors.cyan
        'title': 'go thrifting',
        'description': 'thrifted fit...to go thrifting',
        'likes': 10,
      },
      {
        'color': 0xFF7CB342, // Color(0xFF7CB342)
        'title': 'party tzous',
        'description': 'May 15th get ready idea',
        'likes': 12,
      },
      {
        'color': 0xFFFF4081, // Colors.pinkAccent
        'title': 'outfit uni thursday',
        'description': 'needs a black hoodie',
        'likes': 213,
      },
    ];

    for (var outfit in outfits) {
      final docRef = outfitsRef.doc();
      batch.set(docRef, {
        ...outfit,
        'dateAdded': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> seedMyOutfits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final outfitsRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('outfits');

    final snapshot = await outfitsRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();

    final outfits = [
      {
        'color': 0xFFD01FE8,
        'title': 'outfit to go for coffee',
        'subtitle': 'maybe with red socks it would work better',
        'likes': 14,
        'items': [], // Initialize empty items list
      },
      {
        'color': 0xFFFF9800,
        'title': 'outfit to go to latraac',
        'subtitle': 'its May and the weather is nice',
        'likes': 12,
        'items': [],
      },
      {
        'color': 0xFF1A1A80,
        'title': 'monday morning fit',
        'subtitle': 'coolcoolcoolcoolcool',
        'likes': 10,
        'items': [],
      },
    ];

    for (var outfit in outfits) {
      final docRef = outfitsRef.doc();
      batch.set(docRef, {
        ...outfit,
        'dateAdded': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // =======================================================================
  // SCHEMA EXPANSION & MIGRATION
  // =======================================================================

  Future<void> migrateWardrobe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wardrobeRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe');

    final snapshot = await wardrobeRef.get();
    if (snapshot.docs.isEmpty) {
        print('Wardrobe is empty, nothing to migrate.');
        return;
    }

    print('Starting migration for ${snapshot.docs.length} items...');
    final batch = _db.batch();
    
    // Dummy Data Generators
    final _random = DateTime.now().millisecondsSinceEpoch;
    int counter = 0;
    
    final brands = ['Zara', 'H&M', 'Nike', 'Adidas', 'Thrifted', 'Vintage'];
    final sizes = ['XS', 'S', 'M', 'L', 'XL'];
    final colors = [
        0xFF000000, 0xFFFFFFFF, 0xFF9E9E9E, // Black, White, Grey
        0xFFE91E63, 0xFF2196F3, 0xFF4CAF50, // Pink, Blue, Green
        0xFFFFC107, 0xFF9C27B0, // Amber, Purple
    ];
    final colorNames = ['Black', 'White', 'Grey', 'Pink', 'Blue', 'Green', 'Yellow', 'Purple'];

    for (var doc in snapshot.docs) {
      counter++;
      // Pseudo-random selection based on doc ID hash
      final hash = doc.id.codeUnits.fold(0, (p, c) => p + c) + _random + counter;
      
      final randomPrice = 10 + (hash % 90); // 10 - 100
      final randomWorn = hash % 25; // 0 - 24
      final randomBrand = brands[hash % brands.length];
      final randomSize = sizes[hash % sizes.length];
      final randomColorIndex = hash % colors.length;
      final randomColor = colors[randomColorIndex];
      final randomColorName = colorNames[randomColorIndex % colorNames.length];
      final isInOutfit = (hash % 3 == 0); // 33% chance

      batch.update(doc.reference, {
        'price': randomPrice.toDouble(),
        'timesWorn': randomWorn,
        'brand': randomBrand,
        'size': randomSize,
        'primaryColor': randomColor, 
        'colorName': randomColorName,
        'isInOutfit': isInOutfit,
        // Ensure other fields exist
        'notes': doc.data().containsKey('notes') ? doc.data()['notes'] : '',
      });
    }

    await batch.commit();
    print('Migration complete: ${snapshot.docs.length} items updated.');
  }

  Future<void> updateClothingItem(String docId, Map<String, dynamic> data) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .doc(docId)
        .update(data);
  }

  Future<void> updateItemInOutfitStatus(List<String> imagePaths, bool status) async {
      // Note: We are finding items by ImageURL or Path because that's what we currently store in outfits['items']
      // ideally outfits should store Item IDs. 
      // For now, we will QUERY the wardrobe for these image paths to find the docs.
      if (uid.isEmpty || imagePaths.isEmpty) return;

      final wardrobeRef = _db.collection('users').doc(uid).collection('wardrobe');
      final batch = _db.batch();
      bool hasUpdates = false;

      // We have to query one by one because 'whereIn' is limited and we might have paths
      for (var path in imagePaths) {
          // Try to match by imageUrl (if remote) or just assume valid matching logic
          // This is a bit fragile if multiple items have same image, but acceptable for MVP
          final q = await wardrobeRef.where('imageUrl', isEqualTo: path).get();
          for (var doc in q.docs) {
              batch.update(doc.reference, {'isInOutfit': status});
              hasUpdates = true;
          }
      }

      if (hasUpdates) {
          await batch.commit();
      }
  }
}
