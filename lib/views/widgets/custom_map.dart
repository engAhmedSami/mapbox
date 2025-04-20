import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../config/app_constants.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/storage_controller.dart';
import '../../models/location_model.dart';
import '../../models/place_model.dart';
import '../../models/route_model.dart';

class CustomMap extends StatefulWidget {
  final Function(PlaceModel)? onPlaceSelected;

  const CustomMap({super.key, this.onPlaceSelected});

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  MapboxMap? _mapboxMap;
  late LocationController _locationController;
  late NavigationController _navigationController;
  late StorageController _storageController;

  // معرفات طبقات الخريطة
  final String _routeLayerId = 'route-layer';
  final String _routeSourceId = 'route-source';
  final String _userLocationSourceId = 'user-location-source';
  final String _userLocationLayerId = 'user-location-layer';
  final String _destinationSourceId = 'destination-source';
  final String _destinationLayerId = 'destination-layer';
  final String _destinationCircleLayerId = 'destination-circle-layer';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locationController = Provider.of<LocationController>(context);
    _navigationController = Provider.of<NavigationController>(context);
    _storageController = Provider.of<StorageController>(context);
  }

  @override
  Widget build(BuildContext context) {
    // اختر نمط الخريطة المناسب بناءً على وضع السمة
    String mapStyle =
        _storageController.isDarkMode
            ? AppConstants.nightMapStyle
            : AppConstants.dayMapStyle;

    return Stack(
      children: [
        MapWidget(
          styleUri: mapStyle,
          onMapCreated: _onMapCreated,
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(
                AppConstants.defaultLongitude,
                AppConstants.defaultLatitude,
              ),
            ),
            zoom: AppConstants.defaultZoom,
          ),
        ),

        // زر العودة إلى الموقع الحالي
        Positioned(
          bottom: 110,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'btn_current_location',
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            onPressed: _goToCurrentLocation,
            child: Icon(
              Icons.my_location,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        // زر تبديل وضع الخريطة (الليلي/النهاري)
        Positioned(
          bottom: 160,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'btn_toggle_map_mode',
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            onPressed: () {
              _storageController.toggleThemeMode();
              _updateMapStyle();
            },
            child: Icon(
              _storageController.isDarkMode
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // تنفيذ عند إنشاء الخريطة
  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;

    // تهيئة المصادر والطبقات
    _initializeMapLayers();

    // الانتقال إلى الموقع الحالي عند توفره
    _locationController.addListener(_onLocationControllerChanged);
    _navigationController.addListener(_onNavigationControllerChanged);

    Future.delayed(const Duration(milliseconds: 500), () {
      _goToCurrentLocation();
    });
  }

  // تهيئة طبقات الخريطة
  Future<void> _initializeMapLayers() async {
    try {
      // إضافة مصدر ومكان للمستخدم
      await _mapboxMap?.style.addSource(
        GeoJsonSource(
          id: _userLocationSourceId,
          data: _createPointFeatureCollection(0, 0),
        ),
      );

      await _mapboxMap?.style.addLayer(
        CircleLayer(
          id: _userLocationLayerId,
          sourceId: _userLocationSourceId,
          circleRadius: 8.0,
          circleColor: 0xFF4882C4, // لون أزرق للمستخدم
          circleStrokeWidth: 2.0,
          circleStrokeColor: 0xFFFFFFFF, // حدود بيضاء
        ),
      );

      // إضافة مصدر ومكان للوجهة
      await _mapboxMap?.style.addSource(
        GeoJsonSource(
          id: _destinationSourceId,
          data: _createPointFeatureCollection(0, 0),
        ),
      );

      // طبقة دائرة للوجهة
      await _mapboxMap?.style.addLayer(
        CircleLayer(
          id: _destinationCircleLayerId,
          sourceId: _destinationSourceId,
          circleRadius: 10.0,
          circleColor: 0xffFF0000, // لون أحمر للوجهة
          circleStrokeWidth: 2.0,
          circleStrokeColor: 0xffFFFFFF, // حدود بيضاء
        ),
      );

      // طبقة نص للوجهة
      await _mapboxMap?.style.addLayer(
        SymbolLayer(
          id: _destinationLayerId,
          sourceId: _destinationSourceId,
          iconAllowOverlap: true,
          textField: "{name}",
          textSize: 12.0,
          textOffset: [0, 1.5],
          textAnchor: TextAnchor.TOP,
          textColor: 0xff000000, // لون أسود للنص
          textHaloWidth: 1.0,
          textHaloColor: 0xffffffff, // هالة بيضاء للنص
        ),
      );

      // إضافة مصدر وخط للمسار
      await _mapboxMap?.style.addSource(
        GeoJsonSource(
          id: _routeSourceId,
          data: _createEmptyLineFeatureCollection(),
        ),
      );

      await _mapboxMap?.style.addLayer(
        LineLayer(
          id: _routeLayerId,
          sourceId: _routeSourceId,
          lineColor: 0xff4882C4, // استخدام اللون من الثوابت
          lineWidth: AppConstants.routeLineWidth,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
        ),
      );

      log('تم تهيئة طبقات الخريطة بنجاح');
    } catch (e) {
      log('خطأ في تهيئة طبقات الخريطة: $e');
    }
  }

  // الاستجابة للتغييرات في موقع المستخدم
  void _onLocationControllerChanged() {
    if (_locationController.currentLocation != null) {
      _updateUserLocationOnMap(_locationController.currentLocation!);
    }
  }

  // الاستجابة للتغييرات في حالة التنقل
  void _onNavigationControllerChanged() {
    if (_navigationController.isNavigating) {
      // تأخير قصير للتأكد من تطبيق التغييرات
      Future.delayed(Duration(milliseconds: 100), () {
        if (_navigationController.currentRoute != null) {
          log(
            'تحديث المسار - نقاط: ${_navigationController.currentRoute!.geometry.length}',
          );
          _updateRouteOnMap(_navigationController.currentRoute!);
        }

        if (_navigationController.destination != null) {
          log('تحديث الوجهة - ${_navigationController.destination!.placeName}');
          _updateDestinationOnMap(
            _navigationController.destination!.latitude,
            _navigationController.destination!.longitude,
            _navigationController.destination!.placeName,
          );
        }

        if (_locationController.currentLocation != null) {
          log('تحديث موقع المستخدم');
          _updateUserLocationOnMap(_locationController.currentLocation!);
        }
      });
    } else {
      _clearRouteFromMap();
    }
  }

  // تحديث موقع المستخدم على الخريطة
  void _updateUserLocationOnMap(LocationModel location) {
    try {
      final source =
          _mapboxMap?.style.getSource(_userLocationSourceId) as GeoJsonSource?;
      if (source != null) {
        log('تحديث موقع المستخدم: ${location.latitude}, ${location.longitude}');
        source.updateGeoJSON(
          _createPointFeatureCollection(location.latitude, location.longitude),
        );
      }
    } catch (e) {
      log('خطأ في تحديث موقع المستخدم على الخريطة: $e');
    }
  }

  // تحديث الوجهة على الخريطة
  void _updateDestinationOnMap(double latitude, double longitude, String name) {
    try {
      final source =
          _mapboxMap?.style.getSource(_destinationSourceId) as GeoJsonSource?;
      if (source != null) {
        log('تحديث الوجهة: $latitude, $longitude, $name');
        source.updateGeoJSON(
          _createPointFeatureCollection(
            latitude,
            longitude,
            properties: {'name': name},
          ),
        );
      }
    } catch (e) {
      log('خطأ في تحديث الوجهة على الخريطة: $e');
    }
  }

  // تحديث المسار على الخريطة
  void _updateRouteOnMap(RouteModel route) {
    try {
      final source =
          _mapboxMap?.style.getSource(_routeSourceId) as GeoJsonSource?;
      if (source != null) {
        log('تحديث المسار - عدد النقاط: ${route.geometry.length}');
        if (route.geometry.isNotEmpty) {
          source.updateGeoJSON(_createLineFeatureCollection(route.geometry));
          // التركيز على المسار كاملاً
          _fitRouteInView(route.geometry);
        } else {
          log('تحذير: المسار فارغ!');
        }
      }
    } catch (e) {
      log('خطأ في تحديث المسار على الخريطة: $e');
    }
  }

  // ضبط مستوى تكبير الخريطة لرؤية المسار بالكامل
  void _fitRouteInView(List<List<double>> coordinates) {
    if (coordinates.isEmpty) return;

    try {
      double minLat = 90.0;
      double maxLat = -90.0;
      double minLng = 180.0;
      double maxLng = -180.0;

      for (final point in coordinates) {
        final lng = point[0];
        final lat = point[1];

        minLat = minLat > lat ? lat : minLat;
        maxLat = maxLat < lat ? lat : maxLat;
        minLng = minLng > lng ? lng : minLng;
        maxLng = maxLng < lng ? lng : maxLng;
      }

      // إضافة هامش
      final latDelta = (maxLat - minLat) * 0.2;
      final lngDelta = (maxLng - minLng) * 0.2;

      final southwest = Point(
        coordinates: Position(minLng - lngDelta, minLat - latDelta),
      );
      final northeast = Point(
        coordinates: Position(maxLng + lngDelta, maxLat + latDelta),
      );

      // Create CoordinateBounds object correctly
      final bounds = CoordinateBounds(
        southwest: southwest,
        northeast: northeast,
        infiniteBounds: false,
      );

      // ضبط الكاميرا لعرض المسار بالكامل
      _mapboxMap
          ?.cameraForCoordinateBounds(
            bounds,
            MbxEdgeInsets(top: 100, left: 50, bottom: 150, right: 50),
            null, // bearing (optional)
            null, // pitch (optional)
            null, // maxZoom (optional)
            null, // offset (optional)
          )
          .then((camera) {
            _mapboxMap?.flyTo(camera, MapAnimationOptions(duration: 1000));
          });

      log('تم ضبط مستوى تكبير الخريطة للمسار');
    } catch (e) {
      log('خطأ في ضبط مستوى تكبير الخريطة: $e');
    }
  }

  // مسح المسار من الخريطة
  void _clearRouteFromMap() {
    try {
      final routeSource =
          _mapboxMap?.style.getSource(_routeSourceId) as GeoJsonSource?;
      if (routeSource != null) {
        routeSource.updateGeoJSON(_createEmptyLineFeatureCollection());
      }

      final destinationSource =
          _mapboxMap?.style.getSource(_destinationSourceId) as GeoJsonSource?;
      if (destinationSource != null) {
        destinationSource.updateGeoJSON(_createEmptyPointFeatureCollection());
      }

      log('تم مسح المسار من الخريطة');
    } catch (e) {
      log('خطأ في مسح المسار من الخريطة: $e');
    }
  }

  // الانتقال إلى الموقع الحالي
  void _goToCurrentLocation() {
    if (_locationController.currentLocation != null) {
      _mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              _locationController.currentLocation!.longitude,
              _locationController.currentLocation!.latitude,
            ),
          ),
          zoom: 15.0,
          bearing: 0,
          pitch: 0,
        ),
        MapAnimationOptions(duration: 1000),
      );

      log('تم الانتقال إلى الموقع الحالي');
    } else {
      // محاولة تحديث الموقع الحالي إذا لم يكن متوفرًا
      _locationController.updateCurrentLocation();
      log('جاري محاولة تحديث الموقع الحالي');
    }
  }

  // تحديث نمط الخريطة عند تغيير الوضع
  void _updateMapStyle() {
    String mapStyle =
        _storageController.isDarkMode
            ? AppConstants.nightMapStyle
            : AppConstants.dayMapStyle;

    _mapboxMap?.style.setStyleURI(mapStyle);
    log('تم تحديث نمط الخريطة: $mapStyle');
  }

  // إنشاء مجموعة نقطة فارغة لـ GeoJSON
  String _createEmptyPointFeatureCollection() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  // إنشاء مجموعة نقطة لـ GeoJSON
  String _createPointFeatureCollection(
    double latitude,
    double longitude, {
    Map<String, dynamic>? properties,
  }) {
    final Map<String, dynamic> feature = {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'properties': properties ?? {},
    };

    return '{"type":"FeatureCollection","features":[${jsonEncode(feature)}]}';
  }

  // إنشاء مجموعة خط فارغة لـ GeoJSON
  String _createEmptyLineFeatureCollection() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  // إنشاء مجموعة خط لـ GeoJSON
  String _createLineFeatureCollection(List<List<double>> coordinates) {
    final Map<String, dynamic> feature = {
      'type': 'Feature',
      'geometry': {'type': 'LineString', 'coordinates': coordinates},
      'properties': {},
    };

    return '{"type":"FeatureCollection","features":[${jsonEncode(feature)}]}';
  }

  @override
  void dispose() {
    _locationController.removeListener(_onLocationControllerChanged);
    _navigationController.removeListener(_onNavigationControllerChanged);
    super.dispose();
  }
}
