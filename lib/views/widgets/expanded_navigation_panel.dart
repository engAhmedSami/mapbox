import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/navigation_controller.dart';
import 'package:intl/intl.dart';

class ExpandedNavigationPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const ExpandedNavigationPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationController = Provider.of<NavigationController>(context);

    // If not navigating, don't show anything
    if (!navigationController.isNavigating) {
      return const SizedBox.shrink();
    }

    // Get navigation data
    final destination = navigationController.destination;
    final distanceRemaining = navigationController.distanceRemaining;
    final durationRemaining = navigationController.durationRemaining;
    final eta = navigationController.estimatedArrivalTime;
    final nextStep = navigationController.nextStep;
    final distanceToNextStep = navigationController.distanceToNextStep;

    // Format distance
    String formattedDistance = '';
    if (distanceRemaining < 1000) {
      formattedDistance = '${distanceRemaining.round()} م';
    } else {
      formattedDistance = '${(distanceRemaining / 1000).toStringAsFixed(1)} كم';
    }

    // Format duration
    String formattedDuration = '';
    int minutes = (durationRemaining / 60).floor();
    int hours = (minutes / 60).floor();
    minutes = minutes % 60;

    if (hours > 0) {
      formattedDuration =
          '$hours ساعة ${minutes > 0 ? 'و $minutes دقيقة' : ''}';
    } else {
      formattedDuration = '$minutes دقيقة';
    }

    // Format estimated arrival time
    String formattedETA = '';
    if (eta != null) {
      formattedETA = DateFormat('HH:mm').format(eta);
    }

    // Format distance to next step
    String formattedNextStepDistance = '';
    if (distanceToNextStep < 1000) {
      formattedNextStepDistance = '${distanceToNextStep.toStringAsFixed(0)} م';
    } else {
      formattedNextStepDistance =
          '${(distanceToNextStep / 1000).toStringAsFixed(1)} كم';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle for swiping
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Destination Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: .1,
                ),
                child: Icon(Icons.place, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination?.placeName ?? 'الوجهة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (destination?.address != null)
                      Text(
                        destination!.address,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const Divider(height: 24),

          // Next step directions
          if (nextStep != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getDirectionIcon(nextStep),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextStep.getSimpleDirection(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (nextStep.name.isNotEmpty)
                          Text(
                            '${nextStep.name} (بعد $formattedNextStepDistance)',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Navigation stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                context,
                'المسافة',
                formattedDistance,
                Icons.straighten,
              ),
              _buildInfoItem(
                context,
                'الوقت',
                formattedDuration,
                Icons.timelapse,
              ),
              _buildInfoItem(
                context,
                'الوصول',
                formattedETA,
                Icons.access_time,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                'إعادة حساب',
                Icons.refresh,
                () => navigationController.recalculateRoute(),
              ),
              _buildActionButton(context, 'تفاصيل', Icons.list, () {
                // Show detailed route steps
              }),
              _buildActionButton(context, 'إنهاء', Icons.close, () {
                navigationController.stopNavigation();
                if (onClose != null) onClose!();
              }, isDestructive: true),
            ],
          ),
        ],
      ),
    );
  }

  // Build info item with icon, label and value
  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: .08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build action button
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDestructive
                        ? theme.colorScheme.error.withValues(alpha: .1)
                        : theme.colorScheme.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    isDestructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isDestructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get the appropriate icon for a navigation maneuver
  IconData _getDirectionIcon(dynamic step) {
    // This function uses the maneuver type to determine the appropriate icon
    // You would need to extract the maneuver data from your RouteStepModel
    final maneuver = step.maneuver;
    final modifier = step.modifier;

    switch (maneuver) {
      case 'turn':
        if (modifier == 'right') return Icons.turn_right;
        if (modifier == 'left') return Icons.turn_left;
        if (modifier == 'sharp right') return Icons.turn_sharp_right;
        if (modifier == 'sharp left') return Icons.turn_sharp_left;
        if (modifier == 'slight right') return Icons.turn_slight_right;
        if (modifier == 'slight left') return Icons.turn_slight_left;
        return Icons.turn_right;
      case 'straight':
        return Icons.straight;
      case 'merge':
        return Icons.merge_type;
      case 'ramp':
        return Icons.exit_to_app;
      case 'fork':
        return Icons.fork_right;
      case 'roundabout':
        return Icons.roundabout_right;
      case 'exit roundabout':
        return Icons.roundabout_left;
      case 'arrive':
        return Icons.place;
      case 'depart':
        return Icons.directions_car;
      default:
        return Icons.arrow_forward;
    }
  }
}
