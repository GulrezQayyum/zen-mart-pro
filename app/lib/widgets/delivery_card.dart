import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                Chip(label: Text(isActive ? 'Active' : 'Available')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(from),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('To:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(to),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(distance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.orange : theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isActive ? 'Track' : 'Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}