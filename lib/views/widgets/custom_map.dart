// // // // // ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print
// // // // import 'dart:convert';
// // // // import 'dart:async';
// // // // import 'dart:math';
// // // // import 'dart:typed_data';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// // // // import 'package:provider/provider.dart';
// // // // import '../../config/app_constants.dart';
// // // // import '../../controllers/location_controller.dart';
// // // // import '../../controllers/navigation_controller.dart';
// // // // import '../../controllers/storage_controller.dart';
// // // // import '../../models/location_model.dart';
// // // // import '../../models/place_model.dart';
// // // // import '../../models/route_model.dart';

// // // // class CustomMap extends StatefulWidget {
// // // //   final Function(PlaceModel)? onPlaceSelected;
// // // //   final bool followUserLocation;

// // // //   const CustomMap({
// // // //     super.key,
// // // //     this.onPlaceSelected,
// // // //     this.followUserLocation = false,
// // // //   });

// // // //   @override
// // // //   State<CustomMap> createState() => _CustomMapState();
// // // // }

// // // // class _CustomMapState extends State<CustomMap> {
// // // //   MapboxMap? _mapboxMap;
// // // //   late LocationController _locationController;
// // // //   late NavigationController _navigationController;
// // // //   late StorageController _storageController;
// // // //   bool _layersInitialized = false;
// // // //   Timer? _cameraUpdateTimer;
// // // //   bool isFirstLoad = true;

// // // //   // Direction arrow and camera control variables
// // // //   final String _directionArrowSourceId = 'direction-arrow-source';
// // // //   final String _directionArrowLayerId = 'direction-arrow-layer';
// // // //   double _userBearing = 0; // Current user direction
// // // //   bool _isFollowingUser = false; // Is camera following user?
// // // //   bool _arrowAdded = false; // Has the arrow layer been added?
// // // //   LocationModel?
// // // //   _previousLocation; // Store previous location to calculate bearing

// // // //   // Map layer identifiers
// // // //   final String _routeLayerId = 'route-layer';
// // // //   final String _routeSourceId = 'route-source';
// // // //   final String _userLocationSourceId = 'user-location-source';
// // // //   final String _userLocationLayerId = 'user-location-layer';
// // // //   final String _destinationSourceId = 'destination-source';
// // // //   final String _destinationLayerId = 'destination-layer';
// // // //   final String _destinationCircleLayerId = 'destination-circle-layer';
// // // //   final String customLocationSourceId = 'custom-location-source';
// // // //   final String customLocationLayerId = 'custom-location-layer';
// // // //   bool customLocationAdded = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //   }

// // // //   @override
// // // //   void didChangeDependencies() {
// // // //     super.didChangeDependencies();
// // // //     _locationController = Provider.of<LocationController>(context);
// // // //     _navigationController = Provider.of<NavigationController>(context);
// // // //     _storageController = Provider.of<StorageController>(context);

// // // //     // Add listeners to ensure we catch all state changes
// // // //     _locationController.addListener(_onLocationControllerChanged);
// // // //     _navigationController.addListener(_onNavigationControllerChanged);
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     String mapStyle =
// // // //         _storageController.isDarkMode
// // // //             ? AppConstants.nightMapStyle
// // // //             : AppConstants.outdoorsStyle;

// // // //     return Stack(
// // // //       children: [
// // // //         MapWidget(
// // // //           styleUri: mapStyle,
// // // //           onMapCreated: _onMapCreated,
// // // //           cameraOptions: CameraOptions(
// // // //             center: Point(
// // // //               coordinates: Position(
// // // //                 AppConstants.defaultLongitude,
// // // //                 AppConstants.defaultLatitude,
// // // //               ),
// // // //             ),
// // // //             zoom: AppConstants.defaultZoom,
// // // //           ),
// // // //           onStyleLoadedListener: _onStyleLoaded,
// // // //           onTapListener: _onMapTap,
// // // //         ),
// // // //         // Current location button
// // // //         Positioned(
// // // //           bottom: 110,
// // // //           right: 16,
// // // //           child: FloatingActionButton(
// // // //             heroTag: 'btn_current_location',
// // // //             mini: true,
// // // //             backgroundColor: Theme.of(context).colorScheme.surface,
// // // //             onPressed: _goToCurrentLocation,
// // // //             child: Icon(
// // // //               Icons.my_location,
// // // //               color: Theme.of(context).colorScheme.primary,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         // Toggle map style button
// // // //         Positioned(
// // // //           bottom: 160,
// // // //           right: 16,
// // // //           child: FloatingActionButton(
// // // //             heroTag: 'btn_toggle_map_mode',
// // // //             mini: true,
// // // //             backgroundColor: Theme.of(context).colorScheme.surface,
// // // //             onPressed: () {
// // // //               _storageController.toggleThemeMode();
// // // //               _updateMapStyle();
// // // //             },
// // // //             child: Icon(
// // // //               _storageController.isDarkMode
// // // //                   ? Icons.wb_sunny
// // // //                   : Icons.nightlight_round,
// // // //               color: Theme.of(context).colorScheme.primary,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         // Toggle follow mode button
// // // //         Positioned(
// // // //           bottom: 210,
// // // //           right: 16,
// // // //           child: FloatingActionButton(
// // // //             heroTag: 'btn_toggle_follow_mode',
// // // //             mini: true,
// // // //             backgroundColor: Theme.of(context).colorScheme.surface,
// // // //             onPressed: _toggleFollowMode,
// // // //             child: Icon(
// // // //               _isFollowingUser ? Icons.navigation : Icons.explore,
// // // //               color:
// // // //                   _isFollowingUser
// // // //                       ? Theme.of(context).colorScheme.primary
// // // //                       : Theme.of(context).colorScheme.onSurface,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   void _onMapTap(MapContentGestureContext context) async {
// // // //     if (_mapboxMap == null) return;

// // // //     try {
// // // //       // Convert screen coordinates to geographic coordinates
// // // //       Point point = await _mapboxMap!.coordinateForPixel(
// // // //         context.point as ScreenCoordinate,
// // // //       );
// // // //       Position position = point.coordinates;
// // // //       double latitude = position.lat.toDouble();
// // // //       double longitude = position.lng.toDouble();

// // // //       // Create a PlaceModel for the tapped location
// // // //       PlaceModel selectedPlace = PlaceModel(
// // // //         address: 'الموقع المحدد',
// // // //         id: 'selected',
// // // //         placeName: 'الوجهة المحددة',
// // // //         latitude: latitude,
// // // //         longitude: longitude,
// // // //       );

// // // //       // Start navigation to the selected destination
// // // //       if (_locationController.currentLocation != null) {
// // // //         _navigationController.startNavigation(
// // // //           selectedPlace,
// // // //           _locationController.currentLocation!,
// // // //         );

// // // //         print('Destination set at: $latitude, $longitude');
// // // //         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
// // // //           const SnackBar(content: Text('تم تحديد الوجهة. جارِ حساب المسار...')),
// // // //         );
// // // //       } else {
// // // //         ScaffoldMessenger.of(context as BuildContext).showSnackBar(
// // // //           const SnackBar(content: Text('لم يتم تحديد موقعك الحالي بعد')),
// // // //         );
// // // //       }
// // // //     } catch (e) {
// // // //       print('Error setting destination: $e');
// // // //       ScaffoldMessenger.of(
// // // //         context as BuildContext,
// // // //       ).showSnackBar(SnackBar(content: Text('خطأ في تحديد الوجهة: $e')));
// // // //     }
// // // //   }

// // // //   void _onMapCreated(MapboxMap mapboxMap) {
// // // //     _mapboxMap = mapboxMap;
// // // //     print('Map created');

// // // //     // Enable location tracking
// // // //     _mapboxMap!.location.updateSettings(
// // // //       LocationComponentSettings(
// // // //         enabled: true,
// // // //         pulsingEnabled: true,
// // // //         showAccuracyRing: true,
// // // //       ),
// // // //     );

