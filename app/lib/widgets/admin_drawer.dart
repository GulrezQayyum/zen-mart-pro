// lib/widgets/admin_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class AdminDrawer extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const AdminDrawer({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Admin Panel',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildTile(
            context,
            index: 0,
            icon: Icons.dashboard,
            title: 'Dashboard',
          ),
          _buildTile(
            context,
            index: 1,
            icon: Icons.store,
            title: 'Vendors',
          ),
          _buildTile(
            context,
            index: 2,
            icon: Icons.shop,
            title: 'Shops',
          ),
          _buildTile(
            context,
            index: 3,
            icon: Icons.shopping_bag,
            title: 'Orders',
          ),
          _buildTile(
            context,
            index: 4,
            icon: Icons.two_wheeler,
            title: 'Riders',
          ),
          _buildTile(
            context,
            index: 5,
            icon: Icons.people,
            title: 'Customers',
          ),
          _buildTile(
            context,
            index: 6,
            icon: Icons.analytics,
            title: 'Analytics',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required int index, required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: currentIndex == index ? Colors.blue : null),
      title: Text(title,
          style: TextStyle(
              fontWeight:
                  currentIndex == index ? FontWeight.bold : FontWeight.normal,
              color: currentIndex == index ? Colors.blue : null)),
      onTap: () {
        onItemSelected(index);
        Navigator.pop(context);
      },
    );
  }
}