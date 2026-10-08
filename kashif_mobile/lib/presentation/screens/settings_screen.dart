import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_client.dart';
import '../../core/network/apinex_client.dart';
import '../../core/network/key_pool_manager.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../providers/settings_provider.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/molded_rib.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, String>> apinexFreeModels = [
    {
      'id': 'free/gpt-6-luna',
      'name': 'GPT-6 Luna (مجاني • الافتراضي لكاشف)',
      'desc': 'الموديل المعتمد لتقارير الفحص ومصطلحات الورش الليبية (1M Context)',
    },
    {
      'id': 'free/glm-5.3-flash',
      'name': 'GLM-5.3 Flash (مجاني • سرعة فائقة)',
      'desc': 'استجابة فورية وسريعة جداً في قراءة وتحليل الأعطال (1M Context)',
    },
    {
      'id': 'free/deepseek-v4.1-flash',
      'name': 'DeepSeek V4.1 Flash (مجاني • دقة ومطابقة)',
      'desc': 'قوي جداً في استنتاج الأكواد وتشخيص الأنظمة والدوائر (1M Context)',
    },
    {
      'id': 'free/deepseek-v4-pro-0813',
      'name': 'DeepSeek V4 Pro (مجاني • تحليل معماري دقيق)',
      'desc': 'استدلال منطقي متقدم لأعطال السيارات الشديدة والمتشابكة (1M Context)',
    },
    {
      'id': 'free/mimo-v2.6-pro',
      'name': 'Mimo V2.6 Pro (مجاني • استنتاج احترافي)',
      'desc': 'معالجة فنية متطورة وصياغة تقارير موثوقة (1M Context)',
    },
    {
      'id': 'custom',
      'name': 'نموذج آخر (كتابة يدوية)',
      'desc': 'أدخل اسم أي موديل متاح في حسابك أو السيرفر',
    },
  ];

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _newKeyController;
  late TextEditingController _nameController;
  late TextEditingController _techNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _apinexKeyController;
  late TextEditingController _apinexModelController;
  late String _selectedModelPreset;
  bool _obscureKey = true;
  bool _obscureApinexKey = false;
  bool _isTestingApinex = false;
  bool _isFetchingModels = false;
  List<String> _liveServerModels = [];

  final Map<String, bool> _testingMap = {};
  final Map<String, String?> _testResults = {};
  final KashifApiClient _apiClient = KashifApiClient();

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _newKeyController = TextEditingController();
    _nameController = TextEditingController(text: s.workshopName);
    _techNameController = TextEditingController(text: s.technicianName);
    _phoneController = TextEditingController(text: s.workshopPhone);
    _addressController = TextEditingController(text: s.workshopAddress);
    final initialKey = s.apinexApiKey.isNotEmpty ? s.apinexApiKey : ApinexClient.defaultApiKey;
    _apinexKeyController = TextEditingController(text: initialKey);
    final initialModel = s.apinexModel.isNotEmpty ? s.apinexModel : ApinexClient.defaultModel;
    _apinexModelController = TextEditingController(text: initialModel);
    _selectedModelPreset = SettingsScreen.apinexFreeModels.any((m) => m['id'] == initialModel)
        ? initialModel
        : 'custom';

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
    final techName = _techNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final apKey = _apinexKeyController.text.trim();
    final apModel = _apinexModelController.text.trim();
    final current = ref.read(settingsProvider);
    if (name != current.workshopName ||
        phone != current.workshopPhone ||
        address != current.workshopAddress ||
        techName != current.technicianName) {
      ref.read(settingsProvider.notifier).updateWorkshop(
        name,
        phone,
        address: address,
        technicianName: techName,
      );
    }
    if (apKey != current.apinexApiKey || apModel != current.apinexModel) {
      ref.read(settingsProvider.notifier).updateApinexSettings(
        key: apKey,
        model: apModel,
      );
    }
    _newKeyController.dispose();
    _nameController.dispose();
    _techNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _apinexKeyController.dispose();
    _apinexModelController.dispose();
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

  void _restoreDefaultApinexKey() {
    setState(() {
      _apinexKeyController.text = ApinexClient.defaultApiKey;
    });
    ref.read(settingsProvider.notifier).updateApinexSettings(
      key: ApinexClient.defaultApiKey,
    );
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('تمت استعادة مفتاح GPT-6 الافتراضي المعتمد بنجاح ✅'),
        backgroundColor: Color(0xFF1B5E20),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _fetchServerModels() async {
    setState(() => _isFetchingModels = true);
    final key = _apinexKeyController.text.trim();
    try {
      final models = await ApinexClient().fetchAvailableModels(keyOverride: key);
      if (mounted) {
        setState(() {
          _liveServerModels = models;
          _isFetchingModels = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ تم جلب ${models.length} نموذجاً متاحاً من سيرفر APInex بنجاح!',
              style: KashifTypography.arabic(fontSize: 12),
            ),
            backgroundColor: const Color(0xFF1B5E20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingModels = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ تعذر جلب النماذج من السيرفر: ${e.toString()}',
              style: KashifTypography.arabic(fontSize: 12),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showConnectionResultModal({
    required bool success,
    required int stage,
    required String message,
    required String modelName,
    required List<String> availableModels,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1E38) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: isDark
                  ? KashifColors.goldPrimary.withValues(alpha: 0.3)
                  : KashifColors.royalBlue.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    success
                        ? Icons.check_circle_rounded
                        : (stage == 2
                            ? Icons.warning_amber_rounded
                            : Icons.cancel_rounded),
                    color: success
                        ? const Color(0xFF2E9E5B)
                        : (stage == 2 ? Colors.amber : Colors.redAccent),
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      success
                          ? 'نتيجة فحص الاتصال: ناجح تماماً ✅'
                          : (stage == 2
                              ? 'المفتاح متصل • تنبيه بالنموذج ⚠️'
                              : 'فشل فحص الاتصال ❌'),
                      style: KashifTypography.arabic(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Two-Stage Status Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF142444)
                      : const Color(0xFFF0F4FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          stage >= 1 && (success || stage == 2)
                              ? Icons.check_circle_outline_rounded
                              : Icons.cancel_outlined,
                          color: stage >= 1 && (success || stage == 2)
                              ? const Color(0xFF2E9E5B)
                              : Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'المرحلة 1: التحقق من صلاحية المفتاح وسيرفر APInex',
                            style: KashifTypography.arabic(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (availableModels.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E9E5B).withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${availableModels.length} نموذج',
                              style: KashifTypography.mono(
                                fontSize: 10.5,
                                color: const Color(0xFF2E9E5B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 14),
                    Row(
                      children: [
                        Icon(
                          success
                              ? Icons.check_circle_outline_rounded
                              : (stage == 2
                                  ? Icons.warning_amber_rounded
                                  : Icons.cancel_outlined),
                          color: success
                              ? const Color(0xFF2E9E5B)
                              : (stage == 2 ? Colors.amber : Colors.redAccent),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'المرحلة 2: جاهزية واستجابة النموذج ($modelName)',
                            style: KashifTypography.arabic(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Detail Message Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: success
                      ? (isDark
                          ? const Color(0xFF13281C)
                          : const Color(0xFFE8F5E9))
                      : (isDark
                          ? const Color(0xFF2A1F10)
                          : const Color(0xFFFFF8E1)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: success
                        ? const Color(0xFF2E9E5B)
                        : Colors.amber.shade700,
                  ),
                ),
                child: Text(
                  message,
                  style: KashifTypography.arabic(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (message.contains('apinex.bond') || message.contains('حضور يومي')) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                  label: Text(
                    'تسجيل حضور يومي مجاني بنقرة واحدة (apinex.bond) 🔗',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: () async {
                    final uri = Uri.parse('https://apinex.bond/airdrop?tab=quests');
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        await Clipboard.setData(
                          const ClipboardData(text: 'https://apinex.bond/airdrop?tab=quests'),
                        );
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ الرابط للحافظة: https://apinex.bond/airdrop?tab=quests'),
                            ),
                          );
                        }
                      }
                    } catch (_) {
                      await Clipboard.setData(
                        const ClipboardData(text: 'https://apinex.bond/airdrop?tab=quests'),
                      );
                    }
                  },
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '💡 النماذج مجانية 100% ولا تتطلب أي دفع أو شحن رصيد؛ فقط سجل حضورك اليومي المجاني بنقرة واحدة.',
                          style: KashifTypography.arabic(
                            fontSize: 10.5,
                            color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF795548),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? KashifColors.goldPrimary
                      : KashifColors.royalBlue,
                  foregroundColor: isDark
                      ? const Color(0xFF070E1E)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'تم والمتابعة',
                  style: KashifTypography.arabic(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testApinexConnection() async {
    setState(() => _isTestingApinex = true);
    final keyToTest = _apinexKeyController.text.trim();
    final modelToTest = _apinexModelController.text.trim();

    if (keyToTest.isNotEmpty) {
      await ref.read(settingsProvider.notifier).updateApinexSettings(
        key: keyToTest,
        model: modelToTest,
      );
    }

    final res = await ApinexClient().testConnectionDetailed(
      keyOverride: keyToTest,
      modelOverride: modelToTest,
    );
    final success = res['success'] == true;
    final stage = (res['stage'] as int?) ?? 1;
    final message = res['message']?.toString() ?? '';
    final models = (res['availableModels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    if (models.isNotEmpty) {
      setState(() {
        _liveServerModels = models;
      });
    }

    if (mounted) {
      setState(() => _isTestingApinex = false);
      _showConnectionResultModal(
        success: success,
        stage: stage,
        message: message,
        modelName: modelToTest,
        availableModels: models,
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
          address: _addressController.text.trim(),
          technicianName: _techNameController.text.trim(),
        );

    ref.read(settingsProvider.notifier).updateApinexSettings(
      key: _apinexKeyController.text.trim(),
      model: _apinexModelController.text.trim(),
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
            // Theme Mode Section
            const MoldedRib(label: 'مظهر التطبيق والإضاءة'),
            const SizedBox(height: 10),
            FuseCell(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    s.themeMode == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نمط المظهر:',
                          style: KashifTypography.arabic(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.themeMode == ThemeMode.dark
                              ? 'الوضع الليلي (الداكن)'
                              : s.themeMode == ThemeMode.light
                                  ? 'الوضع النهاري (الفاتح)'
                                  : 'تلقائي (حسب إعدادات الهاتف)',
                          style: KashifTypography.arabic(
                            fontSize: 10.5,
                            color: isDark
                                ? KashifColors.darkTextMuted
                                : KashifColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded, size: 16),
                        label: Text('داكن'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded, size: 16),
                        label: Text('فاتح'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.settings_brightness_rounded, size: 16),
                        label: Text('تلقائي'),
                      ),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (newSelection) {
                      ref.read(settingsProvider.notifier).updateThemeMode(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Workshop and Technician section
            const MoldedRib(label: 'بيانات الورشة والفني للاعتماد الرسمي'),
            const SizedBox(height: 10),

            FuseCell(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اسم الورشة / مركز الفحص:',
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
                      hintText: 'مثال: مركز الفحص الفني المعتمد أو ورشة السلام',
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
                    'اسم الفني المسؤول:',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _techNameController,
                    style: KashifTypography.arabic(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'مثال: م. محمد المهدي أو الفني المسؤول',
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
                    'رقم هاتف التواصل:',
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
                      hintText: 'مثال: 0912345678 أو 0927968986',
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
                    'عنوان الورشة / المدينة:',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _addressController,
                    style: KashifTypography.arabic(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'مثال: طرابلس - طريق السراج أو بنغازي - الهواري',
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
                    'تظهر هذه البيانات وترويسة الورشة وخانة التوقيع والختم في تقارير PDF المعتمدة للزبائن.',
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
                        'حفظ بيانات الورشة والاعتماد',
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
            // Report Sections Customizer Section
            const MoldedRib(
              label: 'أقسام ومكونات تقرير الفحص (تخصيص العرض والطباعة)',
            ),
            const SizedBox(height: 10),
            _buildReportSectionsCustomizer(isDark, s),

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
            const MoldedRib(label: 'اختيار وتثبيت محرك الذكاء الاصطناعي للفحص'),
            const SizedBox(height: 10),

            // Engine Selection Cards (Pinning APInex vs Gemini)
            Row(
              children: [
                // Option 1: APInex
                Expanded(
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(settingsProvider.notifier)
                          .updateApinexSettings(asPrimary: true);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: s.useApinexAsPrimary
                            ? (isDark
                                  ? KashifColors.goldPrimary.withValues(
                                      alpha: 0.18,
                                    )
                                  : KashifColors.royalBlue.withValues(
                                      alpha: 0.12,
                                    ))
                            : (isDark
                                  ? KashifColors.darkBoard
                                  : KashifColors.lightBoard),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: s.useApinexAsPrimary
                              ? (isDark
                                    ? KashifColors.goldPrimary
                                    : KashifColors.royalBlue)
                              : (isDark
                                    ? KashifColors.darkBorder
                                    : KashifColors.lightBorder),
                          width: s.useApinexAsPrimary ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                s.useApinexAsPrimary
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: s.useApinexAsPrimary
                                    ? (isDark
                                          ? KashifColors.goldPrimary
                                          : KashifColors.royalBlue)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'تثبيت APInex',
                                  style: KashifTypography.arabic(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: s.useApinexAsPrimary
                                        ? (isDark
                                              ? KashifColors.goldLight
                                              : KashifColors.royalBlue)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'المحرك الرئيسي دائماً (GPT-6 Luna والأنظمة المجانية دون توقف)',
                            style: KashifTypography.arabic(
                              fontSize: 10,
                              height: 1.3,
                              color: isDark
                                  ? KashifColors.darkTextMuted
                                  : KashifColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (s.useApinexAsPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? KashifColors.goldPrimary
                                        : KashifColors.royalBlue)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '⭐ مُثبّت ومُعتمد',
                                style: KashifTypography.arabic(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? KashifColors.goldLight
                                      : KashifColors.royalBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Option 2: Gemini
                Expanded(
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(settingsProvider.notifier)
                          .updateApinexSettings(asPrimary: false);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !s.useApinexAsPrimary
                            ? (isDark
                                  ? KashifColors.goldPrimary.withValues(
                                      alpha: 0.18,
                                    )
                                  : KashifColors.royalBlue.withValues(
                                      alpha: 0.12,
                                    ))
                            : (isDark
                                  ? KashifColors.darkBoard
                                  : KashifColors.lightBoard),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !s.useApinexAsPrimary
                              ? (isDark
                                    ? KashifColors.goldPrimary
                                    : KashifColors.royalBlue)
                              : (isDark
                                    ? KashifColors.darkBorder
                                    : KashifColors.lightBorder),
                          width: !s.useApinexAsPrimary ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                !s.useApinexAsPrimary
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: !s.useApinexAsPrimary
                                    ? (isDark
                                          ? KashifColors.goldPrimary
                                          : KashifColors.royalBlue)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Google Gemini',
                                  style: KashifTypography.arabic(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !s.useApinexAsPrimary
                                        ? (isDark
                                              ? KashifColors.goldLight
                                              : KashifColors.royalBlue)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'المحرك الافتراضي مع تحويل تلقائي فوري لـ APInex عند نفاذ الكوتة',
                            style: KashifTypography.arabic(
                              fontSize: 10,
                              height: 1.3,
                              color: isDark
                                  ? KashifColors.darkTextMuted
                                  : KashifColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!s.useApinexAsPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? KashifColors.goldPrimary
                                        : KashifColors.royalBlue)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '⭐ مُثبّت ومُعتمد',
                                style: KashifTypography.arabic(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? KashifColors.goldLight
                                      : KashifColors.royalBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const MoldedRib(label: 'إعدادات محرك APInex والنماذج المجانية (Free Models)'),
            const SizedBox(height: 10),

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
                          color: (isDark
                                  ? KashifColors.goldPrimary
                                  : KashifColors.royalBlue)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.swap_calls_rounded,
                          color: isDark
                              ? KashifColors.goldLight
                              : KashifColors.royalBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'محرك APInex الذكي (سيرفر مباشر)',
                              style: KashifTypography.arabic(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'يعمل بكفاءة عالية وبدون توقف؛ سواء كمحرك أساسي أو بديل تلقائي عند كوتة 429',
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
                  const Divider(height: 24),

                  // Failover Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'التبديل التلقائي عند توقف جيميناي',
                      style: KashifTypography.arabic(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'في حال ظهور خطأ نفاذ الكوتة (Quota/429)، يتحول الفحص فوراً لـ APInex',
                      style: KashifTypography.arabic(
                        fontSize: 10,
                        color: isDark
                            ? KashifColors.darkTextMuted
                            : KashifColors.lightTextMuted,
                      ),
                    ),
                    value: s.isApinexAutoFailoverEnabled,
                    activeThumbColor: isDark
                        ? KashifColors.goldPrimary
                        : KashifColors.royalBlue,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateApinexSettings(autoFailover: val);
                    },
                  ),

                  const SizedBox(height: 12),
                  // Fixed, Visible & Editable Key Header
                  Row(
                    children: [
                      Text(
                        'مفتاح API الخاص بـ APInex / GPT-6:',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _restoreDefaultApinexKey,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 14,
                                color: isDark
                                    ? KashifColors.goldLight
                                    : KashifColors.royalBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'استعادة المفتاح الأصلي',
                                style: KashifTypography.arabic(
                                  fontSize: 10,
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
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _apinexKeyController,
                    obscureText: _obscureApinexKey,
                    style: KashifTypography.mono(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'sk-apx...',
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
                              _obscureApinexKey
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: isDark
                                  ? KashifColors.darkTextMuted
                                  : KashifColors.lightTextMuted,
                            ),
                            tooltip: _obscureApinexKey
                                ? 'إظهار المفتاح'
                                : 'إخفاء المفتاح',
                            onPressed: () => setState(
                              () => _obscureApinexKey = !_obscureApinexKey,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            tooltip: 'نسخ المفتاح',
                            onPressed: () async {
                              final text = _apinexKeyController.text.trim();
                              if (text.isNotEmpty) {
                                final messenger = ScaffoldMessenger.of(context);
                                await Clipboard.setData(
                                  ClipboardData(text: text),
                                );
                                if (mounted) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('تم نسخ المفتاح إلى الحافظة ✅'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              size: 18,
                            ),
                            tooltip: 'لصق',
                            onPressed: () async {
                              final data = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              if (data?.text != null &&
                                  data!.text!.trim().isNotEmpty) {
                                setState(() {
                                  _apinexKeyController.text =
                                      data.text!.trim();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'اختر النموذج المجاني (Free Model):',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isFetchingModels)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        InkWell(
                          onTap: _fetchServerModels,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_sync_outlined,
                                  size: 14,
                                  color: isDark
                                      ? KashifColors.goldLight
                                      : KashifColors.royalBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _liveServerModels.isNotEmpty
                                      ? 'محدث (${_liveServerModels.length})'
                                      : 'جلب من السيرفر',
                                  style: KashifTypography.arabic(
                                    fontSize: 10,
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
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Dropdown of Free Models
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? KashifColors.darkBoard
                          : KashifColors.lightBoard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? KashifColors.darkBorder
                            : KashifColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedModelPreset,
                        dropdownColor: isDark
                            ? const Color(0xFF0F1E38)
                            : Colors.white,
                        items: SettingsScreen.apinexFreeModels.map((m) {
                          return DropdownMenuItem<String>(
                            value: m['id'],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    m['name']!,
                                    style: KashifTypography.arabic(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? KashifColors.goldLight
                                          : KashifColors.royalBlue,
                                    ),
                                  ),
                                  Text(
                                    m['desc']!,
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
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedModelPreset = val;
                              if (val != 'custom') {
                                _apinexModelController.text = val;
                              }
                            });
                            if (val != 'custom') {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateApinexSettings(model: val);
                            }
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معرف الموديل المعتمد (قابلة للكتابة والتعديل):',
                              style: KashifTypography.arabic(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _apinexModelController,
                              style: KashifTypography.mono(fontSize: 12),
                              onChanged: (val) {
                                final match = SettingsScreen.apinexFreeModels
                                    .any((m) => m['id'] == val.trim());
                                setState(() {
                                  _selectedModelPreset = match
                                      ? val.trim()
                                      : 'custom';
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'free/gpt-6-luna',
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? KashifColors.goldPrimary
                                  : KashifColors.royalBlue,
                            ),
                            foregroundColor: isDark
                                ? KashifColors.goldLight
                                : KashifColors.royalBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed:
                              _isTestingApinex ? null : _testApinexConnection,
                          icon: _isTestingApinex
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.network_check_rounded,
                                  size: 16,
                                ),
                          label: Text(
                            'فحص الاتصال',
                            style: KashifTypography.arabic(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const MoldedRib(label: 'إدارة استهلاك التوكن (Token Optimizer)'),
            const SizedBox(height: 10),

            FuseCell(
              padding: const EdgeInsets.all(14),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: s.isTokenSaverEnabled,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setTokenSaverEnabled(val);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? KashifColors.goldPrimary.withValues(alpha: 0.15)
                        : KashifColors.royalBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: isDark
                        ? KashifColors.goldPrimary
                        : KashifColors.royalBlue,
                    size: 24,
                  ),
                ),
                title: Text(
                  'وضع توفير التوكن الفائق (Ultra Token Saver)',
                  style: KashifTypography.arabic(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'يقلل استهلاك التوكن بنسبة تتجاوز 90% عبر ضغط الصور التلقائي وتلخيص تقارير الـ PDF قبل إرسالها للذكاء الاصطناعي.',
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    color: isDark
                        ? KashifColors.darkTextMuted
                        : KashifColors.lightTextMuted,
                  ),
                ),
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
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: KashifColors.goldPrimary,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: KashifColors.goldPrimary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 72,
                        height: 72,
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

  Widget _buildReportSectionsCustomizer(bool isDark, SettingsState s) {
    final sections = s.reportSectionsConfig.toItemList();
    final allEnabled = sections.every((item) => item.isEnabled);

    return FuseCell(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? KashifColors.goldPrimary : KashifColors.royalBlue)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التحكم في أجزاء التقرير المعروض والمطبوع:',
                      style: KashifTypography.arabic(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'حدد الأقسام التي تظهر داخل شاشة الفحص وملفات التصدير (PDF / HTML)',
                      style: KashifTypography.arabic(
                        fontSize: 10,
                        color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
                ),
                onPressed: () {
                  ref.read(settingsProvider.notifier).setAllReportSections(!allEnabled);
                },
                child: Text(
                  allEnabled ? 'تعطيل الكل' : 'تفعيل الكل',
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            thickness: 0.8,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(height: 10),
          // Dynamic iteration over all extensible sections
          ...sections.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? (item.isEnabled ? KashifColors.darkBoard : Colors.black26)
                    : (item.isEnabled ? KashifColors.lightBoard : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: item.isEnabled
                      ? (isDark
                          ? KashifColors.goldPrimary.withValues(alpha: 0.3)
                          : KashifColors.royalBlue.withValues(alpha: 0.2))
                      : (isDark ? Colors.white10 : Colors.black12),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color: item.isEnabled
                        ? (isDark ? KashifColors.goldLight : KashifColors.royalBlue)
                        : (isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: KashifTypography.arabic(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: item.isEnabled
                                ? (isDark
                                    ? KashifColors.darkTextPrimary
                                    : KashifColors.lightTextPrimary)
                                : (isDark
                                    ? KashifColors.darkTextMuted
                                    : KashifColors.lightTextMuted),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: KashifTypography.arabic(
                            fontSize: 9.5,
                            color: isDark
                                ? KashifColors.darkTextMuted
                                : KashifColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: item.isEnabled,
                    activeThumbColor:
                        isDark ? KashifColors.goldPrimary : KashifColors.royalBlue,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleReportSection(item.key, val);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
