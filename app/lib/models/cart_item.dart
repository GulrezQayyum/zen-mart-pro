class CartItem {
  final String productId;
  final String shopId;      // ✅ new
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.shopId,   // ✅ new required
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      shopId: shopId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}