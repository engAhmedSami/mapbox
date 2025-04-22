// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_map.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/speech_controller.dart';
import '../../models/place_model.dart';
import '../widgets/navigation_bottom_panel.dart';
import '../widgets/navigation_steps_list.dart';
import '../widgets/turn_by_turn_directions.dart';

class NavigationScreen extends StatefulWidget {
  final PlaceModel destination;

  const NavigationScreen({super.key, required this.destination});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool _showStepsList = false; // Variable to show/hide steps list

  @override
  Widget build(BuildContext context) {
    final navigationController = Provider.of<NavigationController>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Map
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

          // Navigation steps list (shown when tapping the show steps button)
          if (_showStepsList)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: NavigationStepsList(
                onClose: () {
                  setState(() {
                    _showStepsList = false;
                  });
                },
              ),
            ),

          // Bottom navigation panel
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: NavigationBottomPanel(
              onClose: () {
                navigationController.stopNavigation();
                Navigator.of(context).pop();
              },
            ),
          ),

          // Show steps list button
          Positioned(
            bottom: 260,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'btn_show_steps',
              mini: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: () {
                setState(() {
                  _showStepsList = !_showStepsList;
                });
              },
              child: Icon(
                _showStepsList ? Icons.close : Icons.list_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Loading indicator
          if (navigationController.isLoading)
            Container(
              color: Colors.black.withValues(alpha: .2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Handle back button press
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
                  Navigator.pop(context); // Close dialog
                  navigationController.stopNavigation();
                  Navigator.of(context).pop(); // Return to previous screen
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

    if (speechController.isStopNavigationCommand()) {
      // Stop navigation and return to home screen
      navigationController.stopNavigation();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إيقاف التنقل')));
    } else if (speechController.isShowTimeCommand() ||
        speechController.isShowDistanceCommand() ||
        speechController.isShowETACommand()) {
      // Show navigation info
      String info = navigationController.getNavigationInfo();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
    }
  }
}
