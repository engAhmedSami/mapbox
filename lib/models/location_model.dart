class LocationModel {
  final double latitude;
  final double longitude;
  final String? name;
  final String? address;
  final String? placeId;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.name,
    this.address,
    this.placeId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      name: json['name'],
      address: json['address'],
      placeId: json['placeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'address': address,
      'placeId': placeId,
    };
  }

  @override
  String toString() {
    return 'LocationModel(latitude: $latitude, longitude: $longitude, name: $name, address: $address, placeId: $placeId)';
  }
}
