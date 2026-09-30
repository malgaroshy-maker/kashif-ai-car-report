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
import 'settings_screen.dart';
import 'dashboard_lights_screen.dart';
import 'fuse_box_screen.dart';
import 'history_screen.dart';

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

  DateTime? _lastActionTime;

  bool _isDebounced() {
    final now = DateTime.now();
    if (_lastActionTime != null &&
        now.difference(_lastActionTime!).inMilliseconds < 1200) {
      return true;
    }
    _lastActionTime = now;
    return false;
  }

  void _checkAndShowCacheNotice() {
    final state = ref.read(reportProvider);
    if (state.cacheNotice != null && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          backgroundColor: const Color(0xFF152A1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF2E9E5B), width: 1),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.offline_bolt_rounded,
                color: Colors.greenAccent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.cacheNotice!,
                  style: KashifTypography.arabic(
                    fontSize: 11.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'إعادة الفحص بالـ AI',
            textColor: Colors.amberAccent,
            onPressed: () {
              ref.read(reportProvider.notifier).reAnalyzeCurrentWithAi();
            },
          ),
        ),
      );
      ref.read(reportProvider.notifier).clearCacheNotice();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isDebounced()) return;
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        final bytes = await picked.readAsBytes();
        final fileName = picked.name;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ImagePreviewScreen(
              imageBytes: bytes,
              fileName: fileName,
              onConfirm: (enhancedBytes) async {
                await ref
                    .read(reportProvider.notifier)
                    .scanImageBytes(enhancedBytes, fileName);
                if (ref.read(reportProvider).report != null && mounted) {
                  _checkAndShowCacheNotice();
                  widget.onReportReady();
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الصورة: $e')));
      }
    }
  }

  Future<void> _pickPdf() async {
    if (_isDebounced()) return;
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result.isNotEmpty) {
        final picked = result.first;
        final bytes = await picked.readAsBytes();
        final fileName = picked.name;
        if (bytes.isNotEmpty) {
          await ref.read(reportProvider.notifier).scanPdfBytes(bytes, fileName);
          if (ref.read(reportProvider).report != null && mounted) {
            _checkAndShowCacheNotice();
            widget.onReportReady();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في قراءة ملف الـ PDF: $e')));
      }
    }
  }

  Future<void> _submitManual() async {
    if (_isDebounced()) return;
    final codes = _codesController.text.trim();
    if (codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال كود عطل واحد على الأقل مثل: P0102'),
        ),
      );
      return;
    }

    final vin = _vinController.text.trim().isNotEmpty
        ? _vinController.text.trim()
        : null;
    await ref.read(reportProvider.notifier).scanManual(codes, vin);
    if (ref.read(reportProvider).report != null && mounted) {
      _checkAndShowCacheNotice();
      widget.onReportReady();
    }
  }

  Future<void> _loadDemo(String sampleId) async {
    if (_isDebounced()) return;
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
            customBorder: Border.all(
              color: isDark
                  ? KashifColors.goldPrimary.withValues(alpha: 0.35)
                  : KashifColors.royalBlue.withValues(alpha: 0.25),
              width: 1.2,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: KashifColors.goldPrimary,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: KashifColors.goldPrimary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/app_icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flow Cars | فحص أعطال السيارات',
                        style: KashifTypography.arabic(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? KashifColors.goldLight
                              : KashifColors.royalBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'تحويل تقارير الفحص إلى مصطلحات الورش الليبية بدقة هندسية',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          color: isDark
                              ? KashifColors.darkTextMuted
                              : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
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
              backgroundColor: isDark
                  ? const Color(0xFF162432)
                  : const Color(0xFFE8F1FA),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    backgroundColor: isDark
                        ? KashifColors.darkBoard
                        : KashifColors.lightBoard,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? KashifColors.fuse15AInkDark
                          : KashifColors.fuse15AInkLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.progressText.isNotEmpty
                        ? state.progressText
                        : 'جاري التحليل والمعالجة بالذكاء الاصطناعي...',
                    textAlign: TextAlign.center,
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? KashifColors.fuse15AInkDark
                          : KashifColors.fuse15AInkLight,
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
              backgroundColor: isDark
                  ? const Color(0xFF2C1917)
                  : const Color(0xFFFDEEEC),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: isDark
                            ? KashifColors.fuse10AInkDark
                            : KashifColors.fuse10AInkLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: KashifTypography.arabic(
                            fontSize: 12,
                            color: isDark
                                ? KashifColors.fuse10AInkDark
                                : KashifColors.fuse10AInkLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Emergency Actions when Quota/Models are unavailable
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9E5B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          final lastCodes =
                              _codesController.text.trim().isNotEmpty
                              ? _codesController.text.trim()
                              : ref.read(reportProvider).lastManualCodes;
                          final lastVin = _vinController.text.trim().isNotEmpty
                              ? _vinController.text.trim()
                              : ref.read(reportProvider).lastManualVin;

                          if (lastCodes != null && lastCodes.isNotEmpty) {
                            await ref
                                .read(reportProvider.notifier)
                                .generateOfflineReport(lastCodes, lastVin);
                            if (ref.read(reportProvider).report != null &&
                                mounted) {
                              _checkAndShowCacheNotice();
                              widget.onReportReady();
                            }
                          } else {
                            ref.read(reportProvider.notifier).clearError();
                            setState(() {
                              _showManualInput = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '⚡ أدخل كود العطل هنا وسيتم التشخيص فورياً بدون إنترنت!',
                                ),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.offline_bolt_rounded, size: 17),
                        label: Text(
                          'توليد تقرير محلي بالقاموس (0 إنترنت) ⚡',
                          style: KashifTypography.arabic(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? KashifColors.goldLight
                              : KashifColors.royalBlue,
                          side: BorderSide(
                            color: isDark
                                ? KashifColors.goldPrimary.withValues(
                                    alpha: 0.5,
                                  )
                                : KashifColors.royalBlue.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryScreen(
                                onReportSelected: widget.onReportReady,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history_rounded, size: 16),
                        label: Text(
                          'سجل التقارير المحفوظة 📑',
                          style: KashifTypography.arabic(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white70
                              : Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                          if (mounted) {
                            ref.read(reportProvider.notifier).clearError();
                          }
                        },
                        icon: const Icon(Icons.key_rounded, size: 15),
                        label: Text(
                          'إدارة المفاتيح ⚙️',
                          style: KashifTypography.arabic(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Primary Capture Action 1: Camera
          FuseCell(
            onTap: state.isLoading
                ? null
                : () => _pickImage(ImageSource.camera),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132347)
                        : const Color(0xFFE8F0FC),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KashifColors.goldPrimary,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 24,
                    color: isDark
                        ? KashifColors.goldLight
                        : KashifColors.goldDark,
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
                          color: isDark
                              ? KashifColors.darkTextMuted
                              : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: isDark
                      ? KashifColors.goldLight
                      : KashifColors.royalBlue,
                ),
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
                    color: isDark
                        ? const Color(0xFF132347)
                        : const Color(0xFFE8F0FC),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KashifColors.goldPrimary,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 24,
                    color: isDark
                        ? KashifColors.goldLight
                        : KashifColors.goldDark,
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
                          color: isDark
                              ? KashifColors.darkTextMuted
                              : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: isDark
                      ? KashifColors.goldLight
                      : KashifColors.royalBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Primary Capture Action 3: Gallery Screenshot
          FuseCell(
            onTap: state.isLoading
                ? null
                : () => _pickImage(ImageSource.gallery),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132347)
                        : const Color(0xFFE8F0FC),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KashifColors.goldPrimary,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    size: 24,
                    color: isDark
                        ? KashifColors.goldLight
                        : KashifColors.goldDark,
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
                          color: isDark
                              ? KashifColors.darkTextMuted
                              : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: isDark
                      ? KashifColors.goldLight
                      : KashifColors.royalBlue,
                ),
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
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132347)
                        : const Color(0xFFE8F0FC),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KashifColors.goldPrimary.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_rounded,
                    size: 18,
                    color: isDark
                        ? KashifColors.goldLight
                        : KashifColors.goldDark,
                  ),
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
                  _showManualInput
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isDark
                      ? KashifColors.goldLight
                      : KashifColors.royalBlue,
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
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _codesController,
                    style: KashifTypography.mono(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'مثال: P0102, P0113, P0420',
                      hintStyle: KashifTypography.mono(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? KashifColors.darkBoard
                          : KashifColors.lightBoard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'رقم الهيكل VIN (اختياري لمطابقة المحرك والقطع):',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _vinController,
                    style: KashifTypography.mono(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'مثال: JTDBR42E309...',
                      hintStyle: KashifTypography.mono(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? KashifColors.darkBoard
                          : KashifColors.lightBoard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark
                              ? KashifColors.goldPrimary.withValues(alpha: 0.4)
                              : KashifColors.royalBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? KashifColors.goldPrimary
                            : KashifColors.royalBlue,
                        foregroundColor: isDark
                            ? const Color(0xFF070E1E)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        elevation: isDark ? 3 : 1,
                      ),
                      onPressed: state.isLoading ? null : _submitManual,
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: Text(
                        'تحليل الأكواد الآن',
                        style: KashifTypography.arabic(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const MoldedRib(label: 'أدوات التشخيص السريع والميداني'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FuseCell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardLightsScreen(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFDD835,
                          ).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFFDD835),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'لمبات الطبلون',
                              style: KashifTypography.arabic(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'دليل إشارات الطبلون',
                              style: KashifTypography.arabic(
                                fontSize: 10,
                                color: isDark
                                    ? KashifColors.darkTextMuted
                                    : KashifColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FuseCell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FuseBoxScreen()),
                    );
                  },
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1E88E5,
                          ).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.electric_bolt_rounded,
                          color: Color(0xFF1E88E5),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دليل الفيوزات',
                              style: KashifTypography.arabic(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'فحص الدوائر والأمبير',
                              style: KashifTypography.arabic(
                                fontSize: 10,
                                color: isDark
                                    ? KashifColors.darkTextMuted
                                    : KashifColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                        style: KashifTypography.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'عطل شحن وحساسات',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          color: isDark
                              ? KashifColors.darkTextMuted
                              : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FuseCell(
                  onTap: state.isLoading
                      ? null
                      : () => _loadDemo('toyota-corolla'),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Icon(Icons.directions_car, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        'Toyota Corolla',
                        style: KashifTypography.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'عطل حساس ماف فطفطة',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          color: isDark
                              ? KashifColors.darkTextMuted
                              : KashifColors.lightTextMuted,
                        ),
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
