import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';

class CustomerHome extends ConsumerStatefulWidget {
  const CustomerHome({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends ConsumerState<CustomerHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zen Mart Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Call signOut directly via the auth service provider
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            const SearchBar(
              hintText: 'Search shops or products...',
              leading: Icon(Icons.search),
            ),
            const SizedBox(height: 24),

            // Featured Section
            const Text(
              'Featured Shops',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ShopCard(shopName: 'Pizza Palace', rating: 4.5),
                  ShopCard(shopName: 'Burger Barn', rating: 4.2),
                  ShopCard(shopName: 'Salad Station', rating: 4.8),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Popular Products
            const Text(
              'Popular Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: const [
                ProductCard(
                    productName: 'Biryani', price: 'Rs. 450', rating: 4.5),
                ProductCard(
                    productName: 'Karahi', price: 'Rs. 550', rating: 4.3),
                ProductCard(
                    productName: 'Tikka', price: 'Rs. 350', rating: 4.7),
                ProductCard(
                    productName: 'Nihari', price: 'Rs. 400', rating: 4.4),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// Custom Shop Card Widget
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
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 70,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.store, size: 36, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shopName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('$rating', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Product Card Widget
class ProductCard extends StatelessWidget {
  final String productName;
  final String price;
  final double rating;

  const ProductCard({
    Key? key,
    required this.productName,
    required this.price,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text('$rating', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
