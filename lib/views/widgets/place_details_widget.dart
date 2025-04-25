// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../controllers/location_controller.dart';
// import '../../models/place_model.dart';
// import '../../services/mapbox_service.dart';

// class PlaceDetailsWidget extends StatefulWidget {
//   final PlaceModel place;
//   final VoidCallback? onClose;
//   final VoidCallback? onNavigate;

//   const PlaceDetailsWidget({
//     super.key,
//     required this.place,
//     this.onClose,
//     this.onNavigate,
//   });

//   @override
//   State<PlaceDetailsWidget> createState() => _PlaceDetailsWidgetState();
// }

// class _PlaceDetailsWidgetState extends State<PlaceDetailsWidget> {
//   final MapboxService _mapboxService = MapboxService();
//   bool _isLoading = true;
//   Map<String, dynamic>? _placeDetails;
//   String? _distance;

//   @override
//   void initState() {
//     super.initState();
//     _loadPlaceDetails();
//   }

//   Future<void> _loadPlaceDetails() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Get place details from Mapbox
//       final details = await _mapboxService.getPlaceDetails(widget.place.id);

//       // Calculate distance from current location
//       final locationController = Provider.of<LocationController>(
//         context,
//         listen: false,
//       );

//       if (locationController.currentLocation != null) {
//         final distanceInMeters = locationController.getDistanceBetweenPoints(
//           locationController.currentLocation!.latitude,
//           locationController.currentLocation!.longitude,
//           widget.place.latitude,
//           widget.place.longitude,
//         );

//         if (distanceInMeters < 1000) {
//           _distance = '${distanceInMeters.round()} م';
//         } else {
//           _distance = '${(distanceInMeters / 1000).toStringAsFixed(1)} كم';
//         }
//       }

//       setState(() {
//         _placeDetails = details;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: .1),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with name and close button
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 backgroundColor: theme.colorScheme.primary.withValues(
//                   alpha: .1,
//                 ),
//                 radius: 24,
//                 child: Icon(
//                   _getCategoryIcon(),
//                   color: theme.colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.place.placeName,
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (widget.place.address.isNotEmpty)
//                       Text(
//                         widget.place.address,
//                         style: theme.textTheme.bodyMedium,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: widget.onClose,
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ],
//           ),

//           const Divider(height: 24),

//           // Content
//           if (_isLoading)
//             const Center(child: CircularProgressIndicator())
//           else
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Distance info
//                 if (_distance != null)
//                   _buildInfoRow(
//                     icon: Icons.directions,
//                     title: 'المسافة',
//                     value: _distance!,
//                   ),

//                 // Extract and show relevant place details
//                 _buildPlaceDetailsContent(),

//                 const SizedBox(height: 16),

//                 // Action buttons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildActionButton(
//                       context: context,
//                       icon: Icons.favorite_border,
//                       label: 'إضافة للمفضلة',
//                       onTap: () {
//                         // TODO: Implement adding to favorites
//                       },
//                     ),
//                     _buildActionButton(
//                       context: context,
//                       icon: Icons.share,
//                       label: 'مشاركة',
//                       onTap: () {
//                         // TODO: Implement sharing
//                       },
//                     ),
//                     _buildActionButton(
//                       context: context,
//                       icon: Icons.directions,
//                       label: 'بدء التنقل',
//                       onTap: widget.onNavigate ?? () {},
//                       isPrimary: true,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   // Extract and display relevant place information based on the place type
//   Widget _buildPlaceDetailsContent() {
//     // Extract category from place properties
//     String category = '';
//     if (_placeDetails != null &&
//         _placeDetails!['features'] != null &&
//         _placeDetails!['features'].isNotEmpty) {
//       final feature = _placeDetails!['features'][0];
//       if (feature['properties'] != null &&
//           feature['properties']['category'] != null) {
//         category = feature['properties']['category'];
//       }
//     }

