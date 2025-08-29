class Turf {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final double pricePerHour;
  final bool isFree;
  final String contact;
  final TurfType type;
  final SurfaceType surfaceType;
  final List<String> amenities;
  final double rating;
  final int totalBookings;
  final List<String> availableTimeSlots;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Turf({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.pricePerHour,
    this.isFree = false,
    required this.contact,
    required this.type,
    this.surfaceType = SurfaceType.artificial,
    required this.amenities,
    required this.rating,
    required this.totalBookings,
    required this.availableTimeSlots,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Turf.fromJson(Map<String, dynamic> json) {
    return Turf(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      isFree: json['isFree'] ?? false,
      contact: json['contact'] ?? '',
      type: TurfType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TurfType.football,
      ),
      surfaceType: SurfaceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['surfaceType'],
        orElse: () => SurfaceType.artificial,
      ),
      amenities: List<String>.from(json['amenities'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      totalBookings: json['totalBookings'] ?? 0,
      availableTimeSlots: List<String>.from(json['availableTimeSlots'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'pricePerHour': pricePerHour,
      'isFree': isFree,
      'contact': contact,
      'type': type.toString().split('.').last,
      'surfaceType': surfaceType.toString().split('.').last,
      'amenities': amenities,
      'rating': rating,
      'totalBookings': totalBookings,
      'availableTimeSlots': availableTimeSlots,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Turf copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    double? pricePerHour,
    bool? isFree,
    String? contact,
    TurfType? type,
    SurfaceType? surfaceType,
    List<String>? amenities,
    double? rating,
    int? totalBookings,
    List<String>? availableTimeSlots,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Turf(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      isFree: isFree ?? this.isFree,
      contact: contact ?? this.contact,
      type: type ?? this.type,
      surfaceType: surfaceType ?? this.surfaceType,
      amenities: amenities ?? this.amenities,
      rating: rating ?? this.rating,
      totalBookings: totalBookings ?? this.totalBookings,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum TurfType {
  football,
}

extension TurfTypeExtension on TurfType {
  String get displayName {
    switch (this) {
      case TurfType.football:
        return 'Football';
    }
  }
}

enum SurfaceType {
  artificial,
  natural,
}

extension SurfaceTypeExtension on SurfaceType {
  String get displayName {
    switch (this) {
      case SurfaceType.artificial:
        return 'Artificial Turf';
      case SurfaceType.natural:
        return 'Natural Grass';
    }
  }

  String get shortName {
    switch (this) {
      case SurfaceType.artificial:
        return 'Turf';
      case SurfaceType.natural:
        return 'Grass';
    }
  }
}
