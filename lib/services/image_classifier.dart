import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ImageClassifier {
  static final ImageClassifier _instance = ImageClassifier._internal();
  factory ImageClassifier() => _instance;
  ImageClassifier._internal();

  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(
      confidenceThreshold: 0.4,
    ), // Raised back to 0.4
  );

  // Mapping from ML Kit labels to our categories
  final Map<String, String> _labelMap = {
    'Jeans': 'Pants',
    'Trousers': 'Pants',
    'Pants': 'Pants',
    'Shorts': 'Pants',
    'Skirt': 'Pants',
    'Denim': 'Pants', // Common for jeans
    'Chinos': 'Pants',
    'Shirt': 'T-Shirts',
    'T-Shirt': 'T-Shirts',
    'Top': 'T-Shirts',
    'Jersey': 'T-Shirts',
    'Blouse': 'T-Shirts',
    'Polo': 'T-Shirts', // Polo shirt
    'Sweatshirt': 'Hoodies',
    'Hoodie': 'Hoodies',
    'Sweater': 'Hoodies', // Added
    'Pullover': 'Hoodies', // Added
    'Jacket': 'Jackets',
    'Coat': 'Jackets',
    'Blazer': 'Jackets',
    'Overcoat': 'Jackets',
    'Vest': 'Jackets',
    // 'Outerwear': 'Jackets', // REMOVED: Too generic, causes bias
    'Cardigan': 'Jackets',
    'Parka': 'Jackets',
    'Raincoat': 'Jackets',
    'Sock': 'Socks',
    'Socks': 'Socks',
    'Shoe': 'Shoes',
    'Sneaker': 'Shoes',
    'Boot': 'Shoes',
    'Sandal': 'Shoes',
    'Flip-flop': 'Shoes',
    'Footwear': 'Shoes',
    'Heels': 'Shoes',
    'Loafers': 'Shoes',
    'Trainers': 'Shoes',
    'Scarf': 'Accessories',
    'Hat': 'Accessories',
    'Cap': 'Accessories',
    'Glove': 'Accessories',
    'Sunglasses': 'Accessories',
    'Bag': 'Accessories',
    'Handbag': 'Accessories',
    'Backpack': 'Accessories',
    'Tie': 'Accessories',
    'Belt': 'Accessories',
    'Watch': 'Accessories',
  };

  final List<String> _validCategories = [
    'Pants',
    'T-Shirts',
    'Hoodies',
    'Jackets',
    'Socks',
    'Shoes',
    'Accessories',
  ];

  Future<String?> classifyImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await _labeler.processImage(inputImage);

      for (final label in labels) {
        final text = label.label;
        final confidence = label.confidence;
        print('Label: $text, Confidence: $confidence');

        // Check exact match in map
        if (_labelMap.containsKey(text)) {
          return _labelMap[text];
        }

        // Check partial match (e.g. "Blue Jeans")
        for (final key in _labelMap.keys) {
          if (text.contains(key)) {
            return _labelMap[key];
          }
        }
      }
    } catch (e) {
      print('Error classifying image: $e');
    }
    return null; // No match found
  }
}