// // // //     // Start periodic camera updates if followUserLocation is true
// // // //     if (widget.followUserLocation) {
// // // //       _cameraUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
// // // //         if (_mapboxMap != null && widget.followUserLocation) {
// // // //           _goToCurrentLocation();
// // // //         }
// // // //       });
// // // //     }
// // // //   }

// // // //   void _onStyleLoaded(styleLoadedEventData) async {
// // // //     print('Map style loaded');

// // // //     // Make sure we initialize layers when style is loaded
// // // //     await Future.delayed(const Duration(milliseconds: 500));

// // // //     await _initializeMapLayers();
// // // //     _goToCurrentLocation();

// // // //     // Check if there's an active navigation and update the map accordingly
// // // //     if (_navigationController.isNavigating) {
// // // //       await Future.delayed(const Duration(milliseconds: 200));

// // // //       if (_navigationController.destination != null) {
// // // //         _updateDestinationOnMap(
// // // //           _navigationController.destination!.latitude,
// // // //           _navigationController.destination!.longitude,
// // // //           _navigationController.destination!.placeName,
// // // //         );
// // // //       }

// // // //       if (_navigationController.currentRoute != null) {
// // // //         _updateRouteOnMap(_navigationController.currentRoute!);
// // // //       }
// // // //     }
// // // //   }

// // // //   Future<void> _initializeMapLayers() async {
// // // //     if (_layersInitialized || _mapboxMap == null) return;

// // // //     try {
// // // //       print('Initializing map layers...');

// // // //       // Add user location source and layers
// // // //       await _mapboxMap!.style.addSource(
// // // //         GeoJsonSource(
// // // //           id: _userLocationSourceId,
// // // //           data: '{"type":"FeatureCollection","features":[]}',
// // // //         ),
// // // //       );

// // // //       await _mapboxMap!.style.addLayer(
// // // //         CircleLayer(
// // // //           id: "${_userLocationLayerId}_outer",
// // // //           sourceId: _userLocationSourceId,
// // // //           circleRadius: 18.0,
// // // //           circleColor: 0x554882C4,
// // // //           circleStrokeWidth: 2.0,
// // // //           circleStrokeColor: 0xFF4882C4,
// // // //         ),
// // // //       );

// // // //       await _mapboxMap!.style.addLayer(
// // // //         CircleLayer(
// // // //           id: _userLocationLayerId,
// // // //           sourceId: _userLocationSourceId,
// // // //           circleRadius: 10.0,
// // // //           circleColor: 0xFF4882C4,
// // // //           circleStrokeWidth: 3.0,
// // // //           circleStrokeColor: 0xFFFFFFFF,
// // // //         ),
// // // //       );

// // // //       // Add destination source and layers
// // // //       await _mapboxMap!.style.addSource(
// // // //         GeoJsonSource(
// // // //           id: _destinationSourceId,
// // // //           data: '{"type":"FeatureCollection","features":[]}',
// // // //         ),
// // // //       );

// // // //       await _mapboxMap!.style.addLayer(
// // // //         CircleLayer(
// // // //           id: _destinationCircleLayerId,
// // // //           sourceId: _destinationSourceId,
// // // //           circleRadius: 12.0,
// // // //           circleColor: 0xFFE53935,
// // // //           circleStrokeWidth: 3.0,
// // // //           circleStrokeColor: 0xFFFFFFFF,
// // // //         ),
// // // //       );

// // // //       await _mapboxMap!.style.addLayer(
// // // //         SymbolLayer(
// // // //           id: _destinationLayerId,
// // // //           sourceId: _destinationSourceId,
// // // //           textField: "{name}",
// // // //           textSize: 14.0,
// // // //           textOffset: [0, 2.0],
// // // //           textAnchor: TextAnchor.TOP,
// // // //           textColor: 0xFF000000,
// // // //           textHaloWidth: 1.5,
// // // //           textHaloColor: 0xFFFFFFFF,
// // // //         ),
// // // //       );

// // // //       // Add route source and layer
// // // //       await _mapboxMap!.style.addSource(
// // // //         GeoJsonSource(
// // // //           id: _routeSourceId,
// // // //           data: '{"type":"FeatureCollection","features":[]}',
// // // //         ),
// // // //       );

// // // //       await _mapboxMap!.style.addLayer(
// // // //         LineLayer(
// // // //           id: _routeLayerId,
// // // //           sourceId: _routeSourceId,
// // // //           lineColor: int.parse(
// // // //             '0xFF${AppConstants.routeLineColor.substring(1)}',
// // // //           ),
// // // //           lineWidth: AppConstants.routeLineWidth,
// // // //           lineCap: LineCap.ROUND,
// // // //           lineJoin: LineJoin.ROUND,
// // // //         ),
// // // //       );

// // // //       // Add direction arrow source and layer
// // // //       await _mapboxMap!.style.addSource(
// // // //         GeoJsonSource(
// // // //           id: _directionArrowSourceId,
// // // //           data: '{"type":"FeatureCollection","features":[]}',
// // // //         ),
// // // //       );

// // // //       await _mapboxMap!.style.addLayer(
// // // //         SymbolLayer(
// // // //           id: _directionArrowLayerId,
// // // //           sourceId: _directionArrowSourceId,
// // // //           iconImage: "arrow", // Name of the arrow image we'll add
// // // //           iconSize: 1.5,
// // // //           iconAllowOverlap: true,
// // // //           iconIgnorePlacement: true,
// // // //           iconRotate:
// // // //               _userBearing, // Rotate arrow based on the calculated bearing
// // // //         ),
// // // //       );

// // // //       // Add arrow image to the map
// // // //       await _addArrowImageToMap();

// // // //       _layersInitialized = true;
// // // //       _arrowAdded = true;
// // // //       print('Map layers initialized successfully');

// // // //       // Update map with current data
// // // //       if (_locationController.currentLocation != null) {
// // // //         _updateUserLocationOnMap(_locationController.currentLocation!);
// // // //       }

// // // //       if (_navigationController.isNavigating) {
// // // //         if (_navigationController.destination != null) {
// // // //           _updateDestinationOnMap(
// // // //             _navigationController.destination!.latitude,
// // // //             _navigationController.destination!.longitude,
// // // //             _navigationController.destination!.placeName,
// // // //           );
// // // //         }
// // // //         if (_navigationController.currentRoute != null) {
// // // //           _updateRouteOnMap(_navigationController.currentRoute!);
// // // //         }
// // // //       }
// // // //     } catch (e) {
// // // //       print('Error initializing map layers: $e');
// // // //     }
// // // //   }

// // // //   // Add arrow image to the map
// // // //   Future<void> _addArrowImageToMap() async {
// // // //     try {
// // // //       // Create arrow image programmatically
// // // //       final int size = 64;
// // // //       final Uint8List data = Uint8List(size * size * 4);

// // // //       // Fill the image data with our arrow
// // // //       for (int y = 0; y < size; y++) {
// // // //         for (int x = 0; x < size; x++) {
// // // //           // Calculate distance from center
// // // //           double centerX = size / 2;
// // // //           double centerY = size / 2;
// // // //           double dx = x - centerX;
// // // //           double dy = y - centerY;

// // // //           // Define arrow shape
// // // //           bool isArrow = false;
// // // //           bool isArrowBorder = false;

// // // //           // Arrow body
// // // //           if (dx.abs() < 8 && dy > 0 && dy < 24) {
// // // //             isArrow = true;
// // // //           }

// // // //           // Arrow head
// // // //           if (dy < 0 && dy > -16 && dx.abs() < -dy) {
// // // //             isArrow = true;
// // // //           }

// // // //           // Arrow border
// // // //           if (dx.abs() < 10 && dy > -2 && dy < 26 && !isArrow) {
// // // //             isArrowBorder = true;
// // // //           }

