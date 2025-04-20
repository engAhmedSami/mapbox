import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/location_controller.dart';
import '../../services/mapbox_service.dart';
import '../../models/place_model.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(PlaceModel) onPlaceSelected;
  final String? initialQuery;
  final bool autofocus;

  const CustomSearchBar({
    super.key,
    required this.onPlaceSelected,
    this.initialQuery,
    this.autofocus = false,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final MapboxService _mapboxService = MapboxService();
  final FocusNode _focusNode = FocusNode();

  bool _isSearching = false;
  List<PlaceModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchPlaces(widget.initialQuery!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // حقل البحث
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // أيقونة البحث
              Icon(Icons.search, color: theme.colorScheme.primary),
              const SizedBox(width: 12),

              // حقل النص
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مكان...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                  textInputAction: TextInputAction.search,
                  onChanged: (query) {
                    if (query.length >= 3) {
                      _searchPlaces(query);
                    } else if (query.isEmpty) {
                      setState(() {
                        _searchResults = [];
                      });
                    }
                  },
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      _searchPlaces(query);
                    }
                  },
                ),
              ),

              // زر المسح
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                    });
                  },
                ),

              // مؤشر التحميل
              if (_isSearching)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),

        // نتائج البحث
        if (_searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                return ListTile(
                  title: Text(
                    place.placeName,
                    style: theme.textTheme.titleMedium,
                    textDirection: TextDirection.rtl,
                  ),
                  subtitle: Text(
                    place.address,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  leading: Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                  ),
                  onTap: () {
                    widget.onPlaceSelected(place);
                    _focusNode.unfocus();
                    setState(() {
                      _searchResults = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  // البحث عن الأماكن باستخدام Mapbox API
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // الحصول على موقع المستخدم الحالي لاستخدامه كمرجع للبحث
      final locationController = Provider.of<LocationController>(
        context,
        listen: false,
      );
      final currentLocation = locationController.currentLocation;

      double? nearLat, nearLng;
      if (currentLocation != null) {
        nearLat = currentLocation.latitude;
        nearLng = currentLocation.longitude;
      }

      // البحث عن الأماكن
      final results = await _mapboxService.searchPlaces(
        query,
        nearLat: nearLat,
        nearLng: nearLng,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      log('خطأ في البحث: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
