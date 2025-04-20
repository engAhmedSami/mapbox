import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationController with ChangeNotifier {
  final LocationService _locationService = LocationService();

  LocationModel? _currentLocation;
  LocationModel? get currentLocation => _currentLocation;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<LocationModel>? _locationSubscription;
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // تهيئة المتحكم
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // طلب صلاحيات الموقع
      bool hasPermission = await _locationService.requestLocationPermission();

      if (hasPermission) {
        // الحصول على الموقع الحالي
        _currentLocation = await _locationService.getCurrentLocation();
        _errorMessage = null;
      } else {
        _errorMessage = 'لم يتم منح إذن الوصول إلى الموقع';
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تهيئة خدمة الموقع: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث الموقع الحالي
  Future<void> updateCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentLocation = await _locationService.getCurrentLocation();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحديث الموقع: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // بدء تتبع الموقع
  void startLocationTracking() {
    if (!_isTracking) {
      _locationSubscription = _locationService.getLocationStream().listen(
        (locationData) {
          _currentLocation = locationData;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'خطأ في تتبع الموقع: $error';
          notifyListeners();
        },
      );

      _isTracking = true;
      notifyListeners();
    }
  }

  // إيقاف تتبع الموقع
  void stopLocationTracking() {
    if (_isTracking) {
      _locationSubscription?.cancel();
      _locationSubscription = null;
      _isTracking = false;
      notifyListeners();
    }
  }

  // الحصول على عنوان من إحداثيات
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return _locationService.getAddressFromCoordinates(latitude, longitude);
  }

  // المسافة بين نقطتين
  double getDistanceBetweenPoints(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return _locationService.getDistanceBetweenPoints(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
