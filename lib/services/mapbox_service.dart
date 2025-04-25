import 'dart:convert';
import 'dart:developer';
import 'dart:math' as a;
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import '../models/route_model.dart';
import '../models/place_model.dart';
import '../models/route_step_model.dart';

class MapboxService {
  // البحث عن أماكن بالاسم مع خيارات إضافية
  Future<List<PlaceModel>> searchPlaces(
    String query, {
    double? nearLat,
    double? nearLng,
    int limit = 10,
    double radius = 1000, // الشعاع بالأمتار
  }) async {
    try {
      // بناء معلمات التقرب إذا تم توفير الموقع
      String proximity = '';
      if (nearLat != null && nearLng != null) {
        proximity = '&proximity=$nearLng,$nearLat';
      }

      // إضافة معلمات الحد والتصفية بناءً على النطاق
      String limitParam = '&limit=$limit';

      // البحث إذا كان الاستعلام غير فارغ، أو الحصول على الأماكن القريبة
      String url = '';
      if (query.isNotEmpty) {
        url =
            '${AppConstants.mapboxGeocodingUrl}/$query.json?access_token=${AppConstants.mapboxAccessToken}$proximity$limitParam&language=ar';
      } else if (nearLat != null && nearLng != null) {
        // في حالة الاستعلام الفارغ، استخدم موقع المستخدم للحصول على الأماكن القريبة
        url =
            '${AppConstants.mapboxGeocodingUrl}/@$nearLng,$nearLat.json?access_token=${AppConstants.mapboxAccessToken}&types=poi&radius=$radius$limitParam&language=ar';
      } else {
        throw Exception('يجب توفير استعلام أو موقع قريب للبحث');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> features = data['features'];

        // تحويل النتائج إلى نماذج الأماكن
        return features
            .map((feature) => PlaceModel.fromMapboxJson(feature))
            .toList();
      } else {
        throw Exception('فشل في البحث: ${response.statusCode}');
      }
    } catch (e) {
      log('خطأ في البحث عن أماكن: $e');
      return [];
    }
  }

