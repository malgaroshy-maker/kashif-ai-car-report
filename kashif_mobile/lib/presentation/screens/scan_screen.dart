import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../providers/report_provider.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/molded_rib.dart';

import 'image_preview_screen.dart';

class ScanScreen extends ConsumerStatefulWidget {
  final VoidCallback onReportReady;

  const ScanScreen({super.key, required this.onReportReady});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _picker = ImagePicker();
  final _codesController = TextEditingController();
  final _vinController = TextEditingController();
  bool _showManualInput = false;

  @override
  void dispose() {
    _codesController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 95);
      if (picked != null && mounted) {
        final rawFile = File(picked.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ImagePreviewScreen(
              imageFile: rawFile,
              onConfirm: (enhancedFile) async {
                await ref.read(reportProvider.notifier).scanImage(enhancedFile);
                if (ref.read(reportProvider).report != null && mounted) {
                  widget.onReportReady();
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
        );
      }
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result.isNotEmpty && result.first.path != null) {
        final file = File(result.first.path!);
        await ref.read(reportProvider.notifier).scanPdf(file);
        if (ref.read(reportProvider).report != null && mounted) {
          widget.onReportReady();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في قراءة ملف الـ PDF: $e')),
        );
      }
    }
  }

  Future<void> _submitManual() async {
    final codes = _codesController.text.trim();
    if (codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كود عطل واحد على الأقل مثل: P0102')),
      );
      return;
    }

    final vin = _vinController.text.trim().isNotEmpty ? _vinController.text.trim() : null;
    await ref.read(reportProvider.notifier).scanManual(codes, vin);
    if (ref.read(reportProvider).report != null) {
      widget.onReportReady();
    }
  }

  Future<void> _loadDemo(String sampleId) async {
    await ref.read(reportProvider.notifier).loadDemo(sampleId);
    if (ref.read(reportProvider).report != null) {
      widget.onReportReady();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(reportProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner / Legend Header
          FuseCell(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Icon(
                        Icons.scanner_rounded,
                        color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كاشف AI | فحص أعطال السيارات',
                            style: KashifTypography.arabic(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'تحويل تقارير الفحص إلى مصطلحات الورش الليبية بدقة هندسية',
                            style: KashifTypography.arabic(
                              fontSize: 11,
                              color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const MoldedRib(label: 'طرق إدخال الفحص'),
          const SizedBox(height: 10),

          // Loading state overlay if active
          if (state.isLoading) ...[
            FuseCell(
              backgroundColor: isDark ? const Color(0xFF162432) : const Color(0xFFE8F1FA),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    backgroundColor: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.progressText.isNotEmpty ? state.progressText : 'جاري التحليل والمعالجة بالذكاء الاصطناعي...',
                    textAlign: TextAlign.center,
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Error box
          if (state.errorMessage != null && !state.isLoading) ...[
            FuseCell(
              backgroundColor: isDark ? const Color(0xFF2C1917) : const Color(0xFFFDEEEC),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: KashifTypography.arabic(
                        fontSize: 12,
                        color: isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Primary Capture Action 1: Camera
          FuseCell(
            onTap: state.isLoading ? null : () => _pickImage(ImageSource.camera),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KashifColors.fuse10ATab.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 26,
                    color: isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تصوير شاشة جهاز الفحص بالكاميرا',
                        style: KashifTypography.arabic(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'صوّر شاشة Launch أو Autel أو ThinkDiag مباشرة',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Primary Capture Action 2: PDF Document
          FuseCell(
            onTap: state.isLoading ? null : _pickPdf,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KashifColors.fuse15ATab.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 26,
                    color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رفع تقرير فحص بصيغة PDF',
                        style: KashifTypography.arabic(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'استيراد التقرير الكامل المستخرج من الماسح الضوئي',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Primary Capture Action 3: Gallery Screenshot
          FuseCell(
            onTap: state.isLoading ? null : () => _pickImage(ImageSource.gallery),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KashifColors.fuse30ATab.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 26,
                    color: isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختيار لقطة شاشة من المعرض',
                        style: KashifTypography.arabic(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'اختر صورة لشاشة الفحص محفوظة في الهاتف',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Manual Entry Toggle
          FuseCell(
            onTap: () => setState(() => _showManualInput = !_showManualInput),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  Icons.keyboard_outlined,
                  size: 20,
                  color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  'إدخال يدوي للأكواد ورقم الهيكل (VIN)',
                  style: KashifTypography.arabic(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showManualInput ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                ),
              ],
            ),
          ),

          if (_showManualInput) ...[
            const SizedBox(height: 8),
            FuseCell(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أكواد الأعطال (مفصولة بمسافة أو فاصلة):',
                    style: KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _codesController,
                    style: KashifTypography.mono(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'مثال: P0102, P0113, P0420',
                      hintStyle: KashifTypography.mono(fontSize: 12, color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'رقم الهيكل VIN (اختياري لمطابقة المحرك والقطع):',
                    style: KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _vinController,
                    style: KashifTypography.mono(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'مثال: JTDBR42E309...',
                      hintStyle: KashifTypography.mono(fontSize: 12, color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      onPressed: state.isLoading ? null : _submitManual,
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: Text(
                        'تحليل الأكواد الآن',
                        style: KashifTypography.arabic(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          const MoldedRib(label: 'نماذج فحص جاهزة للتجربة'),
          const SizedBox(height: 10),

          // Quick Demo Scan Buttons
          Row(
            children: [
              Expanded(
                child: FuseCell(
                  onTap: state.isLoading ? null : () => _loadDemo('bmw-528i'),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Icon(Icons.directions_car_filled, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        'BMW 528i',
                        style: KashifTypography.mono(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'عطل شحن وحساسات',
                        style: KashifTypography.arabic(fontSize: 11, color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FuseCell(
                  onTap: state.isLoading ? null : () => _loadDemo('toyota-corolla'),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Icon(Icons.directions_car, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        'Toyota Corolla',
                        style: KashifTypography.mono(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'عطل حساس ماف تفتفة',
                        style: KashifTypography.arabic(fontSize: 11, color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
