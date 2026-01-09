import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class WardrobeManager {
  static final WardrobeManager _instance = WardrobeManager._internal();
  factory WardrobeManager() => _instance;
  WardrobeManager._internal();

  List<Map<String, dynamic>> _items = [];

  Future<void> init() async {
    final file = await _getJsonFile();
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        // Handle migration: if list of strings, convert to maps
        if (jsonList.isNotEmpty && jsonList.first is String) {
          _items = jsonList
              .map((e) => {'path': e as String, 'category': 'My Uploads'})
              .toList();
        } else {
          _items = jsonList.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        print('Error reading wardrobe json: $e');
        _items = [];
      }
    }
  }

  Future<File> _getJsonFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'wardrobe.json'));
  }

  Future<String> saveImagePermanent(
    String tempPath, {
    required String category,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(tempPath);
    final permPath = p.join(dir.path, fileName);

    // Copy file
    await File(tempPath).copy(permPath);

    // Add to list
    _items.add({
      'path': permPath,
      'category': category,
      'date': DateTime.now().toIso8601String(),
    });
    await _saveJson();

    return permPath;
  }

  Future<void> _saveJson() async {
    final file = await _getJsonFile();
    await file.writeAsString(json.encode(_items));
  }

  List<Map<String, dynamic>> getItems() => _items;

  List<String> getItemsByCategory(String category) {
    return _items
        .where((item) => item['category'] == category)
        .map((item) => item['path'] as String)
        .toList();
  }
}
