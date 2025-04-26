// lib/controllers/speech_controller.dart
// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_constants.dart';
import '../services/mapbox_service.dart';
import '../models/place_model.dart';
import 'location_controller.dart';

class SpeechController with ChangeNotifier {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final MapboxService _mapboxService = MapboxService();
  bool _isInitialized = false;

  // قائمة محلية بالأوامر الإضافية (حتى إذا لم يتم تحديثها في AppConstants)
  final List<String> _additionalCommands = [
    'أماكن قريبة',
    'أقرب مطعم',
    'أقرب مستشفى',
    'أقرب مدرسة',
    'أقرب جامعة',
    'أقرب مركز تسوق',
    'أقرب فندق',
    'أقرب مسجد',
    'أقرب صيدلية',
    'مطعم قريب',
    'مستشفى قريب',
  ];

  bool _isListening = false;
  bool get isListening => _isListening;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  String? _detectedCommand;
  String? get detectedCommand => _detectedCommand;

  bool _isInitializing = false;
  bool get isInitialized => _isInitialized;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // إضافة للاحتفاظ بنتائج البحث عن الأماكن
  List<PlaceModel> _searchResults = [];
  List<PlaceModel> get searchResults => _searchResults;
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // متغير لتتبع نوع البحث الحالي
  String? _searchType;
  String? get searchType => _searchType;

