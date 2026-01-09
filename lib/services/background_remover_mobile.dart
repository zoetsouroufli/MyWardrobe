import 'dart:io';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class BackgroundRemoverImplementation {
  Future<String?> removeBackground(String imagePath) async {
    final segmenter = SelfieSegmenter(
      mode: SegmenterMode.single,
      enableRawSizeMask: false, // matches Input Image capacity
    );

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      print('Processing image for Selfie Isolation: $imagePath');

      // Calculate Input Image size first to verify mask match
      final originalBytes = await File(imagePath).readAsBytes();
      var originalImg = img.decodeImage(
        originalBytes,
      ); // var because we might update it
      if (originalImg == null) return imagePath;

      // CRITICAL: Bake orientation so pixels match visual (and likely ML Kit's view)
      originalImg = img.bakeOrientation(originalImg);

      final result = await segmenter.processImage(inputImage);

      // Check if result is null (implied by lints)
      if (result == null) {
        print('Error: Selfie Segmentation result is null.');
        return imagePath;
      }

      // SegmentationMask properties might be nullable or result itself?
      // Assuming result is not null if no error thrown.

      final maskWidth = result.width;
      final maskHeight = result.height;
      final confidences = result.confidences;

      print(
        'Mask Size: ${maskWidth}x${maskHeight}, Input: ${originalImg.width}x${originalImg.height}',
      );

      if (maskWidth != originalImg.width || maskHeight != originalImg.height) {
        print(
          'Warning: Mask size differs from Input size. Scaling logic needed but not implemented.',
        );
        // We might proceed if size is close or just return original.
        // Actually, InputImage typically handles rotation, so dimensions might swap.
        // If swapped, we swap originalImg?
        // For now, let's assume strict match or similar.
      }

      // Create new transparent image
      final isolatedImg = img.Image(
        width: originalImg.width,
        height: originalImg.height,
        numChannels: 4,
      );

      // Debug: Check max confidence
      double maxConf = 0.0;
      for (var c in confidences) {
        if (c > maxConf) maxConf = c;
      }
      print('Max Confidence Found: $maxConf');

      // Apply mask
      // confidences is row-major?
      for (int y = 0; y < originalImg.height; y++) {
        for (int x = 0; x < originalImg.width; x++) {
          // If dimensions differ, we need mapping. Assuming 1:1 for now.
          if (x < maskWidth && y < maskHeight) {
            final index = y * maskWidth + x;
            final confidence = confidences[index];

            if (confidence > 0.5) {
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

      final pngBytes = img.encodePng(isolatedImg);
      final tempDir = await getTemporaryDirectory();
      final processedPath =
          '${tempDir.path}/isolated_${DateTime.now().millisecondsSinceEpoch}.png';

      await File(processedPath).writeAsBytes(pngBytes);
      print('Saved Selfie Isolated PNG to: $processedPath');

      segmenter.close();
      return processedPath;
    } catch (e) {
      print('Error isolating background (Selfie): $e');
      segmenter.close();
      return imagePath;
    }
  }
}

BackgroundRemoverImplementation getBackgroundRemoverImplementation() =>
    BackgroundRemoverImplementation();
