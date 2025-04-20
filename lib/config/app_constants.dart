class AppConstants {
  // Mapbox Access Token
  static const String mapboxAccessToken =
      'pk.eyJ1IjoiYWhtZWQwMTFzIiwiYSI6ImNtOW9wdTRwZjA3N3UyaXNmcGQyNzhvdjkifQ.fmyHIApsfMRPP3Sq2zQEHA';

  // Mapbox API URLs
  static const String mapboxDirectionsUrl =
      'https://api.mapbox.com/directions/v5/mapbox/driving';
  static const String mapboxGeocodingUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';

  // Default Map Camera Position
  static const double defaultLatitude = 31.9539; // Cairo, Egypt
  static const double defaultLongitude = 35.9106;
  static const double defaultZoom = 14.0;

  // Speech to Text Constants
  static const List<String> navigationCommands = [
    'ابدأ التنقل',
    'توقف عن التنقل',
    'اعرض الوقت',
    'كم المسافة',
    'الوصول المتوقع',
    'ابحث عن',
  ];

  // Shared Preferences Keys
  static const String recentSearchesKey = 'recent_searches';
  static const String favoriteLocationsKey = 'favorite_locations';
  static const String themeKey = 'app_theme';

  // Route Style
  static const double routeLineWidth = 5.0;
  static const String routeLineColor = '#4882C4';

  // Map Styles
  static const String dayMapStyle = 'mapbox://styles/mapbox/navigation-day-v1';
  static const String nightMapStyle =
      'mapbox://styles/mapbox/navigation-night-v1';
}
