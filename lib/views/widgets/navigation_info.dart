import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/navigation_controller.dart';
import 'package:intl/intl.dart';

class NavigationInfo extends StatelessWidget {
  final VoidCallback? onClose;

  const NavigationInfo({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationController = Provider.of<NavigationController>(context);

    // إذا لم يكن في وضع التنقل، لا تعرض هذه القطعة
    if (!navigationController.isNavigating) {
      return const SizedBox.shrink();
    }

    // الحصول على بيانات التنقل
    final destination = navigationController.destination;
    final distanceRemaining = navigationController.distanceRemaining;
    final durationRemaining = navigationController.durationRemaining;
    final eta = navigationController.estimatedArrivalTime;

    // تنسيق المسافة
    String formattedDistance = '';
    if (distanceRemaining < 1000) {
      formattedDistance = '${distanceRemaining.round()} م';
    } else {
      formattedDistance = '${(distanceRemaining / 1000).toStringAsFixed(1)} كم';
    }

    // تنسيق الوقت المتبقي
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

    // تنسيق وقت الوصول المقدر
    String formattedETA = '';
    if (eta != null) {
      formattedETA = DateFormat('HH:mm').format(eta);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط العنوان
          Row(
            children: [
              Expanded(
                child: Text(
                  'التنقل إلى ${destination?.placeName ?? 'الوجهة'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed:
                    onClose ??
                    () {
                      navigationController.stopNavigation();
                    },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const Divider(height: 16),

          // معلومات التنقل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // المسافة المتبقية
              _buildInfoItem(
                context,
                'المسافة',
                formattedDistance,
                Icons.straighten,
              ),

              // الوقت المتبقي
              _buildInfoItem(
                context,
                'الوقت',
                formattedDuration,
                Icons.timelapse,
              ),

              // وقت الوصول المقدر
              _buildInfoItem(
                context,
                'الوصول',
                formattedETA,
                Icons.access_time,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // زر إعادة حساب المسار
          if (navigationController.isNavigating)
            OutlinedButton(
              onPressed: () {
                navigationController.recalculateRoute();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 8),
                  Text('إعادة حساب المسار'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // بناء عنصر معلومات واحد
  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
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
}
