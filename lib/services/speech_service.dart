// ignore_for_file: avoid_print, deprecated_member_use

import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_constants.dart';

class SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;

  // تهيئة خدمة التعرف على الكلام
  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => print('خطأ في التعرف على الكلام: $error'),
        onStatus: (status) => print('حالة التعرف على الكلام: $status'),
      );
    }
    return _isInitialized;
  }

  // بدء الاستماع إلى الكلام
  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onListeningComplete,
  }) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) {
        print('فشل في تهيئة خدمة التعرف على الكلام');
        return;
      }
    }

    if (!_speechToText.isAvailable) {
      print('خدمة التعرف على الكلام غير متاحة');
      return;
    }

    if (!_speechToText.isListening) {
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            onResult(recognizedWords);
          }
        },
        localeId: 'ar_SA', // اللغة العربية
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        listenFor: const Duration(seconds: 10),
      );
    }

    // الاستماع حتى التوقف
    Future.delayed(const Duration(seconds: 5), () {
      if (_speechToText.isListening) {
        stopListening();
        onListeningComplete();
      }
    });
  }

  // إيقاف الاستماع
  void stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
  }

  // التحقق مما إذا كان النص المعترف به يتضمن أمرًا معروفًا
  String? detectCommand(String recognizedText) {
    recognizedText = recognizedText.trim().toLowerCase();

    for (String command in AppConstants.navigationCommands) {
      if (recognizedText.contains(command.toLowerCase())) {
        return command;
      }
    }

    // البحث عن نمط "ابحث عن X"
    if (recognizedText.contains('ابحث عن')) {
      final searchQuery = recognizedText.split('ابحث عن')[1].trim();
      if (searchQuery.isNotEmpty) {
        return 'ابحث عن $searchQuery';
      }
    }

    return null;
  }

  // التحقق من حالة الاستماع
  bool get isListening => _speechToText.isListening;
}
