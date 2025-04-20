import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/place_model.dart';
import '../models/route_model.dart';
import '../services/mapbox_service.dart';
import '../services/location_service.dart';

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

  DateTime? _estimatedArrivalTime;
  DateTime? get estimatedArrivalTime => _estimatedArrivalTime;

  double _distanceRemaining = 0;
  double get distanceRemaining => _distanceRemaining;

  int _durationRemaining = 0;
  int get durationRemaining => _durationRemaining;

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
        startAddress ?? 'موقعك الحالي',
        destinationPlace.address,
      );

      if (route != null) {
        _currentRoute = route;
        _estimatedArrivalTime = route.estimatedArrivalTime;
        _distanceRemaining = route.distance;
        _durationRemaining = route.duration.toInt();

        // بدء التنقل
        _startLocationTracking();
        _startEtaTimer();

        _isNavigating = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'لم يتم العثور على مسار إلى الوجهة';
        _isLoading = false;
        notifyListeners();
        return false;
      }
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

    _stopLocationTracking();
    _stopEtaTimer();

    notifyListeners();
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

        if (eta != null) {
          _estimatedArrivalTime = eta;

          // تحديث المدة المتبقية
          _durationRemaining = eta.difference(DateTime.now()).inSeconds;

          notifyListeners();
        }
      }
    });
  }

  // إيقاف مؤقت تحديث وقت الوصول المقدر
  void _stopEtaTimer() {
    _etaTimer?.cancel();
    _etaTimer = null;
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
          startAddress ?? 'موقعك الحالي',
          _destination!.address,
        );

        if (route != null) {
          _currentRoute = route;
          _estimatedArrivalTime = route.estimatedArrivalTime;
          _distanceRemaining = route.distance;
          _durationRemaining = route.duration.toInt();
          _errorMessage = null;
        } else {
          _errorMessage = 'لم يتم العثور على مسار بديل';
        }
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

  @override
  void dispose() {
    _stopLocationTracking();
    _stopEtaTimer();
    super.dispose();
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

          notifyListeners();

          // تحقق مما إذا وصلنا إلى الوجهة
          if (_distanceRemaining < 50) {
            // إذا كنا على بعد 50 متر من الوجهة
            stopNavigation();
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
