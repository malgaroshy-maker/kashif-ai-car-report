// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final inputPath = r'C:\Users\Administrator\.gemini\antigravity-ide\brain\30bbd297-517b-4df7-8174-9529b6e2efed\.user_uploaded\media_1790814026328.jpg';
  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    print('Error: Input file does not exist at $inputPath');
    exit(1);
  }

  final bytes = inputFile.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Error: Failed to decode image');
    exit(1);
  }

  print('Decoded source image: ${image.width}x${image.height}');

  // 1. Save main high-res app icon in assets/images/app_icon.png (1024x1024)
  final highRes = img.copyResize(image, width: 1024, height: 1024, interpolation: img.Interpolation.cubic);
  final highResPng = img.encodePng(highRes);
  File('assets/images/app_icon.png').writeAsBytesSync(highResPng);
  print('Saved assets/images/app_icon.png (1024x1024)');

  // 2. Android Mipmaps
  final mipmaps = {
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  };

  for (final entry in mipmaps.entries) {
    final resized = img.copyResize(image, width: entry.value, height: entry.value, interpolation: img.Interpolation.cubic);
    final pngBytes = img.encodePng(resized);
    final f = File(entry.key);
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(pngBytes);
    print('Generated ${entry.key} (${entry.value}x${entry.value})');
  }

  // 3. Web icons
  final webIcons = {
    'web/favicon.png': 64,
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
  };

  for (final entry in webIcons.entries) {
    final resized = img.copyResize(image, width: entry.value, height: entry.value, interpolation: img.Interpolation.cubic);
    final pngBytes = img.encodePng(resized);
    final f = File(entry.key);
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(pngBytes);
    print('Generated ${entry.key} (${entry.value}x${entry.value})');
  }

  print('All icons successfully updated!');
}
