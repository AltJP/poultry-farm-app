import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _countController = TextEditingController();
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  Future<void> _saveInventoryRecord() async {
    if (_countController.text.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('inventory_records').add({
        'farmerId': _userId,
        'chickenCount': int.parse(_countController.text.trim()),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _countController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chicken Inventory'), backgroundColor: Colors.blue.shade700),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Chicken Count', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, minimumSize: const Size.fromHeight(50)),
              onPressed: _saveInventoryRecord,
              child: const Text('Update Inventory Count', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
            const Text('Inventory History:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('inventory_records')
                    .where('farmerId', isEqualTo: _userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No counts logged yet.'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.pets, color: Colors.blue),
                          title: Text('${data['chickenCount']} Chickens Logged'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}