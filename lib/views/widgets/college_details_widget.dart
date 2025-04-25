import 'package:flutter/material.dart';
import '../../models/place_model.dart';

class CollegeDetailsWidget extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback? onClose;
  final VoidCallback? onNavigate;

  const CollegeDetailsWidget({
    super.key,
    required this.place,
    this.onClose,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          // Header with college name and close button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: .1,
                ),
                radius: 24,
                child: Icon(Icons.school, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.placeName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (place.address.isNotEmpty)
                      Text(
                        place.address,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
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

          // College information
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // College Type
                  _buildInfoSection(
                    context: context,
                    title: 'معلومات عامة',
                    children: [
                      _buildInfoRow(
                        context: context,
                        icon: Icons.category,
                        title: 'التصنيف',
                        value: _getCollegeType(),
                      ),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.access_time,
                        title: 'ساعات العمل',
                        value: 'من الأحد إلى الخميس: 8:00 ص - 4:00 م',
                      ),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.phone,
                        title: 'رقم الهاتف',
                        value: '+20 2 XXXX XXXX',
                      ),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.language,
                        title: 'الموقع الإلكتروني',
                        value: 'www.example.edu.eg',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Academic Programs
                  _buildInfoSection(
                    context: context,
                    title: 'البرامج الأكاديمية',
                    children: [
                      _buildListItem(context, 'بكالوريوس علوم الحاسب'),
                      _buildListItem(context, 'بكالوريوس نظم المعلومات'),
                      _buildListItem(context, 'بكالوريوس هندسة البرمجيات'),
                      _buildListItem(context, 'ماجستير علوم الحاسب'),
                      _buildListItem(context, 'دكتوراه علوم الحاسب'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Facilities
                  _buildInfoSection(
                    context: context,
                    title: 'المرافق',
                    children: [
                      _buildListItem(context, 'مكتبة'),
                      _buildListItem(context, 'معامل حاسب آلي'),
                      _buildListItem(context, 'كافتيريا'),
                      _buildListItem(context, 'قاعات محاضرات'),
                      _buildListItem(context, 'ملاعب رياضية'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // College Description
                  _buildInfoSection(
                    context: context,
                    title: 'نبذة',
                    children: [
                      Text(
                        'تأسست ${place.placeName} عام 1980، وتعتبر من أهم المؤسسات الأكاديمية في المنطقة. '
                        'توفر الكلية بيئة تعليمية متميزة تجمع بين النظرية والتطبيق، مع التركيز على تطوير مهارات الطلاب '
                        'وإعدادهم لسوق العمل. تضم الكلية نخبة من أعضاء هيئة التدريس المتميزين وتحرص على متابعة أحدث التطورات '
                        'في مجالات التخصص المختلفة.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Important Dates
                  _buildInfoSection(
                    context: context,
                    title: 'تواريخ مهمة',
                    children: [
                      _buildInfoRow(
                        context: context,
                        icon: Icons.event,
                        title: 'بدء الفصل الدراسي',
                        value: '1 أكتوبر 2023',
                      ),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.event,
                        title: 'نهاية الفصل الدراسي',
                        value: '15 يناير 2024',
                      ),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.event,
                        title: 'فترة التسجيل',
                        value: '1 - 15 سبتمبر 2023',
                      ),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.event,
                        title: 'الامتحانات النهائية',
                        value: '15 - 30 يناير 2024',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onNavigate,
              icon: const Icon(Icons.directions),
              label: const Text('بدء التنقل'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Share and favorite buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement share functionality
                },
                icon: const Icon(Icons.share),
                label: const Text('مشاركة'),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement add to favorites
                },
                icon: const Icon(Icons.favorite_border),
                label: const Text('إضافة للمفضلة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build section with title and children
  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  // Helper method to build info row with icon, title, and value
  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: .6),
                    fontSize: 12,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build list item
  Widget _buildListItem(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  // Helper method to determine college type from name
  String _getCollegeType() {
    final lowerName = place.placeName.toLowerCase();

    if (lowerName.contains('جامعة')) {
      return 'جامعة';
    } else if (lowerName.contains('كلية')) {
      return 'كلية';
    } else if (lowerName.contains('معهد')) {
      return 'معهد';
    } else if (lowerName.contains('مدرسة')) {
      return 'مدرسة';
    } else {
      return 'مؤسسة تعليمية';
    }
  }
}
