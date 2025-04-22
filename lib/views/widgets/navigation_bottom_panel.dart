import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/navigation_controller.dart';

class NavigationBottomPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const NavigationBottomPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final navigationController = Provider.of<NavigationController>(context);

    // If not navigating, don't show anything
    if (!navigationController.isNavigating) {
      return const SizedBox.shrink();
    }

    // Get navigation data
    final distanceRemaining = navigationController.distanceRemaining;
    final durationRemaining = navigationController.durationRemaining;

    // Format distance
    String formattedDistance = '';
    if (distanceRemaining < 1000) {
      formattedDistance = '${distanceRemaining.round()}';
    } else {
      formattedDistance = (distanceRemaining / 1000).toStringAsFixed(1);
    }

    // Format duration
    int minutes = (durationRemaining / 60).floor();

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            // This could open a more detailed navigation panel
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade200,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ),

                // Central content - time and distance
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time section
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: 'min ',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: '$minutes',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Separator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "·",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Distance
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: formattedDistance,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: distanceRemaining < 1000 ? ' م' : ' كم',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Expand/Settings button
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade200,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () {
                      // Show expanded navigation info
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
