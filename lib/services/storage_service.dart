import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';
import '../models/place_model.dart';

class StorageService {
  // حفظ البحث الأخير
  Future<void> saveRecentSearch(PlaceModel place) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // الحصول على قائمة البحث الأخيرة
      List<String> recentSearches =
          prefs.getStringList(AppConstants.recentSearchesKey) ?? [];

      // تحويل PlaceModel إلى JSON ثم إلى string
      final String placeJson = jsonEncode(place.toJson());

      // إزالة المكان إذا كان موجودًا بالفعل لتجنب التكرار
      recentSearches.removeWhere((item) {
        try {
          final Map<String, dynamic> itemMap = jsonDecode(item);
          final PlaceModel existingPlace = PlaceModel.fromJson(itemMap);
          return existingPlace.id == place.id;
        } catch (e) {
          return false;
        }
      });

      // إضافة المكان الجديد في المقدمة
      recentSearches.insert(0, placeJson);

      // الاحتفاظ بأحدث 10 عمليات بحث فقط
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.sublist(0, 10);
      }

      // حفظ القائمة المحدثة
      await prefs.setStringList(AppConstants.recentSearchesKey, recentSearches);
    } catch (e) {
      log('خطأ في حفظ البحث الأخير: $e');
    }
  }

  // الحصول على قائمة البحث الأخيرة
  Future<List<PlaceModel>> getRecentSearches() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> recentSearches =
          prefs.getStringList(AppConstants.recentSearchesKey) ?? [];

      return recentSearches
          .map((item) {
            try {
              final Map<String, dynamic> itemMap = jsonDecode(item);
              return PlaceModel.fromJson(itemMap);
            } catch (e) {
              log('خطأ في تحليل عنصر البحث: $e');
              return null;
            }
          })
          .where((place) => place != null)
          .cast<PlaceModel>()
          .toList();
    } catch (e) {
      log('خطأ في الحصول على البحث الأخير: $e');
      return [];
    }
  }

  // حفظ الموقع المفضل
  Future<void> saveFavoriteLocation(PlaceModel place) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // الحصول على قائمة المواقع المفضلة
      List<String> favoriteLocations =
          prefs.getStringList(AppConstants.favoriteLocationsKey) ?? [];

      // تحويل PlaceModel إلى JSON ثم إلى string
      place = place.copyWith(isFavorite: true);
      final String placeJson = jsonEncode(place.toJson());

      // إزالة المكان إذا كان موجودًا بالفعل لتجنب التكرار
      favoriteLocations.removeWhere((item) {
        try {
          final Map<String, dynamic> itemMap = jsonDecode(item);
          final PlaceModel existingPlace = PlaceModel.fromJson(itemMap);
          return existingPlace.id == place.id;
        } catch (e) {
          return false;
        }
      });

      // إضافة المكان الجديد في المقدمة
      favoriteLocations.insert(0, placeJson);

      // حفظ القائمة المحدثة
      await prefs.setStringList(
        AppConstants.favoriteLocationsKey,
        favoriteLocations,
      );
    } catch (e) {
      log('خطأ في حفظ الموقع المفضل: $e');
    }
  }

  // الحصول على قائمة المواقع المفضلة
  Future<List<PlaceModel>> getFavoriteLocations() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> favoriteLocations =
          prefs.getStringList(AppConstants.favoriteLocationsKey) ?? [];

      return favoriteLocations
          .map((item) {
            try {
              final Map<String, dynamic> itemMap = jsonDecode(item);
              return PlaceModel.fromJson(itemMap);
            } catch (e) {
              log('خطأ في تحليل عنصر مفضل: $e');
              return null;
            }
          })
          .where((place) => place != null)
          .cast<PlaceModel>()
          .toList();
    } catch (e) {
      log('خطأ في الحصول على المواقع المفضلة: $e');
      return [];
    }
  }

  // إزالة موقع من المفضلة
  Future<void> removeFavoriteLocation(String placeId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> favoriteLocations =
          prefs.getStringList(AppConstants.favoriteLocationsKey) ?? [];

      favoriteLocations.removeWhere((item) {
        try {
          final Map<String, dynamic> itemMap = jsonDecode(item);
          final PlaceModel existingPlace = PlaceModel.fromJson(itemMap);
          return existingPlace.id == placeId;
        } catch (e) {
          return false;
        }
      });

      await prefs.setStringList(
        AppConstants.favoriteLocationsKey,
        favoriteLocations,
      );
    } catch (e) {
      log('خطأ في إزالة الموقع المفضل: $e');
    }
  }

  // مسح الكاش
  Future<void> clearAllData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.recentSearchesKey);
      await prefs.remove(AppConstants.favoriteLocationsKey);
    } catch (e) {
      log('خطأ في مسح البيانات: $e');
    }
  }

  // حفظ وضع السمة (فاتح/داكن)
  Future<void> saveThemeMode(bool isDarkMode) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, isDarkMode);
    } catch (e) {
      log('خطأ في حفظ وضع السمة: $e');
    }
  }

  // الحصول على وضع السمة المحفوظ
  Future<bool> getThemeMode() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.themeKey) ?? false;
    } catch (e) {
      log('خطأ في الحصول على وضع السمة: $e');
      return false;
    }
  }
}
