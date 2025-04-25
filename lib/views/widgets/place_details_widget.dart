import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/location_controller.dart';
import '../../models/place_model.dart';
import '../../services/mapbox_service.dart';

class PlaceDetailsWidget extends StatefulWidget {
  final PlaceModel place;
  final VoidCallback? onClose;
  final VoidCallback? onNavigate;

  const PlaceDetailsWidget({
    super.key,
    required this.place,
    this.onClose,
    this.onNavigate,
  });

  @override
  State<PlaceDetailsWidget> createState() => _PlaceDetailsWidgetState();
}

class _PlaceDetailsWidgetState extends State<PlaceDetailsWidget> {
  final MapboxService _mapboxService = MapboxService();
  bool _isLoading = true;
  Map<String, dynamic>? _placeDetails;
  String? _distance;

  @override
  void initState() {
    super.initState();
    _loadPlaceDetails();
  }

  Future<void> _loadPlaceDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get place details from Mapbox
      final details = await _mapboxService.getPlaceDetails(widget.place.id);

      // Calculate distance from current location
      final locationController = Provider.of<LocationController>(
        context,
        listen: false,
      );

      if (locationController.currentLocation != null) {
        final distanceInMeters = locationController.getDistanceBetweenPoints(
          locationController.currentLocation!.latitude,
          locationController.currentLocation!.longitude,
          widget.place.latitude,
          widget.place.longitude,
        );

        if (distanceInMeters < 1000) {
          _distance = '${distanceInMeters.round()} م';
        } else {
          _distance = '${(distanceInMeters / 1000).toStringAsFixed(1)} كم';
        }
      }

