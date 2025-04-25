// // // // ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print
// // // import 'dart:convert';
// // // import 'dart:async';
// // // import 'dart:math';
// // // import 'dart:typed_data';
// // // import 'package:flutter/material.dart';
// // // import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// // // import 'package:provider/provider.dart';
// // // import '../../config/app_constants.dart';
// // // import '../../controllers/location_controller.dart';
// // // import '../../controllers/navigation_controller.dart';
// // // import '../../controllers/storage_controller.dart';
// // // import '../../models/location_model.dart';
// // // import '../../models/place_model.dart';
// // // import '../../models/route_model.dart';

// // // class CustomMap extends StatefulWidget {
// // //   final Function(PlaceModel)? onPlaceSelected;
// // //   final bool followUserLocation;

// // //   const CustomMap({
// // //     super.key,
// // //     this.onPlaceSelected,
// // //     this.followUserLocation = false,
// // //   });

// // //   @override
// // //   State<CustomMap> createState() => _CustomMapState();
// // // }

// // // class _CustomMapState extends State<CustomMap> {
// // //   MapboxMap? _mapboxMap;
// // //   late LocationController _locationController;
// // //   late NavigationController _navigationController;
// // //   late StorageController _storageController;
// // //   bool _layersInitialized = false;
// // //   Timer? _cameraUpdateTimer;
// // //   bool isFirstLoad = true;

// // //   // Direction arrow and camera control variables
// // //   final String _directionArrowSourceId = 'direction-arrow-source';
// // //   final String _directionArrowLayerId = 'direction-arrow-layer';
// // //   double _userBearing = 0; // Current user direction
// // //   bool _isFollowingUser = false; // Is camera following user?
// // //   bool _arrowAdded = false; // Has the arrow layer been added?
// // //   LocationModel?
// // //   _previousLocation; // Store previous location to calculate bearing

// // //   // Map layer identifiers
// // //   final String _routeLayerId = 'route-layer';
// // //   final String _routeSourceId = 'route-source';
// // //   final String _userLocationSourceId = 'user-location-source';
// // //   final String _userLocationLayerId = 'user-location-layer';
// // //   final String _destinationSourceId = 'destination-source';
// // //   final String _destinationLayerId = 'destination-layer';
// // //   final String _destinationCircleLayerId = 'destination-circle-layer';
// // //   final String customLocationSourceId = 'custom-location-source';
// // //   final String customLocationLayerId = 'custom-location-layer';
// // //   bool customLocationAdded = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //   }

// // //   @override
// // //   void didChangeDependencies() {
// // //     super.didChangeDependencies();
// // //     _locationController = Provider.of<LocationController>(context);
// // //     _navigationController = Provider.of<NavigationController>(context);
// // //     _storageController = Provider.of<StorageController>(context);

// // //     // Add listeners to ensure we catch all state changes
// // //     _locationController.addListener(_onLocationControllerChanged);
// // //     _navigationController.addListener(_onNavigationControllerChanged);
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     String mapStyle =
// // //         _storageController.isDarkMode
// // //             ? AppConstants.nightMapStyle
// // //             : AppConstants.outdoorsStyle;

