class RouteModel {
  final List<List<double>> geometry;
  final double distance; // بالأمتار
  final double duration; // بالثواني
  final String startAddress;
  final String endAddress;
  final DateTime? estimatedArrivalTime;

  RouteModel({
    required this.geometry,
    required this.distance,
    required this.duration,
    required this.startAddress,
    required this.endAddress,
    this.estimatedArrivalTime,
  });

  factory RouteModel.fromMapboxJson(
    Map<String, dynamic> json,
    String startAddress,
    String endAddress,
  ) {
    // استخراج المسار الهندسي (الإحداثيات)
    List<List<double>> decodedGeometry = [];

    if (json['routes'] != null && json['routes'].isNotEmpty) {
      final route = json['routes'][0];

      // فك تشفير تنسيق الخط المتعدد إلى قائمة من الإحداثيات
      if (route['geometry'] != null) {
        String encodedGeometry = route['geometry'];
        decodedGeometry = _decodePolyline(encodedGeometry);
      }

      double distance = route['distance']?.toDouble() ?? 0.0;
      double duration = route['duration']?.toDouble() ?? 0.0;

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
      );
    }

    // إذا لم نجد مسارًا، نعيد نموذجًا فارغًا
    return RouteModel(
      geometry: decodedGeometry,
      distance: 0.0,
      duration: 0.0,
      startAddress: startAddress,
      endAddress: endAddress,
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
    };
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
