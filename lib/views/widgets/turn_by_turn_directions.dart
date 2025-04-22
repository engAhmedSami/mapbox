import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/route_step_model.dart';

class TurnByTurnDirections extends StatelessWidget {
  final VoidCallback? onClose;

  const TurnByTurnDirections({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationController = Provider.of<NavigationController>(context);

    // إذا لم يكن في وضع التنقل، لا تعرض هذه القطعة
    if (!navigationController.isNavigating ||
        navigationController.nextStep == null) {
      return const SizedBox.shrink();
    }

    final nextStep = navigationController.nextStep!;
    final distanceToNextStep = navigationController.distanceToNextStep;

    // تنسيق المسافة
    String formattedDistance = '';
    if (distanceToNextStep < 1000) {
      formattedDistance = '${distanceToNextStep.round()} م';
    } else {
      formattedDistance =
          '${(distanceToNextStep / 1000).toStringAsFixed(1)} كم';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getDirectionIcon(nextStep),
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // معلومات الاتجاه
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // المسافة
                    Text(
                      formattedDistance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // وصف المناورة
                    Text(
                      nextStep.getSimpleDirection(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // اسم الشارع
                    Text(
                      nextStep.name.isNotEmpty ? nextStep.name : 'الطريق',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .9),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // معلومات الوجهة
          if (navigationController.destination != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: .3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // المسافة المتبقية
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'المسافة المتبقية',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          navigationController.distanceRemaining < 1000
                              ? '${navigationController.distanceRemaining.round()} م'
                              : '${(navigationController.distanceRemaining / 1000).toStringAsFixed(1)} كم',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // وقت الوصول المقدر
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'وقت الوصول',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          navigationController.estimatedArrivalTime != null
                              ? '${navigationController.estimatedArrivalTime!.hour.toString().padLeft(2, '0')}:${navigationController.estimatedArrivalTime!.minute.toString().padLeft(2, '0')}'
                              : '--:--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // الوجهة
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'الوجهة',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          navigationController.destination!.placeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // الحصول على أيقونة الاتجاه
  IconData _getDirectionIcon(RouteStepModel step) {
    switch (step.maneuver) {
      case 'turn':
        if (step.modifier == 'right') return Icons.turn_right;
        if (step.modifier == 'left') return Icons.turn_left;
        if (step.modifier == 'sharp right') return Icons.turn_right;
        if (step.modifier == 'sharp left') return Icons.turn_left;
        if (step.modifier == 'slight right') return Icons.turn_slight_right;
        if (step.modifier == 'slight left') return Icons.turn_slight_left;
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
