import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> addClothingItem(Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .add(data);
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

    for (var entry in sampleData.entries) {
      final category = entry.key;
      final assets = entry.value;
      
      // Check if this category has items already
      final catSnapshot = await wardrobeRef
          .where('category', isEqualTo: category)
          .limit(1)
          .get();
          
      if (catSnapshot.docs.isEmpty) {
         for (var assetPath in assets) {
           final docRef = wardrobeRef.doc();
           batch.set(docRef, {
             'imageUrl': assetPath,
             'category': category,
             'dateAdded': FieldValue.serverTimestamp(),
             'isSample': true,
           });
         }
      }
    }

    await batch.commit();
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
}
