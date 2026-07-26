class AppConstants {
  // API Strings
  static const String appName = 'Zen Mart Pro';
  static const String appVersion = '1.0.0';
 
  // Firebase
  static const String usersCollection = 'users';
  static const String shopsCollection = 'shops';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String ridersCollection = 'riders';
  static const String categoriesCollection = 'categories';
  static const String complaintsCollection = 'complaints';
 
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorValidation = 'Please fill all required fields.';
 
  // Success Messages
  static const String successCreate = 'Created successfully!';
  static const String successUpdate = 'Updated successfully!';
  static const String successDelete = 'Deleted successfully!';
 
  // Order Status
  static const Map<String, String> orderStatusDisplay = {
    'pending': 'Pending',
    'accepted': 'Accepted',
    'preparing': 'Preparing',
    'readyForPickup': 'Ready for Pickup',
    'outForDelivery': 'Out for Delivery',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
  };
 
  // Delivery Fee
  static const double deliveryFee = 200.0;
  static const double tax = 0.15; // 15% tax
}
 