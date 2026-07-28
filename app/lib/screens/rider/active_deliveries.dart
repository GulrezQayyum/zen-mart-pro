import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/delivery_card.dart';

class ActiveDeliveriesScreen extends StatelessWidget {
  const ActiveDeliveriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final riderId = FirebaseAuth.instance.currentUser?.uid;

    // ✅ No Scaffold – just return the StreamBuilder
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('riderId', isEqualTo: riderId)
          .where('status', whereIn: ['Assigned', 'Picked Up', 'Out for Delivery'])
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
          return const Center(child: Text('No active deliveries'));
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
              distance: '2.3 km',
              isActive: true,
              onAccept: () => _showStatusUpdate(context, orders[index].id),
              onTap: () {},
            );
          },
        );
      },
    );
  }

  void _showStatusUpdate(BuildContext context, String orderId) {
    showModalBottomSheet(
      context: context, // ✅ REQUIRED – pass the context
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Picked Up'),
              onTap: () async {
                await _updateStatus(orderId, 'Picked Up');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Out for Delivery'),
              onTap: () async {
                await _updateStatus(orderId, 'Out for Delivery');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Delivered'),
              onTap: () async {
                await _updateStatus(orderId, 'Delivered');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}