// // // //           if (dy < 2 && dy > -18 && dx.abs() < (-dy + 2) && !isArrow) {
// // // //             isArrowBorder = true;
// // // //           }

// // // //           int pixelIndex = (y * size + x) * 4;
// // // //           if (isArrow) {
// // // //             // Blue fill for the arrow
// // // //             data[pixelIndex] = 72; // R
// // // //             data[pixelIndex + 1] = 130; // G
// // // //             data[pixelIndex + 2] = 196; // B
// // // //             data[pixelIndex + 3] = 255; // A
// // // //           } else if (isArrowBorder) {
// // // //             // White border for the arrow
// // // //             data[pixelIndex] = 255; // R
// // // //             data[pixelIndex + 1] = 255; // G
// // // //             data[pixelIndex + 2] = 255; // B
// // // //             data[pixelIndex + 3] = 255; // A
// // // //           } else {
// // // //             // Transparent
// // // //             data[pixelIndex + 3] = 0; // A
// // // //           }
// // // //         }
// // // //       }

// // // //       // Create MbxImage from the Uint8List
// // // //       final MbxImage arrowImage = MbxImage(
// // // //         width: size,
// // // //         height: size,
// // // //         data: data,
// // // //       );

// // // //       // Add the image to the map style
// // // //       await _mapboxMap!.style.addStyleImage(
// // // //         "arrow", // imageId
// // // //         1.0, // scale
// // // //         arrowImage, // image
// // // //         false, // sdf
// // // //         [], // stretchX
// // // //         [], // stretchY
// // // //         null, // content
// // // //       );

// // // //       print('Arrow image added to map successfully');
// // // //     } catch (e) {
// // // //       print('Error adding arrow image to map: $e');
// // // //     }
// // // //   }

// // // //   void _onLocationControllerChanged() {
// // // //     if (_locationController.currentLocation != null) {
// // // //       if (!_layersInitialized) {
// // // //         _initializeMapLayers();
// // // //       } else {
// // // //         // Store previous location and update with new one
// // // //         _previousLocation = _locationController.currentLocation;
// // // //         _updateUserLocationOnMap(_locationController.currentLocation!);

// // // //         // Calculate bearing if we have a previous location
// // // //         if (_previousLocation != null) {
// // // //           _userBearing = _calculateBearing(
// // // //             _previousLocation!.latitude,
// // // //             _previousLocation!.longitude,
// // // //             _locationController.currentLocation!.latitude,
// // // //             _locationController.currentLocation!.longitude,
// // // //           );
// // // //         }
// // // //       }
// // // //     }
// // // //   }

// // // //   void _onNavigationControllerChanged() async {
// // // //     if (!_layersInitialized) {
// // // //       await _initializeMapLayers();
// // // //       // Return and let the next listener update handle displaying the route
// // // //       return;
// // // //     }

// // // //     if (_navigationController.isNavigating) {
// // // //       print(
// // // //         'Navigation state changed - isNavigating: ${_navigationController.isNavigating}',
// // // //       );

// // // //       // Add a slight delay to ensure all data is ready
// // // //       await Future.delayed(const Duration(milliseconds: 300));

// // // //       if (_navigationController.currentRoute != null) {
// // // //         print(
// // // //           'Updating route - points: ${_navigationController.currentRoute!.geometry.length}',
// // // //         );
// // // //         _updateRouteOnMap(_navigationController.currentRoute!);
// // // //       } else {
// // // //         print('Navigation active but route is null!');
// // // //       }

// // // //       if (_navigationController.destination != null) {
// // // //         print(
// // // //           'Updating destination - ${_navigationController.destination!.placeName}',
// // // //         );
// // // //         _updateDestinationOnMap(
// // // //           _navigationController.destination!.latitude,
// // // //           _navigationController.destination!.longitude,
// // // //           _navigationController.destination!.placeName,
// // // //         );
// // // //       }
// // // //     } else {
// // // //       _clearRouteFromMap();
// // // //     }
// // // //   }

// // // //   void _updateUserLocationOnMap(LocationModel location) async {
// // // //     try {
// // // //       if (!_layersInitialized || _mapboxMap == null) return;

// // // //       final Map<String, dynamic> featureCollection = {
// // // //         'type': 'FeatureCollection',
// // // //         'features': [
// // // //           {
// // // //             'type': 'Feature',
// // // //             'geometry': {
// // // //               'type': 'Point',
// // // //               'coordinates': [location.longitude, location.latitude],
// // // //             },
// // // //             'properties': {},
// // // //           },
// // // //         ],
// // // //       };

// // // //       final String geoJsonString = jsonEncode(featureCollection);

// // // //       // Get the source asynchronously
// // // //       final sourceObj = await _mapboxMap!.style.getSource(
// // // //         _userLocationSourceId,
// // // //       );

// // // //       if (sourceObj != null) {
// // // //         // Cast after unwrapping the Future
// // // //         final source = sourceObj as GeoJsonSource;
// // // //         source.updateGeoJSON(geoJsonString);
// // // //       } else {
// // // //         print('User location source not found - reinitializing layers');
// // // //         _layersInitialized = false;
// // // //         await _initializeMapLayers();

// // // //         // Try updating the user location again after reinitializing
// // // //         final newSourceObj = await _mapboxMap!.style.getSource(
// // // //           _userLocationSourceId,
// // // //         );
// // // //         if (newSourceObj != null) {
// // // //           final source = newSourceObj as GeoJsonSource;
// // // //           source.updateGeoJSON(geoJsonString);
// // // //         }
// // // //       }

// // // //       // Update direction arrow
// // // //       _updateDirectionArrow(location);

// // // //       // Move camera if in following mode
// // // //       if (_isFollowingUser) {
// // // //         _goToCurrentLocationWithBearing();
// // // //       }
// // // //     } catch (e) {
// // // //       print('Error updating user location on map: $e');
// // // //     }
// // // //   }

// // // //   void _updateDirectionArrow(LocationModel location) async {
// // // //     if (!_layersInitialized || _mapboxMap == null || !_arrowAdded) return;

// // // //     try {
// // // //       // In a real app, get the bearing from the compass sensor or calculate from locations
// // // //       // For demo purposes, we'll use the calculated bearing or simulate movement
// // // //       if (_previousLocation == null) {
// // // //         // If no previous location, just use the current bearing or simulate
// // // //         _userBearing = (_userBearing + 2) % 360;
// // // //       }

// // // //       // Update the direction arrow
// // // //       final Map<String, dynamic> arrowFeatureCollection = {
// // // //         'type': 'FeatureCollection',
// // // //         'features': [
// // // //           {
// // // //             'type': 'Feature',
// // // //             'geometry': {
// // // //               'type': 'Point',
// // // //               'coordinates': [location.longitude, location.latitude],
// // // //             },
// // // //             'properties': {
// // // //               'bearing': _userBearing, // Arrow direction
// // // //             },
// // // //           },
// // // //         ],
// // // //       };

// // // //       final String arrowGeoJsonString = jsonEncode(arrowFeatureCollection);

// // // //       final arrowSourceObj = await _mapboxMap!.style.getSource(
// // // //         _directionArrowSourceId,
// // // //       );
// // // //       if (arrowSourceObj != null) {
// // // //         final arrowSource = arrowSourceObj as GeoJsonSource;
// // // //         arrowSource.updateGeoJSON(arrowGeoJsonString);
// // // //       }
// // // //     } catch (e) {
// // // //       print('Error updating direction arrow: $e');
// // // //     }
// // // //   }

// // // //   void _updateDestinationOnMap(
// // // //     double latitude,
// // // //     double longitude,
// // // //     String name,
// // // //   ) async {
// // // //     try {
// // // //       if (!_layersInitialized || _mapboxMap == null) return;

// // // //       print('Updating destination: $latitude, $longitude, $name');

