// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/admin_drawer.dart';
import 'admin_vendors_screen.dart';
import 'admin_shops_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_riders_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_analytics_screen.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardHome(),
    const AdminVendorsScreen(),
    const AdminShopsScreen(),
    const AdminOrdersScreen(),
    const AdminRidersScreen(),
    const AdminCustomersScreen(),
    const AdminAnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text('⚡ Zenvyro',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
            ),
          ),
        ],
      ),
      drawer: AdminDrawer(
        currentIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

// ========== Dashboard Home (with real stats) ==========
class _DashboardHome extends ConsumerStatefulWidget {
  const _DashboardHome({Key? key}) : super(key: key);

  @override
  ConsumerState<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<_DashboardHome> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return SingleChildScrollView(
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
                  currentUserAsync.when(
                    data: (user) => Text(
                      'Welcome, ${user?.displayName ?? 'Super Admin'}!',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    loading: () => const Text('Welcome, Super Admin!'),
                    error: (_, __) => const Text('Welcome, Super Admin!'),
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

          // Quick Stats - real counts
          const Text('Quick Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FutureBuilder(
            future: _getStats(),
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
                      title: 'Total Vendors',
                      value: stats['vendors'].toString(),
                      icon: Icons.store),
                  StatCard(
                      title: 'Total Shops',
                      value: stats['shops'].toString(),
                      icon: Icons.shop),
                  StatCard(
                      title: 'Total Orders',
                      value: stats['orders'].toString(),
                      icon: Icons.shopping_bag),
                  StatCard(
                      title: 'Total Riders',
                      value: stats['riders'].toString(),
                      icon: Icons.two_wheeler),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Recent Activity (optional)
          const Text('Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
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
                  return ListTile(
                    title: Text('Order ${doc.id}'),
                    subtitle: Text('Status: ${data['status'] ?? 'Pending'}'),
                    trailing: Text('Rs. ${data['total'] ?? 0}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, int>> _getStats() async {
    final vendors = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'vendor')
        .get();
    final shops = await FirebaseFirestore.instance.collection('shops').get();
    final orders = await FirebaseFirestore.instance.collection('orders').get();
    final riders = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'rider')
        .get();

    return {
      'vendors': vendors.docs.length,
      'shops': shops.docs.length,
      'orders': orders.docs.length,
      'riders': riders.docs.length,
    };
  }
}