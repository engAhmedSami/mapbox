import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'config/app_constants.dart';
import 'config/theme.dart';
import 'views/screens/home_screen.dart';
import 'controllers/location_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/speech_controller.dart';
import 'controllers/storage_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Check and log Mapbox token
  final mapboxToken = AppConstants.mapboxAccessToken;
  if (mapboxToken.isNotEmpty) {
    log('Mapbox token found: ${mapboxToken.substring(0, 5)}...');
    MapboxOptions.setAccessToken(mapboxToken);
  } else {
    log('ERROR: Mapbox access token not found in .env file');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationController()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => SpeechController()),
        ChangeNotifierProvider(create: (_) => StorageController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // الحصول على حالة الوضع الداكن من المخزن
    final storageController = Provider.of<StorageController>(context);

    return MaterialApp(
      title: 'تطبيق التنقل باستخدام Mapbox',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          storageController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      builder: (context, child) {
        // تهيئة اتجاه التطبيق من اليمين إلى اليسار للغة العربية
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
  }
}
