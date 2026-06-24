import 'dart:convert';

class RoomType {
  final String name;
  final String description;
  final double priceMultiplier;

  RoomType({
    required this.name,
    required this.description,
    required this.priceMultiplier,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'priceMultiplier': priceMultiplier,
      };

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceMultiplier: (json['priceMultiplier'] ?? 1.0).toDouble(),
    );
  }
}

class Hotel {
  final int id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final double pricePerNight;
  final double rating;
  final String checkinTime;
  final String checkoutTime;
  final List<String> amenities;
  final int bedrooms;
  final int bathrooms;
  final int tvs;
  final bool hasAC;
  final String? roomTypesJson;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.pricePerNight,
    required this.rating,
    this.checkinTime = '14:00',
    this.checkoutTime = '12:00',
    required this.amenities,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.tvs = 1,
    this.hasAC = false,
    this.roomTypesJson,
  });

  List<RoomType> get roomTypes {
    if (roomTypesJson == null || roomTypesJson!.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(roomTypesJson!);
      return decoded.map((item) => RoomType.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Helper para converter valores que podem vir como String, int ou double para double
    double toDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      pricePerNight: toDouble(json['price_per_night'], 0.0),
      rating: toDouble(json['rating'], 5.0),
      checkinTime: json['checkin_time'] ?? '14:00',
      checkoutTime: json['checkout_time'] ?? '12:00',
      amenities: json['amenities'] is String
          ? (json['amenities'] as String).split(',')
          : [],
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      tvs: json['tvs'] ?? 1,
      hasAC: json['has_ac'] == 1 || json['has_ac'] == true,
      roomTypesJson: json['room_types_json'],
    );
  }
}