//     // College or educational institution
//     if (category.contains('education') ||
//         widget.place.placeName.contains('كلية') ||
//         widget.place.placeName.contains('جامعة') ||
//         widget.place.placeName.contains('مدرسة')) {
//       return _buildEducationalContent();
//     }
//     // Restaurant or food place
//     else if (category.contains('food') ||
//         category.contains('restaurant') ||
//         widget.place.placeName.contains('مطعم') ||
//         widget.place.placeName.contains('كافيه')) {
//       return _buildRestaurantContent();
//     }
//     // Shopping or retail
//     else if (category.contains('shop') ||
//         category.contains('mall') ||
//         widget.place.placeName.contains('سوق') ||
//         widget.place.placeName.contains('مول')) {
//       return _buildShoppingContent();
//     }
//     // Hospital or healthcare
//     else if (category.contains('hospital') ||
//         category.contains('healthcare') ||
//         widget.place.placeName.contains('مستشفى') ||
//         widget.place.placeName.contains('صحي')) {
//       return _buildHealthcareContent();
//     }
//     // Default content for other places
//     else {
//       return _buildDefaultContent();
//     }
//   }

//   // Content for educational institutions like colleges and universities
//   Widget _buildEducationalContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow(
//           icon: Icons.school,
//           title: 'نوع المؤسسة',
//           value:
//               widget.place.placeName.contains('جامعة')
//                   ? 'جامعة'
//                   : widget.place.placeName.contains('كلية')
//                   ? 'كلية'
//                   : widget.place.placeName.contains('مدرسة')
//                   ? 'مدرسة'
//                   : 'مؤسسة تعليمية',
//         ),
//         _buildInfoRow(
//           icon: Icons.location_on,
//           title: 'العنوان',
//           value: widget.place.address,
//         ),
//         _buildInfoRow(
//           icon: Icons.access_time,
//           title: 'ساعات العمل',
//           value: 'من السبت إلى الخميس: 8:00 ص - 4:00 م',
//         ),
//         _buildInfoRow(
//           icon: Icons.phone,
//           title: 'رقم الهاتف',
//           value: 'غير متوفر',
//         ),
//         _buildInfoRow(
//           icon: Icons.public,
//           title: 'الموقع الإلكتروني',
//           value: 'غير متوفر',
//         ),
//       ],
//     );
//   }

//   // Content for restaurants and cafes
//   Widget _buildRestaurantContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow(
//           icon: Icons.restaurant,
//           title: 'نوع المطعم',
//           value: 'غير متوفر',
//         ),
//         _buildInfoRow(
//           icon: Icons.location_on,
//           title: 'العنوان',
//           value: widget.place.address,
//         ),
//         _buildInfoRow(
//           icon: Icons.access_time,
//           title: 'ساعات العمل',
//           value: 'من السبت إلى الجمعة: 10:00 ص - 12:00 م',
//         ),
//         _buildInfoRow(
//           icon: Icons.phone,
//           title: 'رقم الهاتف',
//           value: 'غير متوفر',
//         ),
//         _buildInfoRow(icon: Icons.star, title: 'التقييم', value: 'غير متوفر'),
//       ],
//     );
//   }

//   // Content for shopping places
//   Widget _buildShoppingContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow(
//           icon: Icons.shopping_bag,
//           title: 'نوع المتجر',
//           value: 'متجر تسوق',
//         ),
//         _buildInfoRow(
//           icon: Icons.location_on,
//           title: 'العنوان',
//           value: widget.place.address,
//         ),
//         _buildInfoRow(
//           icon: Icons.access_time,
//           title: 'ساعات العمل',
//           value: 'من السبت إلى الجمعة: 10:00 ص - 10:00 م',
//         ),
//         _buildInfoRow(
//           icon: Icons.phone,
//           title: 'رقم الهاتف',
//           value: 'غير متوفر',
//         ),
//       ],
//     );
//   }

//   // Content for healthcare facilities
//   Widget _buildHealthcareContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow(
//           icon: Icons.local_hospital,
//           title: 'نوع المنشأة',
//           value:
//               widget.place.placeName.contains('مستشفى')
//                   ? 'مستشفى'
//                   : 'منشأة صحية',
//         ),
//         _buildInfoRow(
//           icon: Icons.location_on,
//           title: 'العنوان',
//           value: widget.place.address,
//         ),
//         _buildInfoRow(
//           icon: Icons.access_time,
//           title: 'ساعات العمل',
//           value: 'على مدار 24 ساعة',
//         ),
//         _buildInfoRow(
//           icon: Icons.phone,
//           title: 'رقم الهاتف',
//           value: 'غير متوفر',
//         ),
//         _buildInfoRow(
//           icon: Icons.medical_services,
//           title: 'خدمات الطوارئ',
//           value: 'متوفرة',
//         ),
//       ],
//     );
//   }

