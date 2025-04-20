import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

class LocationService {
  // طلب إذن الوصول للموقع
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق مما إذا كانت خدمات الموقع ممكّنة
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // خدمات الموقع غير ممكّنة، لا يمكن متابعة الطلب
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // الإذن مرفوض، لا يمكن متابعة الطلب
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // الإذن مرفوض بشكل دائم، لا يمكن طلب الإذن
      return false;
    }

    // تم منح الإذن
    return true;
  }

  // الحصول على الموقع الحالي
  Future<LocationModel?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // الحصول على العنوان من الإحداثيات
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? address;
      String? name;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        name = place.name;
        address = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        name: name,
        address: address,
      );
    } catch (e) {
      log('خطأ في الحصول على الموقع الحالي: $e');
      return null;
    }
  }

  // بدء تتبع الموقع المستمر
  Stream<LocationModel> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // تحديث كل 10 أمتار
      ),
    ).map((position) {
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }

  // الحصول على عنوان من إحداثيات
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }

      return null;
    } catch (e) {
      log('خطأ في الحصول على العنوان: $e');
      return null;
    }
  }

  // الحصول على المسافة بين موقعين
  double getDistanceBetweenPoints(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
