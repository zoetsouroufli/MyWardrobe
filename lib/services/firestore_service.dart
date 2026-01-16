import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart'; // ML Kit
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart'
    show rootBundle, AssetManifest; // For accessing assets on web
import 'dart:convert'; // For jsonDecode
import 'dart:math'; // For random

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // New Method for Bulk Upload from Assets
  Future<void> uploadDummyDataFromAssets() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      print("Starting bulk upload...");

      List<String> imagePaths = [];
      try {
        // Try modern AssetManifest API first (Flutter 3.10+)
        // Note: AssetManifest class might not be available in older SDKs, so we keep the json fallback
        final manifestContent = await rootBundle.loadString(
          'AssetManifest.json',
        );
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        imagePaths = manifestMap.keys
            .where((String key) => key.contains('assets/dummytest/'))
            .toList();
      } catch (e) {
        print("AssetManifest.json load failed: $e");
        // Fallback: Try AssetManifest.bin.json (sometimes used in web release)
        try {
          final manifestContent = await rootBundle.loadString(
            'assets/AssetManifest.bin.json',
          );
          // Parsing binary json is harder here, skipping for now.
          print(
            "Attempting to handle AssetManifest.bin.json - Not Implemented",
          );
        } catch (e2) {
          print("All manifest loads failed.");
        }
      }

      if (imagePaths.isEmpty) {
        print(
          "No images found in assets/dummytest via Manifest. Using HARDCODED FALLBACK.",
        );
        imagePaths = _dummyAssets.map((f) => 'assets/dummytest/$f').toList();
      }

      if (imagePaths.isEmpty) {
        print("Fallback failed too. No images.");
        return;
      }

      print("Found ${imagePaths.length} images to upload...");

      final random = Random();

      // Initialize Image Labeler (only works on Mobile/Desktop, NOT Web)
      // Check platform or catch errors
      dynamic labeler;
      if (!kIsWeb) {
        // We utilize reflection or dynamic import if possible, but here we assume the package is imported
        // We need to import: import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
      }

      int count = 0;
      for (var assetPath in imagePaths) {
        final fileName = assetPath.split('/').last;

        // 3. Load asset as bytes (Try multiple path formats for Web compatibility)
        ByteData byteData;
        String storagePathName = fileName;

        try {
          byteData = await rootBundle.load(assetPath);
        } catch (e1) {
          // If "assets/dummytest/..." failed, try "dummytest/..." (strip leading assets/)
          if (assetPath.startsWith('assets/')) {
            final tempPath = assetPath.replaceFirst('assets/', '');
            try {
              print("Retrying load with path: $tempPath");
              byteData = await rootBundle.load(tempPath);
              storagePathName = tempPath.split('/').last;
            } catch (e2) {
              // Try adding it back if it was missing? No, error showed double assets.
              print("Failed to load $assetPath or $tempPath. Skipping.");
              continue;
            }
          } else {
            print("Failed to load $assetPath. Skipping.");
            continue;
          }
        }

        final bytes = byteData.buffer.asUint8List();

        // 4. Upload to Storage
        final storageRef = _storage.ref().child(
          'users/${user.uid}/wardrobe/dummy_${DateTime.now().millisecondsSinceEpoch}_$storagePathName',
        );

        final uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // 5. DETERMINE CATEGORY (RANDOM as requested)
        final fallbackCategories = [
          'Pants',
          'T-Shirts',
          'Hoodies',
          'Jackets',
          'Socks',
          'Shoes',
          'Accessories',
        ];
        String category = fallbackCategories[count % fallbackCategories.length];

        // Remove ML Kit logic for now to ensure stability on Web
        /*
         if (!kIsWeb) {
             // ... ML Kit Code ...
         }
         */

        // Random metadata for visual flair
        final brands = [
          'Nike',
          'Adidas',
          'Zara',
          'H&M',
          'Uniqlo',
          'Gucci',
          'Gap',
        ];
        final colors = [
          'Red',
          'Blue',
          'Black',
          'White',
          'Green',
          'Yellow',
          'Grey',
        ];
        final sizes = ['S', 'M', 'L', 'XL'];

        await _db.collection('users').doc(user.uid).collection('wardrobe').add({
          'imageUrl': downloadUrl,
          'category': category,
          'dateAdded': FieldValue.serverTimestamp(),
          'monthAdded': random.nextInt(12) + 1, // Random Month 1-12 (New Field)
          'isInOutfit': false,
          'timesWorn': random.nextInt(20),
          'brand': brands[random.nextInt(brands.length)],
          'price': (10 + random.nextDouble() * 140).roundToDouble(),
          'size': sizes[random.nextInt(sizes.length)],
          'colorName': colors[random.nextInt(colors.length)],
          'primaryColor': 0xFF000000 | random.nextInt(0xFFFFFF),
          'notes': 'Imported from dummy data',
        });

        print("Uploaded $fileName as $category");
        count++;
      }
      print("Batch upload complete! Uploaded $count items.");
    } catch (e) {
      print("Error uploading dummy data: $e");
    }
  }

  Future<String> uploadImage(File file) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not logged in';

    final fileName = p.basename(file.path);
    // Use timestamp to prevent duplicates / conflicts
    final storagePath =
        'users/${user.uid}/wardrobe/img_${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final ref = _storage.ref().child(storagePath);

    // Read bytes directly to avoid File locking/path issues and metadata complexity
    print('Reading bytes from $fileName...');
    final bytes = await file.readAsBytes();

    print('Starting upload (putData) of ${bytes.length} bytes to $storagePath');
    final task = ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    // Force jpeg for consistency, or detect based on extension if needed.
    // Usually 'image/jpeg' works fine for png too in display, but for correctness let's guess.

    final snapshot = await task;
    print(
      'Upload Task Finished. State: ${snapshot.state}, Bytes: ${snapshot.bytesTransferred}/${snapshot.totalBytes}',
    );

    if (snapshot.state != TaskState.success) {
      throw 'Upload failed with state: ${snapshot.state}';
    }

    // Small delay
    await Future.delayed(const Duration(milliseconds: 500));

    return await snapshot.ref.getDownloadURL();
  }

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> seedDummyUsers() async {
    try {
      final batch = _db.batch();

      final dummyUsers = [
        {
          'uid': 'dummy_user_1',
          'username': 'testuser',
          'name': 'Test User',
          'description': 'I am a test user for searching.',
          'email': 'test@example.com',
          'avatarUrl': 'assets/friend1.jpg',
        },
        {
          'uid': 'dummy_user_2',
          'username': 'anna_fashion',
          'name': 'Anna K.',
          'description': 'Lover of vintage style.',
          'email': 'anna@example.com',
          'avatarUrl': 'assets/friend2.jpg',
        },
        {
          'uid': 'dummy_user_3',
          'username': 'giorgos99',
          'name': 'Giorgos P.',
          'description': 'Minimalist wardrobe.',
          'email': 'giorgos@example.com',
          'avatarUrl': 'assets/friend3.jpg',
        },
        {
          'uid': 'dummy_user_4',
          'username': 'maria_style',
          'name': 'Maria S.',
          'description': 'Colorful outfits only!',
          'email': 'maria@example.com',
          'avatarUrl':
              'assets/friend5.jpg', // Assuming friend5 exists or reusing
        },
      ];

      for (var u in dummyUsers) {
        final docRef = _db.collection('users').doc(u['uid']);
        batch.set(docRef, u);
      }

      await batch.commit();
      print('Dummy users created!');
    } catch (e) {
      print('Error seeding dummy users: $e');
      rethrow; // Pass error to UI
    }
  }

  // Follow a user
  Future<void> followUser(
    String targetUid,
    Map<String, dynamic> friendData,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Add to 'friends' sub-collection
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(targetUid)
        .set({
          'friendId': targetUid,
          'username': friendData['username'],
          'name': friendData['name'] ?? friendData['username'],
          'avatarUrl': friendData['avatarUrl'] ?? 'assets/friend1.jpg',
          'dateAdded': FieldValue.serverTimestamp(),
        });
  }

  // Unfollow a user
  Future<void> unfollowUser(String targetUid) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(targetUid)
        .delete();
  }

  // Check if following
  Stream<bool> isFollowing(String targetUid) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(targetUid)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> addClothingItem(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('wardrobe').add({
      // Default Schema Values
      'timesWorn': 0,
      'price': 0.0,
      'size': 'M',
      'primaryColor': 0xFF000000,
      'colorName': '',
      'isInOutfit': false,

      ...data, // User data overrides defaults
    });
  }

  Future<void> deleteClothingItem(String docId, {String? imageUrl}) async {
    if (uid.isEmpty) return;

    // 1. Delete Firestore Document
    await _db
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .doc(docId)
        .delete();

    // 2. Delete Storage Image (if remote)
    if (imageUrl != null && imageUrl.startsWith('http')) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        print(
          'Error deleting image from storage: $e',
        ); // Likely object-not-found or similar
      }
    }
  }

  Future<void> seedSampleData() async {
    final wardrobeRef = _db.collection('users').doc(uid).collection('wardrobe');

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
      'Socks': ['assets/zoe-socks.png'],
      'Accessories': ['assets/zoe-hat.png', 'assets/outfit_cap.jpg'],
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

  // =======================================================================
  // BACKUP & RESTORE SYSTEM
  // =======================================================================

  Future<void> exportWardrobeToBackup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wardrobeRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe');
    final backupRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe_backup');

    final snapshot = await wardrobeRef.get();
    if (snapshot.docs.isEmpty) {
      print('Wardrobe is empty, nothing to backup.');
      return;
    }

    // Clear existing backup first
    final existingBackup = await backupRef.get();
    final deleteBatch = _db.batch();
    for (var doc in existingBackup.docs) {
      deleteBatch.delete(doc.reference);
    }
    await deleteBatch.commit();

    // Copy all items to backup
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      data['backupTimestamp'] = FieldValue.serverTimestamp();
      data['originalId'] = doc.id;
      batch.set(backupRef.doc(), data);
    }

    await batch.commit();
    print('Backup complete: ${snapshot.docs.length} items saved.');
  }

  Future<void> restoreFromBackupWithMLKit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final backupRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe_backup');
    final wardrobeRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe');

    final snapshot = await backupRef.get();
    if (snapshot.docs.isEmpty) {
      print('No backup found.');
      return;
    }

    print('Restoring ${snapshot.docs.length} items from backup...');

    // Initialize ML Kit (mobile only)
    ImageLabeler? labeler;
    if (!kIsWeb) {
      try {
        final options = ImageLabelerOptions(confidenceThreshold: 0.5);
        labeler = ImageLabeler(options: options);
      } catch (e) {
        print('ML Kit initialization failed: $e');
      }
    }

    int count = 0;
    for (var doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      data.remove('backupTimestamp');
      data.remove('originalId');

      String category = data['category'] ?? 'Other';
      final imageUrl = data['imageUrl'] as String?;

      // Try ML Kit re-categorization on mobile
      if (labeler != null && imageUrl != null && imageUrl.startsWith('http')) {
        try {
          // Download image temporarily for ML Kit processing
          // This is a simplified version - in production you'd want better error handling
          final response = await _storage.refFromURL(imageUrl).getData();
          if (response != null) {
            final tempFile = File(
              '${Directory.systemTemp.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            await tempFile.writeAsBytes(response);

            final inputImage = InputImage.fromFile(tempFile);
            final labels = await labeler.processImage(inputImage);

            // Map ML Kit labels to categories
            for (var label in labels) {
              final text = label.label.toLowerCase();
              if (text.contains('pant') ||
                  text.contains('jean') ||
                  text.contains('trouser')) {
                category = 'Pants';
                break;
              } else if (text.contains('shirt') || text.contains('top')) {
                category = 'T-Shirts';
                break;
              } else if (text.contains('jacket') || text.contains('coat')) {
                category = 'Jackets';
                break;
              } else if (text.contains('shoe') || text.contains('footwear')) {
                category = 'Shoes';
                break;
              } else if (text.contains('sweater') || text.contains('hoodie')) {
                category = 'Hoodies';
                break;
              }
            }

            await tempFile.delete();
          }
        } catch (e) {
          print('ML Kit processing failed for item: $e');
        }
      }

      data['category'] = category;
      data['dateAdded'] = FieldValue.serverTimestamp();

      await wardrobeRef.add(data);
      count++;

      if (count % 10 == 0) {
        print('Restored $count/${snapshot.docs.length} items...');
      }
    }

    if (labeler != null) {
      labeler.close();
    }

    print('Restore complete: $count items restored.');
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
      batch.set(docRef, {...outfit, 'dateAdded': FieldValue.serverTimestamp()});
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
      batch.set(docRef, {...outfit, 'dateAdded': FieldValue.serverTimestamp()});
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
    final colorNames = [
      'Black',
      'White',
      'Grey',
      'Pink',
      'Blue',
      'Green',
      'Yellow',
      'Purple',
    ];

    for (var doc in snapshot.docs) {
      counter++;
      // Pseudo-random selection based on doc ID hash
      final hash =
          doc.id.codeUnits.fold(0, (p, c) => p + c) + _random + counter;

      final data = doc.data();

      // 1. Backfill Category if missing
      String currentCategory = (data['category'] ?? '').toString();
      if (currentCategory.isEmpty) {
        currentCategory = 'Other';
      }

      // 2. Backfill DateAdded if missing
      // We'll use a slightly randomized past timestamp if it's missing so they don't all look identical
      FieldValue? dateAddedUpdate;
      if (!data.containsKey('dateAdded') || data['dateAdded'] == null) {
        dateAddedUpdate = FieldValue.serverTimestamp();
      }

      final randomPrice = 10 + (hash % 90); // 10 - 100
      final randomWorn = hash % 25; // 0 - 24
      final randomBrand = brands[hash % brands.length];
      final randomSize = sizes[hash % sizes.length];
      final randomColorIndex = hash % colors.length;
      final randomColor = colors[randomColorIndex];
      final randomColorName = colorNames[randomColorIndex % colorNames.length];
      final isInOutfit = (hash % 3 == 0); // 33% chance

      final updateData = {
        'price': (data['price'] ?? randomPrice).toDouble(),
        'timesWorn': data['timesWorn'] ?? randomWorn,
        'brand': data['brand'] ?? randomBrand,
        'size': data['size'] ?? randomSize,
        'primaryColor': data['primaryColor'] ?? randomColor,
        'colorName': data['colorName'] ?? randomColorName,
        'isInOutfit': data['isInOutfit'] ?? isInOutfit,
        'category': currentCategory, // Ensure valid category
        'notes': data['notes'] ?? '',
      };

      if (dateAddedUpdate != null) {
        updateData['dateAdded'] = dateAddedUpdate;
        updateData['monthAdded'] = DateTime.now().month; // Approximate
      }

      batch.update(doc.reference, updateData);
    }

    await batch.commit();
    print(
      'Migration from existing wardrobe complete: ${snapshot.docs.length} items updated.',
    );

    // =========================================================================
    // PART 2: GHOST ITEM RECOVERY
    // Scan all outfits to find items that don't exist in the wardrobe anymore
    // =========================================================================

    final outfitsSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('outfits')
        .get();

    final wardrobeSnapshotForCheck = await wardrobeRef.get();
    final Set<String> existingImageUrls = wardrobeSnapshotForCheck.docs
        .map((d) => (d.data()['imageUrl'] as String?) ?? '')
        .toSet();

    final batch2 = _db.batch();
    int recoveredCount = 0;

    for (var outfitDoc in outfitsSnapshot.docs) {
      final items = outfitDoc.data()['items'] as List<dynamic>?;
      if (items == null) continue;

      for (var itemPath in items) {
        final path = itemPath.toString();
        // If this image path is NOT in our wardrobe, we need to recover it
        if (path.isNotEmpty && !existingImageUrls.contains(path)) {
          // Create a new doc
          final newDocRef = wardrobeRef.doc();

          // Enhanced category detection based on filename/URL keywords
          String recoveredCategory = 'Accessories'; // Default fallback
          final pathLower = path.toLowerCase();

          if (pathLower.contains('pant') ||
              pathLower.contains('jean') ||
              pathLower.contains('short') ||
              pathLower.contains('trouser')) {
            recoveredCategory = 'Pants';
          } else if (pathLower.contains('shirt') ||
              pathLower.contains('tee') ||
              pathLower.contains('top') ||
              pathLower.contains('blouse')) {
            recoveredCategory = 'T-Shirts';
          } else if (pathLower.contains('sweater') ||
              pathLower.contains('hoodie') ||
              pathLower.contains('pullover') ||
              pathLower.contains('sweatshirt')) {
            recoveredCategory = 'Hoodies';
          } else if (pathLower.contains('jacket') ||
              pathLower.contains('coat') ||
              pathLower.contains('blazer')) {
            recoveredCategory = 'Jackets';
          } else if (pathLower.contains('shoe') ||
              pathLower.contains('sneaker') ||
              pathLower.contains('boot') ||
              pathLower.contains('sandal')) {
            recoveredCategory = 'Shoes';
          } else if (pathLower.contains('sock')) {
            recoveredCategory = 'Socks';
          }

          batch2.set(newDocRef, {
            'imageUrl': path,
            'category': recoveredCategory,
            'dateAdded': FieldValue.serverTimestamp(),
            'monthAdded': DateTime.now().month,
            'isInOutfit': true,
            'price': 0,
            'notes': 'Auto-recovered from outfit',
            'timesWorn': 1,
            'brand': 'Unknown',
            'size': 'M',
            'primaryColor': 0xFF9E9E9E,
            'colorName': 'Grey',
          });

          // Add to set to prevent duplicate recovery in same run
          existingImageUrls.add(path);
          recoveredCount++;
        }
      }
    }

    if (recoveredCount > 0) {
      await batch2.commit();
      print('Recovered $recoveredCount ghost items from outfits!');
    }

    // =========================================================================
    // PART 3: CLEANUP & RECATEGORIZATION
    // Fix existing "Recovered" items and remove invalid paths on Web
    // =========================================================================

    final finalSnapshot = await wardrobeRef.get();
    final batch3 = _db.batch();
    int recategorizedCount = 0;
    int deletedCount = 0;

    for (var doc in finalSnapshot.docs) {
      final data = doc.data();
      final category = (data['category'] ?? '').toString();
      final imageUrl = (data['imageUrl'] ?? '').toString();

      // Delete items with invalid paths on Web (local file paths)
      if (kIsWeb &&
          imageUrl.isNotEmpty &&
          !imageUrl.startsWith('http') &&
          !imageUrl.startsWith('assets/') &&
          !imageUrl.startsWith('blob:')) {
        batch3.delete(doc.reference);
        deletedCount++;
        continue;
      }

      // Recategorize items still marked as "Recovered"
      if (category == 'Recovered') {
        String newCategory = 'Accessories';
        final pathLower = imageUrl.toLowerCase();

        if (pathLower.contains('pant') ||
            pathLower.contains('jean') ||
            pathLower.contains('short') ||
            pathLower.contains('trouser')) {
          newCategory = 'Pants';
        } else if (pathLower.contains('shirt') ||
            pathLower.contains('tee') ||
            pathLower.contains('top') ||
            pathLower.contains('blouse')) {
          newCategory = 'T-Shirts';
        } else if (pathLower.contains('sweater') ||
            pathLower.contains('hoodie') ||
            pathLower.contains('pullover') ||
            pathLower.contains('sweatshirt')) {
          newCategory = 'Hoodies';
        } else if (pathLower.contains('jacket') ||
            pathLower.contains('coat') ||
            pathLower.contains('blazer')) {
          newCategory = 'Jackets';
        } else if (pathLower.contains('shoe') ||
            pathLower.contains('sneaker') ||
            pathLower.contains('boot') ||
            pathLower.contains('sandal')) {
          newCategory = 'Shoes';
        } else if (pathLower.contains('sock')) {
          newCategory = 'Socks';
        }

        batch3.update(doc.reference, {'category': newCategory});
        recategorizedCount++;
      }
    }

    if (recategorizedCount > 0 || deletedCount > 0) {
      await batch3.commit();
      if (recategorizedCount > 0)
        print('Recategorized $recategorizedCount "Recovered" items.');
      if (deletedCount > 0)
        print('Deleted $deletedCount invalid items (Web incompatible paths).');
    }
  }

  Future<void> updateClothingItem(
    String docId,
    Map<String, dynamic> data,
  ) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .doc(docId)
        .update(data);
  }

  Future<void> updateItemInOutfitStatus(
    List<String> imagePaths,
    bool status,
  ) async {
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

  // HARDCODED FALLBACK LIST (Generated for Web Compatibility)
  static const List<String> _dummyAssets = [
    "00304426422-e1.jpg",
    "00526403712-e1.jpg",
    "00653277800-e1.jpg",
    "00761411898-e1.jpg",
    "00962400400-e1.jpg",
    "00962406791-e1.jpg",
    "00993401801-e1.jpg",
    "01131860611-e1.jpg",
    "01437360922-e1.jpg",
    "01608426505-e1.jpg",
    "01608436505-e1.jpg",
    "01732401615-e1.jpg",
    "01758211710-e1.jpg",
    "01758654800-e1.jpg",
    "01856004808-e1.jpg",
    "01887324600-e1.jpg",
    "02335059615-e1.jpg",
    "02335559812-e1.jpg",
    "02750408760-000-e1.jpg",
    "03046540401-e1.jpg",
    "03152570753-e2.jpg",
    "03166323627-e1.jpg",
    "03334203717-e1.jpg",
    "03334302529-e1.jpg",
    "03443374420-e1.jpg",
    "03641873669-e1.jpg",
    "03739024700-e1.jpg",
    "03739032832-e1.jpg",
    "03739315802-e1.jpg",
    "03920008600-e1.jpg",
    "03920015300-e1.jpg",
    "03920405922-e1.jpg",
    "03920765800-e1.jpg",
    "03992386555-e1.jpg",
    "03992403555-e1.jpg",
    "04027400800-e1.jpg",
    "04048377427-e1.jpg",
    "04048400822-e1.jpg",
    "04174026803-e1.jpg",
    "04174687803-e1.jpg",
    "04201306800-e2.jpg",
    "04231309803-e1.jpg",
    "04387590800-e1.jpg",
    "04547405555-e2.jpg",
    "04644002620-e1.jpg",
    "04695900800-e1.jpg",
    "05039836104-e1.jpg",
    "05536001681-e1.jpg",
    "05644812620-e1.jpg",
    "05755155515-e1.jpg",
    "05854810545-e1.jpg",
    "06224280700-e1.jpg",
    "06907407800-e1.jpg",
    "07484303401-e1.jpg",
    "07677627405-e1.jpg",
    "08062330407-e1.jpg",
    "08281289800-e1.jpg",
    "08975071506-e1.jpg",
    "09198651712-e1.jpg",
    "09819671605-e1.jpg",
    "11000710800-e2.jpg",
    "11500710022-e2.jpg",
    "12051620800-e1.jpg",
    "12105620802-e2.jpg",
    "12384620500-e1.jpg",
    "12418620800-e1.jpg",
    "12422620800-e1.jpg",
    "12500710107-e2.jpg",
    "15030610800-e1.jpg",
    "15213710800-e2.jpg",
  ];
}