      setState(() {
        _placeDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
          // Header with name and close button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: .1,
                ),
                radius: 24,
                child: Icon(
                  _getCategoryIcon(),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.placeName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.place.address.isNotEmpty)
                      Text(
                        widget.place.address,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const Divider(height: 24),

          // Content
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance info
                if (_distance != null)
                  _buildInfoRow(
                    icon: Icons.directions,
                    title: 'المسافة',
                    value: _distance!,
                  ),

                // Extract and show relevant place details
                _buildPlaceDetailsContent(),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      context: context,
                      icon: Icons.favorite_border,
                      label: 'إضافة للمفضلة',
                      onTap: () {
                        // TODO: Implement adding to favorites
                      },
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.share,
                      label: 'مشاركة',
                      onTap: () {
                        // TODO: Implement sharing
                      },
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.directions,
                      label: 'بدء التنقل',
                      onTap: widget.onNavigate ?? () {},
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Extract and display relevant place information based on the place type
  Widget _buildPlaceDetailsContent() {
    // Extract category from place properties
    String category = '';
    if (_placeDetails != null &&
        _placeDetails!['features'] != null &&
        _placeDetails!['features'].isNotEmpty) {
      final feature = _placeDetails!['features'][0];
      if (feature['properties'] != null &&
          feature['properties']['category'] != null) {
        category = feature['properties']['category'];
      }
    }

    // College or educational institution
    if (category.contains('education') ||
        widget.place.placeName.contains('كلية') ||
        widget.place.placeName.contains('جامعة') ||
        widget.place.placeName.contains('مدرسة')) {
      return _buildEducationalContent();
    }
    // Restaurant or food place
    else if (category.contains('food') ||
        category.contains('restaurant') ||
        widget.place.placeName.contains('مطعم') ||
        widget.place.placeName.contains('كافيه')) {
      return _buildRestaurantContent();
    }
    // Shopping or retail
    else if (category.contains('shop') ||
        category.contains('mall') ||
        widget.place.placeName.contains('سوق') ||
        widget.place.placeName.contains('مول')) {
      return _buildShoppingContent();
    }
    // Hospital or healthcare
    else if (category.contains('hospital') ||
        category.contains('healthcare') ||
        widget.place.placeName.contains('مستشفى') ||
        widget.place.placeName.contains('صحي')) {
      return _buildHealthcareContent();
    }
    // Default content for other places
    else {
      return _buildDefaultContent();
    }
  }

  // Content for educational institutions like colleges and universities
  Widget _buildEducationalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.school,
          title: 'نوع المؤسسة',
          value:
              widget.place.placeName.contains('جامعة')
                  ? 'جامعة'
                  : widget.place.placeName.contains('كلية')
                  ? 'كلية'
                  : widget.place.placeName.contains('مدرسة')
                  ? 'مدرسة'
                  : 'مؤسسة تعليمية',
        ),
        _buildInfoRow(
          icon: Icons.location_on,
          title: 'العنوان',
          value: widget.place.address,
        ),
        _buildInfoRow(
          icon: Icons.access_time,
          title: 'ساعات العمل',
          value: 'من السبت إلى الخميس: 8:00 ص - 4:00 م',
        ),
        _buildInfoRow(
          icon: Icons.phone,
          title: 'رقم الهاتف',
          value: 'غير متوفر',
        ),
        _buildInfoRow(
          icon: Icons.public,
          title: 'الموقع الإلكتروني',
          value: 'غير متوفر',
        ),
      ],
    );
  }

  // Content for restaurants and cafes
  Widget _buildRestaurantContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.restaurant,
          title: 'نوع المطعم',
          value: 'غير متوفر',
        ),
        _buildInfoRow(
          icon: Icons.location_on,
          title: 'العنوان',
          value: widget.place.address,
        ),
        _buildInfoRow(
          icon: Icons.access_time,
          title: 'ساعات العمل',
          value: 'من السبت إلى الجمعة: 10:00 ص - 12:00 م',
        ),
        _buildInfoRow(
          icon: Icons.phone,
          title: 'رقم الهاتف',
          value: 'غير متوفر',
        ),
        _buildInfoRow(icon: Icons.star, title: 'التقييم', value: 'غير متوفر'),
      ],
    );
  }

  // Content for shopping places
  Widget _buildShoppingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.shopping_bag,
          title: 'نوع المتجر',
          value: 'متجر تسوق',
        ),
        _buildInfoRow(
          icon: Icons.location_on,
          title: 'العنوان',
          value: widget.place.address,
        ),
        _buildInfoRow(
          icon: Icons.access_time,
          title: 'ساعات العمل',
          value: 'من السبت إلى الجمعة: 10:00 ص - 10:00 م',
        ),
        _buildInfoRow(
          icon: Icons.phone,
          title: 'رقم الهاتف',
          value: 'غير متوفر',
        ),
      ],
    );
  }

  // Content for healthcare facilities
  Widget _buildHealthcareContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.local_hospital,
          title: 'نوع المنشأة',
          value:
              widget.place.placeName.contains('مستشفى')
                  ? 'مستشفى'
                  : 'منشأة صحية',
        ),
        _buildInfoRow(
          icon: Icons.location_on,
          title: 'العنوان',
          value: widget.place.address,
        ),
        _buildInfoRow(
          icon: Icons.access_time,
          title: 'ساعات العمل',
          value: 'على مدار 24 ساعة',
        ),
        _buildInfoRow(
          icon: Icons.phone,
          title: 'رقم الهاتف',
          value: 'غير متوفر',
        ),
        _buildInfoRow(
          icon: Icons.medical_services,
          title: 'خدمات الطوارئ',
          value: 'متوفرة',
        ),
      ],
    );
  }

  // Default content for other types of places
  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(icon: Icons.category, title: 'النوع', value: 'موقع عام'),
        _buildInfoRow(
          icon: Icons.location_on,
          title: 'العنوان',
          value: widget.place.address,
        ),
        _buildInfoRow(
          icon: Icons.access_time,
          title: 'ساعات العمل',
          value: 'غير متوفر',
        ),
        _buildInfoRow(
          icon: Icons.phone,
          title: 'رقم الهاتف',
          value: 'غير متوفر',
        ),
      ],
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow({
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

  // Helper method to build action buttons
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration:
            isPrimary
                ? BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                )
                : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get icon based on place category
  IconData _getCategoryIcon() {
    final name = widget.place.placeName.toLowerCase();

    if (name.contains('جامعة') ||
        name.contains('كلية') ||
        name.contains('مدرسة')) {
      return Icons.school;
    } else if (name.contains('مستشفى') || name.contains('صحي')) {
      return Icons.local_hospital;
    } else if (name.contains('مطعم') || name.contains('كافيه')) {
      return Icons.restaurant;
    } else if (name.contains('مول') || name.contains('سوق')) {
      return Icons.shopping_bag;
    } else if (name.contains('متحف') || name.contains('معرض')) {
      return Icons.museum;
    } else if (name.contains('فندق')) {
      return Icons.hotel;
    } else if (name.contains('مسجد')) {
      return Icons.mosque;
    } else if (name.contains('حديقة') || name.contains('منتزه')) {
      return Icons.park;
    } else {
      return Icons.place;
    }
  }
}
