import 'package:flutter_riverpod/flutter_riverpod.dart';

// A simple cart item model
class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final String shopId;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl = '',
    required this.shopId,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      shopId: shopId,
    );
  }
}

// Cart provider – holds the list of items and total
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final existingIndex = state.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      // Increase quantity
      final existing = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existing.copyWith(quantity: existing.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = state.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        removeItem(productId);
      } else {
        final item = state[index];
        state = [
          ...state.sublist(0, index),
          item.copyWith(quantity: newQuantity),
          ...state.sublist(index + 1),
        ];
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalPrice => state.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);
}