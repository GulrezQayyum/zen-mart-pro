// lib/screens/admin/admin_vendors_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVendorsScreen extends StatelessWidget {
  const AdminVendorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendors')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'vendor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No vendors found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['displayName'] ?? 'No name'),
                  subtitle: Text(data['email'] ?? ''),
                  trailing: data['shopId'] != null
                      ? const Chip(label: Text('Shop Assigned'))
                      : ElevatedButton(
                          onPressed: () {
                            _showAssignShopDialog(context, docs[index].id);
                          },
                          child: const Text('Assign Shop'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAssignShopDialog(BuildContext context, String vendorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Shop'),
        content: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('shops')
              .where('vendorId', isEqualTo: null)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final shops = snapshot.data!.docs;
            if (shops.isEmpty) {
              return const Text('No unassigned shops available');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: shops.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['name'] ?? 'Shop'),
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection('shops')
                        .doc(doc.id)
                        .update({'vendorId': vendorId});
                    // Also update vendor's shopId
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(vendorId)
                        .update({'shopId': doc.id});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Shop assigned')));
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}