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
import '../../data/storage/hive_storage.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/molded_rib.dart';
import '../../core/constants/app_version.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, String>> apinexFreeModels = [
    {
      'id': 'free/gemini-2.5-flash',
      'name': 'Gemini 2.5 Flash 🌟 (مجاني • فائق الذكاء والسرعة ⚡ • موصى به)',
      'desc': 'النسخة المجانية الأفضل والأدق في قراءة تقارير الفحص وتشخيص الأعطال بالقاموس الليبي',
    },
    {
      'id': 'free/claude-3.5-sonnet',
      'name': 'Claude 3.5 Sonnet ✨ (مجاني • دقة استدلال هندسية فائقة)',
      'desc': 'تحليل منطقي متقدم لأعطال السيارات المعقدة والكهربائية والحساسات',
    },
    {
      'id': 'free/qwen-3.8-max',
      'name': 'Qwen 3.8 Max ⚡ (مجاني • فائق السرعة 1.8 ثانية)',
      'desc': 'أسرع نموذج مجاني تم اختباره (1.8s)، كفاءة عالية ومستقرة في تشخيص الأعطال',
    },
    {
      'id': 'free/gpt-6-luna',
      'name': 'GPT-6 Luna (مجاني • صياغة تقارير شاملة)',
      'desc': 'تحليل تفصيلي شامل للأعطال مع مقارنات دقيقة لحساسات الأكسجين والعادم',
    },
    {
      'id': 'free/deepseek-v4.1-flash',
      'name': 'DeepSeek V4.1 Flash (مجاني • مستقر ومجرب)',
      'desc': 'النموذج الشهير المعتمد لتشخيص الأعطال وقراءة أكواد الفحص بدون اشتراك',
    },
    {
      'id': 'free/glm-5.3-flash',
      'name': 'GLM-5.3 Flash (مجاني • سريع جداً 2.6 ثانية ⚡)',
      'desc': 'استجابة فائقة السرعة مع دقة هندسية في تفسير أكواد OBD-II وحساسات المحرك',
    },
    {
      'id': 'custom',
      'name': 'نموذج آخر (كتابة يدوية مخصصة)',
      'desc': 'أدخل اسم أي موديل متاح على حسابك في سيرفر APInex',
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
    final initialKey = s.apinexApiKey;
    _apinexKeyController = TextEditingController(text: initialKey);
    String initialModel = s.apinexModel.isNotEmpty ? s.apinexModel.trim() : ApinexClient.defaultModel;
    if (!initialModel.startsWith('free/') && !initialModel.contains('/')) {
      initialModel = 'free/$initialModel';
    }
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

  void _clearApinexKey() {
    setState(() {
      _apinexKeyController.clear();
    });
    ref.read(settingsProvider.notifier).updateApinexSettings(
      key: '',
    );
    KashifStorage.setApinexApiKey('');
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('تم مسح مفتاح APInex بنجاح ✅'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  int _getModelRank(String modelId) {
    final lower = modelId.toLowerCase();
    // Prioritize free models so they appear at the top and avoid 402 Payment Required
    final int freeOffset = lower.startsWith('free/') ? 0 : 300;

    // 1. Google Gemini (المرتبة الأولى: الأفضل في التطبيق)
    if (lower.contains('gemini')) {
      if (lower.contains('2.5') || lower.contains('flash')) return freeOffset + 10;
      if (lower.contains('2.0')) return freeOffset + 12;
      if (lower.contains('1.5-flash')) return freeOffset + 14;
      if (lower.contains('1.5-pro') || lower.contains('pro')) return freeOffset + 16;
      return freeOffset + 18;
    }
    // 2. Anthropic Claude (المرتبة الثانية: استدلال فني متفوق)
    if (lower.contains('claude')) {
      if (lower.contains('3.7') || lower.contains('3-7')) return freeOffset + 30;
      if (lower.contains('3.5-sonnet') || lower.contains('3-5-sonnet')) return freeOffset + 32;
      if (lower.contains('3.5-haiku') || lower.contains('3-5-haiku')) return freeOffset + 34;
      return freeOffset + 36;
    }
    // 3. OpenAI GPT / o-series
    if (lower.contains('gpt-4o') || lower.contains('gpt-4')) return freeOffset + 50;
    if (lower.contains('o1') || lower.contains('o3')) return freeOffset + 52;
    if (lower.contains('gpt')) return freeOffset + 54;
    // 4. DeepSeek
    if (lower.contains('deepseek')) {
      if (lower.contains('v3') || lower.contains('chat')) return freeOffset + 70;
      if (lower.contains('r1') || lower.contains('reasoner')) return freeOffset + 72;
      return freeOffset + 74;
    }
    // 5. Qwen
    if (lower.contains('qwen')) {
      if (lower.contains('max')) return freeOffset + 90;
      if (lower.contains('72b')) return freeOffset + 92;
      return freeOffset + 94;
    }
    // 6. GLM / Llama / Others
    if (lower.contains('glm')) return freeOffset + 110;
    if (lower.contains('llama')) return freeOffset + 120;
    return freeOffset + 200;
  }

  List<String> _sortModelsByPreference(List<String> rawModels) {
    final list = List<String>.from(rawModels);
    list.sort((a, b) {
      final rankA = _getModelRank(a);
      final rankB = _getModelRank(b);
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return list;
  }

  List<Map<String, String>> _getAvailableModelItems() {
    if (_liveServerModels.isEmpty) {
      return SettingsScreen.apinexFreeModels;
    }

    final List<Map<String, String>> items = [];
    for (final id in _liveServerModels) {
      final lower = id.toLowerCase();
      String name = id;
      String desc = 'نموذج متاح من سيرفر APInex';

      if (lower.contains('gemini')) {
        name = 'Google Gemini ($id) 🌟 (الأفضل في التطبيق)';
        desc = 'أعلى دقة في قراءة الفحص وتشخيص الأعطال بالقاموس الليبي';
      } else if (lower.contains('claude')) {
        name = 'Anthropic Claude ($id) ✨ (دقة استدلال فائقة)';
        desc = 'دقة استدلال منطقي فائقة لعزل الأعطال والحساسات';
      } else if (lower.contains('gpt-4') || lower.contains('o1') || lower.contains('o3')) {
        name = 'OpenAI GPT ($id)';
        desc = 'تحليل شامل ومفصل للأعطال';
      } else if (lower.contains('deepseek')) {
        name = 'DeepSeek ($id)';
        desc = 'استدلال متقدم لأعطال المحرك وأكواد OBD-II';
      } else if (lower.contains('qwen')) {
        name = 'Qwen ($id)';
        desc = 'استجابة سريعة لتشخيص الأعطال';
      } else if (lower.contains('glm')) {
        name = 'GLM Flash ($id)';
        desc = 'نموذج سريع وخفيف';
      }

      items.add({
        'id': id,
        'name': name,
        'desc': desc,
      });
    }

    // Always include Custom at the end
    items.add({
      'id': 'custom',
      'name': 'نموذج آخر (كتابة يدوية مخصصة)',
      'desc': 'أدخل اسم أي موديل متاح على حسابك في سيرفر APInex',
    });

    return items;
  }

  Future<void> _fetchServerModels() async {

    final key = _apinexKeyController.text.trim();
    if (key.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('⚠️ يرجى إدخال مفتاح APInex أولاً لجلب النماذج المتاحة من السيرفر.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() => _isFetchingModels = true);
    try {
      final rawModels = await ApinexClient().fetchAvailableModels(keyOverride: key);
      if (mounted) {
        final sorted = _sortModelsByPreference(rawModels);
        setState(() {
          _liveServerModels = sorted;
          _isFetchingModels = false;
        });

        // Automatically select the best free Gemini/Claude model, or best available free model
        String? bestCandidate;
        try {
          bestCandidate = sorted.firstWhere((m) => m.startsWith('free/') && m.toLowerCase().contains('gemini'));
        } catch (_) {
          try {
            bestCandidate = sorted.firstWhere((m) => m.startsWith('free/') && m.toLowerCase().contains('claude'));
          } catch (_) {
            try {
              bestCandidate = sorted.firstWhere((m) => m.startsWith('free/'));
            } catch (_) {
              try {
                bestCandidate = sorted.firstWhere((m) => m.toLowerCase().contains('gemini'));
              } catch (_) {
                if (sorted.isNotEmpty) bestCandidate = sorted.first;
              }
            }
          }
        }

        if (bestCandidate != null && bestCandidate.isNotEmpty) {
          final chosen = bestCandidate;
          setState(() {
            _selectedModelPreset = chosen;
            _apinexModelController.text = chosen;
          });
          ref.read(settingsProvider.notifier).updateApinexSettings(model: chosen);
          KashifStorage.setApinexModel(chosen);
        }

        final geminiCount = sorted.where((m) => m.toLowerCase().contains('gemini')).length;
        final claudeCount = sorted.where((m) => m.toLowerCase().contains('claude')).length;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ تم جلب ${sorted.length} نموذجاً مرتبة بالأفضلية: نماذج Gemini في المقدمة ($geminiCount) ثم Claude ($claudeCount)! تم تفعيل الأفضل تلقائياً.',
              style: KashifTypography.arabic(fontSize: 12),
            ),
            backgroundColor: const Color(0xFF1B5E20),
            duration: const Duration(seconds: 4),
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
    final rawAvailable = (res['availableModels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((m) => m.isNotEmpty)
            .toList() ??
        [];
    final models = _sortModelsByPreference(rawAvailable);

    if (models.isNotEmpty) {
      setState(() {
        _liveServerModels = models;
      });
    }

    final activeModel = res['activeModel']?.toString();
    if (activeModel != null && activeModel.isNotEmpty) {
      setState(() {
        _selectedModelPreset = activeModel;
        _apinexModelController.text = activeModel;
      });
      await ref.read(settingsProvider.notifier).updateApinexSettings(model: activeModel);
      await KashifStorage.setApinexModel(activeModel);
    }

    if (mounted) {
      setState(() => _isTestingApinex = false);
      _showConnectionResultModal(
        success: success,
        stage: stage,
        message: message,
        modelName: activeModel ?? modelToTest,
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        s.themeMode == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نمط المظهر',
                              style: KashifTypography.arabic(
                                fontSize: 13,
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
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
                      if (_apinexKeyController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '⚠️ تم اختيار APInex كمحرك أساسي. تأكد من إدخال مفتاحك من apinex.bond أدناه ليعمل الفحص.',
                            ),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
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
                                  'تثبيت APInex (الأساسي)',
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
                            'المحرك الأساسي والرئيسي للفحص (نماذج Gemini و Claude و GPT)',
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
                                '⭐ المحرك الأساسي المُعتمد',
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
                                  'Google Gemini (ثانوي)',
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
                            'المحرك الثانوي / الاحتياطي (يعمل كبديل فوري عند تعذر اتصال APInex)',
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _apinexKeyController.text.trim().isNotEmpty
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _apinexKeyController.text.trim().isNotEmpty
                                ? const Color(0xFF10B981)
                                : Colors.amber.shade700,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          _apinexKeyController.text.trim().isNotEmpty
                              ? '✅ مضبوط ومحفوظ'
                              : '⚠️ غير مدخل (مطلوب)',
                          style: KashifTypography.arabic(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: _apinexKeyController.text.trim().isNotEmpty
                                ? const Color(0xFF10B981)
                                : Colors.amber.shade800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _clearApinexKey,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 14,
                                color: isDark
                                    ? KashifColors.goldLight
                                    : KashifColors.royalBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'مسح المفتاح',
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
                    onChanged: (val) {
                      final clean = val.trim();
                      ref.read(settingsProvider.notifier).updateApinexSettings(key: clean);
                      KashifStorage.setApinexApiKey(clean);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'sk-apx... (أدخل مفتاحك الشخصي من apinex.bond)',
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
                              final messenger = ScaffoldMessenger.of(context);
                              final data = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              if (data?.text != null &&
                                  data!.text!.trim().isNotEmpty) {
                                final clean = data.text!.trim();
                                if (mounted) {
                                  setState(() {
                                    _apinexKeyController.text = clean;
                                  });
                                }
                                ref.read(settingsProvider.notifier).updateApinexSettings(key: clean);
                                await KashifStorage.setApinexApiKey(clean);
                                messenger.clearSnackBars();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('تم لصق وحفظ مفتاح APInex بنجاح ✅'),
                                    backgroundColor: Color(0xFF065F46),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF132038)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? Colors.white12
                            : Colors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 16,
                          color: isDark ? KashifColors.goldLight : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'أمان الحساب: الصق مفتاحك الشخصي الخاص من apinex.bond. يُحفظ المفتاح محلياً على هاتفك فقط لتجنب تعليق الحساب.',
                            style: KashifTypography.arabic(
                              fontSize: 10,
                              color: isDark
                                  ? KashifColors.darkTextMuted
                                  : KashifColors.lightTextMuted,
                            ),
                          ),
                        ),
                      ],
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

                  // Dropdown of Available / Server Models (Gemini & Claude prioritized)
                  Builder(
                    builder: (context) {
                      final modelItems = _getAvailableModelItems();
                      final currentVal = modelItems.any((m) => m['id'] == _selectedModelPreset)
                          ? _selectedModelPreset
                          : 'custom';

                      return Container(
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
                            value: currentVal,
                            dropdownColor: isDark
                                ? const Color(0xFF0F1E38)
                                : Colors.white,
                            items: modelItems.map((m) {
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
                                final modelToSave = val != 'custom'
                                    ? val
                                    : _apinexModelController.text.trim();
                                if (modelToSave.isNotEmpty) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .updateApinexSettings(model: modelToSave);
                                  KashifStorage.setApinexModel(modelToSave);
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                final clean = val.trim();
                                final match = _getAvailableModelItems()
                                    .any((m) => m['id'] == clean);
                                setState(() {
                                  _selectedModelPreset = match
                                      ? clean
                                      : 'custom';
                                });
                                if (clean.isNotEmpty) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .updateApinexSettings(model: clean);
                                  KashifStorage.setApinexModel(clean);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'free/gemini-3.8-flash',
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
                      const SizedBox(width: 8),
                      // Quick Apply/Save Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          final selected = _apinexModelController.text.trim();
                          final key = _apinexKeyController.text.trim();
                          ref
                              .read(settingsProvider.notifier)
                              .updateApinexSettings(
                                model: selected.isNotEmpty ? selected : null,
                                key: key,
                              );
                          if (selected.isNotEmpty) {
                            KashifStorage.setApinexModel(selected);
                          }
                          KashifStorage.setApinexApiKey(key);

                          final messenger = ScaffoldMessenger.of(context);
                          messenger.clearSnackBars();
                          if (key.isEmpty) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم حفظ النموذج ($selected) ✅ ولكن تنبيه: لم يتم إدخال مفتاح APInex بعد! يرجى لصق مفتاحك من apinex.bond لتفعيل الفحص.',
                                  style: KashifTypography.arabic(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.orange.shade800,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم حفظ وتفعيل النموذج ($selected) والمفتاح بنجاح ✅',
                                  style: KashifTypography.arabic(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF065F46),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: Text(
                          'تفعيل',
                          style: KashifTypography.arabic(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
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
                            horizontal: 10,
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
                          'فحص',
                          style: KashifTypography.arabic(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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

            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
                side: BorderSide(
                  color: (isDark ? KashifColors.goldPrimary : KashifColors.royalBlue).withValues(alpha: 0.5),
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('مسح الذاكرة وتحديث البيانات', style: KashifTypography.arabic(fontWeight: FontWeight.bold)),
                    content: Text(
                      'سيتم مسح التقارير وذاكرة قطع الغيار المؤقتة لإعادة قراءة وفحص التقارير بأحدث الأكواد والتحديثات فورياً. هل أنت متأكد؟',
                      style: KashifTypography.arabic(fontSize: 13),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('مسح الآن'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await KashifStorage.clearAllCaches();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم مسح الذاكرة المؤقتة بنجاح، التطبيق جاهز للفحص بأحدث التحديثات!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              label: Text(
                'تحديث ومسح الذاكرة المؤقتة (تحديث شامل)',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
                    'Flow Cars للأندرويد — ' + AppVersion.display,
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
                    'الرقم التسلسلي: ' + AppVersion.serial,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
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
