import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../providers/chat_provider.dart';
import '../providers/report_provider.dart';
import '../widgets/fuse_cell.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    'شن أول حاجة نفحصها في الكود هذا؟',
    'هل السيارة آمنة للسفر مسافة 200 كم؟',
    'كم سعر القطعة التقريبية في سوق الورش؟',
    'وين مكان الحساس في الموتوري؟',
    'هل تنصحني نغير الحساس ولا ننظفه بس؟',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? promptText]) {
    final text = promptText ?? _controller.text;
    if (text.trim().isEmpty) return;

    final report = ref.read(reportProvider).report;
    ref.read(chatProvider.notifier).sendMessage(text, report);
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleDictation() {
    ref.read(chatProvider.notifier).toggleListening((recognizedText) {
      setState(() {
        _controller.text = recognizedText;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatState = ref.watch(chatProvider);
    final report = ref.watch(reportProvider).report;

    return Scaffold(
      body: Column(
        children: [
          // Report Context Banner if report is active
          if (report != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
              child: Row(
                children: [
                  Icon(Icons.directions_car_rounded, size: 16, color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الأسطى مطلع على تقرير: ${report.vehicle.make} ${report.vehicle.model} (${report.totalFaultsCount} أعطال)',
                      style: KashifTypography.arabic(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                return _buildMessageBubble(msg, isDark);
              },
            ),
          ),

          // Sending loading indicator
          if (chatState.isSending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الأسطى يكتب الرد بالمصطلحات الليبية...',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),

          // Error banner if any
          if (chatState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Text(
                chatState.errorMessage!,
                style: KashifTypography.arabic(fontSize: 11, color: KashifColors.fuse10ATab),
              ),
            ),

          // Quick Prompts Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickPrompts.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final p = _quickPrompts[index];
                return ActionChip(
                  label: Text(
                    p,
                    style: KashifTypography.arabic(fontSize: 11),
                  ),
                  backgroundColor: isDark ? KashifColors.darkCell : KashifColors.lightCell,
                  side: BorderSide(
                    color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
                    width: 0.8,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  onPressed: chatState.isSending ? null : () => _sendMessage(p),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Input Bar with Speech Dictation & Send
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
              border: Border(
                top: BorderSide(
                  color: isDark ? KashifColors.darkRib : KashifColors.lightRib,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Speech Dictation Button
                IconButton(
                  icon: Icon(
                    chatState.isListening ? Icons.mic : Icons.mic_none,
                    color: chatState.isListening
                        ? KashifColors.fuse10ATab
                        : (isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
                  ),
                  tooltip: 'إملاء صوتي',
                  onPressed: _toggleDictation,
                ),
                // Text Input
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: KashifTypography.arabic(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: chatState.isListening ? 'تحدث الآن... جاري الاستماع' : 'اسأل الأسطى عن أي عطل أو قطعة...',
                      hintStyle: KashifTypography.arabic(
                        fontSize: 12,
                        color: chatState.isListening ? KashifColors.fuse10ATab : Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                // Send Button
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  ),
                  tooltip: 'إرسال',
                  onPressed: chatState.isSending ? null : () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isDark) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: const BoxConstraints(maxWidth: 320),
        child: FuseCell(
          backgroundColor: isUser
              ? (isDark ? const Color(0xFF132333) : const Color(0xFFE4F0FA))
              : (isDark ? KashifColors.darkCell : KashifColors.lightCell),
          customBorder: Border.all(
            color: isUser
                ? (isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight)
                : (isDark ? KashifColors.darkBorder : KashifColors.lightBorder),
            width: 0.8,
          ),
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUser ? Icons.person_outline : Icons.engineering_outlined,
                    size: 14,
                    color: isUser
                        ? (isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight)
                        : KashifColors.fuse20ATab,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isUser ? 'أنت' : 'الأسطى الذكي',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUser
                          ? (isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight)
                          : KashifColors.fuse20ATab,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                msg.text,
                style: KashifTypography.arabic(
                  fontSize: 13,
                  height: 1.45,
                  color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
