// لا تنس إضافة هذا الاستيراد في أعلى الملف
import 'dart:math';
import 'route_step_model.dart';

class RouteModel {
  final List<List<double>> geometry;
  final double distance; // بالأمتار
  final double duration; // بالثواني
  final String startAddress;
  final String endAddress;
  final DateTime? estimatedArrivalTime;
  final List<RouteStepModel> steps; // قائمة خطوات الرحلة
  final RouteStepModel? nextStep; // الخطوة التالية للتنقل

  RouteModel({
    required this.geometry,
    required this.distance,
    required this.duration,
    required this.startAddress,
    required this.endAddress,
    this.estimatedArrivalTime,
    this.steps = const [],
    this.nextStep,
  });

  factory RouteModel.fromMapboxJson(
    Map<String, dynamic> json,
    String startAddress,
    String endAddress,
  ) {
    // استخراج المسار الهندسي (الإحداثيات)
    List<List<double>> decodedGeometry = [];
    List<RouteStepModel> routeSteps = [];
    RouteStepModel? nextRouteStep;

    if (json['routes'] != null && json['routes'].isNotEmpty) {
      final route = json['routes'][0];

      // فك تشفير تنسيق الخط المتعدد إلى قائمة من الإحداثيات
      if (route['geometry'] != null) {
        String encodedGeometry = route['geometry'];
        decodedGeometry = _decodePolyline(encodedGeometry);
      }

      double distance = route['distance']?.toDouble() ?? 0.0;
      double duration = route['duration']?.toDouble() ?? 0.0;

      // استخراج خطوات الرحلة
      if (route['legs'] != null && route['legs'].isNotEmpty) {
        final leg = route['legs'][0]; // نأخذ أول قسم من الرحلة

        if (leg['steps'] != null) {
          routeSteps =
              (leg['steps'] as List)
                  .map((step) => RouteStepModel.fromJson(step))
                  .toList();

          // تحديد الخطوة التالية (أول خطوة في القائمة)
          if (routeSteps.isNotEmpty) {
            nextRouteStep = routeSteps[0];
          }
        }
      }

      // حساب وقت الوصول المقدر
      DateTime now = DateTime.now();
      DateTime estimatedArrival = now.add(Duration(seconds: duration.round()));

      return RouteModel(
        geometry: decodedGeometry,
        distance: distance,
        duration: duration,
        startAddress: startAddress,
        endAddress: endAddress,
        estimatedArrivalTime: estimatedArrival,
        steps: routeSteps,
        nextStep: nextRouteStep,
      );
    }

    // إذا لم نجد مسارًا، نعيد نموذجًا فارغًا
    return RouteModel(
      geometry: decodedGeometry,
      distance: 0.0,
      duration: 0.0,
      startAddress: startAddress,
      endAddress: endAddress,
      steps: routeSteps,
    );
  }

  // تحويل polyline المشفر إلى قائمة إحداثيات
  static List<List<double>> _decodePolyline(String encoded) {
    List<List<double>> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latValue = lat / 1E5;
      double lngValue = lng / 1E5;
      points.add([lngValue, latValue]); // لاحظ أن Mapbox يستخدم [lng, lat]
    }
    return points;
  }

  // تحويل إلى تنسيق JSON
  Map<String, dynamic> toJson() {
    return {
      'geometry': geometry,
      'distance': distance,
      'duration': duration,
      'startAddress': startAddress,
      'endAddress': endAddress,
      'estimatedArrivalTime': estimatedArrivalTime?.toIso8601String(),
      'steps': steps.map((step) => step.toString()).toList(),
    };
  }

  // تحديث الخطوة التالية بناءً على الموقع الحالي
  RouteModel updateNextStep(double currentLat, double currentLng) {
    if (steps.isEmpty) {
      return this;
    }

    // حساب المسافة للخطوات وتحديد الخطوة التالية
    double minDistance = double.infinity;
    int nextStepIndex = 0;

    for (int i = 0; i < steps.length; i++) {
      if (steps[i].location.length < 2) continue;

      // حساب المسافة إلى موقع المناورة
      double stepLng = steps[i].location[0];
      double stepLat = steps[i].location[1];

      double distance = _calculateDistance(
        currentLat,
        currentLng,
        stepLat,
        stepLng,
      );

      // إذا كانت هذه المناورة هي الأقرب التي لم نتجاوزها بعد
      if (distance < minDistance && distance > 50) {
        // نحدد أننا لم نتجاوز المناورة إذا كانت المسافة > 50 متر
        minDistance = distance;
        nextStepIndex = i;
      }
    }

    // إنشاء نسخة جديدة من RouteModel مع تحديث nextStep
    return RouteModel(
      geometry: geometry,
      distance: distance,
      duration: duration,
      startAddress: startAddress,
      endAddress: endAddress,
      estimatedArrivalTime: estimatedArrivalTime,
      steps: steps,
      nextStep: steps[nextStepIndex],
    );
  }

  // حساب المسافة بين نقطتين باستخدام صيغة هافرساين
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // تحويل الدرجات إلى راديان
    double p = 0.017453292519943295; // Pi/180
    double a =
        0.5 -
        0.5 * cos((lat2 - lat1) * p) +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) * 0.5;
    return 12742 *
        1000 *
        asin(sqrt(a)); // 2 * R * asin(sqrt(a)) حيث R = 6371 كم
  }

  // إنشاء نموذج من JSON
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      geometry:
          (json['geometry'] as List)
              .map(
                (e) =>
                    (e as List<dynamic>)
                        .map((e) => e.toDouble())
                        .toList()
                        .cast<double>(),
              )
              .toList(),
      distance: json['distance'],
      duration: json['duration'],
      startAddress: json['startAddress'],
      endAddress: json['endAddress'],
      estimatedArrivalTime:
          json['estimatedArrivalTime'] != null
              ? DateTime.parse(json['estimatedArrivalTime'])
              : null,
      steps: [], // يمكن إضافة استخراج الخطوات من JSON إذا لزم الأمر
    );
  }

  // تنسيق المسافة بشكل مقروء
  String getFormattedDistance() {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} م';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} كم';
    }
  }

  // تنسيق الوقت بشكل مقروء
  String getFormattedDuration() {
    int minutes = (duration / 60).floor();
    int hours = (minutes / 60).floor();
    minutes = minutes % 60;

    if (hours > 0) {
      return '$hours ساعة ${minutes > 0 ? 'و $minutes دقيقة' : ''}';
    } else {
      return '$minutes دقيقة';
    }
  }

  // الحصول على وقت الوصول المقدر بتنسيق مقروء
  String getFormattedETA() {
    if (estimatedArrivalTime == null) {
      return 'غير متاح';
    }

    String hour = estimatedArrivalTime!.hour.toString().padLeft(2, '0');
    String minute = estimatedArrivalTime!.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
