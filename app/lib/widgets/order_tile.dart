import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String total;
  final String status;
  final VoidCallback onTap; // ✅ REQUIRED

  const OrderTile({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.total,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text('$orderId - $customerName'),
          subtitle: Text('Total: $total'),
          trailing: Chip(
            label: Text(status, style: const TextStyle(fontSize: 12)),
            backgroundColor: status == 'Pending'
                ? Colors.orange.shade100
                : status == 'Delivered'
                    ? Colors.green.shade100
                    : Colors.blue.shade100,
          ),
        ),
      ),
    );
  }
}