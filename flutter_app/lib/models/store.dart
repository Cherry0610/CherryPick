import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String id;
  final String name;
  final String type; // grocery, hypermarket, convenience, etc.
  final String address;
  final String city;
  final String state;
  final String postcode;
  final double latitude;
  final double longitude;
  final String? website;
  final String? phone;
  final String? imageUrl;
  final List<String> operatingHours; // ["Monday: 8AM-10PM", ...]
  final bool isActive;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.postcode,
    required this.latitude,
    required this.longitude,
    this.website,
    this.phone,
    this.imageUrl,
    this.operatingHours = const [],
    this.isActive = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Store(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postcode: data['postcode'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      website: data['website'],
      phone: data['phone'],
      imageUrl: data['imageUrl'],
      operatingHours: List<String>.from(data['operatingHours'] ?? []),
      isActive: data['isActive'] ?? true,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'address': address,
      'city': city,
      'state': state,
      'postcode': postcode,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'phone': phone,
      'imageUrl': imageUrl,
      'operatingHours': operatingHours,
      'isActive': isActive,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get fullAddress => '$address, $postcode $city, $state';

  Store copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    String? city,
    String? state,
    String? postcode,
    double? latitude,
    double? longitude,
    String? website,
    String? phone,
    String? imageUrl,
    List<String>? operatingHours,
    bool? isActive,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postcode: postcode ?? this.postcode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      operatingHours: operatingHours ?? this.operatingHours,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
