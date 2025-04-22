import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/navigation_controller.dart';

class NavigationStepsList extends StatelessWidget {
  final VoidCallback? onClose;

  const NavigationStepsList({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationController = Provider.of<NavigationController>(context);

    if (!navigationController.isNavigating ||
        navigationController.currentRoute == null) {
      return const SizedBox.shrink();
    }

    // الحصول على الخطوات
    final directions = navigationController.getStepByStepDirections();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان وزر الإغلاق
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'خطوات التنقل',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),

          const Divider(),

          // الوجهة
          if (navigationController.destination != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.place, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الوجهة',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: .7,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          navigationController.destination!.placeName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (navigationController
                            .destination!
                            .address
                            .isNotEmpty)
                          Text(
                            navigationController.destination!.address,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const Divider(),

          // قائمة الخطوات
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child:
                directions.isEmpty
                    ? Center(
                      child: Text(
                        'لا توجد خطوات متاحة',
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: directions.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final step = directions[index];
                        final isNextStep = step['is_next_step'];
                        final isCurrentStep = step['is_current_step'];

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isNextStep
                                    ? theme.colorScheme.primary.withValues(
                                      alpha: .1,
                                    )
                                    : isCurrentStep
                                    ? theme.colorScheme.surface
                                    : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // الرقم الترتيبي
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color:
                                      isNextStep
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: .1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          isNextStep
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // تفاصيل الخطوة
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step['simple_direction'] ?? '',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight:
                                                isNextStep
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'المسافة: ${step['distance'] ?? ""}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),

                              // علامة الخطوة القادمة
                              if (isNextStep)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'التالية',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
