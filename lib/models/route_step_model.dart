import 'package:flutter/material.dart';

class RouteStepModel {
  final String instruction; // النص الوصفي للخطوة (مثل "توجه يمينًا")
  final double distance; // المسافة لهذه الخطوة (بالأمتار)
  final double duration; // الوقت المقدر لهذه الخطوة (بالثواني)
  final String maneuver; // نوع المناورة (مثل turn-right, turn-left, etc.)
  final List<double> location; // موقع المناورة [lng, lat]
  final String name; // اسم الشارع أو الطريق
  final String? modifier; // تفاصيل إضافية عن المناورة (مثل sharp, slight)

  RouteStepModel({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.maneuver,
    required this.location,
    required this.name,
    this.modifier,
  });

  factory RouteStepModel.fromJson(Map<String, dynamic> json) {
    return RouteStepModel(
      instruction: json['instruction'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toDouble(),
      maneuver: json['maneuver']?['type'] ?? '',
      location:
          (json['maneuver']?['location'] as List<dynamic>?)
              ?.whereType<num>()
              .map((e) => (e).toDouble())
              .toList() ??
          [],
      name: json['name'] ?? '',
      modifier: json['maneuver']?['modifier'],
    );
  }

  // تحويل المسافة إلى صيغة مقروءة
  String getFormattedDistance() {
    if (distance < 1000) {
      return '${distance.round()} م';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} كم';
    }
  }

  // الحصول على أيقونة مناسبة لنوع المناورة
  IconData getManeuverIcon() {
    switch (maneuver) {
      case 'turn':
        if (modifier == 'right') return Icons.turn_right;
        if (modifier == 'left') return Icons.turn_left;
        if (modifier == 'sharp right') return Icons.turn_sharp_right;
        if (modifier == 'sharp left') return Icons.turn_sharp_left;
        if (modifier == 'slight right') return Icons.turn_slight_right;
        if (modifier == 'slight left') return Icons.turn_slight_left;
        return Icons.turn_right;
      case 'merge':
        return Icons.merge;
      case 'ramp':
        return Icons.exit_to_app;
      case 'fork':
        return Icons.fork_right;
      case 'roundabout':
        return Icons.roundabout_right;
      case 'arrive':
        return Icons.place;
      case 'depart':
        return Icons.directions_car;
      default:
        return Icons.straight;
    }
  }

  // الحصول على وصف بسيط للمناورة بالعربية
  String getSimpleDirection() {
    switch (maneuver) {
      case 'turn':
        if (modifier == 'right') return 'انعطف يمينًا';
        if (modifier == 'left') return 'انعطف يسارًا';
        if (modifier == 'sharp right') return 'انعطف يمينًا بحدة';
        if (modifier == 'sharp left') return 'انعطف يسارًا بحدة';
        if (modifier == 'slight right') return 'انعطف يمينًا قليلاً';
        if (modifier == 'slight left') return 'انعطف يسارًا قليلاً';
        return 'انعطف';
      case 'straight':
        return 'استمر مباشرة';
      case 'merge':
        return 'اندمج';
      case 'ramp':
        return 'اخرج';
      case 'fork':
        if (modifier == 'right') return 'خذ المسار الأيمن';
        if (modifier == 'left') return 'خذ المسار الأيسر';
        return 'تفرع';
      case 'roundabout':
        return 'ادخل الدوار';
      case 'exit roundabout':
        return 'اخرج من الدوار';
      case 'arrive':
        return 'وصلت إلى الوجهة';
      case 'depart':
        return 'ابدأ';
      default:
        return 'استمر';
    }
  }

  @override
  String toString() {
    return 'RouteStepModel(instruction: $instruction, distance: $distance, maneuver: $maneuver)';
  }
}
