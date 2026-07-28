import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/delivery_card.dart';

class DeliveryHistoryScreen extends StatelessWidget {
  const DeliveryHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final riderId = FirebaseAuth.instance.currentUser?.uid;

    // ✅ Return only the StreamBuilder (no Scaffold, no AppBar)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('riderId', isEqualTo: riderId)
          .where('status', isEqualTo: 'Delivered')
          .orderBy('updatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!.docs;
        if (orders.isEmpty) {
          return const Center(child: Text('No delivery history'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final data = orders[index].data() as Map<String, dynamic>;
            return DeliveryCard(
              orderId: orders[index].id,
              from: data['shopId'] ?? 'Shop',
              to: data['deliveryAddress'] ?? 'Address',
              amount: data['total']?.toString() ?? '0',
              distance: '2.0 km',
              isActive: false,
              onAccept: null, // no action for history
            );
          },
        );
      },
    );
  }
}