import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled
}

class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) => OrderItemModel(
    productId: data['productId'] ?? '',
    productName: data['productName'] ?? '',
    price: (data['price'] as num?)?.toDouble() ?? 0.0,
    quantity: (data['quantity'] as num?)?.toInt() ?? 0,
    total: (data['total'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
    'total': total,
  };
}

class OrderModel {
  final String id;
  final String customerId;
  final String shopId;
  final String? riderId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final String deliveryPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.shopId,
    this.riderId,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0.0,
    this.tax = 0.0,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.deliveryPhone,
    this.notes,
    required this.createdAt,
    this.completedAt,
  });

  // Helper method to safely parse DateTime across all formats
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
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      shopId: data['shopId'] ?? '',
      riderId: data['riderId'],
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(
                  Map<String, dynamic>.from(item as Map)))
              .toList() ??
          [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: data['deliveryAddress'] ?? '',
      deliveryPhone: data['deliveryPhone'] ?? '',
      notes: data['notes'],
      createdAt: _parseDateTime(data['createdAt']),
      completedAt: data['completedAt'] != null
          ? _parseDateTime(data['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'customerId': customerId,
    'shopId': shopId,
    'riderId': riderId,
    'items': items.map((i) => i.toMap()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'tax': tax,
    'total': total,
    'status': status.name,
    'deliveryAddress': deliveryAddress,
    'deliveryPhone': deliveryPhone,
    'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
  };
}