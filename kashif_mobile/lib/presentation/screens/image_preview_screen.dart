import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/image_enhancer.dart';

class ImagePreviewScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String fileName;
  final ValueChanged<Uint8List> onConfirm;

  const ImagePreviewScreen({
    super.key,
    required this.imageBytes,
    required this.fileName,
    required this.onConfirm,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _colorContrastBoost = true;
  int _rotation = 0;
  bool _isProcessing = false;

  // Crop area percentages (0.0 to 1.0)
  final double _cropLeft = 0.05;
  final double _cropTop = 0.05;
  final double _cropWidth = 0.90;
  final double _cropHeight = 0.90;
  bool _isCroppingEnabled = true;

  Future<void> _processAndAnalyze() async {
    setState(() => _isProcessing = true);

    try {
      final processedBytes = await ImageEnhancer.processScannerImageBytes(
        bytes: widget.imageBytes,
        colorContrastBoost: _colorContrastBoost,
        rotateDegrees: _rotation,
        cropLeftPct: _isCroppingEnabled ? _cropLeft : null,
        cropTopPct: _isCroppingEnabled ? _cropTop : null,
        cropWidthPct: _isCroppingEnabled ? _cropWidth : null,
        cropHeightPct: _isCroppingEnabled ? _cropHeight : null,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onConfirm(processedBytes);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء معالجة الصورة: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'معاينة وتحسين صورة شاشة الفحص',
          style: KashifTypography.arabic(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right_rounded),
            tooltip: 'تدوير 90 درجة',
            onPressed: () {
              setState(() {
                _rotation = (_rotation + 90) % 360;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview area with interactive crop frame
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: RotatedBox(
                    quarterTurns: _rotation ~/ 90,
                    child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                  ),
                ),

                // Crop border overlay guide
                if (_isCroppingEnabled)
                  IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: KashifColors.fuse15ATab,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                'إطار شاشة جهاز الفحص',
                                style: KashifTypography.arabic(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 14),
                          Text(
                            'جاري تحسين التباين وضغط الصورة للذكاء الاصطناعي...',
                            style: KashifTypography.arabic(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Control Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131920) : const Color(0xFF1E252D),
              border: const Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Auto-enhance contrast chip
                    FilterChip(
                      selected: _colorContrastBoost,
                      label: Text(
                        'إزالة الانعكاس وتحسين التباين ✨',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _colorContrastBoost
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                      onSelected: (val) =>
                          setState(() => _colorContrastBoost = val),
                      selectedColor: KashifColors.fuse15AInkDark,
                      backgroundColor: Colors.white10,
                      checkmarkColor: Colors.white,
                    ),

                    // Toggle crop frame
                    FilterChip(
                      selected: _isCroppingEnabled,
                      label: Text(
                        'تحديد الشاشة',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isCroppingEnabled
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                      onSelected: (val) =>
                          setState(() => _isCroppingEnabled = val),
                      selectedColor: KashifColors.fuse20AInkDark,
                      backgroundColor: Colors.white10,
                      checkmarkColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Confirm and Analyze Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KashifColors.fuse30AInkLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: _isProcessing ? null : _processAndAnalyze,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      'تحليل التقرير بالذكاء الاصطناعي',
                      style: KashifTypography.arabic(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
