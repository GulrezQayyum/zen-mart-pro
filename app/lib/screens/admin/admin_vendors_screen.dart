import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminVendorsScreen extends StatelessWidget {
  const AdminVendorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Use parent's AppBar
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateVendorDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ----- Dialog: Assign existing shop to vendor -----
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

  // lib/screens/admin/admin_vendors_screen.dart
// Add these imports at the top:
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

  void _showCreateVendorDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Vendor'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty || !v.contains('@')
                    ? 'Valid email required'
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  // 1. Create Auth user
                  final authResult = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );
                  final uid = authResult.user!.uid;

                  // 2. Save Firestore doc with UID as ID
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({
                    'displayName': _nameController.text.trim(),
                    'email': _emailController.text.trim(),
                    'role': 'vendor',
                    'shopId': null,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // ✅ Use context.mounted instead of mounted
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Vendor created successfully')),
                  );
                } on FirebaseAuthException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Auth error: ${e.message}')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
