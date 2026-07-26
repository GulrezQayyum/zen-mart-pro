import 'package:flutter/material.dart';

class ShopCard extends StatelessWidget {
  final String shopName;
  final double rating;

  const ShopCard({
    Key? key,
    required this.shopName,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store, size: 40),
            const SizedBox(height: 8),
            Text(
              shopName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                Text(' $rating'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}