  // الحصول على مسار بين نقطتين
  Future<RouteModel?> getRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
    String startAddress,
    String endAddress,
  ) async {
    try {
      // تعديل طلب API ليشمل تفاصيل خطوات الرحلة
      final response = await http.get(
        Uri.parse(
          '${AppConstants.mapboxDirectionsUrl}/$startLng,$startLat;$endLng,$endLat?geometries=polyline&access_token=${AppConstants.mapboxAccessToken}&overview=full&steps=true&language=ar&alternatives=false&annotations=duration,distance,speed',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RouteModel.fromMapboxJson(data, startAddress, endAddress);
      } else {
        log('فشل في الحصول على المسار: ${response.statusCode}');
        log('استجابة API: ${response.body}');
        throw Exception('فشل في الحصول على المسار: ${response.statusCode}');
      }
    } catch (e) {
      log('خطأ في الحصول على المسار: $e');
      return null;
    }
  }

  // الحصول على وقت الوصول المقدر
  Future<DateTime?> getEstimatedArrivalTime(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final route = await getRoute(
        startLat,
        startLng,
        endLat,
        endLng,
        'موقعك الحالي',
        'الوجهة',
      );

      if (route != null) {
        return route.estimatedArrivalTime;
      }

      return null;
    } catch (e) {
      log('خطأ في حساب وقت الوصول المقدر: $e');
      return null;
    }
  }

  // الحصول على خطوات الرحلة
  Future<List<RouteStepModel>> getRouteSteps(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final route = await getRoute(
        startLat,
        startLng,
        endLat,
        endLng,
        'موقعك الحالي',
        'الوجهة',
      );

      if (route != null) {
        return route.steps;
      }

      return [];
    } catch (e) {
      log('خطأ في الحصول على خطوات الرحلة: $e');
      return [];
    }
  }

  // الحصول على تفاصيل مكان بواسطة المعرف
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.mapboxGeocodingUrl}/$placeId.json?access_token=${AppConstants.mapboxAccessToken}&language=ar',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        log('فشل في الحصول على تفاصيل المكان: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('خطأ في الحصول على تفاصيل المكان: $e');
      return null;
    }
  }

  // البحث عن المباني داخل حرم جامعي أو مؤسسة
  Future<List<PlaceModel>> searchBuildingsInCampus(
    String campusName,
    double campusLat,
    double campusLng,
  ) async {
    try {
      // البحث عن المباني باستخدام اسم الحرم
      final results = await searchPlaces(
        '$campusName مبنى',
        nearLat: campusLat,
        nearLng: campusLng,
        limit: 50,
        radius: 1000, // 1 كم
      );

      // فلترة النتائج للتأكد من أنها مباني داخل الحرم الجامعي
      final filteredResults =
          results.where((place) {
            final name = place.placeName.toLowerCase();
            final address = place.address.toLowerCase();
            final campusNameLower = campusName.toLowerCase();

            // التحقق من أن المبنى مرتبط بالحرم الجامعي
            return name.contains(campusNameLower) ||
                address.contains(campusNameLower) ||
                name.contains('مبنى') ||
                name.contains('كلية') ||
                name.contains('قاعة');
          }).toList();

      return filteredResults;
    } catch (e) {
      log('خطأ في البحث عن المباني داخل الحرم الجامعي: $e');
      return [];
    }
  }

  // إضافة طريقة جديدة للبحث عن المباني والقاعات داخل مؤسسة كبيرة
  Future<List<PlaceModel>> searchInternalBuildings(PlaceModel place) async {
    try {
      // استخدام مجموعة متنوعة من الكلمات المفتاحية للعثور على المباني الداخلية
      final List<String> keywords = [
        'مبنى',
        'قاعة',
        'كلية',
        'قسم',
        'مركز',
        'مدخل',
        'بوابة',
        'معمل',
        'مختبر',
      ];

      List<PlaceModel> allBuildings = [];

      // البحث باستخدام كل كلمة مفتاحية
      for (String keyword in keywords) {
        final results = await searchPlaces(
          '${place.placeName} $keyword',
          nearLat: place.latitude,
          nearLng: place.longitude,
          limit: 20,
          radius: 1000, // 1 كم
        );

        // إضافة النتائج إلى القائمة الإجمالية
        allBuildings.addAll(results);
      }

      // إزالة التكرارات باستخدام معرف المكان
      final uniqueBuildings = <String, PlaceModel>{};
      for (var building in allBuildings) {
        uniqueBuildings[building.id] = building;
      }

      // تحويل القائمة مرة أخرى إلى قائمة
      return uniqueBuildings.values.toList();
    } catch (e) {
      log('خطأ في البحث عن المباني الداخلية: $e');
      return [];
    }
  }

  // البحث عن الأماكن القريبة بناءً على الفئة
  Future<List<PlaceModel>> searchNearbyPlacesByCategory(
    String category,
    double lat,
    double lng, {
    int limit = 10,
    double radius = 1000,
  }) async {
    try {
      // استخدام استعلام فئة محددة للبحث
      final results = await searchPlaces(
        category,
        nearLat: lat,
        nearLng: lng,
        limit: limit,
        radius: radius,
      );

      return results;
    } catch (e) {
      log('خطأ في البحث عن الأماكن القريبة بواسطة الفئة: $e');
      return [];
    }
  }

  // الحصول على تفاصيل المباني في منطقة معينة بناءً على حدود الخريطة
  Future<List<PlaceModel>> getBuildingsInBounds(
    double swLat,
    double swLng,
    double neLat,
    double neLng,
  ) async {
    try {
      // حساب المركز
      final centerLat = (swLat + neLat) / 2;
      final centerLng = (swLng + neLng) / 2;

      // حساب المسافة القطرية (تقريبي)
      final double radius = _calculateDistance(swLat, swLng, neLat, neLng) / 2;

      // البحث عن المباني بالقرب من المركز
      final results = await searchPlaces(
        'مبنى',
        nearLat: centerLat,
        nearLng: centerLng,
        limit: 50,
        radius: radius,
      );

      return results;
    } catch (e) {
      log('خطأ في الحصول على المباني ضمن الحدود: $e');
      return [];
    }
  }

  // حساب المسافة بين نقطتين بالمتر
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // متر
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2));
    double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  // تحويل الدرجات إلى راديان
  double _degToRad(double deg) {
    return deg * (math.pi / 180);
  }
}
