import 'dart:io';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class BackgroundRemoverImplementation {
  Future<String?> removeBackground(String imagePath) async {
    // 1. Create Segmenter
    final options = SubjectSegmenterOptions(
      enableForegroundConfidenceMask: true,
      enableForegroundBitmap: false,
      enableMultipleSubjects: SubjectResultOptions(
        enableConfidenceMask: false,
        enableSubjectBitmap: false,
      ),
    );
    final segmenter = SubjectSegmenter(options: options);

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      print('Processing image for Subject Isolation: $imagePath');

      // 2. Load Original Image for comparison & saving
      final originalBytes = await File(imagePath).readAsBytes();
      var originalImg = img.decodeImage(originalBytes);
      if (originalImg == null) return imagePath;

      // CRITICAL: Bake orientation so pixels match
      originalImg = img.bakeOrientation(originalImg);

      // 3. Process
      final result = await segmenter.processImage(inputImage);

      // 4. Get Mask
      // v0.0.2 returns List<double> directly for foregroundConfidenceMask
      final confidences = result.foregroundConfidenceMask;
      if (confidences == null) {
        print('Error: Subject Segmentation mask is null.');
        return imagePath;
      }

      // Assumption: Mask matches Input Image Size
      final maskWidth = originalImg.width;
      final maskHeight = originalImg.height;

      print(
        'Mask Size assumed: ${maskWidth}x${maskHeight}, Input: ${originalImg.width}x${originalImg.height}',
      );

      // 5. Create New Transparent Image
      final isolatedImg = img.Image(
        width: originalImg.width,
        height: originalImg.height,
        numChannels: 4,
      );

      // 6. Apply Mask to Original Pixels
      for (int y = 0; y < originalImg.height; y++) {
        for (int x = 0; x < originalImg.width; x++) {
          final index = y * maskWidth + x;

          if (index < confidences.length) {
            final confidence = confidences[index];
            // Threshold 0.4
            if (confidence > 0.4) {
              isolatedImg.setPixel(x, y, originalImg.getPixel(x, y));
            } else {
              isolatedImg.setPixel(
                x,
                y,
                img.ColorFloat16.rgba(0, 0, 0, 0),
              ); // Transparent
            }
          }
        }
      }

      // 7. Save Result
      final pngBytes = img.encodePng(isolatedImg);
      final tempDir = await getTemporaryDirectory();
      final processedPath =
          '${tempDir.path}/isolated_${DateTime.now().millisecondsSinceEpoch}.png';

      await File(processedPath).writeAsBytes(pngBytes);
      print('Saved Subject Isolated PNG to: $processedPath');

      segmenter.close();
      return processedPath;
    } catch (e) {
      print('Error isolating background (Subject): $e');
      segmenter.close();
      return imagePath;
    }
  }
}

BackgroundRemoverImplementation getBackgroundRemoverImplementation() =>
    BackgroundRemoverImplementation();
