// lib/screens/admin/admin_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/stat_card.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Revenue Overview',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(child: Text('Chart (coming soon)')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: _getOrderCounts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                        title: 'Total Orders',
                        value: data['total'].toString(),
                        icon: Icons.shopping_bag),
                    StatCard(
                        title: 'Pending',
                        value: data['pending'].toString(),
                        icon: Icons.pending),
                    StatCard(
                        title: 'Delivered',
                        value: data['delivered'].toString(),
                        icon: Icons.check_circle),
                    StatCard(
                        title: 'Cancelled',
                        value: data['cancelled'].toString(),
                        icon: Icons.cancel),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, int>> _getOrderCounts() async {
    final total = await FirebaseFirestore.instance.collection('orders').get();
    final pending = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Pending')
        .get();
    final delivered = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Delivered')
        .get();
    final cancelled = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Cancelled')
        .get();
    return {
      'total': total.docs.length,
      'pending': pending.docs.length,
      'delivered': delivered.docs.length,
      'cancelled': cancelled.docs.length,
    };
  }
}