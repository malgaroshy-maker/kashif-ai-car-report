import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/key_pool_manager.dart';
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
  late TextEditingController _newKeyController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _obscureKey = true;

  final Map<String, bool> _testingMap = {};
  final Map<String, String?> _testResults = {};
  final KashifApiClient _apiClient = KashifApiClient();

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _newKeyController = TextEditingController();
    _nameController = TextEditingController(text: s.workshopName);
    _phoneController = TextEditingController(text: s.workshopPhone);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

  @override
  void dispose() {
    final enteredKey = _newKeyController.text
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '');
    if (enteredKey.isNotEmpty) {
      final currentKeys = ref.read(settingsProvider).customApiKeys;
      if (!currentKeys.contains(enteredKey)) {
        ref.read(settingsProvider.notifier).addApiKey(enteredKey);
      }
    }
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final current = ref.read(settingsProvider);
    if (name != current.workshopName || phone != current.workshopPhone) {
      ref.read(settingsProvider.notifier).updateWorkshop(name, phone);
    }
    _newKeyController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _newKeyController.text = data.text!
            .trim()
            .replaceAll('"', '')
            .replaceAll("'", '');
      });
    }
  }

  void _addNewKey() {
    final text = _newKeyController.text
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '');
    if (text.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('يرجى لصق أو إدخال مفتاح Google Gemini أولاً.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    if (!text.startsWith('AIzaSy')) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'تنبيه: مفتاح Google Gemini يبدأ عادةً بـ AIzaSy... تأكد من صحة المفتاح.',
          ),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 3),
        ),
      );
    }

    final currentKeys = ref.read(settingsProvider).customApiKeys;
    if (currentKeys.contains(text)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('هذا المفتاح مضاف بالفعل مسبقاً.')),
      );
      return;
    }

    ref.read(settingsProvider.notifier).addApiKey(text);
    _newKeyController.clear();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('تم حفظ وتفعيل المفتاح بنجاح!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _testKey(String key) async {
    setState(() {
      _testingMap[key] = true;
      _testResults[key] = null;
    });

    final res = await _apiClient.testApiKey(key);
    final success = res['success'] == true;
    final message = res['message']?.toString() ?? '';

    if (mounted) {
      setState(() {
        _testingMap[key] = false;
        _testResults[key] = message;
      });

      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _removeKey(int index) {
    ref.read(settingsProvider.notifier).removeApiKey(index);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('تم حذف المفتاح.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _saveSettings() {
    final enteredKey = _newKeyController.text
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '');
    bool addedKey = false;
    if (enteredKey.isNotEmpty) {
      final currentKeys = ref.read(settingsProvider).customApiKeys;
      if (!currentKeys.contains(enteredKey)) {
        ref.read(settingsProvider.notifier).addApiKey(enteredKey);
        addedKey = true;
      }
      _newKeyController.clear();
    }

    ref
        .read(settingsProvider.notifier)
        .updateWorkshop(
          _nameController.text.trim(),
          _phoneController.text.trim(),
        );

    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4ADE80),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                addedKey
                    ? 'تم حفظ المفتاح الجديد وبيانات الورشة بنجاح ✅'
                    : 'تم حفظ البيانات بنجاح',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F1E38),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: KashifColors.goldPrimary, width: 1),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = ref.watch(settingsProvider);
    final keys = s.customApiKeys;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المنظومة والورشة'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check_circle_outline,
              size: 22,
              color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
            ),
            tooltip: 'حفظ البيانات',
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Technician section
            const MoldedRib(label: 'بيانات الفني للتقارير'),
            const SizedBox(height: 10),

            FuseCell(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اسم الفني:',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: KashifTypography.arabic(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'اكتب اسم الفني هنا',
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
                  Text(
                    'رقم الهاتف:',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: KashifTypography.mono(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'مثال: 0927968986',
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
                  const SizedBox(height: 8),
                  Text(
                    'يظهر اسم الفني ورقم الهاتف تلقائياً في التقرير وشهادة الفحص.',
                    style: KashifTypography.arabic(
                      fontSize: 10,
                      color: isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(
                        'حفظ بيانات الفني',
                        style: KashifTypography.arabic(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? KashifColors.fuse15AInkDark
                            : KashifColors.fuse15AInkLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Multi-Key Pool Section
            const MoldedRib(
              label: 'مفاتيح Google Gemini المجانية (التدوير الذكي)',
            ),
            const SizedBox(height: 10),

            FuseCell(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_mode_rounded,
                        size: 20,
                        color: isDark
                            ? KashifColors.fuse20AInkDark
                            : KashifColors.fuse20AInkLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'نظام التدوير الاحتياطي التلقائي',
                          style: KashifTypography.arabic(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أضف 2 أو 3 مفاتيح مجانية من Google AI Studio. سينتقل التطبيق بينهم تلقائياً في الخلفية فور وصول أي مفتاح لحد الدقيقة، لضمان استمرار الفحص دون أي توقف أو رسائل خطأ.',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      color: isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Existing Keys List
                  if (keys.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E190E)
                            : const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? Colors.amber.withValues(alpha: 0.5)
                              : Colors.orange.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 22,
                            color: isDark ? Colors.amberAccent : Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'لم يتم تعيين مفتاح API بعد. الصق مفتاح Google Gemini المجاني أدناه واضغط "إضافة المفتاح" أو "حفظ التغييرات" لتفعيل الفحص.',
                              style: KashifTypography.arabic(
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...keys.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final key = entry.value;
                      final isTesting = _testingMap[key] == true;
                      final isCooldown = KeyPoolManager.instance.isCoolingDown(
                        key,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? KashifColors.darkBoard
                              : KashifColors.lightBoard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: idx == 0
                                ? (isDark
                                      ? KashifColors.goldPrimary
                                      : KashifColors.royalBlue)
                                : (isDark
                                      ? KashifColors.darkBorder
                                      : KashifColors.lightBorder),
                            width: idx == 0 ? 1.4 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (idx == 0
                                                ? (isDark
                                                      ? KashifColors.goldPrimary
                                                      : KashifColors.royalBlue)
                                                : Colors.grey)
                                            .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    idx == 0
                                        ? 'المفتاح 1 (الرئيسي والنشط)'
                                        : 'المفتاح ${idx + 1} (احتياطي)',
                                    style: KashifTypography.arabic(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: idx == 0
                                          ? (isDark
                                                ? KashifColors.goldLight
                                                : KashifColors.royalBlue)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isCooldown)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'تهدئة 60 ثانية',
                                      style: KashifTypography.arabic(
                                        fontSize: 10,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'نشط وجاهز',
                                      style: KashifTypography.arabic(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                // Test Button
                                InkWell(
                                  onTap: isTesting ? null : () => _testKey(key),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: isTesting
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Row(
                                            children: [
                                              Icon(
                                                Icons.verified_outlined,
                                                size: 14,
                                                color: isDark
                                                    ? KashifColors.goldLight
                                                    : KashifColors.royalBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'فحص المفتاح',
                                                style: KashifTypography.arabic(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? KashifColors.goldLight
                                                      : KashifColors.royalBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Delete Button
                                InkWell(
                                  onTap: () => _removeKey(idx),
                                  borderRadius: BorderRadius.circular(4),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              KeyPoolManager.maskKey(key),
                              style: KashifTypography.mono(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 12),
                  Text(
                    'إضافة مفتاح جديد:',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newKeyController,
                          obscureText: _obscureKey,
                          style: KashifTypography.mono(fontSize: 12),
                          onSubmitted: (_) => _addNewKey(),
                          decoration: InputDecoration(
                            hintText: 'AIzaSy... (الصق مفتاحك هنا)',
                            filled: true,
                            fillColor: isDark
                                ? KashifColors.darkBoard
                                : KashifColors.lightBoard,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _obscureKey
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: isDark
                                        ? KashifColors.darkTextMuted
                                        : KashifColors.lightTextMuted,
                                  ),
                                  tooltip: _obscureKey
                                      ? 'إظهار المفتاح'
                                      : 'إخفاء المفتاح',
                                  onPressed: () => setState(
                                    () => _obscureKey = !_obscureKey,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.content_paste_rounded,
                                    size: 18,
                                  ),
                                  tooltip: 'لصق من الحافظة',
                                  onPressed: _pasteFromClipboard,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? KashifColors.goldPrimary
                              : KashifColors.royalBlue,
                          foregroundColor: isDark
                              ? const Color(0xFF070E1E)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _addNewKey,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'إضافة المفتاح',
                          style: KashifTypography.arabic(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '💡 ملاحظة: يمكنك الضغط على "إضافة المفتاح" أو الضغط مباشرة على زر "حفظ التغييرات" بالأسفل.',
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

            const SizedBox(height: 16),
            const MoldedRib(label: 'مظهر غطاء الفيوز (Theme)'),
            const SizedBox(height: 10),

            FuseCell(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildThemeOption(
                    'المظهر النهاري الملكي (Royal Daylight)',
                    'خلفية نقية مع عناصر بالأزرق الملكي ولمسات ذهبية',
                    ThemeMode.light,
                    s.themeMode,
                    isDark,
                  ),
                  const Divider(height: 16),
                  _buildThemeOption(
                    'المظهر الليلي الملكي (Royal Navy & Gold)',
                    'أزرق ملكي داكن مع لمعان ذهبي مطابق لشعار Flow Cars',
                    ThemeMode.dark,
                    s.themeMode,
                    isDark,
                  ),
                  const Divider(height: 16),
                  _buildThemeOption(
                    'مطابقة مظهر الجهاز (System Default)',
                    'يتبع إعدادات ومظهر الهاتف تلقائياً',
                    ThemeMode.system,
                    s.themeMode,
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? KashifColors.goldPrimary
                    : KashifColors.royalBlue,
                foregroundColor: isDark
                    ? const Color(0xFF070E1E)
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: isDark ? 2 : 1,
              ),
              onPressed: _saveSettings,
              child: Text(
                'حفظ التغييرات',
                style: KashifTypography.arabic(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Flow Cars للأندرويد — الإصدار 1.0.0',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'منظومة فحص أعطال السيارات الذكية',
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
                      ? (isDark
                            ? KashifColors.fuse15AInkDark
                            : KashifColors.fuse15AInkLight)
                      : (isDark
                            ? KashifColors.darkBorder
                            : KashifColors.lightBorder),
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
                          color: isDark
                              ? KashifColors.fuse15AInkDark
                              : KashifColors.fuse15AInkLight,
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
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
    );
  }
}
