import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_app/providers/auth_providers.dart';
import 'package:dashboard_app/services/firestore_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen ({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late final TextEditingController _vendorNameController;
  late final TextEditingController _vendorEmailController;
  late final TextEditingController _vendorPhoneController;
  late final TextEditingController _shopNameController;
  late final TextEditingController _shopAddressController;

  @override
  void initState() {
    super.initState();
    _vendorNameController = TextEditingController();
    _vendorEmailController = TextEditingController();
    _vendorPhoneController = TextEditingController();
    _shopNameController = TextEditingController();
    _shopAddressController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // Watch user data from your Riverpod provider
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
            // Admin Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Welcome, Super Admin!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    currentUserAsync.when(
                      data: (user) => Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error loading profile'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            const Text('Quick Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: const [
                StatCard(
                    title: 'Total Vendors', value: '12', icon: Icons.store),
                StatCard(title: 'Active Shops', value: '15', icon: Icons.shop),
                StatCard(
                    title: 'Total Orders',
                    value: '324',
                    icon: Icons.shopping_bag),
                StatCard(
                    title: 'Total Riders', value: '8', icon: Icons.two_wheeler),
              ],
            ),
            const SizedBox(height: 32),

            // Create Vendor Section
            const Text('Create Vendor Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _vendorNameController,
              decoration: const InputDecoration(
                hintText: 'Vendor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vendorEmailController,
              decoration: const InputDecoration(
                hintText: 'Vendor Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vendorPhoneController,
              decoration: const InputDecoration(
                hintText: 'Vendor Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createVendor,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Create Vendor'),
            ),
            const SizedBox(height: 32),

            // Create Shop Section
            const Text('Create Shop',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _shopNameController,
              decoration: const InputDecoration(
                hintText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _shopAddressController,
              decoration: const InputDecoration(
                hintText: 'Shop Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createShop,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Create Shop'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createVendor() async {
    if (_vendorNameController.text.trim().isEmpty ||
        _vendorEmailController.text.trim().isEmpty ||
        _vendorPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final String vendorId = 'ven_${DateTime.now().millisecondsSinceEpoch}';

      // Save vendor profile to the 'users' collection
      await _firestoreService.createUserProfile(
        uid: vendorId,
        email: _vendorEmailController.text.trim(),
        displayName: _vendorNameController.text.trim(),
        role: 'vendor',
      );

      _vendorNameController.clear();
      _vendorEmailController.clear();
      _vendorPhoneController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create vendor: $e')),
        );
      }
    }
  }

  Future<void> _createShop() async {
    if (_shopNameController.text.trim().isEmpty ||
        _shopAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final String shopId = 'shop_${DateTime.now().millisecondsSinceEpoch}';
      final String dummyVendorId = 'admin_managed_vendor';

      // Save shop to the 'shops' collection
      await _firestoreService.createShop(
        shopId: shopId,
        name: _shopNameController.text.trim(),
        address: _shopAddressController.text.trim(),
        vendorId: dummyVendorId,
      );

      _shopNameController.clear();
      _shopAddressController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create shop: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _vendorEmailController.dispose();
    _vendorPhoneController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    super.dispose();
  }
}

// StatCard Widget
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