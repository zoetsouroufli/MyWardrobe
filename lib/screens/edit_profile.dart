import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../widgets/back_button.dart';
import '../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _usernameController.text = data['username'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _currentAvatarUrl = data['avatarUrl'];
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      String? newAvatarUrl = _currentAvatarUrl;

      // 1. Upload new image if selected
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(uid)
            .child('profile_pic.jpg');

        await ref.putFile(_imageFile!);
        newAvatarUrl = await ref.getDownloadURL();
      }

      // 2. Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': _usernameController.text.trim(),
        'description': _descriptionController.text.trim(),
        if (newAvatarUrl != null) 'avatarUrl': newAvatarUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BackButtonCircle(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Image.asset(
                    'assets/MyWardrobe.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ===== FORM CARD =====
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: const Color(0xFFD01FE8),
                    width: 1.5,
                  ), // Purple border
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            // Handle bar
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD01FE8), // Purple handle
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Profile Picture Picker
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: _imageFile != null
                                        ? FileImage(_imageFile!)
                                        : (_currentAvatarUrl != null
                                                  ? NetworkImage(
                                                      _currentAvatarUrl!,
                                                    )
                                                  : null)
                                              as ImageProvider?,
                                    child:
                                        (_imageFile == null &&
                                            _currentAvatarUrl == null)
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD01FE8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Change profile picture',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 30),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // New Username
                                  const Text(
                                    'new username',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _usernameController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // New Description
                                  const Text(
                                    'new description',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _descriptionController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // Ready Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveUserData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF8B00FF,
                                        ), // Strong Purple
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Ready',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Migration / Debug Button
                                  TextButton.icon(
                                    onPressed: () async {
                                      setState(() => _isLoading = true);
                                      try {
                                        await FirestoreService().migrateWardrobe();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Legacy data fixed! Check Categories now.')),
                                          );
                                        }
                                      } catch (e) {
                                         if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: $e')),
                                          );
                                        }
                                      } finally {
                                        if (mounted) setState(() => _isLoading = false);
                                      }
                                    }, 
                                    icon: const Icon(Icons.build, color: Colors.grey),
                                    label: const Text('Fix Legacy Data', style: TextStyle(color: Colors.grey)),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Backup & Clear Button
                                  TextButton.icon(
                                    onPressed: () async {
                                      // Confirm dialog
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Backup & Clear Wardrobe'),
                                          content: const Text(
                                            'This will:\n'
                                            '1. Save all items to backup\n'
                                            '2. Clear your wardrobe\n\n'
                                            'You can restore later with ML Kit auto-categories.\n\n'
                                            'Continue?'
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Backup & Clear', style: TextStyle(color: Colors.orange)),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirm != true) return;
                                      
                                      setState(() => _isLoading = true);
                                      try {
                                        await FirestoreService().exportWardrobeToBackup();
                                        await FirestoreService().clearWardrobe();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('✅ Backup saved & wardrobe cleared!')),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: $e')),
                                          );
                                        }
                                      } finally {
                                        if (mounted) setState(() => _isLoading = false);
                                      }
                                    },
                                    icon: const Icon(Icons.backup, color: Colors.orange),
                                    label: const Text('Backup & Clear Wardrobe', style: TextStyle(color: Colors.orange)),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Restore with ML Kit Button
                                  TextButton.icon(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Restore from Backup'),
                                          content: Text(
                                            kIsWeb 
                                              ? 'This will restore items from backup.\n\n'
                                                '⚠️ ML Kit auto-categorization only works on mobile.'
                                              : 'This will restore items from backup.\n\n'
                                                '🤖 ML Kit will auto-detect categories on mobile!'
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Restore', style: TextStyle(color: Colors.green)),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirm != true) return;
                                      
                                      setState(() => _isLoading = true);
                                      try {
                                        await FirestoreService().restoreFromBackupWithMLKit();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('✅ Wardrobe restored!')),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: $e')),
                                          );
                                        }
                                      } finally {
                                        if (mounted) setState(() => _isLoading = false);
                                      }
                                    },
                                    icon: const Icon(Icons.restore, color: Colors.green),
                                    label: const Text('Restore with ML Kit', style: TextStyle(color: Colors.green)),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
