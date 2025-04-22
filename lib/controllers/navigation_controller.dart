import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../models/place_model.dart';
import '../../models/route_model.dart';
import '../../models/route_step_model.dart';
import '../../services/location_service.dart';
import '../../services/mapbox_service.dart';

class NavigationController with ChangeNotifier {
  final MapboxService _mapboxService = MapboxService();
  final LocationService _locationService = LocationService();

  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RouteModel? _currentRoute;
  RouteModel? get currentRoute => _currentRoute;

  PlaceModel? _destination;
  PlaceModel? get destination => _destination;

  LocationModel? _currentLocation;
  LocationModel? get currentLocation => _currentLocation;

  StreamSubscription<LocationModel>? _locationSubscription;
  Timer? _etaTimer;
  Timer? _nextStepUpdateTimer; // مؤقت لتحديث الخطوة التالية

  DateTime? _estimatedArrivalTime;
  DateTime? get estimatedArrivalTime => _estimatedArrivalTime;

  double _distanceRemaining = 0;
  double get distanceRemaining => _distanceRemaining;

  int _durationRemaining = 0;
  int get durationRemaining => _durationRemaining;

  // الخطوة الحالية
  RouteStepModel? _currentStep;
  RouteStepModel? get currentStep => _currentStep;

  // الخطوة التالية
  RouteStepModel? _nextStep;
  RouteStepModel? get nextStep => _nextStep;

  // المسافة إلى الخطوة التالية
  double _distanceToNextStep = 0;
  double get distanceToNextStep => _distanceToNextStep;

  // تهيئة المتحكم
  Future<void> initialize(LocationModel initialLocation) async {
    _currentLocation = initialLocation;
    notifyListeners();
  }

