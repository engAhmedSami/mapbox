import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../services/storage_service.dart';

class StorageController with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<PlaceModel> _recentSearches = [];
  List<PlaceModel> get recentSearches => _recentSearches;

  List<PlaceModel> _favoriteLocations = [];
  List<PlaceModel> get favoriteLocations => _favoriteLocations;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // تهيئة المتحكم
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadRecentSearches(),
        _loadFavoriteLocations(),
        _loadThemeMode(),
      ]);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تهيئة بيانات التخزين: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحميل عمليات البحث الأخيرة
  Future<void> _loadRecentSearches() async {
    try {
      _recentSearches = await _storageService.getRecentSearches();
    } catch (e) {
      log('خطأ في تحميل عمليات البحث الأخيرة: $e');
      _recentSearches = [];
    }
  }

  // تحميل المواقع المفضلة
  Future<void> _loadFavoriteLocations() async {
    try {
      _favoriteLocations = await _storageService.getFavoriteLocations();
    } catch (e) {
      log('خطأ في تحميل المواقع المفضلة: $e');
      _favoriteLocations = [];
    }
  }

  // تحميل وضع السمة
  Future<void> _loadThemeMode() async {
    try {
      _isDarkMode = await _storageService.getThemeMode();
    } catch (e) {
      log('خطأ في تحميل وضع السمة: $e');
      _isDarkMode = false;
    }
  }

  // حفظ عملية بحث جديدة
  Future<void> saveRecentSearch(PlaceModel place) async {
    await _storageService.saveRecentSearch(place);
    await _loadRecentSearches();
    notifyListeners();
  }

  // إضافة موقع إلى المفضلة
  Future<void> addFavoriteLocation(PlaceModel place) async {
    await _storageService.saveFavoriteLocation(place);
    await _loadFavoriteLocations();
    notifyListeners();
  }

  // إزالة موقع من المفضلة
  Future<void> removeFavoriteLocation(String placeId) async {
    await _storageService.removeFavoriteLocation(placeId);
    await _loadFavoriteLocations();
    notifyListeners();
  }

  // التحقق مما إذا كان المكان مفضلاً
  bool isFavoriteLocation(String placeId) {
    return _favoriteLocations.any((place) => place.id == placeId);
  }

  // تبديل وضع السمة
  Future<void> toggleThemeMode() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  // مسح الكاش
  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.clearAllData();
      _recentSearches = [];
      _favoriteLocations = [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء مسح البيانات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
