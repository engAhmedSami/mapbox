import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/voice_button.dart';
import '../../controllers/storage_controller.dart';
import '../../controllers/speech_controller.dart';
import '../../models/place_model.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final Function(PlaceModel) onPlaceSelected;

  const SearchScreen({
    super.key,
    this.initialQuery,
    required this.onPlaceSelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final storageController = Provider.of<StorageController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'البحث الأخير'), Tab(text: 'المفضلة')],
        ),
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              initialQuery: widget.initialQuery,
              autofocus: widget.initialQuery == null,
              onPlaceSelected: _handlePlaceSelection,
            ),
          ),

          // قائمة البحث الأخير والمفضلة
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // البحث الأخير
                _buildRecentSearchesList(storageController),

                // المفضلة
                _buildFavoritesList(storageController),
              ],
            ),
          ),
        ],
      ),

      // زر الأوامر الصوتية
      floatingActionButton: VoiceButton(
        size: 56,
        onCommand: _handleVoiceCommand,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // بناء قائمة البحث الأخير
  Widget _buildRecentSearchesList(StorageController storageController) {
    final recentSearches = storageController.recentSearches;

    if (recentSearches.isEmpty) {
      return _buildEmptyListMessage('لا توجد عمليات بحث سابقة');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: recentSearches.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = recentSearches[index];
        return _buildPlaceListItem(
          place: place,
          onTap: () => _handlePlaceSelection(place),
          onFavoriteTap: () => _toggleFavorite(place),
          isFavorite: storageController.isFavoriteLocation(place.id),
        );
      },
    );
  }

  // بناء قائمة المفضلة
  Widget _buildFavoritesList(StorageController storageController) {
    final favorites = storageController.favoriteLocations;

    if (favorites.isEmpty) {
      return _buildEmptyListMessage('لا توجد أماكن مفضلة');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: favorites.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = favorites[index];
        return _buildPlaceListItem(
          place: place,
          onTap: () => _handlePlaceSelection(place),
          onFavoriteTap: () => _toggleFavorite(place),
          isFavorite: true,
        );
      },
    );
  }

  // بناء رسالة القائمة الفارغة
  Widget _buildEmptyListMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: .3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .5),
            ),
          ),
        ],
      ),
    );
  }

  // بناء عنصر مكان في القائمة
  Widget _buildPlaceListItem({
    required PlaceModel place,
    required VoidCallback onTap,
    required VoidCallback onFavoriteTap,
    required bool isFavorite,
  }) {
    return ListTile(
      title: Text(
        place.placeName,
        style: Theme.of(context).textTheme.titleMedium,
        textDirection: TextDirection.rtl,
      ),
      subtitle: Text(
        place.address,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textDirection: TextDirection.rtl,
      ),
      leading: Icon(
        Icons.location_on,
        color: Theme.of(context).colorScheme.primary,
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: onFavoriteTap,
      ),
      onTap: onTap,
    );
  }

  // معالجة الأوامر الصوتية
  void _handleVoiceCommand(String command) {
    final speechController = Provider.of<SpeechController>(
      context,
      listen: false,
    );

    if (command.startsWith('ابحث عن')) {
      // استخراج نص البحث من الأمر الصوتي
      String? searchQuery = speechController.extractSearchQuery();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // إعادة بناء الشاشة مع استعلام البحث الجديد
        setState(() {});
      }
    }
  }

  // معالجة اختيار مكان
  void _handlePlaceSelection(PlaceModel place) {
    widget.onPlaceSelected(place);
    Navigator.pop(context);
  }

  // تبديل حالة المفضلة للمكان
  void _toggleFavorite(PlaceModel place) async {
    final storageController = Provider.of<StorageController>(
      context,
      listen: false,
    );

    if (storageController.isFavoriteLocation(place.id)) {
      await storageController.removeFavoriteLocation(place.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تمت إزالة ${place.placeName} من المفضلة')),
        );
      }
    } else {
      await storageController.addFavoriteLocation(place);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تمت إضافة ${place.placeName} إلى المفضلة')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
