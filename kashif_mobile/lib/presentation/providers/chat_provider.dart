import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/network/api_client.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/repositories/offline_report_service.dart';
import '../../data/storage/hive_storage.dart';
import 'report_provider.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final bool isListening;
  final String? errorMessage;

  ChatState({
    this.messages = const [],
    this.isSending = false,
    this.isListening = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    bool? isListening,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isListening: isListening ?? this.isListening,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final KashifApiClient _apiClient;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;

  ChatNotifier({KashifApiClient? apiClient})
    : _apiClient = apiClient ?? KashifApiClient(),
      super(
        ChatState(
          messages: [
            ChatMessage(
              id: 'welcome',
              text:
                  'أهلاً بيك يا غالي في ورشة Flow Cars! أنا المساعد الذكي معاك، أي كود مش فاهمه أو تبي تسأل على قطعة وسعرها وطريقة فحصها بالليبي تفضل اسألني.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );

  /// Builds a lightweight compact context of the active report to save tokens
  Map<String, dynamic> _buildCompactReportContext(DiagnosticReport? report) {
    if (report == null) return {};
    final faults = [...report.criticalFaults, ...report.moderateFaults]
        .map(
          (f) => {
            'code': f.code,
            'module': f.module,
            'libyan': f.libyanTerm,
            'symptoms': f.driverSymptoms.take(2).toList(),
            'action': f.recommendedAction,
          },
        )
        .toList();

    return {
      'vehicle':
          '${report.vehicle.year} ${report.vehicle.make} ${report.vehicle.model}'
              .trim(),
      'vin': report.vehicle.vin,
      'faults': faults,
      'summary': report.summary.briefSummaryArabic,
    };
  }

  Future<void> sendMessage(String text, DiagnosticReport? report) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      text: cleanText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      clearError: true,
    );

    // 1. Instant Offline Knowledge Lookup (0 tokens / 0 API calls)
    // If the question mentions a specific standard OBD2 code and is relatively brief
    final dtcMatch = RegExp(r'\b([PBUCpbc][0-9]{4})\b').firstMatch(cleanText);
    if (dtcMatch != null && cleanText.length <= 40) {
      final code = dtcMatch.group(1)!.toUpperCase();
      final k = OfflineReportService.findCode(code);
      if (k != null) {
        final reply =
            '⚡ تشخيص فوري للكود ($code) من القاموس الليبي الداخلي:\n\n'
            '• المعنى بالليبي: ${k.libyanTerm}\n'
            '• الوصف: ${k.standardArabicDescription}\n'
            '• الأعراض: ${k.driverSymptoms.join("، ")}\n'
            '• الأسباب المتوقعة: ${k.rootCauses.join("، ")}\n'
            '• الإجراء الموصى به: ${k.recommendedAction}\n'
            '${k.partNameLibyan != null ? "• القطعة المقترحة: ${k.partNameLibyan} (${k.partPriceMin?.toStringAsFixed(0) ?? ''} - ${k.partPriceMax?.toStringAsFixed(0) ?? ''} د.ل)\n" : ""}'
            '\n💡 يمكنك سؤالي بمزيد من التفصيل إن أردت استشارة متقدمة.';

        final botMsg = ChatMessage(
          id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, botMsg],
          isSending: false,
        );
        return;
      }
    }

    try {
      final apiKey = KashifStorage.customApiKey;
      // 2. Token Economy: Compact report context instead of huge full JSON
      final reportContext = _buildCompactReportContext(report);

      // 3. Sliding Window History: Keep only last 6 messages to prevent token explosion
      final recentMessages = state.messages.length > 6
          ? state.messages.sublist(state.messages.length - 6)
          : state.messages;

      final history = recentMessages.map((m) {
        return {
          'role': m.isUser ? 'user' : 'model',
          'parts': [
            {'text': m.text},
          ],
        };
      }).toList();

      final reply = await _apiClient.sendChatMessage(
        message: cleanText,
        reportContext: reportContext,
        history: history,
        customApiKey: apiKey,
      );

      final botMsg = ChatMessage(
        id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleListening(Function(String) onTextRecognized) async {
    if (state.isListening) {
      await _speech.stop();
      state = state.copyWith(isListening: false);
      return;
    }

    if (!_speechInitialized) {
      _speechInitialized = await _speech.initialize(
        onError: (err) {
          state = state.copyWith(
            isListening: false,
            errorMessage: 'خطأ في التعرف على الصوت: ${err.errorMsg}',
          );
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            state = state.copyWith(isListening: false);
          }
        },
      );
    }

    if (_speechInitialized) {
      state = state.copyWith(isListening: true, clearError: true);
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
        ),
        onResult: (result) {
          onTextRecognized(result.recognizedWords);
          if (result.finalResult) {
            state = state.copyWith(isListening: false);
          }
        },
      );
    } else {
      state = state.copyWith(
        errorMessage: 'تعذر تهيئة الميكروفون للتعرف على الصوت، يرجى منح الإذن.',
      );
    }
  }

  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          id: 'welcome',
          text: 'تم مسح المحادثة. تفضل اسألني عن أي استفسار بخصوص سيارتك!',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final client = ref.watch(apiClientProvider);
  return ChatNotifier(apiClient: client);
});