// // // //       final Map<String, dynamic> featureCollection = {
// // // //         'type': 'FeatureCollection',
// // // //         'features': [
// // // //           {
// // // //             'type': 'Feature',
// // // //             'geometry': {
// // // //               'type': 'Point',
// // // //               'coordinates': [longitude, latitude],
// // // //             },
// // // //             'properties': {'name': name},
// // // //           },
// // // //         ],
// // // //       };

// // // //       final String geoJsonString = jsonEncode(featureCollection);

// // // //       // Get the source asynchronously
// // // //       final sourceObj = await _mapboxMap!.style.getSource(_destinationSourceId);

// // // //       if (sourceObj != null) {
// // // //         // Cast after unwrapping the Future
// // // //         final source = sourceObj as GeoJsonSource;
// // // //         source.updateGeoJSON(geoJsonString);
// // // //       } else {
// // // //         print('Destination source not found - reinitializing layers');
// // // //         _layersInitialized = false;
// // // //         await _initializeMapLayers();

// // // //         // Try updating the destination again after reinitializing
// // // //         final newSourceObj = await _mapboxMap!.style.getSource(
// // // //           _destinationSourceId,
// // // //         );
// // // //         if (newSourceObj != null) {
// // // //           final source = newSourceObj as GeoJsonSource;
// // // //           source.updateGeoJSON(geoJsonString);
// // // //         }
// // // //       }
// // // //     } catch (e) {
// // // //       print('Error updating destination on map: $e');
// // // //     }
// // // //   }

// // // //   void _updateRouteOnMap(RouteModel route) async {
// // // //     try {
// // // //       if (!_layersInitialized || _mapboxMap == null) return;

// // // //       print('Updating route - points count: ${route.geometry.length}');

// // // //       if (route.geometry.isEmpty) {
// // // //         print('Warning: Route is empty!');
// // // //         return;
// // // //       }

// // // //       final Map<String, dynamic> featureCollection = {
// // // //         'type': 'FeatureCollection',
// // // //         'features': [
// // // //           {
// // // //             'type': 'Feature',
// // // //             'geometry': {'type': 'LineString', 'coordinates': route.geometry},
// // // //             'properties': {},
// // // //           },
// // // //         ],
// // // //       };

// // // //       final String geoJsonString = jsonEncode(featureCollection);

// // // //       // Get the source asynchronously
// // // //       final sourceObj = await _mapboxMap!.style.getSource(_routeSourceId);

// // // //       if (sourceObj != null) {
// // // //         // Cast after unwrapping the Future
// // // //         final source = sourceObj as GeoJsonSource;
// // // //         source.updateGeoJSON(geoJsonString);
// // // //         _fitRouteInView(route.geometry);
// // // //       } else {
// // // //         print('Route source not found - reinitializing layers');
// // // //         _layersInitialized = false;
// // // //         await _initializeMapLayers();

// // // //         // Try updating the route again after reinitializing
// // // //         final newSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
// // // //         if (newSourceObj != null) {
// // // //           final source = newSourceObj as GeoJsonSource;
// // // //           source.updateGeoJSON(geoJsonString);
// // // //           _fitRouteInView(route.geometry);
// // // //         }
// // // //       }
// // // //     } catch (e) {
// // // //       print('Error updating route on map: $e');
// // // //     }
// // // //   }

// // // //   void _fitRouteInView(List<List<double>> coordinates) {
// // // //     if (coordinates.isEmpty || _mapboxMap == null) return;

// // // //     try {
// // // //       double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

// // // //       for (final point in coordinates) {
// // // //         if (point.length < 2) continue;
// // // //         final lng = point[0];
// // // //         final lat = point[1];
// // // //         minLat = minLat > lat ? lat : minLat;
// // // //         maxLat = maxLat < lat ? lat : maxLat;
// // // //         minLng = minLng > lng ? lng : minLng;
// // // //         maxLng = maxLng < lng ? lng : maxLng;
// // // //       }

// // // //       // Add padding to the bounding box
// // // //       final latDelta = (maxLat - minLat) * 0.2;
// // // //       final lngDelta = (maxLng - minLng) * 0.2;

// // // //       final southwest = Point(
// // // //         coordinates: Position(minLng - lngDelta, minLat - latDelta),
// // // //       );
// // // //       final northeast = Point(
// // // //         coordinates: Position(maxLng + lngDelta, maxLat + latDelta),
// // // //       );

// // // //       if (!_isValidCoordinate(southwest.coordinates) ||
// // // //           !_isValidCoordinate(northeast.coordinates)) {
// // // //         print('Invalid coordinates for fitting map');
// // // //         return;
// // // //       }

// // // //       final bounds = CoordinateBounds(
// // // //         southwest: southwest,
// // // //         northeast: northeast,
// // // //         infiniteBounds: false,
// // // //       );

// // // //       _mapboxMap!
// // // //           .cameraForCoordinateBounds(
// // // //             bounds,
// // // //             MbxEdgeInsets(top: 100, left: 50, bottom: 150, right: 50),
// // // //             null,
// // // //             null,
// // // //             null,
// // // //             null,
// // // //           )
// // // //           .then((camera) {
// // // //             _mapboxMap!.flyTo(camera, MapAnimationOptions(duration: 1000));
// // // //           });

// // // //       print('Map zoom adjusted for route');
// // // //     } catch (e) {
// // // //       print('Error adjusting map zoom: $e');
// // // //     }
// // // //   }

// // // //   bool _isValidCoordinate(Position position) {
// // // //     return position.lat >= -90 &&
// // // //         position.lat <= 90 &&
// // // //         position.lng >= -180 &&
// // // //         position.lng <= 180;
// // // //   }

// // // //   void _clearRouteFromMap() async {
// // // //     try {
// // // //       if (!_layersInitialized || _mapboxMap == null) return;

// // // //       print('Clearing route from map');

// // // //       // Get sources asynchronously
// // // //       final routeSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
// // // //       if (routeSourceObj != null) {
// // // //         final routeSource = routeSourceObj as GeoJsonSource;
// // // //         routeSource.updateGeoJSON(_createEmptyLineFeatureCollection());
// // // //       }

// // // //       final destinationSourceObj = await _mapboxMap!.style.getSource(
// // // //         _destinationSourceId,
// // // //       );
// // // //       if (destinationSourceObj != null) {
// // // //         final destinationSource = destinationSourceObj as GeoJsonSource;
// // // //         destinationSource.updateGeoJSON(_createEmptyPointFeatureCollection());
// // // //       }

// // // //       print('Route cleared from map');
// // // //     } catch (e) {
// // // //       print('Error clearing route from map: $e');
// // // //     }
// // // //   }

// // // //   void _goToCurrentLocation() {
// // // //     if (_locationController.currentLocation != null && _mapboxMap != null) {
// // // //       _mapboxMap!.flyTo(
// // // //         CameraOptions(
// // // //           center: Point(
// // // //             coordinates: Position(
// // // //               _locationController.currentLocation!.longitude,
// // // //               _locationController.currentLocation!.latitude,
// // // //             ),
// // // //           ),
// // // //           zoom: 15.0,
// // // //           bearing: 0,
// // // //           pitch: 0,
// // // //         ),
// // // //         MapAnimationOptions(duration: 1000),
// // // //       );
// // // //       print('Moved to current location');
// // // //     } else {
// // // //       _locationController.updateCurrentLocation();
// // // //       print('Attempting to update current location');
// // // //     }
// // // //   }

// // // //   // Toggle between follow mode and normal mode
// // // //   void _toggleFollowMode() {
// // // //     setState(() {
// // // //       _isFollowingUser = !_isFollowingUser;
// // // //       if (_isFollowingUser) {
// // // //         _goToCurrentLocationWithBearing();
// // // //       }
// // // //     });
// // // //   }

