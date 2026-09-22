import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/network/api_client.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/diagnostic_report.dart';
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
                    'أهلاً بيك يا غالي في ورشة كاشف AI! أنا الأسطى الذكي معاك، أي كود مش فاهمه أو تبي تسأل على قطعة وسعرها وطريقة فحصها بالليبي تفضل اسألني.',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  Future<void> sendMessage(String text, DiagnosticReport? report) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      clearError: true,
    );

    try {
      final apiKey = KashifStorage.customApiKey;
      final reportContext = report?.toJson() ?? {};

      // Prepare history
      final history = state.messages.map((m) {
        return {
          'role': m.isUser ? 'user' : 'model',
          'parts': [{'text': m.text}],
        };
      }).toList();

      final reply = await _apiClient.sendChatMessage(
        message: text.trim(),
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
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      );
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
          state = state.copyWith(isListening: false, errorMessage: 'خطأ في التعرف على الصوت: ${err.errorMsg}');
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
