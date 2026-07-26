import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String name;
  final String vendorId;
  final String description;
  final String imageUrl;
  final String bannerUrl;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final bool isActive;
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.name,
    required this.vendorId,
    this.description = '',
    this.imageUrl = '',
    this.bannerUrl = '',
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.categories = const [],
    required this.isActive,
    required this.createdAt,
  });

  // Helper method to safely parse DateTime from dynamic Firestore fields
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    }
    return DateTime.fromMillisecondsSinceEpoch(0); // Stable default fallback
  }

  factory ShopModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ShopModel(
      id: doc.id,
      name: data['name'] ?? '',
      vendorId: data['vendorId'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      categories: List<String>.from(data['categories'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'vendorId': vendorId,
    'description': description,
    'imageUrl': imageUrl,
    'bannerUrl': bannerUrl,
    'address': address,
    'phone': phone,
    'latitude': latitude,
    'longitude': longitude,
    'categories': categories,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}