import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageEnhancer {
  /// Enhances a workshop scanner screen photo:
  /// - Fixes camera orientation
  /// - Rotates if requested
  /// - Crops to the scanner screen bounding box if specified
  /// - Applies Color Contrast Boost to cut through glass glare & neon reflections
  /// - Scales to optimal OCR resolution (max 1600px)
  /// - Compresses to lightweight JPEG for fast upload on Libyan mobile networks
  static Future<File> processScannerImage({
    required File originalFile,
    bool colorContrastBoost = true,
    int rotateDegrees = 0,
    double? cropLeftPct,
    double? cropTopPct,
    double? cropWidthPct,
    double? cropHeightPct,
  }) async {
    final bytes = await originalFile.readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return originalFile;

    // Fix phone camera EXIF orientation
    image = img.bakeOrientation(image);

    // Rotate if requested
    if (rotateDegrees != 0) {
      image = img.copyRotate(image, angle: rotateDegrees);
    }

    // Crop if percentage coordinates provided
    if (cropLeftPct != null &&
        cropTopPct != null &&
        cropWidthPct != null &&
        cropHeightPct != null &&
        cropWidthPct > 0.1 &&
        cropHeightPct > 0.1) {
      final x = (cropLeftPct * image.width).clamp(0.0, image.width.toDouble()).toInt();
      final y = (cropTopPct * image.height).clamp(0.0, image.height.toDouble()).toInt();
      final w = (cropWidthPct * image.width).clamp(10.0, (image.width - x).toDouble()).toInt();
      final h = (cropHeightPct * image.height).clamp(10.0, (image.height - y).toDouble()).toInt();

      image = img.copyCrop(image, x: x, y: y, width: w, height: h);
    }

    // Color Contrast Boost (enhances text contrast while preserving red/yellow fault colors)
    if (colorContrastBoost) {
      image = img.adjustColor(
        image,
        contrast: 1.28,
        saturation: 1.12,
        gamma: 0.95,
        brightness: 1.02,
      );
    }

    // Scale down to max 1600px for high-speed AI OCR upload without losing detail
    const maxDim = 1600;
    if (image.width > maxDim || image.height > maxDim) {
      if (image.width > image.height) {
        image = img.copyResize(image, width: maxDim, interpolation: img.Interpolation.linear);
      } else {
        image = img.copyResize(image, height: maxDim, interpolation: img.Interpolation.linear);
      }
    }

    // Encode to optimized JPEG
    final compressedBytes = img.encodeJpg(image, quality: 85);

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final enhancedFile = File(
      '${tempDir.path}/kashif_enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await enhancedFile.writeAsBytes(compressedBytes);

    return enhancedFile;
  }
}