// // // //   // Move to current location with camera bearing aligned to user direction
// // // //   void _goToCurrentLocationWithBearing() {
// // // //     if (_locationController.currentLocation != null && _mapboxMap != null) {
// // // //       _mapboxMap!.flyTo(
// // // //         CameraOptions(
// // // //           center: Point(
// // // //             coordinates: Position(
// // // //               _locationController.currentLocation!.longitude,
// // // //               _locationController.currentLocation!.latitude,
// // // //             ),
// // // //           ),
// // // //           zoom: 18.0, // More zoom for close-up view
// // // //           bearing: _userBearing, // Rotate camera to match user direction
// // // //           pitch: 60.0, // Tilt camera for 3D-like view
// // // //         ),
// // // //         MapAnimationOptions(duration: 1000),
// // // //       );
// // // //       print('Moved to current location with bearing: $_userBearing');
// // // //     } else {
// // // //       _locationController.updateCurrentLocation();
// // // //       print('Attempting to update current location for bearing view');
// // // //     }
// // // //   }

// // // //   // Calculate bearing between two points
// // // //   // Calculate bearing between two points
// // // //   double _calculateBearing(
// // // //     double startLat,
// // // //     double startLng,
// // // //     double endLat,
// // // //     double endLng,
// // // //   ) {
// // // //     double latitude1 = startLat * (pi / 180.0);
// // // //     double longitude1 = startLng * (pi / 180.0);
// // // //     double latitude2 = endLat * (pi / 180.0);
// // // //     double longitude2 = endLng * (pi / 180.0);

// // // //     double y = sin(longitude2 - longitude1) * cos(latitude2);
// // // //     double x =
// // // //         cos(latitude1) * sin(latitude2) -
// // // //         sin(latitude1) * cos(latitude2) * cos(longitude2 - longitude1);

// // // //     double bearing = atan2(y, x);
// // // //     bearing = bearing * (180.0 / pi);
// // // //     bearing = (bearing + 360) % 360;

// // // //     return bearing;
// // // //   }

// // // //   void _updateMapStyle() {
// // // //     if (_mapboxMap == null) return;

// // // //     String mapStyle =
// // // //         _storageController.isDarkMode
// // // //             ? AppConstants.nightMapStyle
// // // //             : AppConstants.dayMapStyle;

// // // //     _mapboxMap!.style.setStyleURI(mapStyle);
// // // //     _layersInitialized = false;
// // // //     customLocationAdded = false;
// // // //     _arrowAdded = false;
// // // //     print('Map style updated: $mapStyle');
// // // //   }

// // // //   String _createEmptyPointFeatureCollection() {
// // // //     return '{"type":"FeatureCollection","features":[]}';
// // // //   }

// // // //   String _createEmptyLineFeatureCollection() {
// // // //     return '{"type":"FeatureCollection","features":[]}';
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _cameraUpdateTimer?.cancel(); // Clean up the timer
// // // //     _locationController.removeListener(_onLocationControllerChanged);
// // // //     _navigationController.removeListener(_onNavigationControllerChanged);
// // // //     super.dispose();
// // // //   }
// // // // }
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

// // //   // Añadir variable para controlar el comportamiento de la cámara
// // //   bool _userHasMovedCamera =
// // //       false; // Flag para detectar si el usuario ha movido la cámara manualmente
// // //   Timer?
// // //   _resetUserMovedCameraTimer; // Timer para resetear el flag después de cierto tiempo

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
// // //           // Usando el listener de cambio de cámara disponible
// // //           onCameraChangeListener: _onCameraChanged,
// // //           // Usando el listener de mapa inactivo (idle) disponible
// // //           onMapIdleListener: _onMapIdle,
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

// // //   // Adaptando para usar los eventos disponibles en la API
// // //   void _onCameraChanged(CameraChangedEventData eventData) {
// // //     // Asumimos que un cambio de cámara podría ser iniciado por el usuario
// // //     // Si no estamos en modo seguimiento, consideramos que el usuario está moviendo la cámara
// // //     if (!_isFollowingUser) {
// // //       setState(() {
// // //         _userHasMovedCamera = true;
// // //       });

// // //       // Cancelamos el timer de reset si existe
// // //       _resetUserMovedCameraTimer?.cancel();
// // //     }
// // //   }

// // //   void _onMapIdle(MapIdleEventData eventData) {
// // //     // Cuando el mapa está inactivo (la cámara deja de moverse),
// // //     // configuramos un timer para resetear el flag después de cierto tiempo
// // //     if (_userHasMovedCamera) {
// // //       _resetUserMovedCameraTimer?.cancel();
// // //       _resetUserMovedCameraTimer = Timer(const Duration(seconds: 30), () {
// // //         setState(() {
// // //           _userHasMovedCamera = false;
// // //         });
// // //       });
// // //     }
// // //   }

// // //   void _onMapTap(MapContentGestureContext context) async {
// // //     if (_mapboxMap == null) return;

// // //     // Cuando el usuario toca el mapa, actualizamos el flag
// // //     setState(() {
// // //       _userHasMovedCamera = true;
// // //     });

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
// // //         // Cuando comienza la navegación, resetear el flag de movimiento manual
// // //         // para permitir el ajuste automático inicial de la cámara
// // //         if (isFirstLoad) {
// // //           _userHasMovedCamera = false;
// // //         }
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

// // //         // Solo ajustamos la vista si es la primera carga de la ruta
// // //         // o si el usuario no ha movido la cámara manualmente y no está en modo seguimiento
// // //         if (isFirstLoad || (!_userHasMovedCamera && !_isFollowingUser)) {
// // //           _fitRouteInView(route.geometry);
// // //           isFirstLoad = false;
// // //         }
// // //       } else {
// // //         print('Route source not found - reinitializing layers');
// // //         _layersInitialized = false;
// // //         await _initializeMapLayers();

// // //         // Try updating the route again after reinitializing
// // //         final newSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
// // //         if (newSourceObj != null) {
// // //           final source = newSourceObj as GeoJsonSource;
// // //           source.updateGeoJSON(geoJsonString);

// // //           // Solo ajustamos la vista si es la primera carga
// // //           if (isFirstLoad) {
// // //             _fitRouteInView(route.geometry);
// // //             isFirstLoad = false;
// // //           }
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print('Error updating route on map: $e');
// // //     }
// // //   }

// // //   void _fitRouteInView(List<List<double>> coordinates) {
// // //     // Si el usuario ha movido la cámara manualmente y no está en modo de seguimiento,
// // //     // no ajustamos la vista automáticamente
// // //     if (_userHasMovedCamera && !_isFollowingUser) {
// // //       return;
// // //     }

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
// // //       // El usuario ha solicitado ir a su ubicación, así que resetear el flag
// // //       _userHasMovedCamera = false;

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
// // //         // Resetear el flag cuando se activa el modo de seguimiento
// // //         _userHasMovedCamera = false;
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
// // //     _resetUserMovedCameraTimer?.cancel(); // No olvidar cancelar este timer
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

// //   // **تعديل**: إضافة متغير لتتبع ما إذا كان المستخدم قد حرك الكاميرا يدويًا
// //   bool _userHasMovedCamera = false;
// //   Timer? _resetUserMovedCameraTimer;

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
// //           // **تعديل**: إضافة مستمعي تغيير الكاميرا والخمول
// //           onCameraChangeListener: _onCameraChanged,
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

// //   // **تعديل**: إضافة مستمع تغيير الكاميرا لتتبع حركة المستخدم اليدوية
// //   void _onCameraChanged(CameraChangedEventData eventData) {
// //     if (!_isFollowingUser) {
// //       setState(() {
// //         _userHasMovedCamera = true;
// //       });
// //       _resetUserMovedCameraTimer?.cancel();
// //     }
// //   }

// //   // **تعديل**: إضافة مستمع خمول الخريطة لإعادة تعيين flag حركة المستخدم
// //   void _onMapIdle(MapIdleEventData eventData) {
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