// // //     return Stack(
// // //       children: [
// // //         MapWidget(
// // //           styleUri: mapStyle,
// // //           onMapCreated: _onMapCreated,
// // //           cameraOptions: CameraOptions(
// // //             center: Point(
// // //               coordinates: Position(
// // //                 AppConstants.defaultLongitude,
// // //                 AppConstants.defaultLatitude,
// // //               ),
// // //             ),
// // //             zoom: AppConstants.defaultZoom,
// // //           ),
// // //           onStyleLoadedListener: _onStyleLoaded,
// // //           onTapListener: _onMapTap,
// // //         ),
// // //         // Current location button
// // //         Positioned(
// // //           bottom: 110,
// // //           right: 16,
// // //           child: FloatingActionButton(
// // //             heroTag: 'btn_current_location',
// // //             mini: true,
// // //             backgroundColor: Theme.of(context).colorScheme.surface,
// // //             onPressed: _goToCurrentLocation,
// // //             child: Icon(
// // //               Icons.my_location,
// // //               color: Theme.of(context).colorScheme.primary,
// // //             ),
// // //           ),
// // //         ),
// // //         // Toggle map style button
// // //         Positioned(
// // //           bottom: 160,
// // //           right: 16,
// // //           child: FloatingActionButton(
// // //             heroTag: 'btn_toggle_map_mode',
// // //             mini: true,
// // //             backgroundColor: Theme.of(context).colorScheme.surface,
// // //             onPressed: () {
// // //               _storageController.toggleThemeMode();
// // //               _updateMapStyle();
// // //             },
// // //             child: Icon(
// // //               _storageController.isDarkMode
// // //                   ? Icons.wb_sunny
// // //                   : Icons.nightlight_round,
// // //               color: Theme.of(context).colorScheme.primary,
// // //             ),
// // //           ),
// // //         ),
// // //         // Toggle follow mode button
// // //         Positioned(
// // //           bottom: 210,
// // //           right: 16,
// // //           child: FloatingActionButton(
// // //             heroTag: 'btn_toggle_follow_mode',
// // //             mini: true,
// // //             backgroundColor: Theme.of(context).colorScheme.surface,
// // //             onPressed: _toggleFollowMode,
// // //             child: Icon(
// // //               _isFollowingUser ? Icons.navigation : Icons.explore,
// // //               color:
// // //                   _isFollowingUser
// // //                       ? Theme.of(context).colorScheme.primary
// // //                       : Theme.of(context).colorScheme.onSurface,
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   void _onMapTap(MapContentGestureContext context) async {
// // //     if (_mapboxMap == null) return;

// // //     try {
// // //       // Convert screen coordinates to geographic coordinates
// // //       Point point = await _mapboxMap!.coordinateForPixel(
// // //         context.point as ScreenCoordinate,
// // //       );
// // //       Position position = point.coordinates;
// // //       double latitude = position.lat.toDouble();
// // //       double longitude = position.lng.toDouble();

// // //       // Create a PlaceModel for the tapped location
// // //       PlaceModel selectedPlace = PlaceModel(
// // //         address: 'الموقع المحدد',
// // //         id: 'selected',
// // //         placeName: 'الوجهة المحددة',
// // //         latitude: latitude,
// // //         longitude: longitude,
// // //       );

// // //       // Start navigation to the selected destination
// // //       if (_locationController.currentLocation != null) {
// // //         _navigationController.startNavigation(
// // //           selectedPlace,
// // //           _locationController.currentLocation!,
// // //         );

// // //         print('Destination set at: $latitude, $longitude');
// // //         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
// // //           const SnackBar(content: Text('تم تحديد الوجهة. جارِ حساب المسار...')),
// // //         );
// // //       } else {
// // //         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
// // //           const SnackBar(content: Text('لم يتم تحديد موقعك الحالي بعد')),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       print('Error setting destination: $e');
// // //       ScaffoldMessenger.of(
// // //         context as BuildContext,
// // //       ).showSnackBar(SnackBar(content: Text('خطأ في تحديد الوجهة: $e')));
// // //     }
// // //   }

// // //   void _onMapCreated(MapboxMap mapboxMap) {
// // //     _mapboxMap = mapboxMap;
// // //     print('Map created');

// // //     // Enable location tracking
// // //     _mapboxMap!.location.updateSettings(
// // //       LocationComponentSettings(
// // //         enabled: true,
// // //         pulsingEnabled: true,
// // //         showAccuracyRing: true,
// // //       ),
// // //     );

// // //     // Start periodic camera updates if followUserLocation is true
// // //     if (widget.followUserLocation) {
// // //       _cameraUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
// // //         if (_mapboxMap != null && widget.followUserLocation) {
// // //           _goToCurrentLocation();
// // //         }
// // //       });
// // //     }
// // //   }

// // //   void _onStyleLoaded(styleLoadedEventData) async {
// // //     print('Map style loaded');

// // //     // Make sure we initialize layers when style is loaded
// // //     await Future.delayed(const Duration(milliseconds: 500));

// // //     await _initializeMapLayers();
// // //     _goToCurrentLocation();

// // //     // Check if there's an active navigation and update the map accordingly
// // //     if (_navigationController.isNavigating) {
// // //       await Future.delayed(const Duration(milliseconds: 200));

// // //       if (_navigationController.destination != null) {
// // //         _updateDestinationOnMap(
// // //           _navigationController.destination!.latitude,
// // //           _navigationController.destination!.longitude,
// // //           _navigationController.destination!.placeName,
// // //         );
// // //       }

// // //       if (_navigationController.currentRoute != null) {
// // //         _updateRouteOnMap(_navigationController.currentRoute!);
// // //       }
// // //     }
// // //   }

// // //   Future<void> _initializeMapLayers() async {
// // //     if (_layersInitialized || _mapboxMap == null) return;

// // //     try {
// // //       print('Initializing map layers...');

// // //       // Add user location source and layers
// // //       await _mapboxMap!.style.addSource(
// // //         GeoJsonSource(
// // //           id: _userLocationSourceId,
// // //           data: '{"type":"FeatureCollection","features":[]}',
// // //         ),
// // //       );

// // //       await _mapboxMap!.style.addLayer(
// // //         CircleLayer(
// // //           id: "${_userLocationLayerId}_outer",
// // //           sourceId: _userLocationSourceId,
// // //           circleRadius: 18.0,
// // //           circleColor: 0x554882C4,
// // //           circleStrokeWidth: 2.0,
// // //           circleStrokeColor: 0xFF4882C4,
// // //         ),
// // //       );

// // //       await _mapboxMap!.style.addLayer(
// // //         CircleLayer(
// // //           id: _userLocationLayerId,
// // //           sourceId: _userLocationSourceId,
// // //           circleRadius: 10.0,
// // //           circleColor: 0xFF4882C4,
// // //           circleStrokeWidth: 3.0,
// // //           circleStrokeColor: 0xFFFFFFFF,
// // //         ),
// // //       );

// // //       // Add destination source and layers
// // //       await _mapboxMap!.style.addSource(
// // //         GeoJsonSource(
// // //           id: _destinationSourceId,
// // //           data: '{"type":"FeatureCollection","features":[]}',
// // //         ),
// // //       );

// // //       await _mapboxMap!.style.addLayer(
// // //         CircleLayer(
// // //           id: _destinationCircleLayerId,
// // //           sourceId: _destinationSourceId,
// // //           circleRadius: 12.0,
// // //           circleColor: 0xFFE53935,
// // //           circleStrokeWidth: 3.0,
// // //           circleStrokeColor: 0xFFFFFFFF,
// // //         ),
// // //       );

// // //       await _mapboxMap!.style.addLayer(
// // //         SymbolLayer(
// // //           id: _destinationLayerId,
// // //           sourceId: _destinationSourceId,
// // //           textField: "{name}",
// // //           textSize: 14.0,
// // //           textOffset: [0, 2.0],
// // //           textAnchor: TextAnchor.TOP,
// // //           textColor: 0xFF000000,
// // //           textHaloWidth: 1.5,
// // //           textHaloColor: 0xFFFFFFFF,
// // //         ),
// // //       );

// // //       // Add route source and layer
// // //       await _mapboxMap!.style.addSource(
// // //         GeoJsonSource(
// // //           id: _routeSourceId,
// // //           data: '{"type":"FeatureCollection","features":[]}',
// // //         ),
// // //       );

// // //       await _mapboxMap!.style.addLayer(
// // //         LineLayer(
// // //           id: _routeLayerId,
// // //           sourceId: _routeSourceId,
// // //           lineColor: int.parse(
// // //             '0xFF${AppConstants.routeLineColor.substring(1)}',
// // //           ),
// // //           lineWidth: AppConstants.routeLineWidth,
// // //           lineCap: LineCap.ROUND,
// // //           lineJoin: LineJoin.ROUND,
// // //         ),
// // //       );

// // //       // Add direction arrow source and layer
// // //       await _mapboxMap!.style.addSource(
// // //         GeoJsonSource(
// // //           id: _directionArrowSourceId,
// // //           data: '{"type":"FeatureCollection","features":[]}',
// // //         ),
// // //       );

// // //       await _mapboxMap!.style.addLayer(
// // //         SymbolLayer(
// // //           id: _directionArrowLayerId,
// // //           sourceId: _directionArrowSourceId,
// // //           iconImage: "arrow", // Name of the arrow image we'll add
// // //           iconSize: 1.5,
// // //           iconAllowOverlap: true,
// // //           iconIgnorePlacement: true,
// // //           iconRotate:
// // //               _userBearing, // Rotate arrow based on the calculated bearing
// // //         ),
// // //       );

// // //       // Add arrow image to the map
// // //       await _addArrowImageToMap();

// // //       _layersInitialized = true;
// // //       _arrowAdded = true;
// // //       print('Map layers initialized successfully');

// // //       // Update map with current data
// // //       if (_locationController.currentLocation != null) {
// // //         _updateUserLocationOnMap(_locationController.currentLocation!);
// // //       }

// // //       if (_navigationController.isNavigating) {
// // //         if (_navigationController.destination != null) {
// // //           _updateDestinationOnMap(
// // //             _navigationController.destination!.latitude,
// // //             _navigationController.destination!.longitude,
// // //             _navigationController.destination!.placeName,
// // //           );
// // //         }
// // //         if (_navigationController.currentRoute != null) {
// // //           _updateRouteOnMap(_navigationController.currentRoute!);
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print('Error initializing map layers: $e');
// // //     }
// // //   }

// // //   // Add arrow image to the map
// // //   Future<void> _addArrowImageToMap() async {
// // //     try {
// // //       // Create arrow image programmatically
// // //       final int size = 64;
// // //       final Uint8List data = Uint8List(size * size * 4);

// // //       // Fill the image data with our arrow
// // //       for (int y = 0; y < size; y++) {
// // //         for (int x = 0; x < size; x++) {
// // //           // Calculate distance from center
// // //           double centerX = size / 2;
// // //           double centerY = size / 2;
// // //           double dx = x - centerX;
// // //           double dy = y - centerY;

// // //           // Define arrow shape
// // //           bool isArrow = false;
// // //           bool isArrowBorder = false;

// // //           // Arrow body
// // //           if (dx.abs() < 8 && dy > 0 && dy < 24) {
// // //             isArrow = true;
// // //           }

// // //           // Arrow head
// // //           if (dy < 0 && dy > -16 && dx.abs() < -dy) {
// // //             isArrow = true;
// // //           }

// // //           // Arrow border
// // //           if (dx.abs() < 10 && dy > -2 && dy < 26 && !isArrow) {
// // //             isArrowBorder = true;
// // //           }

// // //           if (dy < 2 && dy > -18 && dx.abs() < (-dy + 2) && !isArrow) {
// // //             isArrowBorder = true;
// // //           }

// // //           int pixelIndex = (y * size + x) * 4;
// // //           if (isArrow) {
// // //             // Blue fill for the arrow
// // //             data[pixelIndex] = 72; // R
// // //             data[pixelIndex + 1] = 130; // G
// // //             data[pixelIndex + 2] = 196; // B
// // //             data[pixelIndex + 3] = 255; // A
// // //           } else if (isArrowBorder) {
// // //             // White border for the arrow
// // //             data[pixelIndex] = 255; // R
// // //             data[pixelIndex + 1] = 255; // G
// // //             data[pixelIndex + 2] = 255; // B
// // //             data[pixelIndex + 3] = 255; // A
// // //           } else {
// // //             // Transparent
// // //             data[pixelIndex + 3] = 0; // A
// // //           }
// // //         }
// // //       }

// // //       // Create MbxImage from the Uint8List
// // //       final MbxImage arrowImage = MbxImage(
// // //         width: size,
// // //         height: size,
// // //         data: data,
// // //       );

// // //       // Add the image to the map style
// // //       await _mapboxMap!.style.addStyleImage(
// // //         "arrow", // imageId
// // //         1.0, // scale
// // //         arrowImage, // image
// // //         false, // sdf
// // //         [], // stretchX
// // //         [], // stretchY
// // //         null, // content
// // //       );

// // //       print('Arrow image added to map successfully');
// // //     } catch (e) {
// // //       print('Error adding arrow image to map: $e');
// // //     }
// // //   }

// // //   void _onLocationControllerChanged() {
// // //     if (_locationController.currentLocation != null) {
// // //       if (!_layersInitialized) {
// // //         _initializeMapLayers();
// // //       } else {
// // //         // Store previous location and update with new one
// // //         _previousLocation = _locationController.currentLocation;
// // //         _updateUserLocationOnMap(_locationController.currentLocation!);

// // //         // Calculate bearing if we have a previous location
// // //         if (_previousLocation != null) {
// // //           _userBearing = _calculateBearing(
// // //             _previousLocation!.latitude,
// // //             _previousLocation!.longitude,
// // //             _locationController.currentLocation!.latitude,
// // //             _locationController.currentLocation!.longitude,
// // //           );
// // //         }
// // //       }
// // //     }
// // //   }

// // //   void _onNavigationControllerChanged() async {
// // //     if (!_layersInitialized) {
// // //       await _initializeMapLayers();
// // //       // Return and let the next listener update handle displaying the route
// // //       return;
// // //     }

// // //     if (_navigationController.isNavigating) {
// // //       print(
// // //         'Navigation state changed - isNavigating: ${_navigationController.isNavigating}',
// // //       );

// // //       // Add a slight delay to ensure all data is ready
// // //       await Future.delayed(const Duration(milliseconds: 300));

// // //       if (_navigationController.currentRoute != null) {
// // //         print(
// // //           'Updating route - points: ${_navigationController.currentRoute!.geometry.length}',
// // //         );
// // //         _updateRouteOnMap(_navigationController.currentRoute!);
// // //       } else {
// // //         print('Navigation active but route is null!');
// // //       }

// // //       if (_navigationController.destination != null) {
// // //         print(
// // //           'Updating destination - ${_navigationController.destination!.placeName}',
// // //         );
// // //         _updateDestinationOnMap(
// // //           _navigationController.destination!.latitude,
// // //           _navigationController.destination!.longitude,
// // //           _navigationController.destination!.placeName,
// // //         );
// // //       }
// // //     } else {
// // //       _clearRouteFromMap();
// // //     }
// // //   }

// // //   void _updateUserLocationOnMap(LocationModel location) async {
// // //     try {
// // //       if (!_layersInitialized || _mapboxMap == null) return;

// // //       final Map<String, dynamic> featureCollection = {
// // //         'type': 'FeatureCollection',
// // //         'features': [
// // //           {
// // //             'type': 'Feature',
// // //             'geometry': {
// // //               'type': 'Point',
// // //               'coordinates': [location.longitude, location.latitude],
// // //             },
// // //             'properties': {},
// // //           },
// // //         ],
// // //       };

// // //       final String geoJsonString = jsonEncode(featureCollection);

// // //       // Get the source asynchronously
// // //       final sourceObj = await _mapboxMap!.style.getSource(
// // //         _userLocationSourceId,
// // //       );

// // //       if (sourceObj != null) {
// // //         // Cast after unwrapping the Future
// // //         final source = sourceObj as GeoJsonSource;
// // //         source.updateGeoJSON(geoJsonString);
// // //       } else {
// // //         print('User location source not found - reinitializing layers');
// // //         _layersInitialized = false;
// // //         await _initializeMapLayers();

// // //         // Try updating the user location again after reinitializing
// // //         final newSourceObj = await _mapboxMap!.style.getSource(
// // //           _userLocationSourceId,
// // //         );
// // //         if (newSourceObj != null) {
// // //           final source = newSourceObj as GeoJsonSource;
// // //           source.updateGeoJSON(geoJsonString);
// // //         }
// // //       }

// // //       // Update direction arrow
// // //       _updateDirectionArrow(location);

// // //       // Move camera if in following mode
// // //       if (_isFollowingUser) {
// // //         _goToCurrentLocationWithBearing();
// // //       }
// // //     } catch (e) {
// // //       print('Error updating user location on map: $e');
// // //     }
// // //   }

// // //   void _updateDirectionArrow(LocationModel location) async {
// // //     if (!_layersInitialized || _mapboxMap == null || !_arrowAdded) return;

// // //     try {
// // //       // In a real app, get the bearing from the compass sensor or calculate from locations
// // //       // For demo purposes, we'll use the calculated bearing or simulate movement
// // //       if (_previousLocation == null) {
// // //         // If no previous location, just use the current bearing or simulate
// // //         _userBearing = (_userBearing + 2) % 360;
// // //       }

// // //       // Update the direction arrow
// // //       final Map<String, dynamic> arrowFeatureCollection = {
// // //         'type': 'FeatureCollection',
// // //         'features': [
// // //           {
// // //             'type': 'Feature',
// // //             'geometry': {
// // //               'type': 'Point',
// // //               'coordinates': [location.longitude, location.latitude],
// // //             },
// // //             'properties': {
// // //               'bearing': _userBearing, // Arrow direction
// // //             },
// // //           },
// // //         ],
// // //       };

// // //       final String arrowGeoJsonString = jsonEncode(arrowFeatureCollection);

// // //       final arrowSourceObj = await _mapboxMap!.style.getSource(
// // //         _directionArrowSourceId,
// // //       );
// // //       if (arrowSourceObj != null) {
// // //         final arrowSource = arrowSourceObj as GeoJsonSource;
// // //         arrowSource.updateGeoJSON(arrowGeoJsonString);
// // //       }
// // //     } catch (e) {
// // //       print('Error updating direction arrow: $e');
// // //     }
// // //   }

// // //   void _updateDestinationOnMap(
// // //     double latitude,
// // //     double longitude,
// // //     String name,
// // //   ) async {
// // //     try {
// // //       if (!_layersInitialized || _mapboxMap == null) return;

// // //       print('Updating destination: $latitude, $longitude, $name');

// // //       final Map<String, dynamic> featureCollection = {
// // //         'type': 'FeatureCollection',
// // //         'features': [
// // //           {
// // //             'type': 'Feature',
// // //             'geometry': {
// // //               'type': 'Point',
// // //               'coordinates': [longitude, latitude],
// // //             },
// // //             'properties': {'name': name},
// // //           },
// // //         ],
// // //       };

// // //       final String geoJsonString = jsonEncode(featureCollection);

// // //       // Get the source asynchronously
// // //       final sourceObj = await _mapboxMap!.style.getSource(_destinationSourceId);

// // //       if (sourceObj != null) {
// // //         // Cast after unwrapping the Future
// // //         final source = sourceObj as GeoJsonSource;
// // //         source.updateGeoJSON(geoJsonString);
// // //       } else {
// // //         print('Destination source not found - reinitializing layers');
// // //         _layersInitialized = false;
// // //         await _initializeMapLayers();

// // //         // Try updating the destination again after reinitializing
// // //         final newSourceObj = await _mapboxMap!.style.getSource(
// // //           _destinationSourceId,
// // //         );
// // //         if (newSourceObj != null) {
// // //           final source = newSourceObj as GeoJsonSource;
// // //           source.updateGeoJSON(geoJsonString);
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print('Error updating destination on map: $e');
// // //     }
// // //   }

// // //   void _updateRouteOnMap(RouteModel route) async {
// // //     try {
// // //       if (!_layersInitialized || _mapboxMap == null) return;

// // //       print('Updating route - points count: ${route.geometry.length}');

// // //       if (route.geometry.isEmpty) {
// // //         print('Warning: Route is empty!');
// // //         return;
// // //       }

// // //       final Map<String, dynamic> featureCollection = {
// // //         'type': 'FeatureCollection',
// // //         'features': [
// // //           {
// // //             'type': 'Feature',
// // //             'geometry': {'type': 'LineString', 'coordinates': route.geometry},
// // //             'properties': {},
// // //           },
// // //         ],
// // //       };

// // //       final String geoJsonString = jsonEncode(featureCollection);

// // //       // Get the source asynchronously
// // //       final sourceObj = await _mapboxMap!.style.getSource(_routeSourceId);

// // //       if (sourceObj != null) {
// // //         // Cast after unwrapping the Future
// // //         final source = sourceObj as GeoJsonSource;
// // //         source.updateGeoJSON(geoJsonString);
// // //         _fitRouteInView(route.geometry);
// // //       } else {
// // //         print('Route source not found - reinitializing layers');
// // //         _layersInitialized = false;
// // //         await _initializeMapLayers();

// // //         // Try updating the route again after reinitializing
// // //         final newSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
// // //         if (newSourceObj != null) {
// // //           final source = newSourceObj as GeoJsonSource;
// // //           source.updateGeoJSON(geoJsonString);
// // //           _fitRouteInView(route.geometry);
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print('Error updating route on map: $e');
// // //     }
// // //   }

// // //   void _fitRouteInView(List<List<double>> coordinates) {
// // //     if (coordinates.isEmpty || _mapboxMap == null) return;

// // //     try {
// // //       double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

// // //       for (final point in coordinates) {
// // //         if (point.length < 2) continue;
// // //         final lng = point[0];
// // //         final lat = point[1];
// // //         minLat = minLat > lat ? lat : minLat;
// // //         maxLat = maxLat < lat ? lat : maxLat;
// // //         minLng = minLng > lng ? lng : minLng;
// // //         maxLng = maxLng < lng ? lng : maxLng;
// // //       }

// // //       // Add padding to the bounding box
// // //       final latDelta = (maxLat - minLat) * 0.2;
// // //       final lngDelta = (maxLng - minLng) * 0.2;

// // //       final southwest = Point(
// // //         coordinates: Position(minLng - lngDelta, minLat - latDelta),
// // //       );
// // //       final northeast = Point(
// // //         coordinates: Position(maxLng + lngDelta, maxLat + latDelta),
// // //       );

// // //       if (!_isValidCoordinate(southwest.coordinates) ||
// // //           !_isValidCoordinate(northeast.coordinates)) {
// // //         print('Invalid coordinates for fitting map');
// // //         return;
// // //       }

// // //       final bounds = CoordinateBounds(
// // //         southwest: southwest,
// // //         northeast: northeast,
// // //         infiniteBounds: false,
// // //       );

// // //       _mapboxMap!
// // //           .cameraForCoordinateBounds(
// // //             bounds,
// // //             MbxEdgeInsets(top: 100, left: 50, bottom: 150, right: 50),
// // //             null,
// // //             null,
// // //             null,
// // //             null,
// // //           )
// // //           .then((camera) {
// // //             _mapboxMap!.flyTo(camera, MapAnimationOptions(duration: 1000));
// // //           });

// // //       print('Map zoom adjusted for route');
// // //     } catch (e) {
// // //       print('Error adjusting map zoom: $e');
// // //     }
// // //   }

// // //   bool _isValidCoordinate(Position position) {
// // //     return position.lat >= -90 &&
// // //         position.lat <= 90 &&
// // //         position.lng >= -180 &&
// // //         position.lng <= 180;
// // //   }

// // //   void _clearRouteFromMap() async {
// // //     try {
// // //       if (!_layersInitialized || _mapboxMap == null) return;

// // //       print('Clearing route from map');

// // //       // Get sources asynchronously
// // //       final routeSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
// // //       if (routeSourceObj != null) {
// // //         final routeSource = routeSourceObj as GeoJsonSource;
// // //         routeSource.updateGeoJSON(_createEmptyLineFeatureCollection());
// // //       }

// // //       final destinationSourceObj = await _mapboxMap!.style.getSource(
// // //         _destinationSourceId,
// // //       );
// // //       if (destinationSourceObj != null) {
// // //         final destinationSource = destinationSourceObj as GeoJsonSource;
// // //         destinationSource.updateGeoJSON(_createEmptyPointFeatureCollection());
// // //       }

// // //       print('Route cleared from map');
// // //     } catch (e) {
// // //       print('Error clearing route from map: $e');
// // //     }
// // //   }

// // //   void _goToCurrentLocation() {
// // //     if (_locationController.currentLocation != null && _mapboxMap != null) {
// // //       _mapboxMap!.flyTo(
// // //         CameraOptions(
// // //           center: Point(
// // //             coordinates: Position(
// // //               _locationController.currentLocation!.longitude,
// // //               _locationController.currentLocation!.latitude,
// // //             ),
// // //           ),
// // //           zoom: 15.0,
// // //           bearing: 0,
// // //           pitch: 0,
// // //         ),
// // //         MapAnimationOptions(duration: 1000),
// // //       );
// // //       print('Moved to current location');
// // //     } else {
// // //       _locationController.updateCurrentLocation();
// // //       print('Attempting to update current location');
// // //     }
// // //   }

// // //   // Toggle between follow mode and normal mode
// // //   void _toggleFollowMode() {
// // //     setState(() {
// // //       _isFollowingUser = !_isFollowingUser;
// // //       if (_isFollowingUser) {
// // //         _goToCurrentLocationWithBearing();
// // //       }
// // //     });
// // //   }

// // //   // Move to current location with camera bearing aligned to user direction
// // //   void _goToCurrentLocationWithBearing() {
// // //     if (_locationController.currentLocation != null && _mapboxMap != null) {
// // //       _mapboxMap!.flyTo(
// // //         CameraOptions(
// // //           center: Point(
// // //             coordinates: Position(
// // //               _locationController.currentLocation!.longitude,
// // //               _locationController.currentLocation!.latitude,
// // //             ),
// // //           ),
// // //           zoom: 18.0, // More zoom for close-up view
// // //           bearing: _userBearing, // Rotate camera to match user direction
// // //           pitch: 60.0, // Tilt camera for 3D-like view
// // //         ),
// // //         MapAnimationOptions(duration: 1000),
// // //       );
// // //       print('Moved to current location with bearing: $_userBearing');
// // //     } else {
// // //       _locationController.updateCurrentLocation();
// // //       print('Attempting to update current location for bearing view');
// // //     }
// // //   }

// // //   // Calculate bearing between two points
// // //   // Calculate bearing between two points
// // //   double _calculateBearing(
// // //     double startLat,
// // //     double startLng,
// // //     double endLat,
// // //     double endLng,
// // //   ) {
// // //     double latitude1 = startLat * (pi / 180.0);
// // //     double longitude1 = startLng * (pi / 180.0);
// // //     double latitude2 = endLat * (pi / 180.0);
// // //     double longitude2 = endLng * (pi / 180.0);

// // //     double y = sin(longitude2 - longitude1) * cos(latitude2);
// // //     double x =
// // //         cos(latitude1) * sin(latitude2) -
// // //         sin(latitude1) * cos(latitude2) * cos(longitude2 - longitude1);

// // //     double bearing = atan2(y, x);
// // //     bearing = bearing * (180.0 / pi);
// // //     bearing = (bearing + 360) % 360;

// // //     return bearing;
// // //   }

// // //   void _updateMapStyle() {
// // //     if (_mapboxMap == null) return;

// // //     String mapStyle =
// // //         _storageController.isDarkMode
// // //             ? AppConstants.nightMapStyle
// // //             : AppConstants.dayMapStyle;

// // //     _mapboxMap!.style.setStyleURI(mapStyle);
// // //     _layersInitialized = false;
// // //     customLocationAdded = false;
// // //     _arrowAdded = false;
// // //     print('Map style updated: $mapStyle');
// // //   }

// // //   String _createEmptyPointFeatureCollection() {
// // //     return '{"type":"FeatureCollection","features":[]}';
// // //   }

// // //   String _createEmptyLineFeatureCollection() {
// // //     return '{"type":"FeatureCollection","features":[]}';
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _cameraUpdateTimer?.cancel(); // Clean up the timer
// // //     _locationController.removeListener(_onLocationControllerChanged);
// // //     _navigationController.removeListener(_onNavigationControllerChanged);
// // //     super.dispose();
// // //   }
// // // }
// // // ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print
// // import 'dart:convert';
// // import 'dart:async';
// // import 'dart:math';
// // import 'dart:typed_data';
// // import 'package:flutter/material.dart';
// // import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// // import 'package:provider/provider.dart';
// // import '../../config/app_constants.dart';
// // import '../../controllers/location_controller.dart';
// // import '../../controllers/navigation_controller.dart';
// // import '../../controllers/storage_controller.dart';
// // import '../../models/location_model.dart';
// // import '../../models/place_model.dart';
// // import '../../models/route_model.dart';

// // class CustomMap extends StatefulWidget {
// //   final Function(PlaceModel)? onPlaceSelected;
// //   final bool followUserLocation;

// //   const CustomMap({
// //     super.key,
// //     this.onPlaceSelected,
// //     this.followUserLocation = false,
// //   });

// //   @override
// //   State<CustomMap> createState() => _CustomMapState();
// // }

// // class _CustomMapState extends State<CustomMap> {
// //   MapboxMap? _mapboxMap;
// //   late LocationController _locationController;
// //   late NavigationController _navigationController;
// //   late StorageController _storageController;
// //   bool _layersInitialized = false;
// //   Timer? _cameraUpdateTimer;
// //   bool isFirstLoad = true;

// //   // Añadir variable para controlar el comportamiento de la cámara
// //   bool _userHasMovedCamera =
// //       false; // Flag para detectar si el usuario ha movido la cámara manualmente
// //   Timer?
// //   _resetUserMovedCameraTimer; // Timer para resetear el flag después de cierto tiempo

// //   // Direction arrow and camera control variables
// //   final String _directionArrowSourceId = 'direction-arrow-source';
// //   final String _directionArrowLayerId = 'direction-arrow-layer';
// //   double _userBearing = 0; // Current user direction
// //   bool _isFollowingUser = false; // Is camera following user?
// //   bool _arrowAdded = false; // Has the arrow layer been added?
// //   LocationModel?
// //   _previousLocation; // Store previous location to calculate bearing

// //   // Map layer identifiers
// //   final String _routeLayerId = 'route-layer';
// //   final String _routeSourceId = 'route-source';
// //   final String _userLocationSourceId = 'user-location-source';
// //   final String _userLocationLayerId = 'user-location-layer';
// //   final String _destinationSourceId = 'destination-source';
// //   final String _destinationLayerId = 'destination-layer';
// //   final String _destinationCircleLayerId = 'destination-circle-layer';
// //   final String customLocationSourceId = 'custom-location-source';
// //   final String customLocationLayerId = 'custom-location-layer';
// //   bool customLocationAdded = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //   }

// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     _locationController = Provider.of<LocationController>(context);
// //     _navigationController = Provider.of<NavigationController>(context);
// //     _storageController = Provider.of<StorageController>(context);

// //     // Add listeners to ensure we catch all state changes
// //     _locationController.addListener(_onLocationControllerChanged);
// //     _navigationController.addListener(_onNavigationControllerChanged);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     String mapStyle =
// //         _storageController.isDarkMode
// //             ? AppConstants.nightMapStyle
// //             : AppConstants.outdoorsStyle;

// //     return Stack(
// //       children: [
// //         MapWidget(
// //           styleUri: mapStyle,
// //           onMapCreated: _onMapCreated,
// //           cameraOptions: CameraOptions(
// //             center: Point(
// //               coordinates: Position(
// //                 AppConstants.defaultLongitude,
// //                 AppConstants.defaultLatitude,
// //               ),
// //             ),
// //             zoom: AppConstants.defaultZoom,
// //           ),
// //           onStyleLoadedListener: _onStyleLoaded,
// //           onTapListener: _onMapTap,
// //           // Usando el listener de cambio de cámara disponible
// //           onCameraChangeListener: _onCameraChanged,
// //           // Usando el listener de mapa inactivo (idle) disponible
// //           onMapIdleListener: _onMapIdle,
// //         ),
// //         // Current location button
// //         Positioned(
// //           bottom: 110,
// //           right: 16,
// //           child: FloatingActionButton(
// //             heroTag: 'btn_current_location',
// //             mini: true,
// //             backgroundColor: Theme.of(context).colorScheme.surface,
// //             onPressed: _goToCurrentLocation,
// //             child: Icon(
// //               Icons.my_location,
// //               color: Theme.of(context).colorScheme.primary,
// //             ),
// //           ),
// //         ),
// //         // Toggle map style button
// //         Positioned(
// //           bottom: 160,
// //           right: 16,
// //           child: FloatingActionButton(
// //             heroTag: 'btn_toggle_map_mode',
// //             mini: true,
// //             backgroundColor: Theme.of(context).colorScheme.surface,
// //             onPressed: () {
// //               _storageController.toggleThemeMode();
// //               _updateMapStyle();
// //             },
// //             child: Icon(
// //               _storageController.isDarkMode
// //                   ? Icons.wb_sunny
// //                   : Icons.nightlight_round,
// //               color: Theme.of(context).colorScheme.primary,
// //             ),
// //           ),
// //         ),
// //         // Toggle follow mode button
// //         Positioned(
// //           bottom: 210,
// //           right: 16,
// //           child: FloatingActionButton(
// //             heroTag: 'btn_toggle_follow_mode',
// //             mini: true,
// //             backgroundColor: Theme.of(context).colorScheme.surface,
// //             onPressed: _toggleFollowMode,
// //             child: Icon(
// //               _isFollowingUser ? Icons.navigation : Icons.explore,
// //               color:
// //                   _isFollowingUser
// //                       ? Theme.of(context).colorScheme.primary
// //                       : Theme.of(context).colorScheme.onSurface,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // Adaptando para usar los eventos disponibles en la API
// //   void _onCameraChanged(CameraChangedEventData eventData) {
// //     // Asumimos que un cambio de cámara podría ser iniciado por el usuario
// //     // Si no estamos en modo seguimiento, consideramos que el usuario está moviendo la cámara
// //     if (!_isFollowingUser) {
// //       setState(() {
// //         _userHasMovedCamera = true;
// //       });

// //       // Cancelamos el timer de reset si existe
// //       _resetUserMovedCameraTimer?.cancel();
// //     }
// //   }

// //   void _onMapIdle(MapIdleEventData eventData) {
// //     // Cuando el mapa está inactivo (la cámara deja de moverse),
// //     // configuramos un timer para resetear el flag después de cierto tiempo
// //     if (_userHasMovedCamera) {
// //       _resetUserMovedCameraTimer?.cancel();
// //       _resetUserMovedCameraTimer = Timer(const Duration(seconds: 30), () {
// //         setState(() {
// //           _userHasMovedCamera = false;
// //         });
// //       });
// //     }
// //   }

// //   void _onMapTap(MapContentGestureContext context) async {
// //     if (_mapboxMap == null) return;

// //     // Cuando el usuario toca el mapa, actualizamos el flag
// //     setState(() {
// //       _userHasMovedCamera = true;
// //     });

// //     try {
// //       // Convert screen coordinates to geographic coordinates
// //       Point point = await _mapboxMap!.coordinateForPixel(
// //         context.point as ScreenCoordinate,
// //       );
// //       Position position = point.coordinates;
// //       double latitude = position.lat.toDouble();
// //       double longitude = position.lng.toDouble();

// //       // Create a PlaceModel for the tapped location
// //       PlaceModel selectedPlace = PlaceModel(
// //         address: 'الموقع المحدد',
// //         id: 'selected',
// //         placeName: 'الوجهة المحددة',
// //         latitude: latitude,
// //         longitude: longitude,
// //       );

// //       // Start navigation to the selected destination
// //       if (_locationController.currentLocation != null) {
// //         _navigationController.startNavigation(
// //           selectedPlace,
// //           _locationController.currentLocation!,
// //         );

// //         print('Destination set at: $latitude, $longitude');
// //         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
// //           const SnackBar(content: Text('تم تحديد الوجهة. جارِ حساب المسار...')),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
// //           const SnackBar(content: Text('لم يتم تحديد موقعك الحالي بعد')),
// //         );
// //       }
// //     } catch (e) {
// //       print('Error setting destination: $e');
// //       ScaffoldMessenger.of(
// //         context as BuildContext,
// //       ).showSnackBar(SnackBar(content: Text('خطأ في تحديد الوجهة: $e')));
// //     }
// //   }

// //   void _onMapCreated(MapboxMap mapboxMap) {
// //     _mapboxMap = mapboxMap;
// //     print('Map created');

// //     // Enable location tracking
// //     _mapboxMap!.location.updateSettings(
// //       LocationComponentSettings(
// //         enabled: true,
// //         pulsingEnabled: true,
// //         showAccuracyRing: true,
// //       ),
// //     );

// //     // Start periodic camera updates if followUserLocation is true
// //     if (widget.followUserLocation) {
// //       _cameraUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
// //         if (_mapboxMap != null && widget.followUserLocation) {
// //           _goToCurrentLocation();
// //         }
// //       });
// //     }
// //   }

// //   void _onStyleLoaded(styleLoadedEventData) async {
// //     print('Map style loaded');

// //     // Make sure we initialize layers when style is loaded
// //     await Future.delayed(const Duration(milliseconds: 500));

// //     await _initializeMapLayers();
// //     _goToCurrentLocation();

// //     // Check if there's an active navigation and update the map accordingly
// //     if (_navigationController.isNavigating) {
// //       await Future.delayed(const Duration(milliseconds: 200));

// //       if (_navigationController.destination != null) {
// //         _updateDestinationOnMap(
// //           _navigationController.destination!.latitude,
// //           _navigationController.destination!.longitude,
// //           _navigationController.destination!.placeName,
// //         );
// //       }

// //       if (_navigationController.currentRoute != null) {
// //         _updateRouteOnMap(_navigationController.currentRoute!);
// //       }
// //     }
// //   }

// //   Future<void> _initializeMapLayers() async {
// //     if (_layersInitialized || _mapboxMap == null) return;

// //     try {
// //       print('Initializing map layers...');

// //       // Add user location source and layers
// //       await _mapboxMap!.style.addSource(
// //         GeoJsonSource(
// //           id: _userLocationSourceId,
// //           data: '{"type":"FeatureCollection","features":[]}',
// //         ),
// //       );

// //       await _mapboxMap!.style.addLayer(
// //         CircleLayer(
// //           id: "${_userLocationLayerId}_outer",
// //           sourceId: _userLocationSourceId,
// //           circleRadius: 18.0,
// //           circleColor: 0x554882C4,
// //           circleStrokeWidth: 2.0,
// //           circleStrokeColor: 0xFF4882C4,
// //         ),
// //       );

// //       await _mapboxMap!.style.addLayer(
// //         CircleLayer(
// //           id: _userLocationLayerId,
// //           sourceId: _userLocationSourceId,
// //           circleRadius: 10.0,
// //           circleColor: 0xFF4882C4,
// //           circleStrokeWidth: 3.0,
// //           circleStrokeColor: 0xFFFFFFFF,
// //         ),
// //       );

// //       // Add destination source and layers
// //       await _mapboxMap!.style.addSource(
// //         GeoJsonSource(
// //           id: _destinationSourceId,
// //           data: '{"type":"FeatureCollection","features":[]}',
// //         ),
// //       );

// //       await _mapboxMap!.style.addLayer(
// //         CircleLayer(
// //           id: _destinationCircleLayerId,
// //           sourceId: _destinationSourceId,
// //           circleRadius: 12.0,
// //           circleColor: 0xFFE53935,
// //           circleStrokeWidth: 3.0,
// //           circleStrokeColor: 0xFFFFFFFF,
// //         ),
// //       );

// //       await _mapboxMap!.style.addLayer(
// //         SymbolLayer(
// //           id: _destinationLayerId,
// //           sourceId: _destinationSourceId,
// //           textField: "{name}",
// //           textSize: 14.0,
// //           textOffset: [0, 2.0],
// //           textAnchor: TextAnchor.TOP,
// //           textColor: 0xFF000000,
// //           textHaloWidth: 1.5,
// //           textHaloColor: 0xFFFFFFFF,
// //         ),
// //       );

// //       // Add route source and layer
// //       await _mapboxMap!.style.addSource(
// //         GeoJsonSource(
// //           id: _routeSourceId,
// //           data: '{"type":"FeatureCollection","features":[]}',
// //         ),
// //       );

// //       await _mapboxMap!.style.addLayer(
// //         LineLayer(
// //           id: _routeLayerId,
// //           sourceId: _routeSourceId,
// //           lineColor: int.parse(
// //             '0xFF${AppConstants.routeLineColor.substring(1)}',
// //           ),
// //           lineWidth: AppConstants.routeLineWidth,
// //           lineCap: LineCap.ROUND,
// //           lineJoin: LineJoin.ROUND,
// //         ),
// //       );

// //       // Add direction arrow source and layer
// //       await _mapboxMap!.style.addSource(
// //         GeoJsonSource(
// //           id: _directionArrowSourceId,
// //           data: '{"type":"FeatureCollection","features":[]}',
// //         ),
// //       );

// //       await _mapboxMap!.style.addLayer(
// //         SymbolLayer(
// //           id: _directionArrowLayerId,
// //           sourceId: _directionArrowSourceId,
// //           iconImage: "arrow", // Name of the arrow image we'll add
// //           iconSize: 1.5,
// //           iconAllowOverlap: true,
// //           iconIgnorePlacement: true,
// //           iconRotate:
// //               _userBearing, // Rotate arrow based on the calculated bearing
// //         ),
// //       );

// //       // Add arrow image to the map
// //       await _addArrowImageToMap();

// //       _layersInitialized = true;
// //       _arrowAdded = true;
// //       print('Map layers initialized successfully');

// //       // Update map with current data
// //       if (_locationController.currentLocation != null) {
// //         _updateUserLocationOnMap(_locationController.currentLocation!);
// //       }

// //       if (_navigationController.isNavigating) {
// //         if (_navigationController.destination != null) {
// //           _updateDestinationOnMap(
// //             _navigationController.destination!.latitude,
// //             _navigationController.destination!.longitude,
// //             _navigationController.destination!.placeName,
// //           );
// //         }
// //         if (_navigationController.currentRoute != null) {
// //           _updateRouteOnMap(_navigationController.currentRoute!);
// //         }
// //       }
// //     } catch (e) {
// //       print('Error initializing map layers: $e');
// //     }
// //   }

// //   // Add arrow image to the map
// //   Future<void> _addArrowImageToMap() async {
// //     try {
// //       // Create arrow image programmatically
// //       final int size = 64;
// //       final Uint8List data = Uint8List(size * size * 4);

// //       // Fill the image data with our arrow
// //       for (int y = 0; y < size; y++) {
// //         for (int x = 0; x < size; x++) {
// //           // Calculate distance from center
// //           double centerX = size / 2;
// //           double centerY = size / 2;
// //           double dx = x - centerX;
// //           double dy = y - centerY;

// //           // Define arrow shape
// //           bool isArrow = false;
// //           bool isArrowBorder = false;

// //           // Arrow body
// //           if (dx.abs() < 8 && dy > 0 && dy < 24) {
// //             isArrow = true;
// //           }

// //           // Arrow head
// //           if (dy < 0 && dy > -16 && dx.abs() < -dy) {
// //             isArrow = true;
// //           }

// //           // Arrow border
// //           if (dx.abs() < 10 && dy > -2 && dy < 26 && !isArrow) {
// //             isArrowBorder = true;
// //           }

// //           if (dy < 2 && dy > -18 && dx.abs() < (-dy + 2) && !isArrow) {
// //             isArrowBorder = true;
// //           }

// //           int pixelIndex = (y * size + x) * 4;
// //           if (isArrow) {
// //             // Blue fill for the arrow
// //             data[pixelIndex] = 72; // R
// //             data[pixelIndex + 1] = 130; // G
// //             data[pixelIndex + 2] = 196; // B
// //             data[pixelIndex + 3] = 255; // A
// //           } else if (isArrowBorder) {
// //             // White border for the arrow
// //             data[pixelIndex] = 255; // R
// //             data[pixelIndex + 1] = 255; // G
// //             data[pixelIndex + 2] = 255; // B
// //             data[pixelIndex + 3] = 255; // A
// //           } else {
// //             // Transparent
// //             data[pixelIndex + 3] = 0; // A
// //           }
// //         }
// //       }

// //       // Create MbxImage from the Uint8List
// //       final MbxImage arrowImage = MbxImage(
// //         width: size,
// //         height: size,
// //         data: data,
// //       );

// //       // Add the image to the map style
// //       await _mapboxMap!.style.addStyleImage(
// //         "arrow", // imageId
// //         1.0, // scale
// //         arrowImage, // image
// //         false, // sdf
// //         [], // stretchX
// //         [], // stretchY
// //         null, // content
// //       );

// //       print('Arrow image added to map successfully');
// //     } catch (e) {
// //       print('Error adding arrow image to map: $e');
// //     }
// //   }

// //   void _onLocationControllerChanged() {
// //     if (_locationController.currentLocation != null) {
// //       if (!_layersInitialized) {
// //         _initializeMapLayers();
// //       } else {
// //         // Store previous location and update with new one
// //         _previousLocation = _locationController.currentLocation;
// //         _updateUserLocationOnMap(_locationController.currentLocation!);

// //         // Calculate bearing if we have a previous location
// //         if (_previousLocation != null) {
// //           _userBearing = _calculateBearing(
// //             _previousLocation!.latitude,
// //             _previousLocation!.longitude,
// //             _locationController.currentLocation!.latitude,
// //             _locationController.currentLocation!.longitude,
// //           );
// //         }
// //       }
// //     }
// //   }

// //   void _onNavigationControllerChanged() async {
// //     if (!_layersInitialized) {
// //       await _initializeMapLayers();
// //       // Return and let the next listener update handle displaying the route
// //       return;
// //     }

// //     if (_navigationController.isNavigating) {
// //       print(
// //         'Navigation state changed - isNavigating: ${_navigationController.isNavigating}',
// //       );

// //       // Add a slight delay to ensure all data is ready
// //       await Future.delayed(const Duration(milliseconds: 300));

// //       if (_navigationController.currentRoute != null) {
// //         print(
// //           'Updating route - points: ${_navigationController.currentRoute!.geometry.length}',
// //         );
// //         // Cuando comienza la navegación, resetear el flag de movimiento manual
// //         // para permitir el ajuste automático inicial de la cámara
// //         if (isFirstLoad) {
// //           _userHasMovedCamera = false;
// //         }
// //         _updateRouteOnMap(_navigationController.currentRoute!);
// //       } else {
// //         print('Navigation active but route is null!');
// //       }

// //       if (_navigationController.destination != null) {
// //         print(
// //           'Updating destination - ${_navigationController.destination!.placeName}',
// //         );
// //         _updateDestinationOnMap(
// //           _navigationController.destination!.latitude,
// //           _navigationController.destination!.longitude,
// //           _navigationController.destination!.placeName,
// //         );
// //       }
// //     } else {
// //       _clearRouteFromMap();
// //     }
// //   }

// //   void _updateUserLocationOnMap(LocationModel location) async {
// //     try {
// //       if (!_layersInitialized || _mapboxMap == null) return;

// //       final Map<String, dynamic> featureCollection = {
// //         'type': 'FeatureCollection',
// //         'features': [
// //           {
// //             'type': 'Feature',
// //             'geometry': {
// //               'type': 'Point',
// //               'coordinates': [location.longitude, location.latitude],
// //             },
// //             'properties': {},
// //           },
// //         ],
// //       };

// //       final String geoJsonString = jsonEncode(featureCollection);

// //       // Get the source asynchronously
// //       final sourceObj = await _mapboxMap!.style.getSource(
// //         _userLocationSourceId,
// //       );

// //       if (sourceObj != null) {
// //         // Cast after unwrapping the Future
// //         final source = sourceObj as GeoJsonSource;
// //         source.updateGeoJSON(geoJsonString);
// //       } else {
// //         print('User location source not found - reinitializing layers');
// //         _layersInitialized = false;
// //         await _initializeMapLayers();

// //         // Try updating the user location again after reinitializing
// //         final newSourceObj = await _mapboxMap!.style.getSource(
// //           _userLocationSourceId,
// //         );
// //         if (newSourceObj != null) {
// //           final source = newSourceObj as GeoJsonSource;
// //           source.updateGeoJSON(geoJsonString);
// //         }
// //       }

// //       // Update direction arrow
// //       _updateDirectionArrow(location);

// //       // Move camera if in following mode
// //       if (_isFollowingUser) {
// //         _goToCurrentLocationWithBearing();
// //       }
// //     } catch (e) {
// //       print('Error updating user location on map: $e');
// //     }
// //   }

// //   void _updateDirectionArrow(LocationModel location) async {
// //     if (!_layersInitialized || _mapboxMap == null || !_arrowAdded) return;

// //     try {
// //       // In a real app, get the bearing from the compass sensor or calculate from locations
// //       // For demo purposes, we'll use the calculated bearing or simulate movement
// //       if (_previousLocation == null) {
// //         // If no previous location, just use the current bearing or simulate
// //         _userBearing = (_userBearing + 2) % 360;
// //       }

// //       // Update the direction arrow
// //       final Map<String, dynamic> arrowFeatureCollection = {
// //         'type': 'FeatureCollection',
// //         'features': [
// //           {
// //             'type': 'Feature',
// //             'geometry': {
// //               'type': 'Point',
// //               'coordinates': [location.longitude, location.latitude],
// //             },
// //             'properties': {
// //               'bearing': _userBearing, // Arrow direction
// //             },
// //           },
// //         ],
// //       };

// //       final String arrowGeoJsonString = jsonEncode(arrowFeatureCollection);

// //       final arrowSourceObj = await _mapboxMap!.style.getSource(
// //         _directionArrowSourceId,
// //       );
// //       if (arrowSourceObj != null) {
// //         final arrowSource = arrowSourceObj as GeoJsonSource;
// //         arrowSource.updateGeoJSON(arrowGeoJsonString);
// //       }
// //     } catch (e) {
// //       print('Error updating direction arrow: $e');
// //     }
// //   }

// //   void _updateDestinationOnMap(
// //     double latitude,
// //     double longitude,
// //     String name,
// //   ) async {
// //     try {
// //       if (!_layersInitialized || _mapboxMap == null) return;

// //       print('Updating destination: $latitude, $longitude, $name');

// //       final Map<String, dynamic> featureCollection = {
// //         'type': 'FeatureCollection',
// //         'features': [
// //           {
// //             'type': 'Feature',
// //             'geometry': {
// //               'type': 'Point',
// //               'coordinates': [longitude, latitude],
// //             },
// //             'properties': {'name': name},
// //           },
// //         ],
// //       };

// //       final String geoJsonString = jsonEncode(featureCollection);

// //       // Get the source asynchronously
// //       final sourceObj = await _mapboxMap!.style.getSource(_destinationSourceId);

// //       if (sourceObj != null) {
// //         // Cast after unwrapping the Future
// //         final source = sourceObj as GeoJsonSource;
// //         source.updateGeoJSON(geoJsonString);
// //       } else {
// //         print('Destination source not found - reinitializing layers');
// //         _layersInitialized = false;
// //         await _initializeMapLayers();

// //         // Try updating the destination again after reinitializing
// //         final newSourceObj = await _mapboxMap!.style.getSource(
// //           _destinationSourceId,
// //         );
// //         if (newSourceObj != null) {
// //           final source = newSourceObj as GeoJsonSource;
// //           source.updateGeoJSON(geoJsonString);
// //         }
// //       }
// //     } catch (e) {
// //       print('Error updating destination on map: $e');
// //     }
// //   }

// //   void _updateRouteOnMap(RouteModel route) async {
// //     try {
// //       if (!_layersInitialized || _mapboxMap == null) return;

// //       print('Updating route - points count: ${route.geometry.length}');

// //       if (route.geometry.isEmpty) {
// //         print('Warning: Route is empty!');
// //         return;
// //       }

// //       final Map<String, dynamic> featureCollection = {
// //         'type': 'FeatureCollection',
// //         'features': [
// //           {
// //             'type': 'Feature',
// //             'geometry': {'type': 'LineString', 'coordinates': route.geometry},
// //             'properties': {},
// //           },
// //         ],
// //       };

// //       final String geoJsonString = jsonEncode(featureCollection);

// //       // Get the source asynchronously
// //       final sourceObj = await _mapboxMap!.style.getSource(_routeSourceId);

// //       if (sourceObj != null) {
// //         // Cast after unwrapping the Future
// //         final source = sourceObj as GeoJsonSource;
// //         source.updateGeoJSON(geoJsonString);

// //         // Solo ajustamos la vista si es la primera carga de la ruta
// //         // o si el usuario no ha movido la cámara manualmente y no está en modo seguimiento
// //         if (isFirstLoad || (!_userHasMovedCamera && !_isFollowingUser)) {
// //           _fitRouteInView(route.geometry);
// //           isFirstLoad = false;
// //         }
// //       } else {
// //         print('Route source not found - reinitializing layers');
// //         _layersInitialized = false;
// //         await _initializeMapLayers();

// //         // Try updating the route again after reinitializing
// //         final newSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
// //         if (newSourceObj != null) {
// //           final source = newSourceObj as GeoJsonSource;
// //           source.updateGeoJSON(geoJsonString);

// //           // Solo ajustamos la vista si es la primera carga
// //           if (isFirstLoad) {
// //             _fitRouteInView(route.geometry);
// //             isFirstLoad = false;
// //           }
// //         }
// //       }
// //     } catch (e) {
// //       print('Error updating route on map: $e');
// //     }
// //   }

// //   void _fitRouteInView(List<List<double>> coordinates) {
// //     // Si el usuario ha movido la cámara manualmente y no está en modo de seguimiento,
// //     // no ajustamos la vista automáticamente
// //     if (_userHasMovedCamera && !_isFollowingUser) {
// //       return;
// //     }

// //     if (coordinates.isEmpty || _mapboxMap == null) return;

// //     try {
// //       double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

// //       for (final point in coordinates) {
// //         if (point.length < 2) continue;
// //         final lng = point[0];
// //         final lat = point[1];
// //         minLat = minLat > lat ? lat : minLat;
// //         maxLat = maxLat < lat ? lat : maxLat;
// //         minLng = minLng > lng ? lng : minLng;
// //         maxLng = maxLng < lng ? lng : maxLng;
// //       }

// //       // Add padding to the bounding box
// //       final latDelta = (maxLat - minLat) * 0.2;
// //       final lngDelta = (maxLng - minLng) * 0.2;

// //       final southwest = Point(
// //         coordinates: Position(minLng - lngDelta, minLat - latDelta),
// //       );
// //       final northeast = Point(
// //         coordinates: Position(maxLng + lngDelta, maxLat + latDelta),
// //       );

// //       if (!_isValidCoordinate(southwest.coordinates) ||
// //           !_isValidCoordinate(northeast.coordinates)) {
// //         print('Invalid coordinates for fitting map');
// //         return;
// //       }

// //       final bounds = CoordinateBounds(
// //         southwest: southwest,
// //         northeast: northeast,
// //         infiniteBounds: false,
// //       );

// //       _mapboxMap!
// //           .cameraForCoordinateBounds(
// //             bounds,
// //             MbxEdgeInsets(top: 100, left: 50, bottom: 150, right: 50),
// //             null,
// //             null,
// //             null,
// //             null,
// //           )
// //           .then((camera) {
// //             _mapboxMap!.flyTo(camera, MapAnimationOptions(duration: 1000));
// //           });

// //       print('Map zoom adjusted for route');
// //     } catch (e) {
// //       print('Error adjusting map zoom: $e');
// //     }
// //   }

// //   bool _isValidCoordinate(Position position) {
// //     return position.lat >= -90 &&
// //         position.lat <= 90 &&
// //         position.lng >= -180 &&
// //         position.lng <= 180;
// //   }

// //   void _clearRouteFromMap() async {
// //     try {
// //       if (!_layersInitialized || _mapboxMap == null) return;

// //       print('Clearing route from map');

// //       // Get sources asynchronously
// //       final routeSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
// //       if (routeSourceObj != null) {
// //         final routeSource = routeSourceObj as GeoJsonSource;
// //         routeSource.updateGeoJSON(_createEmptyLineFeatureCollection());
// //       }

// //       final destinationSourceObj = await _mapboxMap!.style.getSource(
// //         _destinationSourceId,
// //       );
// //       if (destinationSourceObj != null) {
// //         final destinationSource = destinationSourceObj as GeoJsonSource;
// //         destinationSource.updateGeoJSON(_createEmptyPointFeatureCollection());
// //       }

// //       print('Route cleared from map');
// //     } catch (e) {
// //       print('Error clearing route from map: $e');
// //     }
// //   }

// //   void _goToCurrentLocation() {
// //     if (_locationController.currentLocation != null && _mapboxMap != null) {
// //       // El usuario ha solicitado ir a su ubicación, así que resetear el flag
// //       _userHasMovedCamera = false;

// //       _mapboxMap!.flyTo(
// //         CameraOptions(
// //           center: Point(
// //             coordinates: Position(
// //               _locationController.currentLocation!.longitude,
// //               _locationController.currentLocation!.latitude,
// //             ),
// //           ),
// //           zoom: 15.0,
// //           bearing: 0,
// //           pitch: 0,
// //         ),
// //         MapAnimationOptions(duration: 1000),
// //       );
// //       print('Moved to current location');
// //     } else {
// //       _locationController.updateCurrentLocation();
// //       print('Attempting to update current location');
// //     }
// //   }

// //   // Toggle between follow mode and normal mode
// //   void _toggleFollowMode() {
// //     setState(() {
// //       _isFollowingUser = !_isFollowingUser;
// //       if (_isFollowingUser) {
// //         // Resetear el flag cuando se activa el modo de seguimiento
// //         _userHasMovedCamera = false;
// //         _goToCurrentLocationWithBearing();
// //       }
// //     });
// //   }

// //   // Move to current location with camera bearing aligned to user direction
// //   void _goToCurrentLocationWithBearing() {
// //     if (_locationController.currentLocation != null && _mapboxMap != null) {
// //       _mapboxMap!.flyTo(
// //         CameraOptions(
// //           center: Point(
// //             coordinates: Position(
// //               _locationController.currentLocation!.longitude,
// //               _locationController.currentLocation!.latitude,
// //             ),
// //           ),
// //           zoom: 18.0, // More zoom for close-up view
// //           bearing: _userBearing, // Rotate camera to match user direction
// //           pitch: 60.0, // Tilt camera for 3D-like view
// //         ),
// //         MapAnimationOptions(duration: 1000),
// //       );
// //       print('Moved to current location with bearing: $_userBearing');
// //     } else {
// //       _locationController.updateCurrentLocation();
// //       print('Attempting to update current location for bearing view');
// //     }
// //   }

// //   // Calculate bearing between two points
// //   double _calculateBearing(
// //     double startLat,
// //     double startLng,
// //     double endLat,
// //     double endLng,
// //   ) {
// //     double latitude1 = startLat * (pi / 180.0);
// //     double longitude1 = startLng * (pi / 180.0);
// //     double latitude2 = endLat * (pi / 180.0);
// //     double longitude2 = endLng * (pi / 180.0);

// //     double y = sin(longitude2 - longitude1) * cos(latitude2);
// //     double x =
// //         cos(latitude1) * sin(latitude2) -
// //         sin(latitude1) * cos(latitude2) * cos(longitude2 - longitude1);

// //     double bearing = atan2(y, x);
// //     bearing = bearing * (180.0 / pi);
// //     bearing = (bearing + 360) % 360;

// //     return bearing;
// //   }

// //   void _updateMapStyle() {
// //     if (_mapboxMap == null) return;

// //     String mapStyle =
// //         _storageController.isDarkMode
// //             ? AppConstants.nightMapStyle
// //             : AppConstants.dayMapStyle;

// //     _mapboxMap!.style.setStyleURI(mapStyle);
// //     _layersInitialized = false;
// //     customLocationAdded = false;
// //     _arrowAdded = false;
// //     print('Map style updated: $mapStyle');
// //   }

// //   String _createEmptyPointFeatureCollection() {
// //     return '{"type":"FeatureCollection","features":[]}';
// //   }

// //   String _createEmptyLineFeatureCollection() {
// //     return '{"type":"FeatureCollection","features":[]}';
// //   }

// //   @override
// //   void dispose() {
// //     _cameraUpdateTimer?.cancel(); // Clean up the timer
// //     _resetUserMovedCameraTimer?.cancel(); // No olvidar cancelar este timer
// //     _locationController.removeListener(_onLocationControllerChanged);
// //     _navigationController.removeListener(_onNavigationControllerChanged);
// //     super.dispose();
// //   }
// // }
// // ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print
// import 'dart:convert';
// import 'dart:async';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import '../../config/app_constants.dart';
// import '../../controllers/location_controller.dart';
// import '../../controllers/navigation_controller.dart';
// import '../../controllers/storage_controller.dart';
// import '../../models/location_model.dart';
// import '../../models/place_model.dart';
// import '../../models/route_model.dart';

// class CustomMap extends StatefulWidget {
//   final Function(PlaceModel)? onPlaceSelected;
//   final bool followUserLocation;

//   const CustomMap({
//     super.key,
//     this.onPlaceSelected,
//     this.followUserLocation = false,
//   });

//   @override
//   State<CustomMap> createState() => _CustomMapState();
// }

// class _CustomMapState extends State<CustomMap> {
//   MapboxMap? _mapboxMap;
//   late LocationController _locationController;
//   late NavigationController _navigationController;
//   late StorageController _storageController;
//   bool _layersInitialized = false;
//   Timer? _cameraUpdateTimer;
//   bool isFirstLoad = true;

//   // **تعديل**: إضافة متغير لتتبع ما إذا كان المستخدم قد حرك الكاميرا يدويًا
//   bool _userHasMovedCamera = false;
//   Timer? _resetUserMovedCameraTimer;

//   // Direction arrow and camera control variables
//   final String _directionArrowSourceId = 'direction-arrow-source';
//   final String _directionArrowLayerId = 'direction-arrow-layer';
//   double _userBearing = 0; // Current user direction
//   bool _isFollowingUser = false; // Is camera following user?
//   bool _arrowAdded = false; // Has the arrow layer been added?
//   LocationModel?
//   _previousLocation; // Store previous location to calculate bearing

//   // Map layer identifiers
//   final String _routeLayerId = 'route-layer';
//   final String _routeSourceId = 'route-source';
//   final String _userLocationSourceId = 'user-location-source';
//   final String _userLocationLayerId = 'user-location-layer';
//   final String _destinationSourceId = 'destination-source';
//   final String _destinationLayerId = 'destination-layer';
//   final String _destinationCircleLayerId = 'destination-circle-layer';
//   final String customLocationSourceId = 'custom-location-source';
//   final String customLocationLayerId = 'custom-location-layer';
//   bool customLocationAdded = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _locationController = Provider.of<LocationController>(context);
//     _navigationController = Provider.of<NavigationController>(context);
//     _storageController = Provider.of<StorageController>(context);

//     // Add listeners to ensure we catch all state changes
//     _locationController.addListener(_onLocationControllerChanged);
//     _navigationController.addListener(_onNavigationControllerChanged);
//   }

//   @override
//   Widget build(BuildContext context) {
//     String mapStyle =
//         _storageController.isDarkMode
//             ? AppConstants.nightMapStyle
//             : AppConstants.outdoorsStyle;

//     return Stack(
//       children: [
//         MapWidget(
//           styleUri: mapStyle,
//           onMapCreated: _onMapCreated,
//           cameraOptions: CameraOptions(
//             center: Point(
//               coordinates: Position(
//                 AppConstants.defaultLongitude,
//                 AppConstants.defaultLatitude,
//               ),
//             ),
//             zoom: AppConstants.defaultZoom,
//           ),
//           onStyleLoadedListener: _onStyleLoaded,
//           onTapListener: _onMapTap,
//           // **تعديل**: إضافة مستمعي تغيير الكاميرا والخمول
//           onCameraChangeListener: _onCameraChanged,
//           onMapIdleListener: _onMapIdle,
//         ),
//         // Current location button
//         Positioned(
//           bottom: 110,
//           right: 16,
//           child: FloatingActionButton(
//             heroTag: 'btn_current_location',
//             mini: true,
//             backgroundColor: Theme.of(context).colorScheme.surface,
//             onPressed: _goToCurrentLocation,
//             child: Icon(
//               Icons.my_location,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//         ),
//         // Toggle map style button
//         Positioned(
//           bottom: 160,
//           right: 16,
//           child: FloatingActionButton(
//             heroTag: 'btn_toggle_map_mode',
//             mini: true,
//             backgroundColor: Theme.of(context).colorScheme.surface,
//             onPressed: () {
//               _storageController.toggleThemeMode();
//               _updateMapStyle();
//             },
//             child: Icon(
//               _storageController.isDarkMode
//                   ? Icons.wb_sunny
//                   : Icons.nightlight_round,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//         ),
//         // Toggle follow mode button
//         Positioned(
//           bottom: 210,
//           right: 16,
//           child: FloatingActionButton(
//             heroTag: 'btn_toggle_follow_mode',
//             mini: true,
//             backgroundColor: Theme.of(context).colorScheme.surface,
//             onPressed: _toggleFollowMode,
//             child: Icon(
//               _isFollowingUser ? Icons.navigation : Icons.explore,
//               color:
//                   _isFollowingUser
//                       ? Theme.of(context).colorScheme.primary
//                       : Theme.of(context).colorScheme.onSurface,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // **تعديل**: إضافة مستمع تغيير الكاميرا لتتبع حركة المستخدم اليدوية
//   void _onCameraChanged(CameraChangedEventData eventData) {
//     if (!_isFollowingUser) {
//       setState(() {
//         _userHasMovedCamera = true;
//       });
//       _resetUserMovedCameraTimer?.cancel();
//     }
//   }

//   // **تعديل**: إضافة مستمع خمول الخريطة لإعادة تعيين flag حركة المستخدم
//   void _onMapIdle(MapIdleEventData eventData) {
//     if (_userHasMovedCamera) {
//       _resetUserMovedCameraTimer?.cancel();
//       _resetUserMovedCameraTimer = Timer(const Duration(seconds: 30), () {
//         setState(() {
//           _userHasMovedCamera = false;
//         });
//       });
//     }
//   }

//   void _onMapTap(MapContentGestureContext context) async {
//     if (_mapboxMap == null) return;

//     // **تعديل**: تحديث flag حركة المستخدم عند النقر
//     setState(() {
//       _userHasMovedCamera = true;
//     });

//     try {
//       Point point = await _mapboxMap!.coordinateForPixel(
//         context.point as ScreenCoordinate,
//       );
//       Position position = point.coordinates;
//       double latitude = position.lat.toDouble();
//       double longitude = position.lng.toDouble();

//       PlaceModel selectedPlace = PlaceModel(
//         address: 'الموقع المحدد',
//         id: 'selected',
//         placeName: 'الوجهة المحددة',
//         latitude: latitude,
//         longitude: longitude,
//       );

//       if (_locationController.currentLocation != null) {
//         _navigationController.startNavigation(
//           selectedPlace,
//           _locationController.currentLocation!,
//         );

//         print('Destination set at: $latitude, $longitude');
//         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//           const SnackBar(content: Text('تم تحديد الوجهة. جارِ حساب المسار...')),
//         );
//       } else {
//         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//           const SnackBar(content: Text('لم يتم تحديد موقعك الحالي بعد')),
//         );
//       }
//     } catch (e) {
//       print('Error setting destination: $e');
//       ScaffoldMessenger.of(
//         context as BuildContext,
//       ).showSnackBar(SnackBar(content: Text('خطأ في تحديد الوجهة: $e')));
//     }
//   }

//   void _onMapCreated(MapboxMap mapboxMap) {
//     _mapboxMap = mapboxMap;
//     print('Map created');

//     _mapboxMap!.location.updateSettings(
//       LocationComponentSettings(
//         enabled: true,
//         pulsingEnabled: true,
//         showAccuracyRing: true,
//       ),
//     );

//     if (widget.followUserLocation) {
//       _cameraUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
//         if (_mapboxMap != null && widget.followUserLocation) {
//           _goToCurrentLocation();
//         }
//       });
//     }
//   }

//   void _onStyleLoaded(styleLoadedEventData) async {
//     print('Map style loaded');

//     await Future.delayed(const Duration(milliseconds: 500));

//     await _initializeMapLayers();
//     _goToCurrentLocation();

//     if (_navigationController.isNavigating) {
//       await Future.delayed(const Duration(milliseconds: 200));

//       if (_navigationController.destination != null) {
//         _updateDestinationOnMap(
//           _navigationController.destination!.latitude,
//           _navigationController.destination!.longitude,
//           _navigationController.destination!.placeName,
//         );
//       }

//       if (_navigationController.currentRoute != null) {
//         _updateRouteOnMap(_navigationController.currentRoute!);
//       }
//     }
//   }

//   Future<void> _initializeMapLayers() async {
//     if (_layersInitialized || _mapboxMap == null) return;

//     try {
//       print('Initializing map layers...');

//       await _mapboxMap!.style.addSource(
//         GeoJsonSource(
//           id: _userLocationSourceId,
//           data: '{"type":"FeatureCollection","features":[]}',
//         ),
//       );

//       await _mapboxMap!.style.addLayer(
//         CircleLayer(
//           id: "${_userLocationLayerId}_outer",
//           sourceId: _userLocationSourceId,
//           circleRadius: 18.0,
//           circleColor: 0x554882C4,
//           circleStrokeWidth: 2.0,
//           circleStrokeColor: 0xFF4882C4,
//         ),
//       );

//       await _mapboxMap!.style.addLayer(
//         CircleLayer(
//           id: _userLocationLayerId,
//           sourceId: _userLocationSourceId,
//           circleRadius: 10.0,
//           circleColor: 0xFF4882C4,
//           circleStrokeWidth: 3.0,
//           circleStrokeColor: 0xFFFFFFFF,
//         ),
//       );

//       await _mapboxMap!.style.addSource(
//         GeoJsonSource(
//           id: _destinationSourceId,
//           data: '{"type":"FeatureCollection","features":[]}',
//         ),
//       );

//       await _mapboxMap!.style.addLayer(
//         CircleLayer(
//           id: _destinationCircleLayerId,
//           sourceId: _destinationSourceId,
//           circleRadius: 12.0,
//           circleColor: 0xFFE53935,
//           circleStrokeWidth: 3.0,
//           circleStrokeColor: 0xFFFFFFFF,
//         ),
//       );

//       await _mapboxMap!.style.addLayer(
//         SymbolLayer(
//           id: _destinationLayerId,
//           sourceId: _destinationSourceId,
//           textField: "{name}",
//           textSize: 14.0,
//           textOffset: [0, 2.0],
//           textAnchor: TextAnchor.TOP,
//           textColor: 0xFF000000,
//           textHaloWidth: 1.5,
//           textHaloColor: 0xFFFFFFFF,
//         ),
//       );

//       await _mapboxMap!.style.addSource(
//         GeoJsonSource(
//           id: _routeSourceId,
//           data: '{"type":"FeatureCollection","features":[]}',
//         ),
//       );

//       await _mapboxMap!.style.addLayer(
//         LineLayer(
//           id: _routeLayerId,
//           sourceId: _routeSourceId,
//           lineColor: int.parse(
//             '0xFF${AppConstants.routeLineColor.substring(1)}',
//           ),
//           lineWidth: AppConstants.routeLineWidth,
//           lineCap: LineCap.ROUND,
//           lineJoin: LineJoin.ROUND,
//         ),
//       );

//       await _mapboxMap!.style.addSource(
//         GeoJsonSource(
//           id: _directionArrowSourceId,
//           data: '{"type":"FeatureCollection","features":[]}',
//         ),
//       );

//       await _mapboxMap!.style.addLayer(
//         SymbolLayer(
//           id: _directionArrowLayerId,
//           sourceId: _directionArrowSourceId,
//           iconImage: "arrow",
//           iconSize: 1.5,
//           iconAllowOverlap: true,
//           iconIgnorePlacement: true,
//           iconRotate: _userBearing,
//         ),
//       );

//       await _addArrowImageToMap();

//       _layersInitialized = true;
//       _arrowAdded = true;
//       print('Map layers initialized successfully');

//       if (_locationController.currentLocation != null) {
//         _updateUserLocationOnMap(_locationController.currentLocation!);
//       }

//       if (_navigationController.isNavigating) {
//         if (_navigationController.destination != null) {
//           _updateDestinationOnMap(
//             _navigationController.destination!.latitude,
//             _navigationController.destination!.longitude,
//             _navigationController.destination!.placeName,
//           );
//         }
//         if (_navigationController.currentRoute != null) {
//           _updateRouteOnMap(_navigationController.currentRoute!);
//         }
//       }
//     } catch (e) {
//       print('Error initializing map layers: $e');
//     }
//   }

//   Future<void> _addArrowImageToMap() async {
//     try {
//       final int size = 64;
//       final Uint8List data = Uint8List(size * size * 4);

//       for (int y = 0; y < size; y++) {
//         for (int x = 0; x < size; x++) {
//           double centerX = size / 2;
//           double centerY = size / 2;
//           double dx = x - centerX;
//           double dy = y - centerY;

//           bool isArrow = false;
//           bool isArrowBorder = false;

//           if (dx.abs() < 8 && dy > 0 && dy < 24) {
//             isArrow = true;
//           }

//           if (dy < 0 && dy > -16 && dx.abs() < -dy) {
//             isArrow = true;
//           }

//           if (dx.abs() < 10 && dy > -2 && dy < 26 && !isArrow) {
//             isArrowBorder = true;
//           }

//           if (dy < 2 && dy > -18 && dx.abs() < (-dy + 2) && !isArrow) {
//             isArrowBorder = true;
//           }

//           int pixelIndex = (y * size + x) * 4;
//           if (isArrow) {
//             data[pixelIndex] = 72;
//             data[pixelIndex + 1] = 130;
//             data[pixelIndex + 2] = 196;
//             data[pixelIndex + 3] = 255;
//           } else if (isArrowBorder) {
//             data[pixelIndex] = 255;
//             data[pixelIndex + 1] = 255;
//             data[pixelIndex + 2] = 255;
//             data[pixelIndex + 3] = 255;
//           } else {
//             data[pixelIndex + 3] = 0;
//           }
//         }
//       }

//       final MbxImage arrowImage = MbxImage(
//         width: size,
//         height: size,
//         data: data,
//       );

//       await _mapboxMap!.style.addStyleImage(
//         "arrow",
//         1.0,
//         arrowImage,
//         false,
//         [],
//         [],
//         null,
//       );

//       print('Arrow image added to map successfully');
//     } catch (e) {
//       print('Error adding arrow image to map: $e');
//     }
//   }

//   void _onLocationControllerChanged() {
//     if (_locationController.currentLocation != null) {
//       if (!_layersInitialized) {
//         _initializeMapLayers();
//       } else {
//         _previousLocation = _locationController.currentLocation;
//         _updateUserLocationOnMap(_locationController.currentLocation!);

//         if (_previousLocation != null) {
//           _userBearing = _calculateBearing(
//             _previousLocation!.latitude,
//             _previousLocation!.longitude,
//             _locationController.currentLocation!.latitude,
//             _locationController.currentLocation!.longitude,
//           );
//         }
//       }
//     }
//   }

//   void _onNavigationControllerChanged() async {
//     if (!_layersInitialized) {
//       await _initializeMapLayers();
//       return;
//     }

//     if (_navigationController.isNavigating) {
//       print(
//         'Navigation state changed - isNavigating: ${_navigationController.isNavigating}',
//       );

//       await Future.delayed(const Duration(milliseconds: 300));

//       if (_navigationController.currentRoute != null) {
//         print(
//           'Updating route - points: ${_navigationController.currentRoute!.geometry.length}',
//         );
//         // **تعديل**: إعادة تعيين flag حركة المستخدم عند تحميل روت جديد
//         if (isFirstLoad) {
//           _userHasMovedCamera = false;
//         }
//         _updateRouteOnMap(_navigationController.currentRoute!);
//       } else {
//         print('Navigation active but route is null!');
//       }

//       if (_navigationController.destination != null) {
//         print(
//           'Updating destination - ${_navigationController.destination!.placeName}',
//         );
//         _updateDestinationOnMap(
//           _navigationController.destination!.latitude,
//           _navigationController.destination!.longitude,
//           _navigationController.destination!.placeName,
//         );
//       }
//     } else {
//       _clearRouteFromMap();
//     }
//   }

//   void _updateUserLocationOnMap(LocationModel location) async {
//     try {
//       if (!_layersInitialized || _mapboxMap == null) return;

//       final Map<String, dynamic> featureCollection = {
//         'type': 'FeatureCollection',
//         'features': [
//           {
//             'type': 'Feature',
//             'geometry': {
//               'type': 'Point',
//               'coordinates': [location.longitude, location.latitude],
//             },
//             'properties': {},
//           },
//         ],
//       };

//       final String geoJsonString = jsonEncode(featureCollection);

//       final sourceObj = await _mapboxMap!.style.getSource(
//         _userLocationSourceId,
//       );

//       if (sourceObj != null) {
//         final source = sourceObj as GeoJsonSource;
//         source.updateGeoJSON(geoJsonString);
//       } else {
//         print('User location source not found - reinitializing layers');
//         _layersInitialized = false;
//         await _initializeMapLayers();

//         final newSourceObj = await _mapboxMap!.style.getSource(
//           _userLocationSourceId,
//         );
//         if (newSourceObj != null) {
//           final source = newSourceObj as GeoJsonSource;
//           source.updateGeoJSON(geoJsonString);
//         }
//       }

//       _updateDirectionArrow(location);

//       if (_isFollowingUser) {
//         _goToCurrentLocationWithBearing();
//       }
//     } catch (e) {
//       print('Error updating user location on map: $e');
//     }
//   }

//   void _updateDirectionArrow(LocationModel location) async {
//     if (!_layersInitialized || _mapboxMap == null || !_arrowAdded) return;

//     try {
//       if (_previousLocation == null) {
//         _userBearing = (_userBearing + 2) % 360;
//       }

//       final Map<String, dynamic> arrowFeatureCollection = {
//         'type': 'FeatureCollection',
//         'features': [
//           {
//             'type': 'Feature',
//             'geometry': {
//               'type': 'Point',
//               'coordinates': [location.longitude, location.latitude],
//             },
//             'properties': {'bearing': _userBearing},
//           },
//         ],
//       };

//       final String arrowGeoJsonString = jsonEncode(arrowFeatureCollection);

//       final arrowSourceObj = await _mapboxMap!.style.getSource(
//         _directionArrowSourceId,
//       );
//       if (arrowSourceObj != null) {
//         final arrowSource = arrowSourceObj as GeoJsonSource;
//         arrowSource.updateGeoJSON(arrowGeoJsonString);
//       }
//     } catch (e) {
//       print('Error updating direction arrow: $e');
//     }
//   }

//   void _updateDestinationOnMap(
//     double latitude,
//     double longitude,
//     String name,
//   ) async {
//     try {
//       if (!_layersInitialized || _mapboxMap == null) return;

//       print('Updating destination: $latitude, $longitude, $name');

//       final Map<String, dynamic> featureCollection = {
//         'type': 'FeatureCollection',
//         'features': [
//           {
//             'type': 'Feature',
//             'geometry': {
//               'type': 'Point',
//               'coordinates': [longitude, latitude],
//             },
//             'properties': {'name': name},
//           },
//         ],
//       };

//       final String geoJsonString = jsonEncode(featureCollection);

//       final sourceObj = await _mapboxMap!.style.getSource(_destinationSourceId);

//       if (sourceObj != null) {
//         final source = sourceObj as GeoJsonSource;
//         source.updateGeoJSON(geoJsonString);
//       } else {
//         print('Destination source not found - reinitializing layers');
//         _layersInitialized = false;
//         await _initializeMapLayers();

//         final newSourceObj = await _mapboxMap!.style.getSource(
//           _destinationSourceId,
//         );
//         if (newSourceObj != null) {
//           final source = newSourceObj as GeoJsonSource;
//           source.updateGeoJSON(geoJsonString);
//         }
//       }
//     } catch (e) {
//       print('Error updating destination on map: $e');
//     }
//   }

//   void _updateRouteOnMap(RouteModel route) async {
//     try {
//       if (!_layersInitialized || _mapboxMap == null) return;

//       print('Updating route - points count: ${route.geometry.length}');

//       if (route.geometry.isEmpty) {
//         print('Warning: Route is empty!');
//         return;
//       }

//       final Map<String, dynamic> featureCollection = {
//         'type': 'FeatureCollection',
//         'features': [
//           {
//             'type': 'Feature',
//             'geometry': {'type': 'LineString', 'coordinates': route.geometry},
//             'properties': {},
//           },
//         ],
//       };

//       final String geoJsonString = jsonEncode(featureCollection);

//       final sourceObj = await _mapboxMap!.style.getSource(_routeSourceId);

//       if (sourceObj != null) {
//         final source = sourceObj as GeoJsonSource;
//         source.updateGeoJSON(geoJsonString);

//         // **تعديل**: استخدام _positionCameraBehindUser بدلاً من _fitRouteInView
//         // لضبط الكاميرا خلف المستخدم عند تحميل الروت
//         if (isFirstLoad || (!_userHasMovedCamera && !_isFollowingUser)) {
//           if (_locationController.currentLocation != null) {
//             _positionCameraBehindUser(
//               _locationController.currentLocation!,
//               route,
//             );
//           }
//           isFirstLoad = false;
//         }
//       } else {
//         print('Route source not found - reinitializing layers');
//         _layersInitialized = false;
//         await _initializeMapLayers();

//         final newSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
//         if (newSourceObj != null) {
//           final source = newSourceObj as GeoJsonSource;
//           source.updateGeoJSON(geoJsonString);

//           if (isFirstLoad && _locationController.currentLocation != null) {
//             _positionCameraBehindUser(
//               _locationController.currentLocation!,
//               route,
//             );
//             isFirstLoad = false;
//           }
//         }
//       }
//     } catch (e) {
//       print('Error updating route on map: $e');
//     }
//   }

//   // **تعديل**: إضافة دالة جديدة لضبط الكاميرا خلف المستخدم مع إظهار الروت أمامه
//   void _positionCameraBehindUser(LocationModel userLocation, RouteModel route) {
//     if (_mapboxMap == null || route.geometry.isEmpty) return;

//     try {
//       // موقع المستخدم
//       double userLat = userLocation.latitude;
//       double userLng = userLocation.longitude;

//       // اتجاه المستخدم
//       double bearing = _userBearing;

//       // إزاحة الكاميرا لتكون خلف المستخدم
//       const double offsetDistance = 0.001; // ~100 متر
//       double offsetLat = offsetDistance * cos((bearing + 180) * pi / 180);
//       double offsetLng = offsetDistance * sin((bearing + 180) * pi / 180);

//       // مركز الكاميرا خلف المستخدم
//       Point cameraCenter = Point(
//         coordinates: Position(userLng + offsetLng, userLat + offsetLat),
//       );

//       // ضبط الكاميرا
//       _mapboxMap!.flyTo(
//         CameraOptions(
//           center: cameraCenter,
//           zoom: 17.0, // زووم مناسب لعرض الروت
//           bearing: bearing, // تدوير الكاميرا لتتماشى مع اتجاه المستخدم
//           pitch: 60.0, // إمالة الكاميرا لعرض ثلاثي الأبعاد
//         ),
//         MapAnimationOptions(duration: 1000),
//       );

//       print('Camera positioned behind user with bearing: $bearing');
//     } catch (e) {
//       print('Error positioning camera behind user: $e');
//     }
//   }

//   void _fitRouteInView(List<List<double>> coordinates) {
//     // **تعديل**: إضافة التحقق من _userHasMovedCamera لتجنب ضبط الكاميرا إذا تحرك المستخدم
//     if (_userHasMovedCamera && !_isFollowingUser) {
//       return;
//     }

//     if (coordinates.isEmpty || _mapboxMap == null) return;

//     try {
//       double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

//       for (final point in coordinates) {
//         if (point.length < 2) continue;
//         final lng = point[0];
//         final lat = point[1];
//         minLat = minLat > lat ? lat : minLat;
//         maxLat = maxLat < lat ? lat : maxLat;
//         minLng = minLng > lng ? lng : minLng;
//         maxLng = maxLng < lng ? lng : maxLng;
//       }

//       final latDelta = (maxLat - minLat) * 0.2;
//       final lngDelta = (maxLng - minLng) * 0.2;

//       final southwest = Point(
//         coordinates: Position(minLng - lngDelta, minLat - latDelta),
//       );
//       final northeast = Point(
//         coordinates: Position(maxLng + lngDelta, maxLat + latDelta),
//       );

//       if (!_isValidCoordinate(southwest.coordinates) ||
//           !_isValidCoordinate(northeast.coordinates)) {
//         print('Invalid coordinates for fitting map');
//         return;
//       }

//       final bounds = CoordinateBounds(
//         southwest: southwest,
//         northeast: northeast,
//         infiniteBounds: false,
//       );

//       _mapboxMap!
//           .cameraForCoordinateBounds(
//             bounds,
//             MbxEdgeInsets(top: 100, left: 50, bottom: 150, right: 50),
//             null,
//             null,
//             null,
//             null,
//           )
//           .then((camera) {
//             _mapboxMap!.flyTo(camera, MapAnimationOptions(duration: 1000));
//           });

//       print('Map zoom adjusted for route');
//     } catch (e) {
//       print('Error adjusting map zoom: $e');
//     }
//   }

//   bool _isValidCoordinate(Position position) {
//     return position.lat >= -90 &&
//         position.lat <= 90 &&
//         position.lng >= -180 &&
//         position.lng <= 180;
//   }

//   void _clearRouteFromMap() async {
//     try {
//       if (!_layersInitialized || _mapboxMap == null) return;

//       print('Clearing route from map');

//       final routeSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
//       if (routeSourceObj != null) {
//         final routeSource = routeSourceObj as GeoJsonSource;
//         routeSource.updateGeoJSON(_createEmptyLineFeatureCollection());
//       }

//       final destinationSourceObj = await _mapboxMap!.style.getSource(
//         _destinationSourceId,
//       );
//       if (destinationSourceObj != null) {
//         final destinationSource = destinationSourceObj as GeoJsonSource;
//         destinationSource.updateGeoJSON(_createEmptyPointFeatureCollection());
//       }

//       print('Route cleared from map');
//     } catch (e) {
//       print('Error clearing route from map: $e');
//     }
//   }

//   void _goToCurrentLocation() {
//     if (_locationController.currentLocation != null && _mapboxMap != null) {
//       // **تعديل**: إعادة تعيين flag حركة المستخدم عند طلب الانتقال إلى الموقع الحالي
//       _userHasMovedCamera = false;

//       _mapboxMap!.flyTo(
//         CameraOptions(
//           center: Point(
//             coordinates: Position(
//               _locationController.currentLocation!.longitude,
//               _locationController.currentLocation!.latitude,
//             ),
//           ),
//           zoom: 15.0,
//           bearing: 0,
//           pitch: 0,
//         ),
//         MapAnimationOptions(duration: 1000),
//       );
//       print('Moved to current location');
//     } else {
//       _locationController.updateCurrentLocation();
//       print('Attempting to update current location');
//     }
//   }

//   void _toggleFollowMode() {
//     setState(() {
//       _isFollowingUser = !_isFollowingUser;
//       if (_isFollowingUser) {
//         // **تعديل**: إعادة تعيين flag حركة المستخدم عند تفعيل وضع المتابعة
//         _userHasMovedCamera = false;
//         _goToCurrentLocationWithBearing();
//       }
//     });
//   }

//   void _goToCurrentLocationWithBearing() {
//     if (_locationController.currentLocation != null && _mapboxMap != null) {
//       _mapboxMap!.flyTo(
//         CameraOptions(
//           center: Point(
//             coordinates: Position(
//               _locationController.currentLocation!.longitude,
//               _locationController.currentLocation!.latitude,
//             ),
//           ),
//           zoom: 18.0,
//           bearing: _userBearing,
//           pitch: 60.0,
//         ),
//         MapAnimationOptions(duration: 1000),
//       );
//       print('Moved to current location with bearing: $_userBearing');
//     } else {
//       _locationController.updateCurrentLocation();
//       print('Attempting to update current location for bearing view');
//     }
//   }

//   double _calculateBearing(
//     double startLat,
//     double startLng,
//     double endLat,
//     double endLng,
//   ) {
//     double latitude1 = startLat * (pi / 180.0);
//     double longitude1 = startLng * (pi / 180.0);
//     double latitude2 = endLat * (pi / 180.0);
//     double longitude2 = endLng * (pi / 180.0);

//     double y = sin(longitude2 - longitude1) * cos(latitude2);
//     double x =
//         cos(latitude1) * sin(latitude2) -
//         sin(latitude1) * cos(latitude2) * cos(longitude2 - longitude1);

//     double bearing = atan2(y, x);
//     bearing = bearing * (180.0 / pi);
//     bearing = (bearing + 360) % 360;

//     return bearing;
//   }

//   void _updateMapStyle() {
//     if (_mapboxMap == null) return;

//     String mapStyle =
//         _storageController.isDarkMode
//             ? AppConstants.nightMapStyle
//             : AppConstants.dayMapStyle;

//     _mapboxMap!.style.setStyleURI(mapStyle);
//     _layersInitialized = false;
//     customLocationAdded = false;
//     _arrowAdded = false;
//     print('Map style updated: $mapStyle');
//   }

//   String _createEmptyPointFeatureCollection() {
//     return '{"type":"FeatureCollection","features":[]}';
//   }

//   String _createEmptyLineFeatureCollection() {
//     return '{"type":"FeatureCollection","features":[]}';
//   }

//   @override
//   void dispose() {
//     _cameraUpdateTimer?.cancel();
//     // **تعديل**: إلغاء مؤقت إعادة تعيين flag حركة المستخدم
//     _resetUserMovedCameraTimer?.cancel();
//     _locationController.removeListener(_onLocationControllerChanged);
//     _navigationController.removeListener(_onNavigationControllerChanged);
//     super.dispose();
//   }
// }
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print
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
  bool _layersInitialized = false;
  Timer? _cameraUpdateTimer;
  bool isFirstLoad = true;

  // **تعديل**: إضافة متغير لتتبع ما إذا كان المستخدم قد حرك الكاميرا يدويًا
  bool _userHasMovedCamera = false;
  Timer? _resetUserMovedCameraTimer;

  // Direction arrow and camera control variables
  final String _directionArrowSourceId = 'direction-arrow-source';
  final String _directionArrowLayerId = 'direction-arrow-layer';
  double _userBearing = 0; // Current user direction
  bool _isFollowingUser = false; // Is camera following user?
  bool _arrowAdded = false; // Has the arrow layer been added?
  LocationModel?
  _previousLocation; // Store previous location to calculate bearing

  // Map layer identifiers
  final String _routeLayerId = 'route-layer';
  final String _routeSourceId = 'route-source';
  final String _userLocationSourceId = 'user-location-source';
  final String _userLocationLayerId = 'user-location-layer';
  final String _destinationSourceId = 'destination-source';
  final String _destinationLayerId = 'destination-layer';
  final String _destinationCircleLayerId = 'destination-circle-layer';
  final String customLocationSourceId = 'custom-location-source';
  final String customLocationLayerId = 'custom-location-layer';
  bool customLocationAdded = false;

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

    // Add listeners to ensure we catch all state changes
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
          // **تعديل**: إضافة مستمعي تغيير الكاميرا والخمول
          onCameraChangeListener: _onCameraChanged,
          onMapIdleListener: _onMapIdle,
        ),
        // Current location button
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
        // Toggle map style button
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
        // Toggle follow mode button
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
      ],
    );
  }

  // **تعديل**: إضافة مستمع تغيير الكاميرا لتتبع حركة المستخدم اليدوية
  void _onCameraChanged(CameraChangedEventData eventData) {
    if (!_isFollowingUser) {
      setState(() {
        _userHasMovedCamera = true;
      });
      _resetUserMovedCameraTimer?.cancel();
    }
  }

  // **تعديل**: إضافة مستمع خمول الخريطة لإعادة تعيين flag حركة المستخدم
  void _onMapIdle(MapIdleEventData eventData) {
    if (_userHasMovedCamera) {
      _resetUserMovedCameraTimer?.cancel();
      _resetUserMovedCameraTimer = Timer(const Duration(seconds: 30), () {
        setState(() {
          _userHasMovedCamera = false;
        });
      });
    }
  }

  void _onMapTap(MapContentGestureContext context) async {
    if (_mapboxMap == null) return;

    // تحقق أولاً إذا كان المستخدم نقر على مكان أو معلم
    bool tappedOnPlace = await _checkAndHandlePlaceTap(context);

    // إذا كان قد نقر على مكان، لا تتعامل معه كاختيار للوجهة
    if (tappedOnPlace) return;

    // استكمال كود اختيار الوجهة الحالي...
  }

  Future<bool> _checkAndHandlePlaceTap(MapContentGestureContext context) async {
    if (_mapboxMap == null) return false;

    try {
      // Convert screen coordinate to map coordinate
      final screenCoordinate = context.point as ScreenCoordinate;
      final point = await _mapboxMap!.coordinateForPixel(screenCoordinate);

      // Get current position for creating a place
      final double latitude = point.coordinates.lat.toDouble();
      final double longitude = point.coordinates.lng.toDouble();

      // Since we're having trouble with the feature query, let's create a place at the tap location
      final PlaceModel place = PlaceModel(
        id: 'place_${DateTime.now().millisecondsSinceEpoch}',
        placeName:
            'Selected Location', // We'll update this if we can get more info
        address: 'Loading address...',
        latitude: latitude,
        longitude: longitude,
        properties: {}, // Empty properties since we can't extract them
      );

      // Get address using reverse geocoding
      final String? address = await _locationController
          .getAddressFromCoordinates(latitude, longitude);

      // Try to get a better name for the place using the address
      String placeName = 'Selected Location';
      if (address != null && address.isNotEmpty) {
        final addressParts = address.split(',');
        if (addressParts.isNotEmpty) {
          placeName = addressParts[0].trim();
        }
      }

      final updatedPlace = place.copyWith(
        address: address ?? "Address not available",
        placeName: placeName,
      );

      // Show place details
      _showPlaceDetails(updatedPlace);

      return true;
    } catch (e) {
      print('Error checking for place tap: $e');
      return false;
    }
  }

  // طريقة لعرض تفاصيل المكان
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

                      // بدء التنقل إذا كان الموقع متاحًا
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
      _cameraUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_mapboxMap != null && widget.followUserLocation) {
          _goToCurrentLocation();
        }
      });
    }
  }

  void _onStyleLoaded(styleLoadedEventData) async {
    print('Map style loaded');

    await Future.delayed(const Duration(milliseconds: 500));

    await _initializeMapLayers();
    _goToCurrentLocation();

    if (_navigationController.isNavigating) {
      await Future.delayed(const Duration(milliseconds: 200));

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
  }

  Future<void> _initializeMapLayers() async {
    if (_layersInitialized || _mapboxMap == null) return;

    try {
      print('Initializing map layers...');

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
          iconImage: "arrow",
          iconSize: 1.5,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconRotate: _userBearing,
        ),
      );

      await _addArrowImageToMap();

      _layersInitialized = true;
      _arrowAdded = true;
      print('Map layers initialized successfully');

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

  Future<void> _addArrowImageToMap() async {
    try {
      final int size = 64;
      final Uint8List data = Uint8List(size * size * 4);

      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          double centerX = size / 2;
          double centerY = size / 2;
          double dx = x - centerX;
          double dy = y - centerY;

          bool isArrow = false;
          bool isArrowBorder = false;

          if (dx.abs() < 8 && dy > 0 && dy < 24) {
            isArrow = true;
          }

          if (dy < 0 && dy > -16 && dx.abs() < -dy) {
            isArrow = true;
          }

          if (dx.abs() < 10 && dy > -2 && dy < 26 && !isArrow) {
            isArrowBorder = true;
          }

          if (dy < 2 && dy > -18 && dx.abs() < (-dy + 2) && !isArrow) {
            isArrowBorder = true;
          }

          int pixelIndex = (y * size + x) * 4;
          if (isArrow) {
            data[pixelIndex] = 72;
            data[pixelIndex + 1] = 130;
            data[pixelIndex + 2] = 196;
            data[pixelIndex + 3] = 255;
          } else if (isArrowBorder) {
            data[pixelIndex] = 255;
            data[pixelIndex + 1] = 255;
            data[pixelIndex + 2] = 255;
            data[pixelIndex + 3] = 255;
          } else {
            data[pixelIndex + 3] = 0;
          }
        }
      }

      final MbxImage arrowImage = MbxImage(
        width: size,
        height: size,
        data: data,
      );

      await _mapboxMap!.style.addStyleImage(
        "arrow",
        1.0,
        arrowImage,
        false,
        [],
        [],
        null,
      );

      print('Arrow image added to map successfully');
    } catch (e) {
      print('Error adding arrow image to map: $e');
    }
  }

  void _onLocationControllerChanged() {
    if (_locationController.currentLocation != null) {
      if (!_layersInitialized) {
        _initializeMapLayers();
      } else {
        _previousLocation = _locationController.currentLocation;
        _updateUserLocationOnMap(_locationController.currentLocation!);

        if (_previousLocation != null) {
          _userBearing = _calculateBearing(
            _previousLocation!.latitude,
            _previousLocation!.longitude,
            _locationController.currentLocation!.latitude,
            _locationController.currentLocation!.longitude,
          );
        }
      }
    }
  }

  void _onNavigationControllerChanged() async {
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
        // **تعديل**: إعادة تعيين flag حركة المستخدم عند تحميل روت جديد
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

  void _updateUserLocationOnMap(LocationModel location) async {
    try {
      if (!_layersInitialized || _mapboxMap == null) return;

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
        _layersInitialized = false;
        await _initializeMapLayers();

        final newSourceObj = await _mapboxMap!.style.getSource(
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
    } catch (e) {
      print('Error updating user location on map: $e');
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

  void _updateDestinationOnMap(
    double latitude,
    double longitude,
    String name,
  ) async {
    try {
      if (!_layersInitialized || _mapboxMap == null) return;

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

        final newSourceObj = await _mapboxMap!.style.getSource(
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

  void _updateRouteOnMap(RouteModel route) async {
    try {
      if (!_layersInitialized || _mapboxMap == null) return;

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

        // **تعديل**: استخدام _positionCameraBehindUser بدلاً من _fitRouteInView
        // لضبط الكاميرا خلف المستخدم عند تحميل الروت
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

        final newSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
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

  // **تعديل**: إضافة دالة جديدة لضبط الكاميرا خلف المستخدم مع إظهار الروت أمامه
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

  void fitRouteInView(List<List<double>> coordinates) {
    // **تعديل**: إضافة التحقق من _userHasMovedCamera لتجنب ضبط الكاميرا إذا تحرك المستخدم
    if (_userHasMovedCamera && !_isFollowingUser) {
      return;
    }

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
        print('Invalid coordinates for fitting map');
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

      print('Map zoom adjusted for route');
    } catch (e) {
      print('Error adjusting map zoom: $e');
    }
  }

  bool _isValidCoordinate(Position position) {
    return position.lat >= -90 &&
        position.lat <= 90 &&
        position.lng >= -180 &&
        position.lng <= 180;
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
      // **تعديل**: إعادة تعيين flag حركة المستخدم عند طلب الانتقال إلى الموقع الحالي
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

  void _toggleFollowMode() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;
      if (_isFollowingUser) {
        // **تعديل**: إعادة تعيين flag حركة المستخدم عند تفعيل وضع المتابعة
        _userHasMovedCamera = false;
        _goToCurrentLocationWithBearing();
      }
    });
  }

  void _goToCurrentLocationWithBearing() {
    if (_locationController.currentLocation != null && _mapboxMap != null) {
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

  void _updateMapStyle() {
    if (_mapboxMap == null) return;

    String mapStyle =
        _storageController.isDarkMode
            ? AppConstants.nightMapStyle
            : AppConstants.dayMapStyle;

    _mapboxMap!.style.setStyleURI(mapStyle);
    _layersInitialized = false;
    customLocationAdded = false;
    _arrowAdded = false;
    print('Map style updated: $mapStyle');
  }

  String _createEmptyPointFeatureCollection() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  String _createEmptyLineFeatureCollection() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  @override
  void dispose() {
    _cameraUpdateTimer?.cancel();
    // **تعديل**: إلغاء مؤقت إعادة تعيين flag حركة المستخدم
    _resetUserMovedCameraTimer?.cancel();
    _locationController.removeListener(_onLocationControllerChanged);
    _navigationController.removeListener(_onNavigationControllerChanged);
    super.dispose();
  }
}