  // بدء التنقل إلى وجهة
  Future<bool> startNavigation(
    PlaceModel destinationPlace,
    LocationModel startLocation,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _destination = destinationPlace;
      _currentLocation = startLocation;

      // الحصول على المسار من الموقع الحالي إلى الوجهة
      String? startAddress = await _locationService.getAddressFromCoordinates(
        startLocation.latitude,
        startLocation.longitude,
      );

      RouteModel? route = await _mapboxService.getRoute(
        startLocation.latitude,
        startLocation.longitude,
        destinationPlace.latitude,
        destinationPlace.longitude,
        startAddress!,
        destinationPlace.address,
      );

      _currentRoute = route;
      _estimatedArrivalTime = route?.estimatedArrivalTime;
      _distanceRemaining = route!.distance;
      _durationRemaining = route.duration.toInt();

      // تحديد الخطوات القادمة
      if (route.steps.isNotEmpty) {
        _nextStep = route.steps[0];
        _updateDistanceToNextStep();
      }

      // بدء التنقل
      _startLocationTracking();
      _startEtaTimer();
      _startNextStepUpdateTimer(); // بدء تحديث الخطوة التالية

      _isNavigating = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء بدء التنقل: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // إيقاف التنقل
  void stopNavigation() {
    _isNavigating = false;
    _currentRoute = null;
    _destination = null;
    _estimatedArrivalTime = null;
    _distanceRemaining = 0;
    _durationRemaining = 0;
    _currentStep = null;
    _nextStep = null;
    _distanceToNextStep = 0;

    _stopLocationTracking();
    _stopEtaTimer();
    _stopNextStepUpdateTimer(); // إيقاف مؤقت تحديث الخطوة التالية

    notifyListeners();
  }

  // تحديث المسافة إلى الخطوة التالية
  void _updateDistanceToNextStep() {
    if (_currentLocation != null &&
        _nextStep != null &&
        _nextStep!.location.length >= 2) {
      // حساب المسافة بين الموقع الحالي وموقع الخطوة التالية
      _distanceToNextStep = _locationService.getDistanceBetweenPoints(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _nextStep!.location[1], // lat
        _nextStep!.location[0], // lng
      );
      notifyListeners();
    }
  }

  // إيقاف تتبع الموقع
  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // بدء مؤقت تحديث وقت الوصول المقدر
  void _startEtaTimer() {
    _etaTimer?.cancel();
    _etaTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_currentLocation != null && _destination != null) {
        // تحديث وقت الوصول المقدر كل 30 ثانية
        DateTime? eta = await _mapboxService.getEstimatedArrivalTime(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          _destination!.latitude,
          _destination!.longitude,
        );

        _estimatedArrivalTime = eta;

        // تحديث المدة المتبقية
        _durationRemaining = eta!.difference(DateTime.now()).inSeconds;

        notifyListeners();
      }
    });
  }

  // إيقاف مؤقت تحديث وقت الوصول المقدر
  void _stopEtaTimer() {
    _etaTimer?.cancel();
    _etaTimer = null;
  }

  // بدء مؤقت تحديث الخطوة التالية
  void _startNextStepUpdateTimer() {
    _nextStepUpdateTimer?.cancel();
    _nextStepUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentLocation != null &&
          _currentRoute != null &&
          _currentRoute!.steps.isNotEmpty) {
        _updateNextStep();
      }
    });
  }

  // إيقاف مؤقت تحديث الخطوة التالية
  void _stopNextStepUpdateTimer() {
    _nextStepUpdateTimer?.cancel();
    _nextStepUpdateTimer = null;
  }

  // تحديث الخطوة التالية بناءً على الموقع الحالي
  void _updateNextStep() {
    if (_currentLocation == null ||
        _currentRoute == null ||
        _currentRoute!.steps.isEmpty) {
      return;
    }

    double minDistance = double.infinity;
    int nextStepIndex = -1;

    // البحث عن أقرب خطوة لم يتم الوصول إليها بعد
    for (int i = 0; i < _currentRoute!.steps.length; i++) {
      if (_currentRoute!.steps[i].location.length < 2) continue;

      double stepLat = _currentRoute!.steps[i].location[1]; // lat
      double stepLng = _currentRoute!.steps[i].location[0]; // lng

      double distance = _locationService.getDistanceBetweenPoints(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        stepLat,
        stepLng,
      );

      // نحتفظ بالخطوة التي تكون على مسافة أكبر من 20 متر (لم نصل إليها بعد)
      // ولكنها أقرب من الخطوات الأخرى التي لم نصل إليها بعد
      if (distance < minDistance && distance > 20) {
        minDistance = distance;
        nextStepIndex = i;
      }
    }

    // إذا وجدنا خطوة تالية
    if (nextStepIndex != -1) {
      // إذا كانت الخطوة الحالية مختلفة، نحفظ الخطوة السابقة
      if (_nextStep != _currentRoute!.steps[nextStepIndex]) {
        _currentStep = _nextStep;
        _nextStep = _currentRoute!.steps[nextStepIndex];
        _distanceToNextStep = minDistance;
        notifyListeners();
      } else {
        // تحديث المسافة فقط إلى الخطوة التالية
        _distanceToNextStep = minDistance;
        notifyListeners();
      }
    }
  }

  // إعادة حساب المسار عند الانحراف عن المسار الأصلي
  Future<void> recalculateRoute() async {
    if (_currentLocation != null && _destination != null) {
      _isLoading = true;
      notifyListeners();

      try {
        String? startAddress = await _locationService.getAddressFromCoordinates(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );

        RouteModel? route = await _mapboxService.getRoute(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          _destination!.latitude,
          _destination!.longitude,
          startAddress!,
          _destination!.address,
        );

        _currentRoute = route;
        _estimatedArrivalTime = route!.estimatedArrivalTime;
        _distanceRemaining = route.distance;
        _durationRemaining = route.duration.toInt();

        // تحديث الخطوات
        if (route.steps.isNotEmpty) {
          _nextStep = route.steps[0];
          _currentStep = null;
          _updateDistanceToNextStep();
        }

        _errorMessage = null;
      } catch (e) {
        _errorMessage = 'حدث خطأ أثناء إعادة حساب المسار: $e';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // الحصول على المعلومات الحالية للتنقل كنص
  String getNavigationInfo() {
    if (!_isNavigating || _currentRoute == null) {
      return 'غير متاح';
    }

    String distance =
        _distanceRemaining < 1000
            ? '${_distanceRemaining.toStringAsFixed(0)} م'
            : '${(_distanceRemaining / 1000).toStringAsFixed(1)} كم';

    String duration = '';
    int minutes = (_durationRemaining / 60).floor();
    int hours = (minutes / 60).floor();
    minutes = minutes % 60;

    if (hours > 0) {
      duration = '$hours ساعة ${minutes > 0 ? 'و $minutes دقيقة' : ''}';
    } else {
      duration = '$minutes دقيقة';
    }

    String eta = '';
    if (_estimatedArrivalTime != null) {
      eta =
          '${_estimatedArrivalTime!.hour.toString().padLeft(2, '0')}:${_estimatedArrivalTime!.minute.toString().padLeft(2, '0')}';
    }

    return 'المسافة المتبقية: $distance\nالوقت المتبقي: $duration\nالوصول: $eta';
  }

  // الحصول على معلومات الخطوة التالية
  String getNextStepInfo() {
    if (!_isNavigating || _nextStep == null) {
      return 'اتبع المسار';
    }

    String distanceText =
        _distanceToNextStep < 1000
            ? '${_distanceToNextStep.toStringAsFixed(0)} م'
            : '${(_distanceToNextStep / 1000).toStringAsFixed(1)} كم';

    return '${_nextStep!.getSimpleDirection()} بعد $distanceText';
  }

  // الحصول على توجيهات تفصيلية خطوة بخطوة
  List<Map<String, dynamic>> getStepByStepDirections() {
    if (!_isNavigating ||
        _currentRoute == null ||
        _currentRoute!.steps.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> directions = [];
    for (var i = 0; i < _currentRoute!.steps.length; i++) {
      var step = _currentRoute!.steps[i];
      bool isNextStep = step == _nextStep;
      bool isCurrentStep = step == _currentStep;

      directions.add({
        'instruction': step.instruction,
        'simple_direction': step.getSimpleDirection(),
        'distance': step.getFormattedDistance(),
        'distance_value': step.distance,
        'is_next_step': isNextStep,
        'is_current_step': isCurrentStep,
        'index': i,
      });
    }

    return directions;
  }

  // الحصول على توجيهات الملاحة المبسطة للعرض
  String getSimpleNavigationDirections() {
    if (!_isNavigating || _nextStep == null) {
      return 'اتبع المسار';
    }

    String distanceText =
        _distanceToNextStep < 1000
            ? '${_distanceToNextStep.toStringAsFixed(0)} م'
            : '${(_distanceToNextStep / 1000).toStringAsFixed(1)} كم';

    return '${_nextStep!.getSimpleDirection()} بعد $distanceText على ${_nextStep!.name}';
  }

  // تتبع الموقع أثناء التنقل
  void _startLocationTracking() {
    _locationSubscription = _locationService.getLocationStream().listen(
      (locationData) async {
        _currentLocation = locationData;

        if (_destination != null && _currentRoute != null) {
          // حساب المسافة المتبقية
          _distanceRemaining = _locationService.getDistanceBetweenPoints(
            locationData.latitude,
            locationData.longitude,
            _destination!.latitude,
            _destination!.longitude,
          );

          // إعادة حساب الوقت المتبقي استنادًا إلى متوسط السرعة
          if (_currentRoute!.distance > 0 && _distanceRemaining > 0) {
            double completedDistance =
                _currentRoute!.distance - _distanceRemaining;
            double completionRatio =
                completedDistance / _currentRoute!.distance;

            _durationRemaining =
                (_currentRoute!.duration * (1 - completionRatio)).toInt();

            // تحديث وقت الوصول المقدر
            _estimatedArrivalTime = DateTime.now().add(
              Duration(seconds: _durationRemaining),
            );
          }

          // تحديث المسافة إلى الخطوة التالية
          _updateDistanceToNextStep();

          notifyListeners();

          // تحقق مما إذا وصلنا إلى الوجهة
          if (_distanceRemaining < 50) {
            // إذا كنا على بعد 50 متر من الوجهة
            stopNavigation();
          }

          // تحقق مما إذا وصلنا إلى خطوة وانتقل إلى الخطوة التالية
          if (_nextStep != null && _distanceToNextStep < 20) {
            // انتقل إلى الخطوة التالية في قائمة الخطوات
            int currentIndex = _currentRoute!.steps.indexOf(_nextStep!);
            if (currentIndex >= 0 &&
                currentIndex < _currentRoute!.steps.length - 1) {
              _currentStep = _nextStep;
              _nextStep = _currentRoute!.steps[currentIndex + 1];
              _updateDistanceToNextStep();
              notifyListeners();
            }
          }
        }
      },
      onError: (error) {
        _errorMessage = 'خطأ في تتبع الموقع: $error';
        notifyListeners();
      },
    );
  }
}
