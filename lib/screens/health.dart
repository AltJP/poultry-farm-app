import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _healthController = TextEditingController();
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  Future<void> _saveHealthRecord() async {
    if (_healthController.text.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('health_records').add({
        'farmerId': _userId,
        'statusNote': _healthController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _healthController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health condition logged!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Logs'), 
        backgroundColor: Colors.purple.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _healthController,
              decoration: const InputDecoration(
                labelText: 'Enter Health Status or Notes (e.g., Vaccinated)', 
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700, 
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _saveHealthRecord,
              child: const Text('Log Flock Health Condition', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
            const Text('Flock Condition History:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('health_records')
                    .where('farmerId', isEqualTo: _userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No health observations recorded.'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.favorite, color: Colors.purple),
                          title: Text('${data['statusNote'] ?? 'No notes entered'}'),
                          subtitle: const Text('Saved to Server Record'),
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