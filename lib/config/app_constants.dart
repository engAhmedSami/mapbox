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
  // Mapbox Styles
  static const String dayMapStyle = 'mapbox://styles/mapbox/navigation-day-v1';
  static const String nightMapStyle =
      'mapbox://styles/mapbox/navigation-night-v1';
  static const String streetsStyle = 'mapbox://styles/mapbox/streets-v12';
  static const String outdoorsStyle = 'mapbox://styles/mapbox/outdoors-v12';
  static const String lightStyle = 'mapbox://styles/mapbox/light-v11';
  static const String darkStyle = 'mapbox://styles/mapbox/dark-v11';
  static const String satelliteStyle = 'mapbox://styles/mapbox/satellite-v9';
  static const String satelliteStreetsStyle =
      'mapbox://styles/mapbox/satellite-streets-v12';
  static const String trafficDayStyle =
      'mapbox://styles/mapbox/navigation-preview-day-v4';
  static const String trafficNightStyle =
      'mapbox://styles/mapbox/navigation-preview-night-v4';
}
