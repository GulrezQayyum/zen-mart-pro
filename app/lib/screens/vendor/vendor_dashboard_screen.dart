// lib/screens/vendor/vendor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_providers.dart';
import '../../services/firestore_service.dart';

class VendorDashboardScreen extends ConsumerStatefulWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VendorDashboardScreen> createState() =>
      _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends ConsumerState<VendorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  // Product form controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productStockController = TextEditingController();
  final TextEditingController _productDescController = TextEditingController();

  String? _shopId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    final user = ref.read(currentUserProvider).value;
    if (user?.shopId != null) {
      setState(() => _shopId = user!.shopId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productStockController.dispose();
    _productDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.inventory), text: 'Products'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'Orders'),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                '⚡ Zenvyro',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          if (user.shopId == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No shop assigned yet.'),
                  Text('Please contact admin.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _DashboardTab(shopId: user.shopId!),
              _ProductsTab(shopId: user.shopId!),
              _OrdersTab(shopId: user.shopId!),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

// =============================================
//  DASHBOARD TAB
// =============================================
class _DashboardTab extends ConsumerStatefulWidget {
  final String shopId;
  const _DashboardTab({required this.shopId});

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  @override
  Widget build(BuildContext context) {
    final shopId = widget.shopId;

    return SingleChildScrollView(
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('shops')
                        .doc(shopId)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${data['name'] ?? 'N/A'}'),
                          Text('Address: ${data['address'] ?? 'N/A'}'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Real-time Stats
          const Text(
            'Shop Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: _getStats(shopId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = snapshot.data!;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                      title: 'Products',
                      value: stats['products'].toString(),
                      icon: Icons.inventory),
                  StatCard(
                      title: 'Pending Orders',
                      value: stats['pending'].toString(),
                      icon: Icons.pending),
                  StatCard(
                      title: 'Completed',
                      value: stats['completed'].toString(),
                      icon: Icons.check_circle),
                  StatCard(
                      title: 'Revenue',
                      value: 'Rs. ${stats['revenue']}',
                      icon: Icons.trending_up),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Recent Orders (last 5)
          const Text(
            'Recent Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('shopId', isEqualTo: shopId)
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No orders yet'),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final subtotal = (data['subtotal'] ?? data['total'] ?? 0).toDouble();
                  final deliveryFee = (data['deliveryFee'] ?? 0).toDouble();
                  final total = (data['total'] ?? 0).toDouble();
                  return OrderTile(
                    orderId: doc.id,
                    customerName: data['customerId'] ?? 'Customer',
                    subtotal: subtotal.toStringAsFixed(0),
                    deliveryFee: deliveryFee.toStringAsFixed(0),
                    total: total.toStringAsFixed(0),
                    status: data['status'] ?? 'Pending',
                    onTap: () {
                      // TODO: Navigate to order detail
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔥 FIXED: Revenue uses vendorAmount or subtotal (not total)
  Future<Map<String, dynamic>> _getStats(String shopId) async {
    final products = await FirebaseFirestore.instance
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .get();
    final orders = await FirebaseFirestore.instance
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .get();
    final pending =
        orders.docs.where((doc) => doc.data()['status'] == 'Pending').length;
    final completed =
        orders.docs.where((doc) => doc.data()['status'] == 'Delivered').length;
    double revenue = 0;
    for (var doc in orders.docs) {
      if (doc.data()['status'] == 'Delivered') {
        // Use vendorAmount if exists, else fallback to subtotal
        final vendorAmount = (doc.data()['vendorAmount'] ?? doc.data()['subtotal'] ?? 0).toDouble();
        revenue += vendorAmount;
      }
    }
    return {
      'products': products.docs.length,
      'pending': pending,
      'completed': completed,
      'revenue': revenue.toStringAsFixed(0),
    };
  }
}

// =============================================
//  PRODUCTS TAB (unchanged)
// =============================================
class _ProductsTab extends ConsumerStatefulWidget {
  final String shopId;
  const _ProductsTab({required this.shopId});

  @override
  ConsumerState<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends ConsumerState<_ProductsTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isAdding = false;

  Future<void> _addProduct() async {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _stockController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());
    if (price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid numbers')),
      );
      return;
    }
    setState(() => _isAdding = true);
    try {
      final productId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
      await _firestoreService.addProduct(
        productId: productId,
        shopId: widget.shopId,
        name: _nameController.text.trim(),
        price: price,
        stock: stock,
      );
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
      _descController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
    setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Add Product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Product Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(hintText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _stockController,
                  decoration: const InputDecoration(hintText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  decoration:
                      const InputDecoration(hintText: 'Description (optional)'),
                ),
                const SizedBox(height: 16),
                _isAdding
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _addProduct,
                        child: const Text('Add Product'),
                      ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('shopId', isEqualTo: widget.shopId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No products added yet'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text(data['name'] ?? 'Product'),
                      subtitle: Text('Stock: ${data['stock'] ?? 0}'),
                      trailing: Text(
                        'Rs. ${data['price'] ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        // TODO: Edit product
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// =============================================
//  ORDERS TAB
// =============================================
class _OrdersTab extends ConsumerStatefulWidget {
  final String shopId;
  const _OrdersTab({required this.shopId});

  @override
  ConsumerState<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<_OrdersTab> {
  String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterStatus == 'All',
                  onSelected: (_) => setState(() => _filterStatus = 'All'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _filterStatus == 'Pending',
                  onSelected: (_) => setState(() => _filterStatus = 'Pending'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Preparing'),
                  selected: _filterStatus == 'Preparing',
                  onSelected: (_) =>
                      setState(() => _filterStatus = 'Preparing'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Ready'),
                  selected: _filterStatus == 'Ready for Pickup',
                  onSelected: (_) =>
                      setState(() => _filterStatus = 'Ready for Pickup'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Delivered'),
                  selected: _filterStatus == 'Delivered',
                  onSelected: (_) =>
                      setState(() => _filterStatus = 'Delivered'),
                ),
              ],
            ),
          ),
        ),
        // Order list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _filterStatus == 'All'
                ? FirebaseFirestore.instance
                    .collection('orders')
                    .where('shopId', isEqualTo: widget.shopId)
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('orders')
                    .where('shopId', isEqualTo: widget.shopId)
                    .where('status', isEqualTo: _filterStatus)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No orders found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final subtotal = (data['subtotal'] ?? data['total'] ?? 0).toDouble();
                  final deliveryFee = (data['deliveryFee'] ?? 0).toDouble();
                  final total = (data['total'] ?? 0).toDouble();
                  return OrderTile(
                    orderId: doc.id,
                    customerName: data['customerId'] ?? 'Customer',
                    subtotal: subtotal.toStringAsFixed(0),
                    deliveryFee: deliveryFee.toStringAsFixed(0),
                    total: total.toStringAsFixed(0),
                    status: data['status'] ?? 'Pending',
                    onTap: () => _showOrderActions(
                        context, doc.id, data['status'] ?? 'Pending'),
                    trailing: _buildStatusActions(
                        doc.id, data['status'] ?? 'Pending'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusActions(String orderId, String status) {
    if (status == 'Pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _updateStatus(orderId, 'Preparing'),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _updateStatus(orderId, 'Cancelled'),
          ),
        ],
      );
    } else if (status == 'Preparing') {
      return IconButton(
        icon: const Icon(Icons.pending, color: Colors.orange),
        onPressed: () => _updateStatus(orderId, 'Ready for Pickup'),
        tooltip: 'Mark Ready for Pickup',
      );
    } else if (status == 'Ready for Pickup') {
      return const Chip(
        label: Text('Waiting Rider'),
        backgroundColor: Colors.blue,
      );
    } else if (status == 'Delivered') {
      return const Chip(
        label: Text('Completed'),
        backgroundColor: Colors.green,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    }
  }

  void _showOrderActions(BuildContext context, String orderId, String status) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Update Order Status')),
            if (status == 'Pending') ...[
              ListTile(
                title: const Text('Accept & Prepare'),
                onTap: () {
                  _updateStatus(orderId, 'Preparing');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Reject / Cancel'),
                onTap: () {
                  _updateStatus(orderId, 'Cancelled');
                  Navigator.pop(context);
                },
              ),
            ],
            if (status == 'Preparing')
              ListTile(
                title: const Text('Mark Ready for Pickup'),
                onTap: () {
                  _updateStatus(orderId, 'Ready for Pickup');
                  Navigator.pop(context);
                },
              ),
            if (status == 'Ready for Pickup' || status == 'Out for Delivery')
              ListTile(
                title: const Text('Mark Delivered'),
                onTap: () {
                  _updateStatus(orderId, 'Delivered');
                  Navigator.pop(context);
                },
              ),
            ListTile(
              title: const Text('Close'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================
//  REUSABLE WIDGETS (UPDATED OrderTile)
// =============================================
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

// ✅ UPDATED OrderTile – shows subtotal, deliveryFee, total
class OrderTile extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String subtotal;
  final String deliveryFee;
  final String total;
  final String status;
  final VoidCallback? onTap;
  final Widget? trailing;

  const OrderTile({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text('$orderId - $customerName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: Rs. $total'),
            Text('Subtotal: Rs. $subtotal  |  Delivery: Rs. $deliveryFee',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: trailing ??
            Chip(
              label: Text(
                status,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: status == 'Pending'
                  ? Colors.orange.shade100
                  : status == 'Delivered'
                      ? Colors.green.shade100
                      : status == 'Cancelled'
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
            ),
      ),
    );
  }
}