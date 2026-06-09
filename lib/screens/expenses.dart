import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _amountController = TextEditingController();
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  Future<void> _saveExpenseRecord() async {
    if (_amountController.text.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('expense_records').add({
        'farmerId': _userId,
        'amount': double.parse(_amountController.text.trim()),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _amountController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense logged successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Expenses'), backgroundColor: Colors.red.shade700),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter Expense Amount (Php)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, minimumSize: const Size.fromHeight(50)),
              onPressed: _saveExpenseRecord,
              child: const Text('Log Expense', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
            const Text('Log History:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('expense_records')
                    .where('farmerId', isEqualTo: _userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No expenses recorded yet.'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.money_off, color: Colors.red),
                          title: Text('Php ${data['amount']} Spent'),
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