// //     // **تعديل**: تحديث flag حركة المستخدم عند النقر
// //     setState(() {
// //       _userHasMovedCamera = true;
// //     });

// //     try {
// //       Point point = await _mapboxMap!.coordinateForPixel(
// //         context.point as ScreenCoordinate,
// //       );
// //       Position position = point.coordinates;
// //       double latitude = position.lat.toDouble();
// //       double longitude = position.lng.toDouble();

// //       PlaceModel selectedPlace = PlaceModel(
// //         address: 'الموقع المحدد',
// //         id: 'selected',
// //         placeName: 'الوجهة المحددة',
// //         latitude: latitude,
// //         longitude: longitude,
// //       );

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

// //     _mapboxMap!.location.updateSettings(
// //       LocationComponentSettings(
// //         enabled: true,
// //         pulsingEnabled: true,
// //         showAccuracyRing: true,
// //       ),
// //     );

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

// //     await Future.delayed(const Duration(milliseconds: 500));

// //     await _initializeMapLayers();
// //     _goToCurrentLocation();

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
// //           iconImage: "arrow",
// //           iconSize: 1.5,
// //           iconAllowOverlap: true,
// //           iconIgnorePlacement: true,
// //           iconRotate: _userBearing,
// //         ),
// //       );

// //       await _addArrowImageToMap();

// //       _layersInitialized = true;
// //       _arrowAdded = true;
// //       print('Map layers initialized successfully');

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

// //   Future<void> _addArrowImageToMap() async {
// //     try {
// //       final int size = 64;
// //       final Uint8List data = Uint8List(size * size * 4);

// //       for (int y = 0; y < size; y++) {
// //         for (int x = 0; x < size; x++) {
// //           double centerX = size / 2;
// //           double centerY = size / 2;
// //           double dx = x - centerX;
// //           double dy = y - centerY;

// //           bool isArrow = false;
// //           bool isArrowBorder = false;

// //           if (dx.abs() < 8 && dy > 0 && dy < 24) {
// //             isArrow = true;
// //           }

// //           if (dy < 0 && dy > -16 && dx.abs() < -dy) {
// //             isArrow = true;
// //           }

// //           if (dx.abs() < 10 && dy > -2 && dy < 26 && !isArrow) {
// //             isArrowBorder = true;
// //           }

// //           if (dy < 2 && dy > -18 && dx.abs() < (-dy + 2) && !isArrow) {
// //             isArrowBorder = true;
// //           }

// //           int pixelIndex = (y * size + x) * 4;
// //           if (isArrow) {
// //             data[pixelIndex] = 72;
// //             data[pixelIndex + 1] = 130;
// //             data[pixelIndex + 2] = 196;
// //             data[pixelIndex + 3] = 255;
// //           } else if (isArrowBorder) {
// //             data[pixelIndex] = 255;
// //             data[pixelIndex + 1] = 255;
// //             data[pixelIndex + 2] = 255;
// //             data[pixelIndex + 3] = 255;
// //           } else {
// //             data[pixelIndex + 3] = 0;
// //           }
// //         }
// //       }

// //       final MbxImage arrowImage = MbxImage(
// //         width: size,
// //         height: size,
// //         data: data,
// //       );

// //       await _mapboxMap!.style.addStyleImage(
// //         "arrow",
// //         1.0,
// //         arrowImage,
// //         false,
// //         [],
// //         [],
// //         null,
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
// //         _previousLocation = _locationController.currentLocation;
// //         _updateUserLocationOnMap(_locationController.currentLocation!);

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
// //       return;
// //     }

// //     if (_navigationController.isNavigating) {
// //       print(
// //         'Navigation state changed - isNavigating: ${_navigationController.isNavigating}',
// //       );

// //       await Future.delayed(const Duration(milliseconds: 300));

// //       if (_navigationController.currentRoute != null) {
// //         print(
// //           'Updating route - points: ${_navigationController.currentRoute!.geometry.length}',
// //         );
// //         // **تعديل**: إعادة تعيين flag حركة المستخدم عند تحميل روت جديد
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

// //       final sourceObj = await _mapboxMap!.style.getSource(
// //         _userLocationSourceId,
// //       );

// //       if (sourceObj != null) {
// //         final source = sourceObj as GeoJsonSource;
// //         source.updateGeoJSON(geoJsonString);
// //       } else {
// //         print('User location source not found - reinitializing layers');
// //         _layersInitialized = false;
// //         await _initializeMapLayers();

// //         final newSourceObj = await _mapboxMap!.style.getSource(
// //           _userLocationSourceId,
// //         );
// //         if (newSourceObj != null) {
// //           final source = newSourceObj as GeoJsonSource;
// //           source.updateGeoJSON(geoJsonString);
// //         }
// //       }

// //       _updateDirectionArrow(location);

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
// //       if (_previousLocation == null) {
// //         _userBearing = (_userBearing + 2) % 360;
// //       }

// //       final Map<String, dynamic> arrowFeatureCollection = {
// //         'type': 'FeatureCollection',
// //         'features': [
// //           {
// //             'type': 'Feature',
// //             'geometry': {
// //               'type': 'Point',
// //               'coordinates': [location.longitude, location.latitude],
// //             },
// //             'properties': {'bearing': _userBearing},
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

// //       final sourceObj = await _mapboxMap!.style.getSource(_destinationSourceId);

// //       if (sourceObj != null) {
// //         final source = sourceObj as GeoJsonSource;
// //         source.updateGeoJSON(geoJsonString);
// //       } else {
// //         print('Destination source not found - reinitializing layers');
// //         _layersInitialized = false;
// //         await _initializeMapLayers();

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

// //       final sourceObj = await _mapboxMap!.style.getSource(_routeSourceId);

// //       if (sourceObj != null) {
// //         final source = sourceObj as GeoJsonSource;
// //         source.updateGeoJSON(geoJsonString);

// //         // **تعديل**: استخدام _positionCameraBehindUser بدلاً من _fitRouteInView
// //         // لضبط الكاميرا خلف المستخدم عند تحميل الروت
// //         if (isFirstLoad || (!_userHasMovedCamera && !_isFollowingUser)) {
// //           if (_locationController.currentLocation != null) {
// //             _positionCameraBehindUser(
// //               _locationController.currentLocation!,
// //               route,
// //             );
// //           }
// //           isFirstLoad = false;
// //         }
// //       } else {
// //         print('Route source not found - reinitializing layers');
// //         _layersInitialized = false;
// //         await _initializeMapLayers();

// //         final newSourceObj = await _mapboxMap!.style.getSource(_routeSourceId);
// //         if (newSourceObj != null) {
// //           final source = newSourceObj as GeoJsonSource;
// //           source.updateGeoJSON(geoJsonString);

// //           if (isFirstLoad && _locationController.currentLocation != null) {
// //             _positionCameraBehindUser(
// //               _locationController.currentLocation!,
// //               route,
// //             );
// //             isFirstLoad = false;
// //           }
// //         }
// //       }
// //     } catch (e) {
// //       print('Error updating route on map: $e');
// //     }
// //   }

// //   // **تعديل**: إضافة دالة جديدة لضبط الكاميرا خلف المستخدم مع إظهار الروت أمامه
// //   void _positionCameraBehindUser(LocationModel userLocation, RouteModel route) {
// //     if (_mapboxMap == null || route.geometry.isEmpty) return;

// //     try {
// //       // موقع المستخدم
// //       double userLat = userLocation.latitude;
// //       double userLng = userLocation.longitude;

// //       // اتجاه المستخدم
// //       double bearing = _userBearing;

// //       // إزاحة الكاميرا لتكون خلف المستخدم
// //       const double offsetDistance = 0.001; // ~100 متر
// //       double offsetLat = offsetDistance * cos((bearing + 180) * pi / 180);
// //       double offsetLng = offsetDistance * sin((bearing + 180) * pi / 180);

