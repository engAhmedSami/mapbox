import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import '../models/route_model.dart';
import '../models/place_model.dart';
import '../models/route_step_model.dart';

class MapboxService {
  // البحث عن أماكن بالاسم
  Future<List<PlaceModel>> searchPlaces(
    String query, {
    double? nearLat,
    double? nearLng,
  }) async {
    try {
      String proximity = '';
      if (nearLat != null && nearLng != null) {
        proximity = '&proximity=$nearLng,$nearLat';
      }

      final response = await http.get(
        Uri.parse(
          '${AppConstants.mapboxGeocodingUrl}/$query.json?access_token=${AppConstants.mapboxAccessToken}$proximity&language=ar',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> features = data['features'];

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
}
