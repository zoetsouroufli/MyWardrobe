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
              .map(
                (e) => <String, dynamic>{
                  'path': e as String,
                  'category': 'My Uploads',
                },
              )
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
    Map<String, dynamic> metadata = const {},
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(tempPath);
    final permPath = p.join(dir.path, fileName);

    // Copy file
    await File(tempPath).copy(permPath);

    // Add to list
    _items.add(<String, dynamic>{
      'path': permPath,
      'category': category,
      'date': DateTime.now().toIso8601String(),
      'isSynced': false,
      ...metadata, // Spread other fields
    });
    await _saveJson();

    return permPath;
  }

  Future<void> markAsSynced(String path) async {
    final index = _items.indexWhere((element) => element['path'] == path);
    if (index != -1) {
      _items[index]['isSynced'] = true;
      await _saveJson();
    }
  }

  Future<void> updateItem(String path, Map<String, dynamic> updates) async {
    final index = _items.indexWhere((element) => element['path'] == path);
    if (index != -1) {
      _items[index].addAll(updates);
      await _saveJson();
    }
  }

  Future<void> deleteItem(String path) async {
    final index = _items.indexWhere((element) => element['path'] == path);
    if (index != -1) {
      _items.removeAt(index);
      await _saveJson();

      // Delete physical file
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting local file: $e');
      }
    }
  }

  Future<void> _saveJson() async {
    final file = await _getJsonFile();
    await file.writeAsString(json.encode(_items));
  }

  List<Map<String, dynamic>> getItems() => _items;

  List<Map<String, dynamic>> getItemsByCategory(String category) {
    return _items.where((item) => item['category'] == category).toList();
  }
}
