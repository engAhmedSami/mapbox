import 'package:flutter/material.dart';
import '../services/speech_service.dart';

class SpeechController with ChangeNotifier {
  final SpeechService _speechService = SpeechService();

  bool _isListening = false;
  bool get isListening => _isListening;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  String? _detectedCommand;
  String? get detectedCommand => _detectedCommand;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // تهيئة المتحكم
  Future<void> initialize() async {
    try {
      _isInitialized = await _speechService.initialize();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تهيئة خدمة التعرف على الكلام: $e';
      _isInitialized = false;
    }
    notifyListeners();
  }

  // بدء الاستماع إلى الأوامر الصوتية
  Future<void> startListening() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isInitialized && !_isListening) {
      _isListening = true;
      _recognizedText = '';
      _detectedCommand = null;
      notifyListeners();

      await _speechService.startListening(
        onResult: (text) {
          _recognizedText = text;
          _detectedCommand = _speechService.detectCommand(text);
          notifyListeners();
        },
        onListeningComplete: () {
          _isListening = false;
          notifyListeners();
        },
      );
    }
  }

  // إيقاف الاستماع
  void stopListening() {
    if (_isListening) {
      _speechService.stopListening();
      _isListening = false;
      notifyListeners();
    }
  }

  // اعادة ضبط النص والأمر المتعرف عليه
  void resetRecognition() {
    _recognizedText = '';
    _detectedCommand = null;
    notifyListeners();
  }

  // استخراج نص البحث من أمر "ابحث عن X"
  String? extractSearchQuery() {
    if (_detectedCommand != null && _detectedCommand!.startsWith('ابحث عن')) {
      return _detectedCommand!.substring('ابحث عن'.length).trim();
    }
    return null;
  }

  // التحقق إذا كان الأمر هو بدء التنقل
  bool isStartNavigationCommand() {
    return _detectedCommand == 'ابدأ التنقل';
  }

  // التحقق إذا كان الأمر هو إيقاف التنقل
  bool isStopNavigationCommand() {
    return _detectedCommand == 'توقف عن التنقل';
  }

  // التحقق إذا كان الأمر هو عرض الوقت
  bool isShowTimeCommand() {
    return _detectedCommand == 'اعرض الوقت';
  }

  // التحقق إذا كان الأمر هو عرض المسافة
  bool isShowDistanceCommand() {
    return _detectedCommand == 'كم المسافة';
  }

  // التحقق إذا كان الأمر هو عرض وقت الوصول المتوقع
  bool isShowETACommand() {
    return _detectedCommand == 'الوصول المتوقع';
  }
}
