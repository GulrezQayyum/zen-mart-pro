// lib/screens/rider/rider_earnings.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiderEarningsScreen extends StatelessWidget {
  const RiderEarningsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final riderId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text('⚡ Zenvyro', style: TextStyle(fontSize: 12, color: Colors.white70)),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getEarnings(riderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final earnings = snapshot.data ?? 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Total Earnings',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rs. ${earnings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Daily Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Placeholder for chart – you can use fl_chart later
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('Chart (coming soon)')),
                ),
                const SizedBox(height: 32),
                const Text('Recent Deliveries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('riderId', isEqualTo: riderId)
                      .where('status', isEqualTo: 'Delivered')
                      .orderBy('updatedAt', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final orders = snapshot.data!.docs;
                    if (orders.isEmpty) {
                      return const Text('No completed deliveries');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final data = orders[index].data() as Map<String, dynamic>;
                        // 🔥 Rider earns riderAmount (or deliveryFee)
                        final riderEarning = (data['riderAmount'] ?? data['deliveryFee'] ?? 0).toDouble();
                        return ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text('Order ${orders[index].id.substring(0, 8)}'),
                          subtitle: Text(data['deliveryAddress'] ?? ''),
                          trailing: Text(
                            'Rs. ${riderEarning.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔥 FIX: Only sum riderAmount (or deliveryFee)
  Future<double> _getEarnings(String? riderId) async {
    if (riderId == null) return 0.0;
    final query = await FirebaseFirestore.instance
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: 'Delivered')
        .get();
    double total = 0;
    for (var doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Use riderAmount, fallback to deliveryFee
      final riderEarning = (data['riderAmount'] ?? data['deliveryFee'] ?? 0).toDouble();
      total += riderEarning;
    }
    return total;
  }
}