import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/delivery_card.dart';

class AvailableDeliveriesScreen extends StatelessWidget {
  const AvailableDeliveriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final riderId = FirebaseAuth.instance.currentUser?.uid;

    // No Scaffold – just return the body widget
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Ready for Pickup')
          .where('riderId', isEqualTo: null)
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
          return const Center(child: Text('No deliveries available'));
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
              distance: '3.5 km',
              isActive: false,
              onAccept: () async {
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orders[index].id)
                    .update({
                  'riderId': riderId,
                  'status': 'Assigned',
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order accepted!')),
                );
              },
            );
          },
        );
      },
    );
  }
}