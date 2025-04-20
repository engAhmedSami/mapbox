class PlaceModel {
  final String id;
  final String placeName;
  final String address;
  final double latitude;
  final double longitude;
  final Map<String, dynamic>? properties;
  final bool isFavorite;

  PlaceModel({
    required this.id,
    required this.placeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.properties,
    this.isFavorite = false,
  });

  factory PlaceModel.fromMapboxJson(Map<String, dynamic> json) {
    // نستخرج الموقع من نقاط الإحداثيات [longitude, latitude]
    final List<dynamic> coordinates = json['geometry']['coordinates'];
    final double longitude = coordinates[0];
    final double latitude = coordinates[1];

    // نستخرج اسم المكان والعنوان
    final String placeName = json['text'] ?? 'غير معروف';
    final String address = json['place_name'] ?? '';

    return PlaceModel(
      id: json['id'] ?? '',
      placeName: placeName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      properties: json['properties'],
    );
  }

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'],
      placeName: json['placeName'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      properties: json['properties'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeName': placeName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'properties': properties,
      'isFavorite': isFavorite,
    };
  }

  PlaceModel copyWith({
    String? id,
    String? placeName,
    String? address,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? properties,
    bool? isFavorite,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      placeName: placeName ?? this.placeName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      properties: properties ?? this.properties,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'PlaceModel(id: $id, placeName: $placeName, address: $address, latitude: $latitude, longitude: $longitude, isFavorite: $isFavorite)';
  }
}
