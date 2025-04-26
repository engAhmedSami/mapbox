// lib/views/screens/home_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../../models/place_model.dart';
import '../widgets/custom_map.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/speech_controller.dart';
import '../../controllers/storage_controller.dart';
import '../widgets/navigation_bottom_panel.dart';
import '../widgets/search_bar.dart';
import '../widgets/turn_by_turn_directions.dart';
import '../widgets/voice_button.dart';
import 'search_screen.dart';
import 'navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize controllers when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  // Initialize all controllers
  Future<void> _initializeControllers() async {
    final locationController = Provider.of<LocationController>(
      context,
      listen: false,
    );
    final storageController = Provider.of<StorageController>(
      context,
      listen: false,
    );
    final speechController = Provider.of<SpeechController>(
      context,
      listen: false,
    );

    // Initialize controllers in order
    await storageController.initialize();
    await locationController.initialize();
    await speechController.initialize();

    // Start location tracking
    locationController.startLocationTracking();

    // Initialize navigation controller after getting current location
    if (locationController.currentLocation != null) {
      final navigationController = Provider.of<NavigationController>(
        context,
        listen: false,
      );
      await navigationController.initialize(
        locationController.currentLocation!,
      );
    }
  }

  // Handle voice commands
  void _handleVoiceCommand(String command) {
    final navigationController = Provider.of<NavigationController>(
      context,
      listen: false,
    );
    final speechController = Provider.of<SpeechController>(
      context,
      listen: false,
    );
    Provider.of<StorageController>(context, listen: false);

    // Act based on command type
    if (command.startsWith('ابحث عن')) {
      // Extract search text
      String? searchQuery = speechController.extractSearchQuery();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        _navigateToSearchScreen(initialQuery: searchQuery);
      }
    } else if (speechController.isStartNavigationCommand()) {
      // Go to search screen to choose destination
      _navigateToSearchScreen();
    } else if (speechController.isStopNavigationCommand()) {
      // Stop current navigation
      if (navigationController.isNavigating) {
        navigationController.stopNavigation();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إيقاف التنقل')));
      }
    } else if (speechController.isShowTimeCommand() ||
        speechController.isShowDistanceCommand() ||
        speechController.isShowETACommand()) {
      // Show current navigation info
      if (navigationController.isNavigating) {
        String info = navigationController.getNavigationInfo();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(info)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('لا يوجد تنقل حالي')));
      }
    }
    // لا نحتاج معالجة إضافية هنا لأوامر البحث الصوتي لأن VoiceButton ستعرض النتائج
    // وستستدعي دالة _handleVoicePlaceSelection عند اختيار مكان
  }

  // معالجة اختيار مكان من نتائج البحث الصوتي
  void _handleVoicePlaceSelection(PlaceModel place, String searchType) async {
    // إذا كان نوع البحث هو وجهة أو بحث عام، ابدأ التنقل
    if (searchType.contains('destination') ||
        searchType.contains('nearest_') ||
        searchType == 'general') {
      await _handlePlaceSelection(place);
    }
    // غير ذلك يمكن إضافة سلوك مخصص حسب نوع البحث
    else {
      // للأنواع الأخرى، قد ترغب في عرض تفاصيل المكان أولاً
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم اختيار ${place.placeName}')));
      await _handlePlaceSelection(place);
    }
  }

  // Navigate to search screen
  void _navigateToSearchScreen({String? initialQuery}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SearchScreen(
              initialQuery: initialQuery,
              onPlaceSelected: _handlePlaceSelection,
            ),
      ),
    );
  }

  // Handle place selection
  Future<void> _handlePlaceSelection(PlaceModel place) async {
    final locationController = Provider.of<LocationController>(
      context,
      listen: false,
    );
    final navigationController = Provider.of<NavigationController>(
      context,
      listen: false,
    );
    final storageController = Provider.of<StorageController>(
      context,
      listen: false,
    );

    // Get current location
    LocationModel? currentLocation = locationController.currentLocation;
    if (currentLocation == null) {
      // Try to update location if empty
      await locationController.updateCurrentLocation();
      currentLocation = locationController.currentLocation;

      if (currentLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('غير قادر على تحديد موقعك الحالي')),
        );
        return;
      }
    }

    // Start navigation
    bool success = await navigationController.startNavigation(
      place,
      currentLocation,
    );

    if (success) {
      // Save place in recent searches
      await storageController.saveRecentSearch(place);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بدء التنقل إلى ${place.placeName}')),
      );

      // Navigate to navigation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(destination: place),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            navigationController.errorMessage ?? 'فشل في بدء التنقل',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Clear cache
  void _clearCache() {
    final storageController = Provider.of<StorageController>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('مسح بيانات التطبيق'),
            content: const Text(
              'هل أنت متأكد من رغبتك في مسح جميع بيانات البحث والمواقع المفضلة؟',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await storageController.clearAllData();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم مسح جميع البيانات بنجاح'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('مسح'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Provider.of<LocationController>(context);
    final navigationController = Provider.of<NavigationController>(context);
    Provider.of<SpeechController>(context);
    final storageController = Provider.of<StorageController>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Base map
          const CustomMap(),

          // Turn-by-turn directions at the top
          if (navigationController.isNavigating &&
              navigationController.nextStep != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TurnByTurnDirections(),
            ),

          // Search at the top
          Positioned(
            top:
                navigationController.isNavigating &&
                        navigationController.nextStep != null
                    ? 170 // Adjust distance when turn-by-turn UI is shown
                    : MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: CustomSearchBar(
                onPlaceSelected: (place) {
                  _handlePlaceSelection(place);
                },
              ),
            ),
          ),

          // Bottom navigation panel (only during navigation)
          if (navigationController.isNavigating)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              left: 16,
              right: 16,
              child: NavigationBottomPanel(
                onClose: () {
                  navigationController.stopNavigation();
                },
              ),
            ),

          // Voice command button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(
              child: VoiceButton(
                onCommand: _handleVoiceCommand,
                onPlaceSelected: _handleVoicePlaceSelection,
              ),
            ),
          ),

          // Favorites and recent search button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'btn_favorites',
              onPressed: () {
                _navigateToSearchScreen();
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.history),
            ),
          ),

          // Clear cache button
          Positioned(
            top:
                navigationController.isNavigating &&
                        navigationController.nextStep != null
                    ? 186 // Adjust distance when turn-by-turn UI is shown
                    : MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Visibility(
              visible:
                  storageController.recentSearches.isNotEmpty ||
                  storageController.favoriteLocations.isNotEmpty,
              child: FloatingActionButton.small(
                heroTag: 'btn_clear',
                onPressed: _clearCache,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: .8),
                child: const Icon(Icons.delete_sweep, size: 20),
              ),
            ),
          ),

          // Loading indicator
          if (locationController.isLoading ||
              navigationController.isLoading ||
              storageController.isLoading)
            Container(
              color: Colors.black.withValues(alpha: .2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
