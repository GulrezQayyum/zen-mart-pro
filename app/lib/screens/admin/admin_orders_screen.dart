// lib/screens/admin/admin_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedStatus = 'All';

  final List<String> _statuses = [
    'All',
    'Pending',
    'Preparing',
    'Ready for Pickup',
    'Assigned',
    'Out for Delivery',
    'Delivered',
    'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          DropdownButton<String>(
            value: _selectedStatus,
            items: _statuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedStatus = value!);
            },
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.blue,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _selectedStatus == 'All'
            ? FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('orders')
                .where('status', isEqualTo: _selectedStatus)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final orderId = doc.id;
              final status = data['status'] ?? 'Pending';
              final subtotal = (data['subtotal'] ?? 0).toDouble();
              final deliveryFee = (data['deliveryFee'] ?? 0).toDouble();
              final total = (data['total'] ?? 0).toDouble();
              final vendorAmount = (data['vendorAmount'] ?? 0).toDouble();
              final riderAmount = (data['riderAmount'] ?? 0).toDouble();

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
                          Text('Order #${orderId.substring(0, 8)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text(status),
                            backgroundColor: status == 'Delivered'
                                ? Colors.green.shade100
                                : status == 'Cancelled'
                                    ? Colors.red.shade100
                                    : Colors.orange.shade100,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Shop: ${data['shopId'] ?? 'N/A'}'),
                      Text('Customer: ${data['customerId'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text('Rs. ${subtotal.toStringAsFixed(0)}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee:'),
                          Text('Rs. ${deliveryFee.toStringAsFixed(0)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Rs. ${total.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (status != 'Delivered' && status != 'Cancelled') ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _updateOrderStatus(orderId, 'Preparing'),
                              icon: const Icon(Icons.kitchen),
                              label: const Text('Preparing'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _updateOrderStatus(orderId, 'Ready for Pickup'),
                              icon: const Icon(Icons.pending),
                              label: const Text('Ready'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _completeOrder(orderId, vendorAmount, riderAmount, data['vendorId'], data['riderId']),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Deliver'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _updateOrderStatus(orderId, 'Cancelled'),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancel Order'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                      if (status == 'Delivered') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Vendor Earned'),
                                  Text('Rs. ${vendorAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Rider Earned'),
                                  Text('Rs. ${riderAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Update order status (no payment distribution)
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order status updated to $newStatus')),
    );
  }

  // Complete order: mark as Delivered and distribute payments
  Future<void> _completeOrder(
    String orderId,
    double vendorAmount,
    double riderAmount,
    String? vendorId,
    String? riderId,
  ) async {
    // 1. Update order status
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'Delivered',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Credit vendor (if vendorId exists)
    if (vendorId != null && vendorAmount > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(vendorId)
          .update({'balance': FieldValue.increment(vendorAmount)});
    }

    // 3. Credit rider (if riderId exists)
    if (riderId != null && riderAmount > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(riderId)
          .update({'balance': FieldValue.increment(riderAmount)});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order completed – payments distributed!')),
    );
  }
}