// //       // مركز الكاميرا خلف المستخدم
// //       Point cameraCenter = Point(
// //         coordinates: Position(userLng + offsetLng, userLat + offsetLat),
// //       );

// //       // ضبط الكاميرا
// //       _mapboxMap!.flyTo(
// //         CameraOptions(
// //           center: cameraCenter,
// //           zoom: 17.0, // زووم مناسب لعرض الروت
// //           bearing: bearing, // تدوير الكاميرا لتتماشى مع اتجاه المستخدم
// //           pitch: 60.0, // إمالة الكاميرا لعرض ثلاثي الأبعاد
// //         ),
// //         MapAnimationOptions(duration: 1000),
// //       );

// //       print('Camera positioned behind user with bearing: $bearing');
// //     } catch (e) {
// //       print('Error positioning camera behind user: $e');
// //     }
// //   }

// //   void _fitRouteInView(List<List<double>> coordinates) {
// //     // **تعديل**: إضافة التحقق من _userHasMovedCamera لتجنب ضبط الكاميرا إذا تحرك المستخدم
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
// //       // **تعديل**: إعادة تعيين flag حركة المستخدم عند طلب الانتقال إلى الموقع الحالي
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

// //   void _toggleFollowMode() {
// //     setState(() {
// //       _isFollowingUser = !_isFollowingUser;
// //       if (_isFollowingUser) {
// //         // **تعديل**: إعادة تعيين flag حركة المستخدم عند تفعيل وضع المتابعة
// //         _userHasMovedCamera = false;
// //         _goToCurrentLocationWithBearing();
// //       }
// //     });
// //   }

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
// //           zoom: 18.0,
// //           bearing: _userBearing,
// //           pitch: 60.0,
// //         ),
// //         MapAnimationOptions(duration: 1000),
// //       );
// //       print('Moved to current location with bearing: $_userBearing');
// //     } else {
// //       _locationController.updateCurrentLocation();
// //       print('Attempting to update current location for bearing view');
// //     }
// //   }

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
// //     _cameraUpdateTimer?.cancel();
// //     // **تعديل**: إلغاء مؤقت إعادة تعيين flag حركة المستخدم
// //     _resetUserMovedCameraTimer?.cancel();
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
// import 'place_details_widget.dart';

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

//     // تحقق أولاً إذا كان المستخدم نقر على مكان أو معلم
//     bool tappedOnPlace = await _checkAndHandlePlaceTap(context);

//     // إذا كان قد نقر على مكان، لا تتعامل معه كاختيار للوجهة
//     if (tappedOnPlace) return;

//     // استكمال كود اختيار الوجهة الحالي...
//   }

//   Future<bool> _checkAndHandlePlaceTap(MapContentGestureContext context) async {
//     if (_mapboxMap == null) return false;

//     try {
//       // Convert screen coordinate to map coordinate
//       final screenCoordinate = context.point as ScreenCoordinate;
//       final point = await _mapboxMap!.coordinateForPixel(screenCoordinate);

//       // Get current position for creating a place
//       final double latitude = point.coordinates.lat.toDouble();
//       final double longitude = point.coordinates.lng.toDouble();

//       // Since we're having trouble with the feature query, let's create a place at the tap location
//       final PlaceModel place = PlaceModel(
//         id: 'place_${DateTime.now().millisecondsSinceEpoch}',
//         placeName:
//             'Selected Location', // We'll update this if we can get more info
//         address: 'Loading address...',
//         latitude: latitude,
//         longitude: longitude,
//         properties: {}, // Empty properties since we can't extract them
//       );

//       // Get address using reverse geocoding
//       final String? address = await _locationController
//           .getAddressFromCoordinates(latitude, longitude);

//       // Try to get a better name for the place using the address
//       String placeName = 'Selected Location';
//       if (address != null && address.isNotEmpty) {
//         final addressParts = address.split(',');
//         if (addressParts.isNotEmpty) {
//           placeName = addressParts[0].trim();
//         }
//       }

//       final updatedPlace = place.copyWith(
//         address: address ?? "Address not available",
//         placeName: placeName,
//       );

//       // Show place details
//       _showPlaceDetails(updatedPlace);

//       return true;
//     } catch (e) {
//       print('Error checking for place tap: $e');
//       return false;
//     }
//   }

//   // طريقة لعرض تفاصيل المكان
//   void _showPlaceDetails(PlaceModel place) {
//     if (!mounted) return;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder:
//           (context) => FractionallySizedBox(
//             heightFactor: 0.85,
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
//               child: Container(
//                 color: Theme.of(context).colorScheme.surface,
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom,
//                   ),
//                   child: PlaceDetailsWidget(
//                     place: place,
//                     onClose: () => Navigator.of(context).pop(),
//                     onNavigate: () {
//                       // إغلاق النافذة المنبثقة
//                       Navigator.of(context).pop();

//                       // بدء التنقل إذا كان الموقع متاحًا
//                       if (_locationController.currentLocation != null) {
//                         _navigationController.startNavigation(
//                           place,
//                           _locationController.currentLocation!,
//                         );
//                       } else {
//                         // عرض رسالة خطأ
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('لم يتم تحديد موقعك الحالي'),
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//     );
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