  // تهيئة المتحكم
  Future<bool> initialize() async {
    if (_isInitializing) return _isInitialized;

    _isInitializing = true;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => print('خطأ في التعرف على الكلام: $error'),
        onStatus: (status) => print('حالة التعرف على الكلام: $status'),
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تهيئة خدمة التعرف على الكلام: $e';
      _isInitialized = false;
    }
    _isInitializing = false;
    notifyListeners();

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
            _recognizedText = recognizedWords;
            _detectedCommand = detectCommand(recognizedWords);
            onResult(recognizedWords);
            notifyListeners();
          }
        },
        localeId: 'ar_SA', // اللغة العربية
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        listenFor: const Duration(seconds: 10),
      );

      _isListening = true;
      notifyListeners();
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
      _isListening = false;
      notifyListeners();
    }
  }

  // التحقق مما إذا كان النص المعترف به يتضمن أمرًا معروفًا
  String? detectCommand(String recognizedText) {
    recognizedText = recognizedText.trim().toLowerCase();

    // التحقق من الأوامر الرئيسية الموجودة في AppConstants
    for (String command in AppConstants.navigationCommands) {
      if (recognizedText.contains(command.toLowerCase())) {
        return command;
      }
    }

    // التحقق من الأوامر الإضافية
    for (String command in _additionalCommands) {
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

    // أوامر خاصة بالوجهات (يمكن أن يقول المستخدم "خذني إلى X")
    if (recognizedText.contains('خذني إلى') ||
        recognizedText.contains('اذهب إلى') ||
        recognizedText.contains('توجه إلى')) {
      String destinationQuery = "";

      if (recognizedText.contains('خذني إلى')) {
        destinationQuery = recognizedText.split('خذني إلى')[1].trim();
      } else if (recognizedText.contains('اذهب إلى')) {
        destinationQuery = recognizedText.split('اذهب إلى')[1].trim();
      } else if (recognizedText.contains('توجه إلى')) {
        destinationQuery = recognizedText.split('توجه إلى')[1].trim();
      }

      if (destinationQuery.isNotEmpty) {
        return 'توجه إلى $destinationQuery';
      }
    }

    return null;
  }

  // البحث عن أماكن بناءً على الأمر الصوتي
  Future<List<PlaceModel>> searchPlacesByVoiceCommand(
    BuildContext context,
    String command,
  ) async {
    _isSearching = true;
    _searchResults = [];
    _searchType = null;
    notifyListeners();

    try {
      final locationController = Provider.of<LocationController>(
        context,
        listen: false,
      );

      double? nearLat, nearLng;
      if (locationController.currentLocation != null) {
        nearLat = locationController.currentLocation!.latitude;
        nearLng = locationController.currentLocation!.longitude;
      } else {
        await locationController.updateCurrentLocation();
        if (locationController.currentLocation != null) {
          nearLat = locationController.currentLocation!.latitude;
          nearLng = locationController.currentLocation!.longitude;
        }
      }

      // إذا لم نتمكن من الحصول على الموقع الحالي
      if (nearLat == null || nearLng == null) {
        _errorMessage = 'غير قادر على تحديد موقعك الحالي';
        _isSearching = false;
        notifyListeners();
        return [];
      }

      String searchQuery = "";

      // البحث عن "ابحث عن X"
      if (command.startsWith('ابحث عن')) {
        searchQuery = command.substring('ابحث عن'.length).trim();
        _searchType = 'general';
      }
      // البحث عن "توجه إلى X"
      else if (command.startsWith('توجه إلى')) {
        searchQuery = command.substring('توجه إلى'.length).trim();
        _searchType = 'destination';
      }
      // البحث عن نوع محدد من الأماكن القريبة
      else if (command.contains('أقرب') || command.endsWith('قريب')) {
        if (command.contains('مطعم')) {
          searchQuery = 'مطعم';
          _searchType = 'nearest_restaurant';
        } else if (command.contains('مستشفى')) {
          searchQuery = 'مستشفى';
          _searchType = 'nearest_hospital';
        } else if (command.contains('مدرسة')) {
          searchQuery = 'مدرسة';
          _searchType = 'nearest_school';
        } else if (command.contains('جامعة')) {
          searchQuery = 'جامعة';
          _searchType = 'nearest_university';
        } else if (command.contains('مركز تسوق') || command.contains('مول')) {
          searchQuery = 'مركز تسوق';
          _searchType = 'nearest_mall';
        } else if (command.contains('فندق')) {
          searchQuery = 'فندق';
          _searchType = 'nearest_hotel';
        } else if (command.contains('مسجد')) {
          searchQuery = 'مسجد';
          _searchType = 'nearest_mosque';
        } else if (command.contains('صيدلية')) {
          searchQuery = 'صيدلية';
          _searchType = 'nearest_pharmacy';
        }
      }
      // البحث عن أماكن قريبة بشكل عام
      else if (command == 'أماكن قريبة') {
        searchQuery = ''; // بحث فارغ للحصول على الأماكن القريبة
        _searchType = 'nearby_places';
      }

      if (searchQuery.isEmpty && _searchType != 'nearby_places') {
        _errorMessage = 'لم يتم تحديد استعلام البحث بشكل صحيح';
        _isSearching = false;
        notifyListeners();
        return [];
      }

      // البحث عن الأماكن
      List<PlaceModel> results = await _mapboxService.searchPlaces(
        searchQuery,
        nearLat: nearLat,
        nearLng: nearLng,
        limit: 10,
        radius: 5000, // 5 كيلومتر
      );

      _searchResults = results;
      _isSearching = false;
      _errorMessage = null;
      notifyListeners();

      return results;
    } catch (e) {
      print('خطأ في البحث عن الأماكن: $e');
      _errorMessage = 'حدث خطأ أثناء البحث: $e';
      _isSearching = false;
      notifyListeners();
      return [];
    }
  }

  // اعادة ضبط النص والأمر المتعرف عليه
  void resetRecognition() {
    _recognizedText = '';
    _detectedCommand = null;
    _searchResults = [];
    _searchType = null;
    _errorMessage = null;
    notifyListeners();
  }

  // استخراج نص البحث من أمر "ابحث عن X"
  String? extractSearchQuery() {
    if (_detectedCommand != null && _detectedCommand!.startsWith('ابحث عن')) {
      return _detectedCommand!.substring('ابحث عن'.length).trim();
    }
    return null;
  }

  // استخراج وجهة من أمر "توجه إلى X"
  String? extractDestinationQuery() {
    if (_detectedCommand != null && _detectedCommand!.startsWith('توجه إلى')) {
      return _detectedCommand!.substring('توجه إلى'.length).trim();
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

  // التحقق إذا كان الأمر هو البحث عن أماكن قريبة
  bool isNearbyPlacesCommand() {
    return _detectedCommand == 'أماكن قريبة';
  }

  // التحقق إذا كان الأمر هو البحث عن نوع محدد من الأماكن القريبة
  bool isSpecificNearbyPlaceCommand() {
    if (_detectedCommand == null) return false;

    return _detectedCommand!.contains('أقرب') ||
        (_detectedCommand!.contains('قريب') &&
            !_detectedCommand!.startsWith('ابحث عن'));
  }

  // التحقق إذا كان الأمر هو توجيه إلى وجهة محددة
  bool isGoToDestinationCommand() {
    if (_detectedCommand == null) return false;

    return _detectedCommand!.startsWith('توجه إلى') ||
        _detectedCommand!.startsWith('خذني إلى') ||
        _detectedCommand!.startsWith('اذهب إلى');
  }
}
