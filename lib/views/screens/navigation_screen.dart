import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_map.dart';
import '../widgets/navigation_info.dart';
import '../widgets/voice_button.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/speech_controller.dart';
import '../../models/place_model.dart';

class NavigationScreen extends StatefulWidget {
  final PlaceModel destination;

  const NavigationScreen({super.key, required this.destination});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    final navigationController = Provider.of<NavigationController>(context);

    return Scaffold(
      body: Stack(
        children: [
          // الخريطة
          const CustomMap(),

          // شريط العنوان
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: .9),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _handleBackPress,
                    ),
                    Expanded(
                      child: Text(
                        'التنقل إلى ${widget.destination.placeName}',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        navigationController.stopNavigation();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // معلومات التنقل
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: NavigationInfo(
              onClose: () {
                navigationController.stopNavigation();
                Navigator.of(context).pop();
              },
            ),
          ),

          // زر الأوامر الصوتية
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(child: VoiceButton(onCommand: _handleVoiceCommand)),
          ),

          // مؤشر جاري التحميل
          if (navigationController.isLoading)
            Container(
              color: Colors.black.withValues(alpha: .2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // معالجة الضغط على زر العودة
  void _handleBackPress() {
    final navigationController = Provider.of<NavigationController>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إيقاف التنقل'),
            content: const Text('هل تريد إيقاف التنقل الحالي؟'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // إغلاق الحوار
                  navigationController.stopNavigation();
                  Navigator.of(context).pop(); // العودة إلى الشاشة السابقة
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('إيقاف التنقل'),
              ),
            ],
          ),
    );
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

    if (speechController.isStopNavigationCommand()) {
      // إيقاف التنقل والعودة إلى الشاشة الرئيسية
      navigationController.stopNavigation();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إيقاف التنقل')));
    } else if (speechController.isShowTimeCommand() ||
        speechController.isShowDistanceCommand() ||
        speechController.isShowETACommand()) {
      // عرض معلومات التنقل
      String info = navigationController.getNavigationInfo();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
    }
  }
}