//   void fitRouteInView(List<List<double>> coordinates) {
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

  // معرفات طبقات الخريطة
  final String _routeLayerId = 'route-layer';
  final String _routeSourceId = 'route-source';
  final String _userLocationSourceId = 'user-location-source';
  final String _userLocationLayerId = 'user-location-layer';
  final String _destinationSourceId = 'destination-source';
  final String _destinationLayerId = 'destination-layer';
  final String _destinationCircleLayerId = 'destination-circle-layer';
  final String _placesSourceId = 'places-source';
  final String _placesLayerId = 'places-layer';
  final String _placesSymbolLayerId = 'places-symbol-layer';
  final String _buildingsSourceId = 'buildings-source';
  final String buildingsLayerId = 'buildings-layer';
  final String _buildingsExtrusionLayerId = 'buildings-extrusion-layer';
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
  Future<void> _loadVisiblePlaces() async {
    if (_mapboxMap == null || !_layersInitialized) return;

    try {
      // الحصول على حدود الخريطة المرئية

      double lat = await _mapboxMap!.getCameraState().then(
        (state) => state.center.coordinates.lat.toDouble(),
      );
      double lng = await _mapboxMap!.getCameraState().then(
        (state) => state.center.coordinates.lng.toDouble(),
      );

      // استخدام الموقع الحالي كمركز للبحث
      final results = await _mapboxService.searchPlaces(
        '', // بحث فارغ للحصول على الأماكن القريبة
        nearLat: lat,
        nearLng: lng,
      );

      _visiblePlaces = results;

      // تحديث طبقة الأماكن على الخريطة
      _updatePlacesOnMap(_visiblePlaces);
    } catch (e) {
      print('Error loading visible places: $e');
    }
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

    // تمكين تتبع الموقع
    _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );

    // بدء تحديثات الكاميرا الدورية إذا كان تتبع موقع المستخدم مفعلاً
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

    // ضمان تهيئة الطبقات عند تحميل النمط
    await Future.delayed(const Duration(milliseconds: 500));

    await _initializeMapLayers();
    _goToCurrentLocation();

    // تحميل الأماكن المرئية بعد تهيئة الطبقات
    _loadVisiblePlaces();

    // التحقق مما إذا كان هناك تنقل نشط وتحديث الخريطة وفقاً لذلك
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

      // إضافة مصدر وطبقات موقع المستخدم
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

        // تحديث الأماكن عند تغير الموقع إذا لم يحرك المستخدم الكاميرا
        if (!_userHasMovedCamera && _placesAdded) {
          _loadVisiblePlaces();
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
        // إعادة تعيين flag حركة المستخدم عند تحميل روت جديد
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

      // البحث عن المباني القريبة إذا كان المستخدم قريبًا بما فيه الكفاية
      if (_buildingsAdded && _mapboxMap != null) {
        final zoom = await _mapboxMap!.getCameraState().then(
          (state) => state.zoom,
        );
        // تحميل المباني فقط عند مستوى التكبير العالي
        if (zoom > 17) {
          _loadNearbyBuildings(location);
        }
      }
    } catch (e) {
      print('Error updating user location on map: $e');
    }
  }

  // تحميل المباني القريبة
  Future<void> _loadNearbyBuildings(LocationModel location) async {
    try {
      // استخدام خدمة Mapbox للبحث عن المباني القريبة
      final buildings = await _mapboxService.searchPlaces(
        'building', // البحث عن كلمة "مبنى"
        nearLat: location.latitude,
        nearLng: location.longitude,
      );

      // فلترة المباني بناءً على الخصائص
      final filteredBuildings =
          buildings.where((place) {
            // تضمين الأماكن التي تحتوي كلمة مبنى أو مدخل أو قاعة في اسمها أو عنوانها
            final name = place.placeName.toLowerCase();
            final address = place.address.toLowerCase();
            return name.contains('مبنى') ||
                name.contains('مدخل') ||
                name.contains('بوابة') ||
                name.contains('قاعة') ||
                address.contains('مبنى');
          }).toList();

      // في حالة وجود مباني، قم بتحديث طبقة المباني
      if (filteredBuildings.isNotEmpty) {
        _updateBuildingsOnMap(filteredBuildings);
      }
    } catch (e) {
      print('Error loading nearby buildings: $e');
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

        // استخدام _positionCameraBehindUser بدلاً من _fitRouteInView
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

  // تبديل عرض المباني ثلاثية الأبعاد
  void _toggleBuildingsView() async {
    if (_mapboxMap == null) return;

    setState(() {
      _buildingsAdded = !_buildingsAdded;
    });

    if (_buildingsAdded) {
      await _addBuildingsToMap();
    } else {
      await _removeBuildingsFromMap();
    }
  }

  // إضافة طبقة المباني ثلاثية الأبعاد
  Future<void> _addBuildingsToMap() async {
    if (_mapboxMap == null) return;

    try {
      // التحقق مما إذا كانت طبقة المباني موجودة بالفعل
      bool hasBuildingsSource = false;
      try {
        final source = await _mapboxMap!.style.getSource(_buildingsSourceId);
        hasBuildingsSource = source != null;
      } catch (e) {
        hasBuildingsSource = false;
      }

      if (!hasBuildingsSource) {
        // إضافة مصدر بيانات المباني
        await _mapboxMap!.style.addSource(
          GeoJsonSource(
            id: _buildingsSourceId,
            data: '{"type":"FeatureCollection","features":[]}',
          ),
        );

        // إضافة طبقة المباني ثلاثية الأبعاد
        await _mapboxMap!.style.addLayer(
          FillExtrusionLayer(
            id: _buildingsExtrusionLayerId,
            sourceId: _buildingsSourceId,
            fillExtrusionColor: 0xFFAFB4BA, // لون رمادي فاتح
            fillExtrusionOpacity: 0.7,
            fillExtrusionHeight: 10, // ارتفاع المباني
            fillExtrusionBase: 0,
          ),
        );
      }

      // تفعيل خاصية المباني ثلاثية الأبعاد في Mapbox
      await _mapboxMap!.style.setStyleJSON(
        """
        {
          "layers": [
            {
              "id": "3d-buildings",
              "source": "composite",
              "source-layer": "building",
              "type": "fill-extrusion",
              "minzoom": 15,
              "paint": {
                "fill-extrusion-color": "#aaa",
                "fill-extrusion-height": ["get", "height"],
                "fill-extrusion-base": ["get", "min_height"],
                "fill-extrusion-opacity": 0.7
              }
            }
          ]
        }
        """,
        // دمج مع النمط الحالي
      );

      print('3D Buildings layer added to map');
    } catch (e) {
      print('Error adding buildings to map: $e');
    }
  }

  // إزالة طبقة المباني
  Future<void> _removeBuildingsFromMap() async {
    if (_mapboxMap == null) return;

    try {
      // التحقق من وجود طبقة المباني
      try {
        await _mapboxMap!.style.removeStyleLayer(_buildingsExtrusionLayerId);
        await _mapboxMap!.style.removeStyleSource(_buildingsSourceId);

        // إزالة طبقة مباني Mapbox الافتراضية
        await _mapboxMap!.style.removeStyleLayer("3d-buildings");
      } catch (e) {
        // قد لا توجد الطبقة، تجاهل الخطأ
      }

      print('3D Buildings layer removed from map');
    } catch (e) {
      print('Error removing buildings from map: $e');
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
  Future<void> _searchBuildingsInPlace(PlaceModel place) async {
    if (!_layersInitialized || _mapboxMap == null) return;

    try {
      // استخدام اسم المكان في البحث للحصول على المباني الداخلية
      final buildings = await _mapboxService.searchPlaces(
        '${place.placeName} مبنى',
        nearLat: place.latitude,
        nearLng: place.longitude,
      );

      // فلترة النتائج للتأكد من أنها مباني داخل المكان
      final filteredBuildings =
          buildings.where((building) {
            final buildingName = building.placeName.toLowerCase();
            final buildingAddress = building.address.toLowerCase();
            final placeName = place.placeName.toLowerCase();

            // تحقق من أن المبنى مرتبط بالمكان
            return buildingName.contains(placeName) ||
                buildingAddress.contains(placeName);
          }).toList();

      // إضافة المباني إلى الخريطة إذا تم العثور على أي منها
      if (filteredBuildings.isNotEmpty) {
        // إضافة المباني إلى قائمة الأماكن المرئية
        _visiblePlaces.addAll(filteredBuildings);
        _updatePlacesOnMap(_visiblePlaces);

        if (_buildingsAdded) {
          _updateBuildingsOnMap(filteredBuildings);
        }

        // ضبط الخريطة لعرض جميع المباني
        _fitPlacesInView(filteredBuildings);
      }

      // إخبار المستخدم بعدد المباني التي تم العثور عليها
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم العثور على ${filteredBuildings.length} مبنى داخل ${place.placeName}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error searching buildings in place: $e');
    }
  }

  // ضبط حدود الخريطة لعرض جميع الأماكن
  void _fitPlacesInView(List<PlaceModel> places) {
    if (places.isEmpty || _mapboxMap == null) return;

    try {
      double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

      // العثور على الحدود التي تشمل جميع المواقع
      for (final place in places) {
        final lat = place.latitude;
        final lng = place.longitude;

        minLat = minLat > lat ? lat : minLat;
        maxLat = maxLat < lat ? lat : maxLat;
        minLng = minLng > lng ? lng : minLng;
        maxLng = maxLng < lng ? lng : maxLng;
      }

      // إضافة هامش للحدود
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

      print('Map adjusted to show all places');
    } catch (e) {
      print('Error fitting places in view: $e');
    }
  }

  bool _isValidCoordinate(Position position) {
    return position.lat >= -90 &&
        position.lat <= 90 &&
        position.lng >= -180 &&
        position.lng <= 180;
  }

  void _updateMapStyle() {
    if (_mapboxMap == null) return;

    String mapStyle =
        _storageController.isDarkMode
            ? AppConstants.nightMapStyle
            : AppConstants.dayMapStyle;

    _mapboxMap!.style.setStyleURI(mapStyle);
    _layersInitialized = false;
    _placesAdded = false;
    _buildingsAdded = false;
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
    _resetUserMovedCameraTimer?.cancel();
    _locationController.removeListener(_onLocationControllerChanged);
    _navigationController.removeListener(_onNavigationControllerChanged);
    super.dispose();
  }
}
