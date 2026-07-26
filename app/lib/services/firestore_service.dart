// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USERS ====================
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required String role,
    String? phone,
    String? shopId,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'phone': phone ?? '',
      'shopId': shopId,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ==================== SHOPS ====================
  Future<void> createShop({
    required String shopId,
    required String name,
    required String address,
    required String vendorId,
  }) async {
    await _db.collection('shops').doc(shopId).set({
      'id': shopId,
      'name': name,
      'address': address,
      'vendorId': vendorId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getShop(String shopId) async {
    return await _db.collection('shops').doc(shopId).get();
  }

  Future<void> updateShop(String shopId, Map<String, dynamic> data) async {
    await _db.collection('shops').doc(shopId).update(data);
  }

  // Assign a shop to a vendor (updates both documents)
  Future<void> assignShopToVendor({
    required String shopId,
    required String vendorId,
  }) async {
    final batch = _db.batch();

    // Update shop
    final shopRef = _db.collection('shops').doc(shopId);
    batch.update(shopRef, {'vendorId': vendorId});

    // Update vendor's shopId
    final vendorRef = _db.collection('users').doc(vendorId);
    batch.update(vendorRef, {'shopId': shopId});

    await batch.commit();
  }

  // ==================== PRODUCTS ====================
  Future<void> addProduct({
    required String productId,
    required String shopId,
    required String name,
    required double price,
    required int stock,
    String? description,
  }) async {
    await _db.collection('products').doc(productId).set({
      'id': productId,
      'shopId': shopId,
      'name': name,
      'price': price,
      'stock': stock,
      'description': description ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _db.collection('products').doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // ==================== ORDERS ====================
  Future<void> createOrder({
    required String orderId,
    required String customerId,
    required String shopId,
    required double total,
    List<Map<String, dynamic>>? items,
  }) async {
    await _db.collection('orders').doc(orderId).set({
      'id': orderId,
      'customerId': customerId,
      'shopId': shopId,
      'total': total,
      'items': items ?? [],
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignRiderToOrder(String orderId, String riderId) async {
    await _db.collection('orders').doc(orderId).update({
      'riderId': riderId,
      'status': 'Assigned',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== RIDERS ====================
  Future<void> registerRider({
    required String riderId,
    required String name,
    required String phone,
    required String email,
  }) async {
    await _db.collection('users').doc(riderId).set({
      'uid': riderId,
      'displayName': name,
      'phone': phone,
      'email': email,
      'role': 'rider',
      'status': 'active',
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRiderAvailability(String riderId, bool isAvailable) async {
    await _db.collection('users').doc(riderId).update({
      'isAvailable': isAvailable,
    });
  }

  // ==================== COMPLAINTS ====================
  Future<void> submitComplaint({
    required String complaintId,
    required String userId,
    required String subject,
    required String message,
  }) async {
    await _db.collection('complaints').doc(complaintId).set({
      'id': complaintId,
      'userId': userId,
      'subject': subject,
      'message': message,
      'status': 'Open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateComplaintStatus(String complaintId, String newStatus) async {
    await _db.collection('complaints').doc(complaintId).update({
      'status': newStatus,
    });
  }

  // ==================== CATEGORIES ====================
  Future<void> addCategory({
    required String categoryId,
    required String name,
  }) async {
    await _db.collection('categories').doc(categoryId).set({
      'id': categoryId,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== BANNERS ====================
  Future<void> addBanner({
    required String bannerId,
    required String title,
    required String imageUrl,
    required String link,
  }) async {
    await _db.collection('banners').doc(bannerId).set({
      'id': bannerId,
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== QUERIES (helpers) ====================
  Stream<QuerySnapshot> getProductsForShop(String shopId) {
    return _db
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersForShop(String shopId) {
    return _db
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersForCustomer(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAvailableOrders() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'Ready for Pickup')
        .where('riderId', isEqualTo: null)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersForRider(String riderId) {
    return _db
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}