import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== 1. USERS ====================
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== 2. SHOPS ====================
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

  // ==================== 3. PRODUCTS ====================
  Future<void> addProduct({
    required String productId,
    required String shopId,
    required String name,
    required double price,
    required int stock,
  }) async {
    await _db.collection('products').doc(productId).set({
      'id': productId,
      'shopId': shopId,
      'name': name,
      'price': price,
      'stock': stock,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== 4. ORDERS ====================
  Future<void> createOrder({
    required String orderId,
    required String customerId,
    required String shopId,
    required double total,
  }) async {
    await _db.collection('orders').doc(orderId).set({
      'id': orderId,
      'customerId': customerId,
      'shopId': shopId,
      'total': total,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== 5. RIDERS ====================
  Future<void> registerRider({
    required String riderId,
    required String name,
    required String phone,
  }) async {
    await _db.collection('riders').doc(riderId).set({
      'id': riderId,
      'name': name,
      'phone': phone,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== 6. COMPLAINTS ====================
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

  // ==================== 7. CATEGORIES ====================
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
}