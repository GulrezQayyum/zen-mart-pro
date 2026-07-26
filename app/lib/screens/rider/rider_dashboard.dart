import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/delivery_card.dart';
import '../../widgets/info_column.dart';
import 'available_deliveries.dart';
import 'active_deliveries.dart';
import 'delivery_history.dart';
import 'rider_earnings.dart';
import '../../widgets/stat_card.dart';

class RiderDashboard extends ConsumerStatefulWidget {
  const RiderDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends ConsumerState<RiderDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _RiderHomeBody(),
    const AvailableDeliveriesScreen(),
    const ActiveDeliveriesScreen(),
    const DeliveryHistoryScreen(),
    const RiderEarningsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text('⚡ Zenvyro', style: TextStyle(fontSize: 12, color: Colors.white70)),
            ),
          ),
          // Logout button added inside pages to avoid duplication
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Available'),
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Active'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Earnings'),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// ========== Home Body (Dashboard Summary) ==========
class _RiderHomeBody extends ConsumerWidget {
  const _RiderHomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final riderId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
            // Rider Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    currentUserAsync.when(
                      data: (user) => Text(
                        'Welcome, ${user?.displayName.isNotEmpty == true ? user!.displayName : 'Rider'}!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      loading: () => const Text('Welcome, Rider!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      error: (_, __) => const Text('Welcome, Rider!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    // Stats – real values from Firestore
                    FutureBuilder(
                      future: _getRiderStats(riderId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InfoColumn(label: 'Total Deliveries', value: '...'),
                              InfoColumn(label: 'Rating', value: '...'),
                              InfoColumn(label: 'Today Earnings', value: '...'),
                            ],
                          );
                        }
                        final stats = snapshot.data ?? {'deliveries': 0, 'rating': 0.0, 'earnings': 0.0};
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InfoColumn(label: 'Total Deliveries', value: stats['deliveries'].toString()),
                            InfoColumn(label: 'Rating', value: stats['rating'].toStringAsFixed(1) + ' ⭐'),
                            InfoColumn(label: 'Today Earnings', value: 'Rs. ${stats['earnings'].toStringAsFixed(0)}'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Quick stats cards using StatCard
            const Text('Quick Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            FutureBuilder(
              future: _getDeliveryCounts(riderId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final counts = snapshot.data!;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(title: 'Available', value: counts['available'].toString(), icon: Icons.list_alt),
                    StatCard(title: 'Active', value: counts['active'].toString(), icon: Icons.delivery_dining),
                    StatCard(title: 'Completed', value: counts['completed'].toString(), icon: Icons.check_circle),
                    StatCard(title: 'Total Earnings', value: 'Rs. ${counts['totalEarnings'].toStringAsFixed(0)}', icon: Icons.money),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Recent deliveries (last 3)
            const Text('Recent Deliveries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('riderId', isEqualTo: riderId)
                  .orderBy('updatedAt', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data!.docs;
                if (orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No deliveries yet'),
                  );
                }
                return Column(
                  children: orders.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DeliveryCard(
                      orderId: doc.id,
                      from: data['shopId'] ?? 'Shop', // you can fetch shop name separately
                      to: data['deliveryAddress'] ?? 'Address',
                      amount: data['total']?.toString() ?? '0',
                      distance: '3.2 km', // placeholder
                      isActive: data['status'] != 'Delivered',
                      onTap: () {
                        // Navigate to order tracking
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper: get rider stats
  Future<Map<String, dynamic>> _getRiderStats(String? riderId) async {
    if (riderId == null) return {'deliveries': 0, 'rating': 0.0, 'earnings': 0.0};

    final completed = await FirebaseFirestore.instance
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: 'Delivered')
        .get();

    final totalDeliveries = completed.docs.length;
    double totalEarnings = 0;
    for (var doc in completed.docs) {
      totalEarnings += (doc.data()['total'] ?? 0).toDouble();
    }
    // Placeholder rating – you can add a rating field later
    return {
      'deliveries': totalDeliveries,
      'rating': 4.7,
      'earnings': totalEarnings,
    };
  }

  Future<Map<String, dynamic>> _getDeliveryCounts(String? riderId) async {
    if (riderId == null) return {'available': 0, 'active': 0, 'completed': 0, 'totalEarnings': 0.0};

    // Available: orders with status 'Ready for Pickup' and no rider assigned
    final available = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Ready for Pickup')
        .where('riderId', isEqualTo: null)
        .get();

    // Active: orders assigned to this rider and not delivered
    final active = await FirebaseFirestore.instance
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', whereIn: ['Assigned', 'Picked Up', 'Out for Delivery'])
        .get();

    // Completed: delivered orders
    final completed = await FirebaseFirestore.instance
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: 'Delivered')
        .get();

    double totalEarnings = 0;
    for (var doc in completed.docs) {
      totalEarnings += (doc.data()['total'] ?? 0).toDouble();
    }

    return {
      'available': available.docs.length,
      'active': active.docs.length,
      'completed': completed.docs.length,
      'totalEarnings': totalEarnings,
    };
  }
}