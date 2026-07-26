// lib/widgets/delivery_card.dart
import 'package:flutter/material.dart';

class DeliveryCard extends StatelessWidget {
  final String orderId;
  final String from;
  final String to;
  final String amount;
  final String distance;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;

  const DeliveryCard({
    Key? key,
    required this.orderId,
    required this.from,
    required this.to,
    required this.amount,
    required this.distance,
    this.isActive = false,
    this.onTap,
    this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
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
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.orange : theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isActive ? 'View Route' : 'Accept Order'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}