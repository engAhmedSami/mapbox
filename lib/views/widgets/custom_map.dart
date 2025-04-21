// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:developer';
import 'dart:convert';
import 'dart:async'; // Added for Timer
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

class CustomMap extends StatefulWidget {
  final Function(PlaceModel)? onPlaceSelected;
  final bool followUserLocation; // Added to enable live tracking

  const CustomMap({
    super.key,
    this.onPlaceSelected,
    this.followUserLocation = false, // Default is false
  });

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  MapboxMap? _mapboxMap;
  late LocationController _locationController;
  late NavigationController _navigationController;
  late StorageController _storageController;
  bool _layersInitialized = false;
  Timer? _cameraUpdateTimer; // Added for periodic camera updates

  // Map layer identifiers
  final String _routeLayerId = 'route-layer';
  final String _routeSourceId = 'route-source';
  final String _userLocationSourceId = 'user-location-source';
  final String _userLocationLayerId = 'user-location-layer';
  final String _destinationSourceId = 'destination-source';
  final String _destinationLayerId = 'destination-layer';
  final String _destinationCircleLayerId = 'destination-circle-layer';
  final String _customLocationSourceId = 'custom-location-source';
  final String _customLocationLayerId = 'custom-location-layer';
  bool _customLocationAdded = false;

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
  }

  @override
  Widget build(BuildContext context) {
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
          onStyleLoadedListener: (styleLoadedEventData) => _onStyleLoaded,
          onTapListener: _onMapTap, // Added to set destination on tap
        ),
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
        // Positioned(
        //   bottom: 210,
        //   right: 16,
        //   child: FloatingActionButton(
        //     heroTag: 'btn_add_custom_marker',
        //     mini: true,
        //     backgroundColor: Theme.of(context).colorScheme.surface,
        //     onPressed: () async {
        //       try {
        //         if (_mapboxMap != null) {
        //           CameraState cameraState = await _mapboxMap!.getCameraState();
        //           double latitude =
        //               cameraState.center.coordinates.lat.toDouble();
        //           double longitude =
        //               cameraState.center.coordinates.lng.toDouble();
        //           await addCustomMarkerOnMap(latitude, longitude);
        //         }
        //       } catch (e) {
        //         log('Error getting camera position: $e');
        //       }
        //     },
        //     child: Icon(Icons.location_pin, color: Colors.red),
        //   ),
        // ),
      ],
    );
  }

  void _onMapTap(MapContentGestureContext context) async {
    if (_mapboxMap == null) return;

    try {
      // Convert screen coordinates to geographic coordinates
      Point point = await _mapboxMap!.coordinateForPixel(
        context.point as ScreenCoordinate,
      );
      Position position = point.coordinates;
      double latitude = position.lat.toDouble();
      double longitude = position.lng.toDouble();

      // Create a PlaceModel for the tapped location
      PlaceModel selectedPlace = PlaceModel(
        address: 'Selected Location',
        id: 'selected',
        placeName: 'Selected Destination',
        latitude: latitude,
        longitude: longitude,
      );

      // Start navigation to the selected destination
      _navigationController.startNavigation(
        selectedPlace,
        _locationController.currentLocation!,
      );

      log('Destination set at: $latitude, $longitude');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Destination set. Calculating route...')),
      );
    } catch (e) {
      log('Error setting destination: $e');
      ScaffoldMessenger.of(
        context as BuildContext,
      ).showSnackBar(SnackBar(content: Text('Error setting destination: $e')));
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    log('Map created');
    _locationController.addListener(_onLocationControllerChanged);
    _navigationController.addListener(_onNavigationControllerChanged);

    // Enable location tracking
    _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true, // Show user location
        pulsingEnabled: true, // Add pulsing effect
        showAccuracyRing: true, // Show accuracy ring
      ),
    );

    // Start periodic camera updates if followUserLocation is true
    if (widget.followUserLocation) {
      _cameraUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_mapboxMap != null && widget.followUserLocation) {
          _goToCurrentLocation();
        }
      });
    }
  }

  void _onStyleLoaded(MapLoadedEventData eventData) {
    log('Map style loaded');
    _initializeMapLayers();
    Future.delayed(const Duration(milliseconds: 500), _goToCurrentLocation);
  }

  Future<void> _initializeMapLayers() async {
    if (_layersInitialized || _mapboxMap == null) return;

    try {
      log('Initializing map layers...');

      await _mapboxMap!.style.addSource(
        GeoJsonSource(
          id: _userLocationSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );

      await _mapboxMap!.style.addLayer(
        CircleLayer(
          id: "${_userLocationLayerId}_outer",
          sourceId: _userLocationSourceId,
          circleRadius: 18.0,
          circleColor: 0x554882C4,
          circleStrokeWidth: 2.0,
          circleStrokeColor: 0xFF4882C4,
        ),
      );

      await _mapboxMap!.style.addLayer(
        CircleLayer(
          id: _userLocationLayerId,
          sourceId: _userLocationSourceId,
          circleRadius: 10.0,
          circleColor: 0xFF4882C4,
          circleStrokeWidth: 3.0,
          circleStrokeColor: 0xFFFFFFFF,
        ),
      );

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

      _layersInitialized = true;
      log('Map layers initialized successfully');

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
      log('Error initializing map layers: $e');
    }
  }

  void _onLocationControllerChanged() {
    if (_locationController.currentLocation != null && _layersInitialized) {
      _updateUserLocationOnMap(_locationController.currentLocation!);
    }
  }

  void _onNavigationControllerChanged() {
    if (!_layersInitialized) return;

    if (_navigationController.isNavigating) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_navigationController.currentRoute != null) {
          log(
            'Updating route - points: ${_navigationController.currentRoute!.geometry.length}',
          );
          _updateRouteOnMap(_navigationController.currentRoute!);
        }
        if (_navigationController.destination != null) {
          log(
            'Updating destination - ${_navigationController.destination!.placeName}',
          );
          _updateDestinationOnMap(
            _navigationController.destination!.latitude,
            _navigationController.destination!.longitude,
            _navigationController.destination!.placeName,
          );
        }
      });
    } else {
      _clearRouteFromMap();
    }
  }

  void _updateUserLocationOnMap(LocationModel location) {
    try {
      if (!_layersInitialized || _mapboxMap == null) return;

      log(
        'Updating user location: ${location.latitude}, ${location.longitude}',
      );

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
      final GeoJsonSource? source =
          _mapboxMap!.style.getSource(_userLocationSourceId) as GeoJsonSource?;
      if (source != null) {
        source.updateGeoJSON(geoJsonString);
      } else {
        log('User location source not found');
      }
    } catch (e) {
      log('Error updating user location on map: $e');
    }
  }

  Future<void> addCustomMarkerOnMap(double latitude, double longitude) async {
    try {
      if (_mapboxMap == null) return;

      log('Adding custom marker at: $latitude, $longitude');

      if (!_customLocationAdded) {
        await _mapboxMap!.style.addSource(
          GeoJsonSource(
            id: _customLocationSourceId,
            data: '{"type":"FeatureCollection","features":[]}',
          ),
        );

        await _mapboxMap!.style.addLayer(
          CircleLayer(
            id: "${_customLocationLayerId}_outer",
            sourceId: _customLocationSourceId,
            circleRadius: 15.0,
            circleColor: 0x44FF0000,
            circleStrokeWidth: 2.0,
            circleStrokeColor: 0xFFFFFFFF,
          ),
        );

        await _mapboxMap!.style.addLayer(
          CircleLayer(
            id: _customLocationLayerId,
            sourceId: _customLocationSourceId,
            circleRadius: 8.0,
            circleColor: 0xFFFF0000,
            circleStrokeWidth: 2.0,
            circleStrokeColor: 0xFFFFFFFF,
          ),
        );

        await _mapboxMap!.style.addLayer(
          SymbolLayer(
            id: "${_customLocationLayerId}_label",
            sourceId: _customLocationSourceId,
            textField: "{name}",
            textSize: 12.0,
            textOffset: [0, 2.0],
            textAnchor: TextAnchor.TOP,
            textColor: 0xFF000000,
            textHaloColor: 0xFFFFFFFF,
            textHaloWidth: 1.0,
          ),
        );

        _customLocationAdded = true;
      }

      final Source? source = await _mapboxMap!.style.getSource(
        _customLocationSourceId,
      );
      if (source is GeoJsonSource) {
        final Map<String, dynamic> featureCollection = {
          'type': 'FeatureCollection',
          'features': [
            {
              'type': 'Feature',
              'geometry': {
                'type': 'Point',
                'coordinates': [longitude, latitude],
              },
              'properties': {'name': 'Custom Location'},
            },
          ],
        };
        source.updateGeoJSON(jsonEncode(featureCollection));
      }

      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(longitude.toDouble(), latitude.toDouble()),
          ),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 1000),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom marker added successfully')),
      );
    } catch (e) {
      log('Error adding custom marker: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding marker: $e')));
    }
  }

  void _updateDestinationOnMap(double latitude, double longitude, String name) {
    try {
      if (!_layersInitialized || _mapboxMap == null) return;

      log('Updating destination: $latitude, $longitude, $name');

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
      final GeoJsonSource? source =
          _mapboxMap!.style.getSource(_destinationSourceId) as GeoJsonSource?;
      if (source != null) {
        source.updateGeoJSON(geoJsonString);
      } else {
        log('Destination source not found');
      }
    } catch (e) {
      log('Error updating destination on map: $e');
    }
  }

  void _updateRouteOnMap(RouteModel route) {
    try {
      if (!_layersInitialized || _mapboxMap == null) return;

      log('Updating route - points count: ${route.geometry.length}');

      if (route.geometry.isEmpty) {
        log('Warning: Route is empty!');
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
      final GeoJsonSource? source =
          _mapboxMap!.style.getSource(_routeSourceId) as GeoJsonSource?;
      if (source != null) {
        source.updateGeoJSON(geoJsonString);
        _fitRouteInView(route.geometry);
      } else {
        log('Route source not found');
      }
    } catch (e) {
      log('Error updating route on map: $e');
    }
  }

  void _fitRouteInView(List<List<double>> coordinates) {
    if (coordinates.isEmpty || _mapboxMap == null) return;

    try {
      double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

      for (final point in coordinates) {
        if (point.length < 2) continue;
        final lng = point[0];
        final lat = point[1];
        minLat = minLat > lat ? lat : minLat;
        maxLat = maxLat < lat ? lat : maxLat;
        minLng = minLng > lng ? lng : minLng;
        maxLng = maxLng < lng ? lng : maxLng;
      }

      final latDelta = (maxLat - minLat) * 0.2;
      final lngDelta = (maxLng - minLng) * 0.2;

      final southwest = Point(
        coordinates: Position(minLng - lngDelta, minLat - latDelta),
      );
      final northeast = Point(
        coordinates: Position(maxLng + lngDelta, maxLat + latDelta),
      );

      if (!_isValidCoordinate(southwest.coordinates) ||
          !_isValidCoordinate(northeast.coordinates)) {
        log('Invalid coordinates for fitting map');
        return;
      }

      final bounds = CoordinateBounds(
        southwest: southwest,
        northeast: northeast,
        infiniteBounds: false,
      );

      _mapboxMap!
          .cameraForCoordinateBounds(
            bounds,
            MbxEdgeInsets(top: 100, left: 50, bottom: 150, right: 50),
            null,
            null,
            null,
            null,
          )
          .then((camera) {
            _mapboxMap!.flyTo(camera, MapAnimationOptions(duration: 1000));
          });

      log('Map zoom adjusted for route');
    } catch (e) {
      log('Error adjusting map zoom: $e');
    }
  }

  bool _isValidCoordinate(Position position) {
    return position.lat >= -90 &&
        position.lat <= 90 &&
        position.lng >= -180 &&
        position.lng <= 180;
  }

  void _clearRouteFromMap() {
    try {
      if (!_layersInitialized || _mapboxMap == null) return;

      final GeoJsonSource? routeSource =
          _mapboxMap!.style.getSource(_routeSourceId) as GeoJsonSource?;
      if (routeSource != null) {
        routeSource.updateGeoJSON(_createEmptyLineFeatureCollection());
      }

      final GeoJsonSource? destinationSource =
          _mapboxMap!.style.getSource(_destinationSourceId) as GeoJsonSource?;
      if (destinationSource != null) {
        destinationSource.updateGeoJSON(_createEmptyPointFeatureCollection());
      }

      log('Route cleared from map');
    } catch (e) {
      log('Error clearing route from map: $e');
    }
  }

  void _goToCurrentLocation() {
    if (_locationController.currentLocation != null && _mapboxMap != null) {
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
      log('Moved to current location');
    } else {
      _locationController.updateCurrentLocation();
      log('Attempting to update current location');
    }
  }

  void _updateMapStyle() {
    if (_mapboxMap == null) return;

    String mapStyle =
        _storageController.isDarkMode
            ? AppConstants.nightMapStyle
            : AppConstants.dayMapStyle;

    _mapboxMap!.style.setStyleURI(mapStyle);
    _layersInitialized = false;
    _customLocationAdded = false;
    log('Map style updated: $mapStyle');
  }

  String _createEmptyPointFeatureCollection() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  String _createEmptyLineFeatureCollection() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  @override
  void dispose() {
    _cameraUpdateTimer?.cancel(); // Clean up the timer
    _locationController.removeListener(_onLocationControllerChanged);
    _navigationController.removeListener(_onNavigationControllerChanged);
    super.dispose();
  }
}
