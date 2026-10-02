import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../data/storage/hive_storage.dart';

class ImageEnhancer {
  /// Enhances a workshop scanner screen photo:
  /// - Fixes camera orientation
  /// - Rotates if requested
  /// - Crops to the scanner screen bounding box if specified
  /// - Applies Color Contrast Boost to cut through glass glare & neon reflections
  /// - Scales to optimal OCR resolution (800px in token saver mode, 1600px standard)
  /// - Compresses to lightweight JPEG for fast upload on mobile and web networks
  static Future<Uint8List> processScannerImageBytes({
    required Uint8List bytes,
    bool colorContrastBoost = true,
    int rotateDegrees = 0,
    double? cropLeftPct,
    double? cropTopPct,
    double? cropWidthPct,
    double? cropHeightPct,
  }) async {
    var image = img.decodeImage(bytes);
    if (image == null) return bytes;

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
      final x = (cropLeftPct * image.width)
          .clamp(0.0, image.width.toDouble())
          .toInt();
      final y = (cropTopPct * image.height)
          .clamp(0.0, image.height.toDouble())
          .toInt();
      final w = (cropWidthPct * image.width)
          .clamp(10.0, (image.width - x).toDouble())
          .toInt();
      final h = (cropHeightPct * image.height)
          .clamp(10.0, (image.height - y).toDouble())
          .toInt();

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

    // Scale down for AI OCR upload: 800px in Saver mode (saves ~85% Base64 tokens), 1600px standard
    final isSaver = KashifStorage.isTokenSaverEnabled;
    final maxDim = isSaver ? 800 : 1600;
    if (image.width > maxDim || image.height > maxDim) {
      if (image.width > image.height) {
        image = img.copyResize(
          image,
          width: maxDim,
          interpolation: img.Interpolation.linear,
        );
      } else {
        image = img.copyResize(
          image,
          height: maxDim,
          interpolation: img.Interpolation.linear,
        );
      }
    }

    // Encode to optimized JPEG (quality 60 in Saver mode cuts Base64 payload dramatically)
    final quality = isSaver ? 60 : 85;
    final compressedBytes = img.encodeJpg(image, quality: quality);
    return Uint8List.fromList(compressedBytes);
  }
}
