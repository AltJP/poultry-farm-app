import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  final _feedController = TextEditingController();
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  Future<void> _saveFeedingRecord() async {
    if (_feedController.text.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('feeding_records').add({
        'farmerId': _userId,
        'feedAmount': _feedController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _feedController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feeding log saved successfully!')),
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
        title: const Text('Feeding Schedule'), 
        backgroundColor: Colors.teal.shade700,
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
              controller: _feedController,
              decoration: const InputDecoration(
                labelText: 'Enter Feed Type or Weight (e.g., 50kg Mash)', 
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700, 
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _saveFeedingRecord,
              child: const Text('Log Feed Distribution', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
            const Text('Feeding History Logs:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('feeding_records')
                    .where('farmerId', isEqualTo: _userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No feeding logs yet.'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.restaurant, color: Colors.teal),
                          title: Text('${data['feedAmount'] ?? 'No text entered'}'), 
                          subtitle: const Text('Logged to Cloud Securely'),
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