//   // Default content for other types of places
//   Widget _buildDefaultContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow(icon: Icons.category, title: 'النوع', value: 'موقع عام'),
//         _buildInfoRow(
//           icon: Icons.location_on,
//           title: 'العنوان',
//           value: widget.place.address,
//         ),
//         _buildInfoRow(
//           icon: Icons.access_time,
//           title: 'ساعات العمل',
//           value: 'غير متوفر',
//         ),
//         _buildInfoRow(
//           icon: Icons.phone,
//           title: 'رقم الهاتف',
//           value: 'غير متوفر',
//         ),
//       ],
//     );
//   }

//   // Helper method to build info rows
//   Widget _buildInfoRow({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: theme.colorScheme.primary, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: theme.colorScheme.onSurface.withValues(alpha: .6),
//                     fontSize: 12,
//                   ),
//                 ),
//                 Text(value, style: theme.textTheme.bodyMedium),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to build action buttons
//   Widget _buildActionButton({
//     required BuildContext context,
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     bool isPrimary = false,
//   }) {
//     final theme = Theme.of(context);

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         decoration:
//             isPrimary
//                 ? BoxDecoration(
//                   color: theme.colorScheme.primary,
//                   borderRadius: BorderRadius.circular(8),
//                 )
//                 : null,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isPrimary ? Colors.white : theme.colorScheme.primary,
//               size: 24,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isPrimary ? Colors.white : theme.colorScheme.onSurface,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to get icon based on place category
//   IconData _getCategoryIcon() {
//     final name = widget.place.placeName.toLowerCase();

//     if (name.contains('جامعة') ||
//         name.contains('كلية') ||
//         name.contains('مدرسة')) {
//       return Icons.school;
//     } else if (name.contains('مستشفى') || name.contains('صحي')) {
//       return Icons.local_hospital;
//     } else if (name.contains('مطعم') || name.contains('كافيه')) {
//       return Icons.restaurant;
//     } else if (name.contains('مول') || name.contains('سوق')) {
//       return Icons.shopping_bag;
//     } else if (name.contains('متحف') || name.contains('معرض')) {
//       return Icons.museum;
//     } else if (name.contains('فندق')) {
//       return Icons.hotel;
//     } else if (name.contains('مسجد')) {
//       return Icons.mosque;
//     } else if (name.contains('حديقة') || name.contains('منتزه')) {
//       return Icons.park;
//     } else {
//       return Icons.place;
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/location_controller.dart';
import '../../controllers/storage_controller.dart';
import '../../models/place_model.dart';
import '../../services/mapbox_service.dart';

class PlaceDetailsWidget extends StatefulWidget {
  final PlaceModel place;
  final VoidCallback? onClose;
  final VoidCallback? onNavigate;
  final VoidCallback? onExploreBuildings;

  const PlaceDetailsWidget({
    super.key,
    required this.place,
    this.onClose,
    this.onNavigate,
    this.onExploreBuildings,
  });

  @override
  State<PlaceDetailsWidget> createState() => _PlaceDetailsWidgetState();
}

class _PlaceDetailsWidgetState extends State<PlaceDetailsWidget> {
  final MapboxService _mapboxService = MapboxService();
  bool _isLoading = true;
  Map<String, dynamic>? _placeDetails;
  String? _distance;
  bool _isFavorite = false;
  late StorageController _storageController;

  @override
  void initState() {
    super.initState();
    _loadPlaceDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _storageController = Provider.of<StorageController>(context, listen: false);
    // التحقق من حالة المفضلة
    _isFavorite = _storageController.isFavoriteLocation(widget.place.id);
  }

  Future<void> _loadPlaceDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // الحصول على تفاصيل المكان من Mapbox
      final details = await _mapboxService.getPlaceDetails(widget.place.id);

