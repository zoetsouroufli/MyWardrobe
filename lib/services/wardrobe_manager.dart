import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class WardrobeManager {
  static final WardrobeManager _instance = WardrobeManager._internal();
  factory WardrobeManager() => _instance;
  WardrobeManager._internal();

  List<String> _items = [];

  Future<void> init() async {
    final file = await _getJsonFile();
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        _items = jsonList.cast<String>();
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

  Future<String> saveImagePermanent(String tempPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(tempPath);
    final permPath = p.join(dir.path, fileName);

    // Copy file
    await File(tempPath).copy(permPath);

    // Add to list
    _items.add(permPath);
    await _saveJson();

    return permPath;
  }

  Future<void> _saveJson() async {
    final file = await _getJsonFile();
    await file.writeAsString(json.encode(_items));
  }

  List<String> getItems() => _items;
}
