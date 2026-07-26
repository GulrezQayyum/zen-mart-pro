import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';

class RiderDashboard extends ConsumerStatefulWidget {
  const RiderDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends ConsumerState<RiderDashboard> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
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
            // Rider Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    currentUserAsync.when(
                      data: (user) => Text(
                        'Welcome, ${user?.displayName.isNotEmpty == true ? user!.displayName : 'Rider'}!',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      loading: () => const Text(
                        'Welcome, Rider!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      error: (_, __) => const Text(
                        'Welcome, Rider!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InfoColumn(label: 'Total Deliveries', value: '48'),
                        InfoColumn(label: 'Rating', value: '4.8 ⭐'),
                        InfoColumn(label: 'Today Earnings', value: 'Rs. 1,200'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Available Deliveries Section
            const Text(
              'Available Deliveries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const DeliveryCard(
              orderId: 'ORD001',
              from: 'Pizza Palace',
              to: 'Defence Phase 1',
              amount: 'Rs. 150',
              distance: '3.5 km',
            ),
            const DeliveryCard(
              orderId: 'ORD002',
              from: 'Burger Barn',
              to: 'DHA Phase 2',
              amount: 'Rs. 200',
              distance: '5.2 km',
            ),
            const SizedBox(height: 32),

            // Active Deliveries Section
            const Text(
              'Active Deliveries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const DeliveryCard(
              orderId: 'ORD003',
              from: 'Salad Station',
              to: 'G-11 Markaz',
              amount: 'Rs. 120',
              distance: '2.1 km',
              isActive: true,
            ),
          ],
        ),
      ),
    );
  }
}

// Info Column Widget
class InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const InfoColumn({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// Delivery Card Widget
class DeliveryCard extends StatelessWidget {
  final String orderId;
  final String from;
  final String to;
  final String amount;
  final String distance;
  final bool isActive;

  const DeliveryCard({
    Key? key,
    required this.orderId,
    required this.from,
    required this.to,
    required this.amount,
    required this.distance,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.storefront, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text('From: $from')),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text('To: $to')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(distance, style: const TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.navigation, size: 14),
                  visualDensity: VisualDensity.compact,
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Handle accept / view delivery action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isActive ? Colors.orange : theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isActive ? 'View Route' : 'Accept Order'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
