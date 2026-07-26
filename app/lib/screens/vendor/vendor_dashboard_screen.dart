import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../services/firestore_service.dart';

class VendorDashboardScreen extends ConsumerStatefulWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VendorDashboardScreen> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends ConsumerState<VendorDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late final TextEditingController _productNameController;
  late final TextEditingController _productPriceController;
  late final TextEditingController _productStockController;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _productPriceController = TextEditingController();
    _productStockController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // Access the current user from Riverpod
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Call signOut directly via the auth service provider
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Shop',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    currentUserAsync.when(
                      data: (user) =>
                          Text('Shop ID: ${user?.shopId ?? 'Not assigned'}'),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error loading shop info'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            const Text('Shop Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: const [
                StatCard(
                    title: 'Total Products',
                    value: '24',
                    icon: Icons.inventory),
                StatCard(
                    title: 'Pending Orders', value: '5', icon: Icons.pending),
                StatCard(
                    title: 'Completed', value: '156', icon: Icons.check_circle),
                StatCard(
                    title: 'Revenue',
                    value: 'Rs. 45K',
                    icon: Icons.trending_up),
              ],
            ),
            const SizedBox(height: 32),

            // Add Product Form
            const Text('Add New Product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(
                hintText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _productPriceController,
              decoration: const InputDecoration(
                hintText: 'Product Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _productStockController,
              decoration: const InputDecoration(
                hintText: 'Stock Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Add Product'),
            ),
            const SizedBox(height: 32),

            // Pending Orders
            const Text('Pending Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const OrderTile(
              orderId: 'ORD001',
              customerName: 'Ahmed Ali',
              total: 'Rs. 2,500',
              status: 'Pending',
            ),
            const OrderTile(
              orderId: 'ORD002',
              customerName: 'Fatima Khan',
              total: 'Rs. 1,800',
              status: 'Preparing',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    // 1. Validate fields are not empty
    if (_productNameController.text.trim().isEmpty ||
        _productPriceController.text.trim().isEmpty ||
        _productStockController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // 2. Retrieve the current user's shopId using Riverpod
    final currentUser = ref.read(currentUserProvider).value;
    final shopId = currentUser?.shopId;

    if (shopId == null || shopId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No shop assigned to this vendor account')),
      );
      return;
    }

    try {
      // 3. Parse price and stock into proper numeric formats
      final double? price = double.tryParse(_productPriceController.text.trim());
      final int? stock = int.tryParse(_productStockController.text.trim());

      if (price == null || stock == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid numbers for price and stock')),
        );
        return;
      }

      // 4. Generate a unique product ID
      final String productId = 'prod_${DateTime.now().millisecondsSinceEpoch}';

      // 5. Save data to Firestore (automatically provisions 'products' collection)
      await _firestoreService.addProduct(
        productId: productId,
        shopId: shopId,
        name: _productNameController.text.trim(),
        price: price,
        stock: stock,
      );

      // 6. Clear input fields
      _productNameController.clear();
      _productPriceController.clear();
      _productStockController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productStockController.dispose();
    super.dispose();
  }
}

// Stat Card Widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Order Tile Widget
class OrderTile extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String total;
  final String status;

  const OrderTile({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.total,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('$orderId - $customerName'),
        subtitle: Text('Total: $total'),
        trailing: Chip(
          label: Text(
            status,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: status == 'Pending'
              ? Colors.orange.shade100
              : Colors.blue.shade100,
        ),
      ),
    );
  }
}