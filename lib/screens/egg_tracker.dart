import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EggTrackerScreen extends StatefulWidget {
  const EggTrackerScreen({super.key});

  @override
  State<EggTrackerScreen> createState() => _EggTrackerScreenState();
}

class _EggTrackerScreenState extends State<EggTrackerScreen> {
  final _eggController = TextEditingController();
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  // FUNCTION 1: Saves the typed egg count directly into the cloud database
  Future<void> _saveEggRecord() async {
    if (_eggController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('egg_records').add({
        'farmerId': _userId, // Ties this specific record to the logged-in farmer!
        'eggCount': int.parse(_eggController.text.trim()),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _eggController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Egg record saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  // NEW FUNCTION: Deletes a specific record using its Firestore document ID
  Future<void> _deleteEggRecord(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('egg_records')
          .doc(docId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Egg Production Tracker'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Form to type numbers
            TextField(
              controller: _eggController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Today\'s Egg Count',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _saveEggRecord,
              child: const Text('Save to Cloud Database', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
            const Text('Your Saved Production History:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // FUNCTION 2: Live list stream that pulls data ONLY belonging to this specific farmer ID
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('egg_records')
                    .where('farmerId', isEqualTo: _userId) // Filters out other farmers' records!
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No records found yet. Try adding one above!'));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index]; // 👈 Reference the complete document snapshot
                      final data = doc.data() as Map<String, dynamic>;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.egg, color: Colors.orange),
                          title: Text('${data['eggCount'] ?? 0} Eggs Collected'),
                          subtitle: const Text('Saved to Cloud Securely'),
                          
                          // 🛠️ ADDED: Delete Button with confirmation dialog
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Action confirmation pop-up
                              final confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Record'),
                                  content: const Text('Are you sure you want to remove this egg collection entry?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              // If confirmed, trigger deletion function
                              if (confirmDelete == true) {
                                _deleteEggRecord(doc.id);
                              }
                            },
                          ),
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