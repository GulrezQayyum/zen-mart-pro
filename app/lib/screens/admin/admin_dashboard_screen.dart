// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/admin_drawer.dart';
import '../../widgets/zen_mart_buttons.dart'; // ✅ ADD THIS
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
      // ✅ FIXED: Use ZenMartAppBar instead of default AppBar
      appBar: ZenMartAppBar(
        title: 'Admin Panel',
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Zenvyro',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ),
        ],
      ),
      drawer: AdminDrawer(
        currentIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
      body: Container(
        // ✅ Use theme background color
        color: ZenMartColors.darkBg,
        child: _pages[_selectedIndex],
      ),
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
          // ✅ FIXED: Admin Info Card with proper styling
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZenMartColors.darkBgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ZenMartColors.tealAccent.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentUserAsync.when(
                  data: (user) => Text(
                    'Welcome, ${user?.displayName ?? 'Super Admin'}!',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  loading: () => Text(
                    'Welcome, Super Admin!',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  error: (_, __) => Text(
                    'Welcome, Super Admin!',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                const SizedBox(height: 12),
                currentUserAsync.when(
                  data: (user) => Text(
                    user?.email ?? 'admin@zenmartpro.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Text(
                    'admin@zenmartpro.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick Stats - real counts
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, int>>(
            future: _getStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final stats = snapshot.data!;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: 'Total Vendors',
                    value: stats['vendors'].toString(),
                    icon: Icons.store,
                  ),
                  _buildStatCard(
                    title: 'Total Shops',
                    value: stats['shops'].toString(),
                    icon: Icons.shop,
                  ),
                  _buildStatCard(
                    title: 'Total Orders',
                    value: stats['orders'].toString(),
                    icon: Icons.shopping_bag,
                  ),
                  _buildStatCard(
                    title: 'Total Riders',
                    value: stats['riders'].toString(),
                    icon: Icons.two_wheeler,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Recent Activity
          Text(
            'Recent Orders',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .limit(5)
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No orders yet',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ZenMartColors.darkBgSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ZenMartColors.tealAccent.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ${doc.id}',
                              style: const TextStyle(
                                color: ZenMartColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${data['status'] ?? 'Pending'}',
                              style: TextStyle(
                                color: ZenMartColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Rs. ${data['total'] ?? 0}',
                          style: const TextStyle(
                            color: ZenMartColors.greenAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Improved StatCard builder without overflow
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ZenMartColors.darkBgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ZenMartColors.tealAccent.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: ZenMartColors.tealAccent.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ZenMartColors.tealAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: ZenMartColors.tealAccent,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ZenMartColors.greenAccent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ZenMartColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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