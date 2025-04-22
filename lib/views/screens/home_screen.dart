// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../widgets/custom_map.dart';
import '../widgets/search_bar.dart';
import '../widgets/voice_button.dart';
import '../widgets/navigation_info.dart';
import '../widgets/turn_by_turn_directions.dart'; // إضافة استيراد لواجهة خطوات التنقل
import '../../controllers/location_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/speech_controller.dart';
import '../../controllers/storage_controller.dart';
import '../../models/place_model.dart';
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

    // تهيئة المتحكمات عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  // تهيئة جميع المتحكمات
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

    // تهيئة المتحكمات بالترتيب
    await storageController.initialize();
    await locationController.initialize();
    await speechController.initialize();

    // بدء تتبع الموقع
    locationController.startLocationTracking();

    // تهيئة متحكم التنقل بعد الحصول على الموقع الحالي
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

  // معالجة الأوامر الصوتية
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

    // التصرف بناءً على نوع الأمر
    if (command.startsWith('ابحث عن')) {
      // استخراج نص البحث
      String? searchQuery = speechController.extractSearchQuery();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        _navigateToSearchScreen(initialQuery: searchQuery);
      }
    } else if (speechController.isStartNavigationCommand()) {
      // الانتقال إلى شاشة البحث لاختيار وجهة
      _navigateToSearchScreen();
    } else if (speechController.isStopNavigationCommand()) {
      // إيقاف التنقل الحالي
      if (navigationController.isNavigating) {
        navigationController.stopNavigation();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إيقاف التنقل')));
      }
    } else if (speechController.isShowTimeCommand() ||
        speechController.isShowDistanceCommand() ||
        speechController.isShowETACommand()) {
      // عرض معلومات التنقل الحالية
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
  }

  // الانتقال إلى شاشة البحث
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

  // معالجة اختيار مكان
  void _handlePlaceSelection(PlaceModel place) async {
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

    // الحصول على الموقع الحالي
    LocationModel? currentLocation = locationController.currentLocation;
    if (currentLocation == null) {
      // محاولة تحديث الموقع إذا كان فارغًا
      await locationController.updateCurrentLocation();
      currentLocation = locationController.currentLocation;

      if (currentLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('غير قادر على تحديد موقعك الحالي')),
        );
        return;
      }
    }

    // بدء التنقل
    bool success = await navigationController.startNavigation(
      place,
      currentLocation,
    );

    if (success) {
      // حفظ المكان في البحث الأخير
      await storageController.saveRecentSearch(place);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بدء التنقل إلى ${place.placeName}')),
      );

      // الانتقال إلى شاشة التنقل
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(destination: place),
        ),
      );
    } else {
      // عرض رسالة خطأ
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

  // مسح الكاش
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
          // الخريطة الأساسية
          const CustomMap(),

          // واجهة خطوات التنقل في الجزء العلوي
          if (navigationController.isNavigating &&
              navigationController.nextStep != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: TurnByTurnDirections()),
            ),

          // البحث في الجزء العلوي
          Positioned(
            top:
                navigationController.isNavigating &&
                        navigationController.nextStep != null
                    ? 170 // ضبط المسافة عند ظهور واجهة خطوات التنقل
                    : MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Column(
                children: [
                  // شريط البحث
                  CustomSearchBar(
                    onPlaceSelected: (place) {
                      _handlePlaceSelection(place);
                    },
                  ),

                  // بيانات التنقل الحالية (تظهر فقط أثناء التنقل وعندما لا تظهر واجهة خطوات التنقل)
                  if (navigationController.isNavigating &&
                      navigationController.nextStep == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: NavigationInfo(
                        onClose: () {
                          navigationController.stopNavigation();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // زر الأوامر الصوتية
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(child: VoiceButton(onCommand: _handleVoiceCommand)),
          ),

          // زر المفضلة والبحث الأخير
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

          // زر مسح الكاش
          Positioned(
            top:
                navigationController.isNavigating &&
                        navigationController.nextStep != null
                    ? 186 // ضبط المسافة عند ظهور واجهة خطوات التنقل
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

          // مؤشر جاري التحميل
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