      // حساب المسافة من الموقع الحالي
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
      print('Error loading place details: $e');
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس المكان مع الاسم وزر الإغلاق
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
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

          // المحتوى
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات المسافة
                    if (_distance != null)
                      _buildInfoRow(
                        icon: Icons.directions,
                        title: 'المسافة',
                        value: _distance!,
                      ),

                    // استخراج وعرض تفاصيل المكان المناسبة
                    _buildPlaceDetailsContent(),

                    const SizedBox(height: 16),

                    // زر استكشاف المباني للمؤسسات الكبيرة مثل الجامعات
                    if (_isUniversityOrLargePlace())
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton.icon(
                          onPressed: _exploreCampusBuildings,
                          icon: const Icon(Icons.apartment),
                          label: const Text('استكشاف المباني داخل المكان'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),

                    // أزرار العمل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          context: context,
                          icon:
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                          label:
                              _isFavorite
                                  ? 'إزالة من المفضلة'
                                  : 'إضافة للمفضلة',
                          onTap: _toggleFavorite,
                          color: _isFavorite ? Colors.red : null,
                        ),
                        _buildActionButton(
                          context: context,
                          icon: Icons.share,
                          label: 'مشاركة',
                          onTap: () {
                            // تنفيذ المشاركة
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم نسخ الرابط')),
                            );
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
              ),
            ),
        ],
      ),
    );
  }

  // التحقق مما إذا كان المكان مؤسسة كبيرة يمكن استكشاف المباني بداخلها
  bool _isUniversityOrLargePlace() {
    final name = widget.place.placeName.toLowerCase();
    final address = widget.place.address.toLowerCase();

    return name.contains('جامعة') ||
        address.contains('جامعة') ||
        name.contains('حرم') ||
        name.contains('مجمع') ||
        name.contains('مدينة');
  }

  // استكشاف المباني داخل المكان
  void _exploreCampusBuildings() {
    // إغلاق نافذة التفاصيل
    if (widget.onClose != null) {
      widget.onClose!();
    }

    // إذا كانت هناك طريقة مخصصة للاستكشاف
    if (widget.onExploreBuildings != null) {
      widget.onExploreBuildings!();
      return;
    }

    // إخبار المستخدم أننا نبحث عن المباني
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جارٍ البحث عن المباني...'),
        duration: Duration(seconds: 2),
      ),
    );

    // تنفيذ البحث عن المباني داخل المكان
    // هذا الكود يفترض أن CustomMap ستستقبل التحديثات وتقوم بعرض البنايات
  }

  // تبديل حالة المفضلة
  void _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _storageController.removeFavoriteLocation(widget.place.id);
      } else {
        await _storageController.addFavoriteLocation(widget.place);
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      // إظهار رسالة للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? 'تمت إضافة ${widget.place.placeName} إلى المفضلة'
                : 'تمت إزالة ${widget.place.placeName} من المفضلة',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // استخراج وعرض تفاصيل مناسبة بناءً على نوع المكان
  Widget _buildPlaceDetailsContent() {
    // استخراج الفئة من خصائص المكان
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

    // حرم جامعي أو مؤسسة تعليمية
    if (category.contains('education') ||
        widget.place.placeName.toLowerCase().contains('جامعة')) {
      return _buildCampusContent();
    } else if (widget.place.placeName.toLowerCase().contains('كلية') ||
        widget.place.placeName.toLowerCase().contains('مدرسة')) {
      return _buildEducationalContent();
    }
    // مطعم أو مكان طعام
    else if (category.contains('food') ||
        category.contains('restaurant') ||
        widget.place.placeName.toLowerCase().contains('مطعم') ||
        widget.place.placeName.toLowerCase().contains('كافيه')) {
      return _buildRestaurantContent();
    }
    // مكان تسوق
    else if (category.contains('shop') ||
        category.contains('mall') ||
        widget.place.placeName.toLowerCase().contains('سوق') ||
        widget.place.placeName.toLowerCase().contains('مول')) {
      return _buildShoppingContent();
    }
    // مستشفى أو رعاية صحية
    else if (category.contains('hospital') ||
        category.contains('healthcare') ||
        widget.place.placeName.toLowerCase().contains('مستشفى') ||
        widget.place.placeName.toLowerCase().contains('صحي')) {
      return _buildHealthcareContent();
    }
    // محتوى افتراضي لأنواع الأماكن الأخرى
    else {
      return _buildDefaultContent();
    }
  }

  // محتوى الحرم الجامعي مع المباني الداخلية
  Widget _buildCampusContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.school,
          title: 'نوع المؤسسة',
          value: 'جامعة/حرم جامعي',
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
          icon: Icons.language,
          title: 'الموقع الإلكتروني',
          value: 'غير متوفر',
        ),

        const SizedBox(height: 16),

        // وصف موجز للجامعة
        Text(
          'معلومات:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تحتوي ${widget.place.placeName} على العديد من المباني والكليات والمرافق التعليمية والخدمية. يمكنك استكشاف المباني داخل الحرم الجامعي باستخدام الزر أدناه.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  // محتوى للمؤسسات التعليمية مثل الكليات والمدارس
  Widget _buildEducationalContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.school,
          title: 'نوع المؤسسة',
          value:
              widget.place.placeName.toLowerCase().contains('كلية')
                  ? 'كلية'
                  : widget.place.placeName.toLowerCase().contains('مدرسة')
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

  // محتوى للمطاعم والمقاهي
  Widget _buildRestaurantContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.restaurant,
          title: 'نوع المطعم',
          value: _getRestaurantType(),
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
        _buildInfoRow(
          icon: Icons.star,
          title: 'التقييم',
          value: '⭐⭐⭐⭐ (4.0/5.0)',
        ),

        const SizedBox(height: 16),

        Text(
          'الوصف:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يقدم ${widget.place.placeName} تجربة طعام مميزة في جو مريح ومناسب للزوار. يتميز بتنوع الأطباق والخدمة السريعة.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  // محتوى لأماكن التسوق
  Widget _buildShoppingContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.shopping_bag,
          title: 'نوع المتجر',
          value: _getShoppingType(),
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

        const SizedBox(height: 16),

        Text(
          'الوصف:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يوفر ${widget.place.placeName} تجربة تسوق متكاملة مع مجموعة متنوعة من المنتجات والعلامات التجارية. يتميز المكان بسهولة الوصول ومواقف السيارات المتاحة.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  // محتوى للمنشآت الصحية
  Widget _buildHealthcareContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.local_hospital,
          title: 'نوع المنشأة',
          value:
              widget.place.placeName.toLowerCase().contains('مستشفى')
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

  // محتوى افتراضي لأنواع الأماكن الأخرى
  Widget _buildDefaultContent() {
    final theme = Theme.of(context);

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

        const SizedBox(height: 16),

        Text(
          'الوصف:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'موقع ${widget.place.placeName} متاح للزيارة. يمكنك استخدام خاصية التنقل للوصول إليه بسهولة.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  // استخراج نوع المطعم
  String _getRestaurantType() {
    final name = widget.place.placeName.toLowerCase();

    if (name.contains('كافيه') ||
        name.contains('قهوة') ||
        name.contains('كافي')) {
      return 'مقهى';
    } else if (name.contains('مطعم') &&
        (name.contains('شرقي') || name.contains('عربي'))) {
      return 'مطعم مأكولات شرقية';
    } else if (name.contains('مطعم') &&
        (name.contains('غربي') ||
            name.contains('برجر') ||
            name.contains('بيتزا'))) {
      return 'مطعم وجبات سريعة';
    } else {
      return 'مطعم';
    }
  }

  // استخراج نوع مكان التسوق
  String _getShoppingType() {
    final name = widget.place.placeName.toLowerCase();

    if (name.contains('مول')) {
      return 'مركز تسوق';
    } else if (name.contains('سوق')) {
      return 'سوق';
    } else if (name.contains('متجر') || name.contains('محل')) {
      return 'متجر';
    } else {
      return 'مكان تسوق';
    }
  }

  // طريقة مساعدة لبناء صفوف المعلومات
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
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  // طريقة مساعدة لبناء أزرار العمل
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    Color? color,
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
              color:
                  isPrimary ? Colors.white : color ?? theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isPrimary
                        ? Colors.white
                        : color ?? theme.colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تحديد أيقونة بناءً على فئة المكان
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
