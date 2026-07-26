import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final int stock;
  final String imageUrl;
  final List<String> images;
  final String category;
  final double rating;
  final int reviews;
  final bool isActive;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice = 0.0,
    required this.stock,
    required this.imageUrl,
    this.images = const [],
    required this.category,
    this.rating = 0.0,
    this.reviews = 0,
    required this.isActive,
    required this.createdAt,
  });

  // Helper method to safely parse DateTime across all possible Firestore formats
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
    return DateTime.fromMillisecondsSinceEpoch(0); // Stable epoch fallback
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (data['discountPrice'] as num?)?.toDouble() ?? 0.0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (data['reviews'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'shopId': shopId,
    'name': name,
    'description': description,
    'price': price,
    'discountPrice': discountPrice,
    'stock': stock,
    'imageUrl': imageUrl,
    'images': images,
    'category': category,
    'rating': rating,
    'reviews': reviews,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}