import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../providers/settings_provider.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/molded_rib.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _apiKeyController = TextEditingController(text: s.customApiKey ?? '');
    _nameController = TextEditingController(text: s.workshopName);
    _phoneController = TextEditingController(text: s.workshopPhone);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final notifier = ref.read(settingsProvider.notifier);
    notifier.updateApiKey(_apiKeyController.text);
    notifier.updateWorkshop(_nameController.text, _phoneController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الإعدادات بنجاح'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المنظومة والورشة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MoldedRib(label: 'بيانات الورشة للتقارير والواتساب'),
            const SizedBox(height: 10),

            FuseCell(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اسم الورشة أو الفني:',
                    style: KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: KashifTypography.arabic(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'رقم هاتف الورشة:',
                    style: KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: KashifTypography.mono(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'مثال: 0910000000',
                      filled: true,
                      fillColor: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const MoldedRib(label: 'مظهر غطاء الفيوز (Theme)'),
            const SizedBox(height: 10),

            FuseCell(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildThemeOption(
                    'الغطاء النهاري (Daylight Lid)',
                    'الافتراضي لإضاءة الورشة وتحت أشعة الشمس',
                    ThemeMode.light,
                    s.themeMode,
                    isDark,
                  ),
                  const Divider(height: 12),
                  _buildThemeOption(
                    'الغطاء الليلي (Night Bay Lid)',
                    'للورش المغلقة وحفرة الصيانة والظلام',
                    ThemeMode.dark,
                    s.themeMode,
                    isDark,
                  ),
                  const Divider(height: 12),
                  _buildThemeOption(
                    'تلقائي مع إعدادات الجهاز',
                    'يتبع وضع النظام في هاتف الأندرويد',
                    ThemeMode.system,
                    s.themeMode,
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const MoldedRib(label: 'مفتاح الذكاء الاصطناعي (Gemini API)'),
            const SizedBox(height: 10),

            FuseCell(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مفتاح Gemini API خاص (اختياري):',
                    style: KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إذا تُرك فارغاً، يتم استخدام خادم كاشف AI السحابي تلقائياً دون الحاجة لمفتاح خاص.',
                    style: KashifTypography.arabic(fontSize: 11, color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    style: KashifTypography.mono(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'AIzaSy...',
                      filled: true,
                      fillColor: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              ),
              onPressed: _saveSettings,
              child: Text(
                'حفظ التغييرات',
                style: KashifTypography.arabic(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    'كاشف AI للأندرويد — الإصدار 1.0.0',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                    ),
                  ),
                  Text(
                    'منظومة فحص أعطال السيارات الليبية',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    String subtitle,
    ThemeMode mode,
    ThemeMode currentMode,
    bool isDark,
  ) {
    final isSelected = mode == currentMode;
    return InkWell(
      onTap: () => ref.read(settingsProvider.notifier).updateThemeMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight)
                      : (isDark ? KashifColors.darkBorder : KashifColors.lightBorder),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
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
      ),
    );
  }
}
