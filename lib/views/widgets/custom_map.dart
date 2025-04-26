// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/storage_controller.dart';
import '../../models/location_model.dart';
import '../../models/place_model.dart';
import '../../models/route_model.dart';
import '../../services/mapbox_service.dart';
import 'place_details_widget.dart';

class CustomMap extends StatefulWidget {
  final Function(PlaceModel)? onPlaceSelected;
  final bool followUserLocation;

  const CustomMap({
    super.key,
    this.onPlaceSelected,
    this.followUserLocation = false,
  });

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  MapboxMap? _mapboxMap;
  late LocationController _locationController;
  late NavigationController _navigationController;
  late StorageController _storageController;
  final MapboxService _mapboxService = MapboxService();
  bool _layersInitialized = false;
  Timer? _cameraUpdateTimer;
  bool isFirstLoad = true;

  // تعقب حركة المستخدم اليدوية للكاميرا
  bool _userHasMovedCamera = false;
  Timer? _resetUserMovedCameraTimer;

  // متغيرات سهم الاتجاه والتحكم في الكاميرا
  final String _directionArrowSourceId = 'direction-arrow-source';
  final String _directionArrowLayerId = 'direction-arrow-layer';
  double _userBearing = 0; // اتجاه المستخدم الحالي
  bool _isFollowingUser = false; // هل الكاميرا تتبع المستخدم؟
  bool _arrowAdded = false; // هل تمت إضافة طبقة السهم؟
  LocationModel? _previousLocation; // تخزين الموقع السابق لحساب الاتجاه
  bool _isStyleLoading = false; // Add this to your state variables
  // معرفات طبقات الخريطة
  final String _routeLayerId = 'route-layer';
  final String _routeSourceId = 'route-source';
  final String _userLocationSourceId = 'user-location-source';
  final String userLocationLayerId = 'user-location-layer';
  final String _destinationSourceId = 'destination-source';
  final String _destinationLayerId = 'destination-layer';
  final String _destinationCircleLayerId = 'destination-circle-layer';
  final String _placesSourceId = 'places-source';
  final String _placesLayerId = 'places-layer';
  final String _placesSymbolLayerId = 'places-symbol-layer';
  final String _buildingsSourceId = 'buildings-source';
  final String buildingsLayerId = 'buildings-layer';
  final String buildingsExtrusionLayerId = 'buildings-extrusion-layer';
  bool _placesAdded = false;
  bool _buildingsAdded = false;

  // حفظ قائمة الأماكن المعروضة حالياً
  List<PlaceModel> _visiblePlaces = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locationController = Provider.of<LocationController>(context);
    _navigationController = Provider.of<NavigationController>(context);
    _storageController = Provider.of<StorageController>(context);

    // إضافة المستمعين للتأكد من التقاط جميع تغييرات الحالة
    _locationController.addListener(_onLocationControllerChanged);
    _navigationController.addListener(_onNavigationControllerChanged);
  }

  @override
  Widget build(BuildContext context) {
    String mapStyle =
        _storageController.isDarkMode
            ? AppConstants.nightMapStyle
            : AppConstants.outdoorsStyle;

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
          onStyleLoadedListener: _onStyleLoaded,
          onTapListener: _onMapTap,
          onCameraChangeListener: _onCameraChanged,
          onMapIdleListener: _onMapIdle,
        ),
        // زر الموقع الحالي
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
        // زر تبديل نمط الخريطة
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
        // زر تبديل وضع المتابعة
        Positioned(
          bottom: 210,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'btn_toggle_follow_mode',
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            onPressed: _toggleFollowMode,
            child: Icon(
              _isFollowingUser ? Icons.navigation : Icons.explore,
              color:
                  _isFollowingUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        // زر تبديل عرض المباني ثلاثية الأبعاد
        Positioned(
          bottom: 260,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'btn_toggle_buildings',
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            onPressed: _toggleBuildingsView,
            child: Icon(
              Icons.view_in_ar,
              color:
                  _buildingsAdded
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // مستمع تغيير الكاميرا لتتبع حركة المستخدم اليدوية
  void _onCameraChanged(CameraChangedEventData eventData) {
    if (!_isFollowingUser) {
      setState(() {
        _userHasMovedCamera = true;
      });
      _resetUserMovedCameraTimer?.cancel();
    }
  }

  // مستمع خمول الخريطة لإعادة تعيين مؤشر حركة المستخدم وتحديث الأماكن المرئية
  void _onMapIdle(MapIdleEventData eventData) {
    if (_userHasMovedCamera) {
      _resetUserMovedCameraTimer?.cancel();
      _resetUserMovedCameraTimer = Timer(const Duration(seconds: 30), () {
        setState(() {
          _userHasMovedCamera = false;
        });
      });

      // تحديث الأماكن المرئية عند توقف الخريطة
      _loadVisiblePlaces();
    }
  }

  // عند النقر على الخريطة
  void _onMapTap(MapContentGestureContext context) async {
    if (_mapboxMap == null) return;

    // التحقق أولاً إذا كان المستخدم نقر على مكان أو معلم
    bool tappedOnPlace = await _checkAndHandlePlaceTap(context);

    // إذا لم ينقر على مكان، يمكن اعتباره نقطة وجهة جديدة
    if (!tappedOnPlace) {
      try {
        // تحويل إحداثيات الشاشة إلى إحداثيات جغرافية
        Point point = await _mapboxMap!.coordinateForPixel(
          context.point as ScreenCoordinate,
        );
        Position position = point.coordinates;
        double latitude = position.lat.toDouble();
        double longitude = position.lng.toDouble();

        // الحصول على العنوان
        String? address = await _locationController.getAddressFromCoordinates(
          latitude,
          longitude,
        );

        // إنشاء نموذج مكان للموقع المنقور عليه
        PlaceModel selectedPlace = PlaceModel(
          address: address ?? 'الموقع المحدد',
          id: 'selected_${DateTime.now().millisecondsSinceEpoch}',
          placeName: 'الوجهة المحددة',
          latitude: latitude,
          longitude: longitude,
        );

        // عرض تفاصيل المكان
        _showPlaceDetails(selectedPlace);
      } catch (e) {
        print('Error setting destination: $e');
        ScaffoldMessenger.of(
          context as BuildContext,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحديد الوجهة: $e')));
      }
    }
  }

  // تحميل الأماكن المرئية في النطاق الحالي للخريطة
  Timer? _placesDebounceTimer;
  Timer? _buildingsDebounceTimer;

  Future<void> _loadVisiblePlaces() async {
    if (_mapboxMap == null || !_layersInitialized || _isStyleLoading) return;

    // Cancel any existing debounce timer
    _placesDebounceTimer?.cancel();

    // Debounce the operation by 500ms
    _placesDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        double lat = await _mapboxMap!.getCameraState().then(
          (state) => state.center.coordinates.lat.toDouble(),
        );
        double lng = await _mapboxMap!.getCameraState().then(
          (state) => state.center.coordinates.lng.toDouble(),
        );

        final results = await _mapboxService.searchPlaces(
          '',
          nearLat: lat,
          nearLng: lng,
        );

        _visiblePlaces = results;

        _updatePlacesOnMap(_visiblePlaces);
      } catch (e) {
        print('Error loading visible places: $e');
      }
    });
  }

  Future<void> _loadNearbyBuildings(LocationModel location) async {
    if (_mapboxMap == null || !_layersInitialized || _isStyleLoading) return;

    // Cancel any existing debounce timer
    _buildingsDebounceTimer?.cancel();

    // Debounce the operation by 500ms
    _buildingsDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        try {
          final buildings = await _mapboxService.searchPlaces(
            'building',
            nearLat: location.latitude,
            nearLng: location.longitude,
          );

          final filteredBuildings =
              buildings.where((place) {
                final name = place.placeName.toLowerCase();
                final address = place.address.toLowerCase();
                return name.contains('مبنى') ||
                    name.contains('مدخل') ||
                    name.contains('بوابة') ||
                    name.contains('قاعة') ||
                    address.contains('مبنى');
              }).toList();

          if (filteredBuildings.isNotEmpty) {
            _updateBuildingsOnMap(filteredBuildings);
          }
        } catch (e) {
          print('Error loading nearby buildings: $e');
        }
      },
    );
  }

  // التحقق مما إذا كان النقر على مكان
  Future<bool> _checkAndHandlePlaceTap(MapContentGestureContext context) async {
    if (_mapboxMap == null) return false;

    try {
      // تحويل نقطة النقر إلى إحداثيات
      final screenCoordinate = context.point as ScreenCoordinate;
      final point = await _mapboxMap!.coordinateForPixel(screenCoordinate);

      // الحصول على الإحداثيات
      final double latitude = point.coordinates.lat.toDouble();
      final double longitude = point.coordinates.lng.toDouble();

      // التحقق مما إذا كان هناك مكان بالقرب من نقطة النقر
      PlaceModel? tappedPlace;

      // البحث في الأماكن المرئية
      double minDistance = double.infinity;
      for (var place in _visiblePlaces) {
        double distance = _calculateDistance(
          latitude,
          longitude,
          place.latitude,
          place.longitude,
        );

        // اعتبار أي مكان ضمن 50 متر من نقطة النقر
        if (distance < 50 && distance < minDistance) {
          minDistance = distance;
          tappedPlace = place;
        }
      }

      // إذا لم يتم العثور على مكان، يمكن محاولة البحث عن الأماكن القريبة
      if (tappedPlace == null) {
        final nearbyPlaces = await _mapboxService.searchPlaces(
          '',
          nearLat: latitude,
          nearLng: longitude,
        );

        if (nearbyPlaces.isNotEmpty) {
          tappedPlace = nearbyPlaces.first;
        }
      }

      // إذا تم العثور على مكان، عرض تفاصيله
      if (tappedPlace != null) {
        _showPlaceDetails(tappedPlace);
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking for place tap: $e');
      return false;
    }
  }

  // عرض تفاصيل المكان
  void _showPlaceDetails(PlaceModel place) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.85,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: PlaceDetailsWidget(
                    place: place,
                    onClose: () => Navigator.of(context).pop(),
                    onNavigate: () {
                      // إغلاق النافذة المنبثقة
                      Navigator.of(context).pop();

                      // بدء التنقل إذا كان الموقع متاحاً
                      if (_locationController.currentLocation != null) {
                        _navigationController.startNavigation(
                          place,
                          _locationController.currentLocation!,
                        );
                      } else {
                        // عرض رسالة خطأ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('لم يتم تحديد موقعك الحالي'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    print('Map created');

    _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );

    if (widget.followUserLocation) {
      _isFollowingUser = true;
      _cameraUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (_mapboxMap != null &&
            widget.followUserLocation &&
            _isFollowingUser) {
          _goToCurrentLocation();
        }
      });
    }
  }

  void _onStyleLoaded(StyleLoadedEventData styleLoadedEventData) async {
    if (!mounted) return;

    print('Map style loaded');

    setState(() {
      _isStyleLoading = true; // Set flag during style loading
    });

    try {
      // Reset flags and initialize layers
      _layersInitialized = false;
      _placesAdded = false;
      _buildingsAdded = false;
      _arrowAdded = false;

      // Initialize layers
      await _initializeMapLayers();

      // Update the map with the current state
      if (_locationController.currentLocation != null) {
        _updateDirectionArrow(_locationController.currentLocation!);
        _goToCurrentLocation();
      }

      // Load visible places
      await _loadVisiblePlaces();

      if (_navigationController.isNavigating) {
        if (_navigationController.destination != null) {
          _updateDestinationOnMap(
            _navigationController.destination!.latitude,
            _navigationController.destination!.longitude,
            _navigationController.destination!.placeName,
          );
        }
        if (_navigationController.currentRoute != null) {
          _updateRouteOnMap(_navigationController.currentRoute!);
        }
      }
    } catch (e) {
      print('Error in onStyleLoaded: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isStyleLoading = false; // Reset flag after style is loaded
        });
      }
    }
  }

  Future<void> _initializeMapLayers() async {
    if (_layersInitialized || _mapboxMap == null) return;

    try {
      print('Initializing map layers...');

      // // إضافة مصدر وطبقات موقع المستخدم
      // await _mapboxMap!.style.addSource(
      //   GeoJsonSource(
      //     id: _userLocationSourceId,
      //     data: '{"type":"FeatureCollection","features":[]}',
      //   ),
      // );

      // await _mapboxMap!.style.addLayer(
      //   CircleLayer(
      //     id: "${_userLocationLayerId}_outer",
      //     sourceId: _userLocationSourceId,
      //     circleRadius: 18.0,
      //     circleColor: 0x554882C4,
      //     circleStrokeWidth: 2.0,
      //     circleStrokeColor: 0xFF4882C4,
      //   ),
      // );

      // await _mapboxMap!.style.addLayer(
      //   CircleLayer(
      //     id: _userLocationLayerId,
      //     sourceId: _userLocationSourceId,
      //     circleRadius: 10.0,
      //     circleColor: 0xFF4882C4,
      //     circleStrokeWidth: 3.0,
      //     circleStrokeColor: 0xFFFFFFFF,
      //   ),
      // );

      // إضافة مصدر وطبقات الوجهة
      await _mapboxMap!.style.addSource(
        GeoJsonSource(
          id: _destinationSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );

      await _mapboxMap!.style.addLayer(
        CircleLayer(
          id: _destinationCircleLayerId,
          sourceId: _destinationSourceId,
          circleRadius: 12.0,
          circleColor: 0xFFE53935,
          circleStrokeWidth: 3.0,
          circleStrokeColor: 0xFFFFFFFF,
        ),
      );

      await _mapboxMap!.style.addLayer(
        SymbolLayer(
          id: _destinationLayerId,
          sourceId: _destinationSourceId,
          textField: "{name}",
          textSize: 14.0,
          textOffset: [0, 2.0],
          textAnchor: TextAnchor.TOP,
          textColor: 0xFF000000,
          textHaloWidth: 1.5,
          textHaloColor: 0xFFFFFFFF,
        ),
      );

      // إضافة مصدر وطبقة المسار
      await _mapboxMap!.style.addSource(
        GeoJsonSource(
          id: _routeSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );

      await _mapboxMap!.style.addLayer(
        LineLayer(
          id: _routeLayerId,
          sourceId: _routeSourceId,
          lineColor: int.parse(
            '0xFF${AppConstants.routeLineColor.substring(1)}',
          ),
          lineWidth: AppConstants.routeLineWidth,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
        ),
      );

      // إضافة مصدر وطبقة سهم الاتجاه
      await _mapboxMap!.style.addSource(
        GeoJsonSource(
          id: _directionArrowSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );

      await _mapboxMap!.style.addLayer(
        SymbolLayer(
          id: _directionArrowLayerId,
          sourceId: _directionArrowSourceId,
          iconImage: "arrow", // اسم صورة السهم التي سنضيفها
          iconSize: 1.5,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconRotate: _userBearing, // تدوير السهم بناءً على الاتجاه المحسوب
        ),
      );

      // إضافة مصدر وطبقة الأماكن
      await _mapboxMap!.style.addSource(
        GeoJsonSource(
          id: _placesSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );

      await _mapboxMap!.style.addLayer(
        CircleLayer(
          id: _placesLayerId,
          sourceId: _placesSourceId,
          circleRadius: 10.0,
          circleColor: 0xFF4CAF50, // لون أخضر للأماكن
          circleStrokeWidth: 2.0,
          circleStrokeColor: 0xFFFFFFFF,
        ),
      );

      await _mapboxMap!.style.addLayer(
        SymbolLayer(
          id: _placesSymbolLayerId,
          sourceId: _placesSourceId,
          textField: "{name}",
          textSize: 12.0,
          textOffset: [0, 1.5],
          textAnchor: TextAnchor.TOP,
          textColor: 0xFF000000,
          textHaloWidth: 1.0,
          textHaloColor: 0xFFFFFFFF,
          iconImage: "{icon}",
          iconSize: 1.0,
          iconAllowOverlap: false,
          iconIgnorePlacement: false,
          symbolPlacement: SymbolPlacement.POINT,
        ),
      );

      // إضافة صورة السهم إلى الخريطة
      await _addArrowImageToMap();

      // إضافة صور أيقونات الأماكن
      await _addPlaceIconsToMap();

      _layersInitialized = true;
      _arrowAdded = true;
      _placesAdded = true;
      print('Map layers initialized successfully');

      // تحديث الخريطة بالبيانات الحالية
      if (_locationController.currentLocation != null) {
        _updateUserLocationOnMap(_locationController.currentLocation!);
      }

      if (_navigationController.isNavigating) {
        if (_navigationController.destination != null) {
          _updateDestinationOnMap(
            _navigationController.destination!.latitude,
            _navigationController.destination!.longitude,
            _navigationController.destination!.placeName,
          );
        }
        if (_navigationController.currentRoute != null) {
          _updateRouteOnMap(_navigationController.currentRoute!);
        }
      }
    } catch (e) {
      print('Error initializing map layers: $e');
    }
  }

  // إضافة صورة السهم إلى الخريطة
  Future<void> _addArrowImageToMap() async {
    try {
      // إنشاء صورة السهم برمجياً
      final int size = 64;
      final Uint8List data = Uint8List(size * size * 4);

      // ملء بيانات الصورة بشكل السهم
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          // حساب المسافة من المركز
          double centerX = size / 2;
          double centerY = size / 2;
          double dx = x - centerX;
          double dy = y - centerY;

          // تعريف شكل السهم
          bool isArrow = false;
          bool isArrowBorder = false;

          // جسم السهم
          if (dx.abs() < 8 && dy > 0 && dy < 24) {
            isArrow = true;
          }

          // رأس السهم
          if (dy < 0 && dy > -16 && dx.abs() < -dy) {
            isArrow = true;
          }

          // حدود السهم
          if (dx.abs() < 10 && dy > -2 && dy < 26 && !isArrow) {
            isArrowBorder = true;
          }

          if (dy < 2 && dy > -18 && dx.abs() < (-dy + 2) && !isArrow) {
            isArrowBorder = true;
          }

          int pixelIndex = (y * size + x) * 4;
          if (isArrow) {
            // تعبئة زرقاء للسهم
            data[pixelIndex] = 72; // R
            data[pixelIndex + 1] = 130; // G
            data[pixelIndex + 2] = 196; // B
            data[pixelIndex + 3] = 255; // A
          } else if (isArrowBorder) {
            // حدود بيضاء للسهم
            data[pixelIndex] = 255; // R
            data[pixelIndex + 1] = 255; // G
            data[pixelIndex + 2] = 255; // B
            data[pixelIndex + 3] = 255; // A
          } else {
            // شفاف
            data[pixelIndex + 3] = 0; // A
          }
        }
      }

      // إنشاء صورة MbxImage من Uint8List
      final MbxImage arrowImage = MbxImage(
        width: size,
        height: size,
        data: data,
      );

      // إضافة الصورة إلى نمط الخريطة
      await _mapboxMap!.style.addStyleImage(
        "arrow", // imageId
        1.0, // scale
        arrowImage, // image
        false, // sdf
        [], // stretchX
        [], // stretchY
        null, // content
      );

      print('Arrow image added to map successfully');
    } catch (e) {
      print('Error adding arrow image to map: $e');
    }
  }

  // إضافة أيقونات الأماكن
  Future<void> _addPlaceIconsToMap() async {
    try {
      // قائمة أسماء الأيقونات التي سنضيفها
      List<String> iconNames = [
        'university',
        'school',
        'hospital',
        'restaurant',
        'shopping',
        'mosque',
        'park',
        'hotel',
        'place',
      ];

      // إضافة كل أيقونة
      for (String iconName in iconNames) {
        await _addPlaceIconToMap(iconName);
      }

      print('Place icons added to map successfully');
    } catch (e) {
      print('Error adding place icons to map: $e');
    }
  }

  // إضافة أيقونة مكان واحدة
  Future<void> _addPlaceIconToMap(String iconName) async {
    try {
      // إنشاء صورة الأيقونة برمجياً
      final int size = 32;
      final Uint8List data = Uint8List(size * size * 4);

      // تعيين لون الأيقونة حسب نوعها
      int iconR = 0, iconG = 0, iconB = 0;

      switch (iconName) {
        case 'university':
        case 'school':
          // أزرق للمؤسسات التعليمية
          iconR = 33;
          iconG = 150;
          iconB = 243;
          break;
        case 'hospital':
          // أحمر للمستشفيات
          iconR = 244;
          iconG = 67;
          iconB = 54;
          break;
        case 'restaurant':
          // برتقالي للمطاعم
          iconR = 255;
          iconG = 152;
          iconB = 0;
          break;
        case 'shopping':
          // أرجواني للتسوق
          iconR = 156;
          iconG = 39;
          iconB = 176;
          break;
        case 'mosque':
          // أخضر للمساجد
          iconR = 76;
          iconG = 175;
          iconB = 80;
          break;
        case 'park':
          // أخضر فاتح للحدائق
          iconR = 139;
          iconG = 195;
          iconB = 74;
          break;
        case 'hotel':
          // بني للفنادق
          iconR = 121;
          iconG = 85;
          iconB = 72;
          break;
        default:
          // رمادي للأماكن العامة
          iconR = 158;
          iconG = 158;
          iconB = 158;
          break;
      }

      // رسم دائرة ملونة للأيقونة
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          double centerX = size / 2;
          double centerY = size / 2;
          double dx = x - centerX;
          double dy = y - centerY;
          double distance = sqrt(dx * dx + dy * dy);

          int pixelIndex = (y * size + x) * 4;

          // رسم دائرة
          if (distance < size / 4) {
            // داخل الدائرة
            data[pixelIndex] = iconR; // R
            data[pixelIndex + 1] = iconG; // G
            data[pixelIndex + 2] = iconB; // B
            data[pixelIndex + 3] = 255; // A (معتم)
          } else if (distance < size / 4 + 2) {
            // حدود الدائرة
            data[pixelIndex] = 255; // R
            data[pixelIndex + 1] = 255; // G
            data[pixelIndex + 2] = 255; // B
            data[pixelIndex + 3] = 255; // A (معتم)
          } else {
            // خارج الدائرة (شفاف)
            data[pixelIndex + 3] = 0; // A
          }
        }
      }

      // إنشاء صورة MbxImage من Uint8List
      final MbxImage placeImage = MbxImage(
        width: size,
        height: size,
        data: data,
      );

      // إضافة الصورة إلى نمط الخريطة
      await _mapboxMap!.style.addStyleImage(
        iconName, // imageId
        1.0, // scale
        placeImage, // image
        false, // sdf
        [], // stretchX
        [], // stretchY
        null, // content
      );
    } catch (e) {
      print('Error adding $iconName icon to map: $e');
    }
  }

  // تحديث طبقة الأماكن على الخريطة
  Future<void> _updatePlacesOnMap(List<PlaceModel> places) async {
    if (!_layersInitialized || _mapboxMap == null || !_placesAdded) return;

    try {
      final List<Map<String, dynamic>> features = [];

      // إنشاء feature لكل مكان
      for (var place in places) {
        // تحديد نوع الأيقونة بناءً على خصائص المكان
        String iconName = _getPlaceIconName(place);

        features.add({
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [place.longitude, place.latitude],
          },
          'properties': {
            'id': place.id,
            'name': place.placeName,
            'address': place.address,
            'icon': iconName,
          },
        });
      }

      final Map<String, dynamic> featureCollection = {
        'type': 'FeatureCollection',
        'features': features,
      };

      final String geoJsonString = jsonEncode(featureCollection);

      // تحديث مصدر البيانات
      final sourceObj = await _mapboxMap!.style.getSource(_placesSourceId);
      if (sourceObj != null) {
        final source = sourceObj as GeoJsonSource;
        source.updateGeoJSON(geoJsonString);
      } else {
        print('Places source not found - reinitializing layers');
        _placesAdded = false;
        await _initializeMapLayers();
      }
    } catch (e) {
      print('Error updating places on map: $e');
    }
  }

  // تحديد نوع أيقونة المكان
  String _getPlaceIconName(PlaceModel place) {
    final name = place.placeName.toLowerCase();
    final address = place.address.toLowerCase();

    if (name.contains('جامعة') || address.contains('جامعة')) {
      return 'university';
    } else if (name.contains('كلية') || address.contains('كلية')) {
      return 'university';
    } else if (name.contains('مدرسة') || address.contains('مدرسة')) {
      return 'school';
    } else if (name.contains('مستشفى') || address.contains('مستشفى')) {
      return 'hospital';
    } else if (name.contains('مطعم') ||
        address.contains('مطعم') ||
        name.contains('كافيه') ||
        address.contains('كافيه')) {
      return 'restaurant';
    } else if (name.contains('مول') ||
        address.contains('مول') ||
        name.contains('سوق') ||
        address.contains('سوق')) {
      return 'shopping';
    } else if (name.contains('مسجد') || address.contains('مسجد')) {
      return 'mosque';
    } else if (name.contains('حديقة') ||
        address.contains('حديقة') ||
        name.contains('منتزه') ||
        address.contains('منتزه')) {
      return 'park';
    } else if (name.contains('فندق') || address.contains('فندق')) {
      return 'hotel';
    } else {
      return 'place';
    }
  }

  DateTime? _lastLocationUpdate;
  final Duration _locationUpdateThrottle = const Duration(
    milliseconds: 1000,
  ); // Increase to 1000ms

  void _onLocationControllerChanged() async {
    if (_locationController.currentLocation != null) {
      final now = DateTime.now();
      if (_lastLocationUpdate != null &&
          now.difference(_lastLocationUpdate!) < _locationUpdateThrottle) {
        return; // Skip if the last update was too recent
      }
      _lastLocationUpdate = now;

      if (!_layersInitialized) {
        _initializeMapLayers();
      } else {
        _previousLocation = _locationController.currentLocation;

        if (_previousLocation != null) {
          _userBearing = _calculateBearing(
            _previousLocation!.latitude,
            _previousLocation!.longitude,
            _locationController.currentLocation!.latitude,
            _locationController.currentLocation!.longitude,
          );
        }

        _updateDirectionArrow(_locationController.currentLocation!);

        if (_isFollowingUser) {
          _goToCurrentLocationWithBearing();
        }

        if (!_userHasMovedCamera && _placesAdded) {
          _loadVisiblePlaces();
        }

        if (_buildingsAdded && _mapboxMap != null) {
          final zoom = await _mapboxMap!.getCameraState().then(
            (state) => state.zoom,
          );
          if (zoom > 17) {
            _loadNearbyBuildings(_locationController.currentLocation!);
          }
        }
      }
    }
  }

  DateTime? _lastNavigationUpdate;
  final Duration _navigationUpdateThrottle = const Duration(milliseconds: 1000);

  void _onNavigationControllerChanged() async {
    if (_mapboxMap == null || !mounted) return;

    final now = DateTime.now();
    if (_lastNavigationUpdate != null &&
        now.difference(_lastNavigationUpdate!) < _navigationUpdateThrottle) {
      return; // Skip if the last navigation update was too recent
    }
    _lastNavigationUpdate = now;

    if (!_layersInitialized) {
      await _initializeMapLayers();
      return;
    }

    if (_navigationController.isNavigating) {
      print(
        'Navigation state changed - isNavigating: ${_navigationController.isNavigating}',
      );

      await Future.delayed(const Duration(milliseconds: 300));

      if (_navigationController.currentRoute != null) {
        print(
          'Updating route - points: ${_navigationController.currentRoute!.geometry.length}',
        );
        if (isFirstLoad) {
          _userHasMovedCamera = false;
        }
        _updateRouteOnMap(_navigationController.currentRoute!);
      } else {
        print('Navigation active but route is null!');
      }

      if (_navigationController.destination != null) {
        print(
          'Updating destination - ${_navigationController.destination!.placeName}',
        );
        _updateDestinationOnMap(
          _navigationController.destination!.latitude,
          _navigationController.destination!.longitude,
          _navigationController.destination!.placeName,
        );
      }
    } else {
      _clearRouteFromMap();
    }
  }

  void _updateDestinationOnMap(
    double latitude,
    double longitude,
    String name,
  ) async {
    if (!mounted ||
        !_layersInitialized ||
        _mapboxMap == null ||
        _isStyleLoading) {
      return;
    }

    try {
      print('Updating destination: $latitude, $longitude, $name');

      final Map<String, dynamic> featureCollection = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [longitude, latitude],
            },
            'properties': {'name': name},
          },
        ],
      };

      final String geoJsonString = jsonEncode(featureCollection);

      final sourceObj = await _mapboxMap!.style.getSource(_destinationSourceId);

      if (sourceObj != null) {
        final source = sourceObj as GeoJsonSource;
        source.updateGeoJSON(geoJsonString);
      } else {
        print('Destination source not found - reinitializing layers');
        _layersInitialized = false;
        await _initializeMapLayers();

        final newSourceObj = await _mapboxMap?.style.getSource(
          _destinationSourceId,
        );
        if (newSourceObj != null) {
          final source = newSourceObj as GeoJsonSource;
          source.updateGeoJSON(geoJsonString);
        }
      }
    } catch (e) {
      print('Error updating destination on map: $e');
    }
  }

  void _updateDirectionArrow(LocationModel location) async {
    if (!_layersInitialized || _mapboxMap == null || !_arrowAdded) return;

    try {
      if (_previousLocation == null) {
        _userBearing = (_userBearing + 2) % 360;
      }

      final Map<String, dynamic> arrowFeatureCollection = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [location.longitude, location.latitude],
            },
            'properties': {'bearing': _userBearing},
          },
        ],
      };

      final String arrowGeoJsonString = jsonEncode(arrowFeatureCollection);

      final arrowSourceObj = await _mapboxMap!.style.getSource(
        _directionArrowSourceId,
      );
      if (arrowSourceObj != null) {
        final arrowSource = arrowSourceObj as GeoJsonSource;
        arrowSource.updateGeoJSON(arrowGeoJsonString);
      }
    } catch (e) {
      print('Error updating direction arrow: $e');
    }
  }

  void _updateUserLocationOnMap(LocationModel location) async {
    if (!mounted || _mapboxMap == null || !_layersInitialized) return;

    try {
      final Map<String, dynamic> featureCollection = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [location.longitude, location.latitude],
            },
            'properties': {},
          },
        ],
      };

      final String geoJsonString = jsonEncode(featureCollection);

      final sourceObj = await _mapboxMap!.style.getSource(
        _userLocationSourceId,
      );

      if (sourceObj != null) {
        final source = sourceObj as GeoJsonSource;
        source.updateGeoJSON(geoJsonString);
      } else {
        print('User location source not found - reinitializing layers');
        await _initializeMapLayers();
        final newSourceObj = await _mapboxMap?.style.getSource(
          _userLocationSourceId,
        );
        if (newSourceObj != null) {
          final source = newSourceObj as GeoJsonSource;
          source.updateGeoJSON(geoJsonString);
        }
      }

      _updateDirectionArrow(location);

      if (_isFollowingUser) {
        _goToCurrentLocationWithBearing();
      }

      if (_buildingsAdded && _mapboxMap != null) {
        final zoom = await _mapboxMap!.getCameraState().then(
          (state) => state.zoom,
        );
        if (zoom > 17) {
          _loadNearbyBuildings(location);
        }
      }
    } catch (e) {
      print('Error updating user location on map: $e');
    }
  }

  // تحديث طبقة المباني على الخريطة
  Future<void> _updateBuildingsOnMap(List<PlaceModel> buildings) async {
    if (!_layersInitialized || _mapboxMap == null || !_buildingsAdded) return;

    try {
      final List<Map<String, dynamic>> features = [];

      // إنشاء feature لكل مبنى
      for (var building in buildings) {
        features.add({
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [building.longitude, building.latitude],
          },
          'properties': {
            'id': building.id,
            'name': building.placeName,
            'address': building.address,
            'height': 30, // ارتفاع افتراضي للمبنى
          },
        });
      }

      final Map<String, dynamic> featureCollection = {
        'type': 'FeatureCollection',
        'features': features,
      };

      final String geoJsonString = jsonEncode(featureCollection);

      // تحديث مصدر البيانات
      final sourceObj = await _mapboxMap!.style.getSource(_buildingsSourceId);
      if (sourceObj != null) {
        final source = sourceObj as GeoJsonSource;
        source.updateGeoJSON(geoJsonString);
      }
    } catch (e) {
      print('Error updating buildings on map: $e');
    }
  }

  void _updateRouteOnMap(RouteModel route) async {
    if (!mounted ||
        !_layersInitialized ||
        _mapboxMap == null ||
        _isStyleLoading) {
      return;
    }

    try {
      print('Updating route - points count: ${route.geometry.length}');

      if (route.geometry.isEmpty) {
        print('Warning: Route is empty!');
        return;
      }

      final Map<String, dynamic> featureCollection = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {'type': 'LineString', 'coordinates': route.geometry},
            'properties': {},
          },
        ],
      };

      final String geoJsonString = jsonEncode(featureCollection);

      final sourceObj = await _mapboxMap!.style.getSource(_routeSourceId);

      if (sourceObj != null) {
        final source = sourceObj as GeoJsonSource;
        source.updateGeoJSON(geoJsonString);

        if (isFirstLoad || (!_userHasMovedCamera && !_isFollowingUser)) {
          if (_locationController.currentLocation != null) {
            _positionCameraBehindUser(
              _locationController.currentLocation!,
              route,
            );
          }
          isFirstLoad = false;
        }
      } else {
        print('Route source not found - reinitializing layers');
        _layersInitialized = false;
        await _initializeMapLayers();

        final newSourceObj = await _mapboxMap?.style.getSource(_routeSourceId);
        if (newSourceObj != null) {
          final source = newSourceObj as GeoJsonSource;
          source.updateGeoJSON(geoJsonString);

          if (isFirstLoad && _locationController.currentLocation != null) {
            _positionCameraBehindUser(
              _locationController.currentLocation!,
              route,
            );
            isFirstLoad = false;
          }
        }
      }
    } catch (e) {
      print('Error updating route on map: $e');
    }
  }

  // إضافة دالة جديدة لضبط الكاميرا خلف المستخدم مع إظهار الروت أمامه
  void _positionCameraBehindUser(LocationModel userLocation, RouteModel route) {
    if (_mapboxMap == null || route.geometry.isEmpty) return;

    try {
      // موقع المستخدم
      double userLat = userLocation.latitude;
      double userLng = userLocation.longitude;

      // اتجاه المستخدم
      double bearing = _userBearing;

      // إزاحة الكاميرا لتكون خلف المستخدم
      const double offsetDistance = 0.001; // ~100 متر
      double offsetLat = offsetDistance * cos((bearing + 180) * pi / 180);
      double offsetLng = offsetDistance * sin((bearing + 180) * pi / 180);

      // مركز الكاميرا خلف المستخدم
      Point cameraCenter = Point(
        coordinates: Position(userLng + offsetLng, userLat + offsetLat),
      );

      // ضبط الكاميرا
      _mapboxMap!.flyTo(
        CameraOptions(
          center: cameraCenter,
          zoom: 17.0, // زووم مناسب لعرض الروت
          bearing: bearing, // تدوير الكاميرا لتتماشى مع اتجاه المستخدم
          pitch: 60.0, // إمالة الكاميرا لعرض ثلاثي الأبعاد
        ),
        MapAnimationOptions(duration: 1000),
      );

      print('Camera positioned behind user with bearing: $bearing');
    } catch (e) {
      print('Error positioning camera behind user: $e');
    }
  }

  void _clearRouteFromMap() async {
    try {
      if (!_layersInitialized || _mapboxMap == null) return;

      print('Clearing route from map');

      final routeSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
      if (routeSourceObj != null) {
        final routeSource = routeSourceObj as GeoJsonSource;
        routeSource.updateGeoJSON(_createEmptyLineFeatureCollection());
      }

      final destinationSourceObj = await _mapboxMap!.style.getSource(
        _destinationSourceId,
      );
      if (destinationSourceObj != null) {
        final destinationSource = destinationSourceObj as GeoJsonSource;
        destinationSource.updateGeoJSON(_createEmptyPointFeatureCollection());
      }

      print('Route cleared from map');
    } catch (e) {
      print('Error clearing route from map: $e');
    }
  }

  void _goToCurrentLocation() {
    if (_locationController.currentLocation != null && _mapboxMap != null) {
      // إعادة تعيين مؤشر حركة المستخدم عند طلب الانتقال إلى الموقع الحالي
      _userHasMovedCamera = false;

      _mapboxMap!.flyTo(
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
      print('Moved to current location');
    } else {
      _locationController.updateCurrentLocation();
      print('Attempting to update current location');
    }
  }

  DateTime? _lastCameraUpdate;
  final Duration _cameraUpdateThrottle = const Duration(
    milliseconds: 2000,
  ); // Increase to 2000ms

  void _goToCurrentLocationWithBearing() {
    if (_locationController.currentLocation != null && _mapboxMap != null) {
      final now = DateTime.now();
      if (_lastCameraUpdate != null &&
          now.difference(_lastCameraUpdate!) < _cameraUpdateThrottle) {
        return; // Skip if the last camera update was too recent
      }
      _lastCameraUpdate = now;

      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              _locationController.currentLocation!.longitude,
              _locationController.currentLocation!.latitude,
            ),
          ),
          zoom: 18.0,
          bearing: _userBearing,
          pitch: 60.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
      print('Moved to current location with bearing: $_userBearing');
    } else {
      _locationController.updateCurrentLocation();
      print('Attempting to update current location for bearing view');
    }
  }

  // تبديل عرض المباني ثلاثية الأبعاد
  void _toggleBuildingsView() async {
    if (_mapboxMap == null || !mounted) return;

    setState(() {
      _isStyleLoading = true; // Set flag to indicate style is loading
      _buildingsAdded = !_buildingsAdded;
    });

    try {
      if (_buildingsAdded) {
        // Switch to a style that supports 3D buildings
        await _mapboxMap!.style.setStyleURI(
          "mapbox://styles/mapbox/streets-v12",
        );

        // Reset flags
        _layersInitialized = false;
        _placesAdded = false;
        _buildingsAdded = false;
        _arrowAdded = false;

        // Wait for the style to load
        await Future.delayed(const Duration(milliseconds: 500));

        // Re-initialize layers
        await _initializeMapLayers();

        // Add 3D buildings layer
        await _add3DBuildingsLayer();

        if (_locationController.currentLocation != null) {
          _mapboxMap!.flyTo(
            CameraOptions(
              center: Point(
                coordinates: Position(
                  _locationController.currentLocation!.longitude,
                  _locationController.currentLocation!.latitude,
                ),
              ),
              zoom: 16.0,
              pitch: 60.0,
              bearing: 0.0,
            ),
            MapAnimationOptions(duration: 1000),
          );
        }
      } else {
        // Switch back to the original style
        String mapStyle =
            _storageController.isDarkMode
                ? AppConstants.nightMapStyle
                : AppConstants.outdoorsStyle;
        await _mapboxMap!.style.setStyleURI(mapStyle);

        // Reset flags
        _layersInitialized = false;
        _placesAdded = false;
        _buildingsAdded = false;
        _arrowAdded = false;

        // Wait for the style to load
        await Future.delayed(const Duration(milliseconds: 500));

        // Re-initialize layers
        await _initializeMapLayers();

        if (_locationController.currentLocation != null) {
          _mapboxMap!.flyTo(
            CameraOptions(
              center: Point(
                coordinates: Position(
                  _locationController.currentLocation!.longitude,
                  _locationController.currentLocation!.latitude,
                ),
              ),
              zoom: 15.0,
              pitch: 0.0,
              bearing: 0.0,
            ),
            MapAnimationOptions(duration: 1000),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _buildingsAdded
                  ? 'تم تفعيل عرض المباني ثلاثية الأبعاد'
                  : 'تم إيقاف عرض المباني ثلاثية الأبعاد',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling buildings view: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isStyleLoading = false; // Reset flag after style is loaded
        });
      }
    }
  }

  Future<void> _add3DBuildingsLayer() async {
    if (!mounted || _mapboxMap == null) return;

    try {
      final layerProperties = {
        "id": "3d-buildings",
        "source": "composite",
        "source-layer": "building",
        "type": "fill-extrusion",
        "minzoom": 15,
        "paint": {
          "fill-extrusion-color": "#aaa",
          "fill-extrusion-height": ["get", "height"],
          "fill-extrusion-base": ["get", "min_height"],
          "fill-extrusion-opacity": 0.7,
        },
      };

      await _mapboxMap!.style.addStyleLayer(layerProperties as String, null);
      print('تم إضافة طبقة المباني ثلاثية الأبعاد بنجاح');
    } catch (e) {
      print('خطأ في إضافة طبقة المباني: $e');

      try {
        await _mapboxMap!.style.addSource(
          GeoJsonSource(
            id: "building-source",
            data: '{"type":"FeatureCollection","features":[]}',
          ),
        );

        await _mapboxMap!.style.addLayer(
          FillExtrusionLayer(
            id: "building-extrusions",
            sourceId: "building-source",
            fillExtrusionColor: 0xFFAAAAAA,
            fillExtrusionHeight: 30,
            fillExtrusionOpacity: 0.7,
          ),
        );
      } catch (fallbackError) {
        print('فشلت الطريقة البديلة أيضًا: $fallbackError');
      }
    }
  }

  void _toggleFollowMode() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;
      if (_isFollowingUser) {
        // إعادة تعيين مؤشر حركة المستخدم عند تفعيل وضع المتابعة
        _userHasMovedCamera = false;
        _goToCurrentLocationWithBearing();
      }
    });
  }

  // حساب المسافة بين نقطتين بالكيلومترات
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // نصف قطر الأرض بالأمتار
    double lat1Rad = _degreesToRadians(lat1);
    double lat2Rad = _degreesToRadians(lat2);
    double deltaLatRad = _degreesToRadians(lat2 - lat1);
    double deltaLonRad = _degreesToRadians(lon2 - lon1);

    double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLonRad / 2) *
            sin(deltaLonRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // المسافة بالأمتار
  }

  // تحويل الدرجات إلى راديان
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  double _calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    double latitude1 = startLat * (pi / 180.0);
    double longitude1 = startLng * (pi / 180.0);
    double latitude2 = endLat * (pi / 180.0);
    double longitude2 = endLng * (pi / 180.0);

    double y = sin(longitude2 - longitude1) * cos(latitude2);
    double x =
        cos(latitude1) * sin(latitude2) -
        sin(latitude1) * cos(latitude2) * cos(longitude2 - longitude1);

    double bearing = atan2(y, x);
    bearing = bearing * (180.0 / pi);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  // البحث عن المباني داخل مؤسسة معينة مثل الجامعة

  // ضبط حدود الخريطة لعرض جميع الأماكن

  void _updateMapStyle() async {
    if (_mapboxMap == null || !mounted) return;

    setState(() {
      _isStyleLoading = true; // Set flag to indicate style is loading
    });

    String mapStyle =
        _storageController.isDarkMode
            ? AppConstants.nightMapStyle
            : AppConstants.dayMapStyle;

    // Reset flags to prevent access during style change
    _layersInitialized = false;
    _placesAdded = false;
    _buildingsAdded = false;
    _arrowAdded = false;

    try {
      // Load the new style
      await _mapboxMap!.style.setStyleURI(mapStyle);

      // Wait for the style to fully load
      await Future.delayed(const Duration(milliseconds: 500));

      // Re-initialize layers after the style is loaded
      await _initializeMapLayers();

      print('Map style updated and layers re-initialized: $mapStyle');
    } catch (e) {
      print('Error updating map style: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isStyleLoading = false; // Reset flag after style is loaded
        });
      }
    }
  }

  String _createEmptyPointFeatureCollection() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  String _createEmptyLineFeatureCollection() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  @override
  void dispose() {
    // Cancel timers
    _cameraUpdateTimer?.cancel();
    _resetUserMovedCameraTimer?.cancel();
    _placesDebounceTimer?.cancel();
    _buildingsDebounceTimer?.cancel();

    // Remove listeners
    _locationController.removeListener(_onLocationControllerChanged);
    _navigationController.removeListener(_onNavigationControllerChanged);

    // Clear map reference and reset flags
    _mapboxMap = null;
    _layersInitialized = false;
    _placesAdded = false;
    _buildingsAdded = false;
    _arrowAdded = false;
    _isStyleLoading = false;

    // Call super last
    super.dispose();
  }
}
