import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'inventory.dart';
import 'egg_tracker.dart';
import 'expenses.dart';
import 'feeding.dart';
import 'health.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalChickens = 0;
  int eggsToday = 0;
  double feedStock = 0;
  double expensesToday = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final db = await DatabaseHelper.instance.database;

    // Chickens count
    final chickens = await db.query('chickens');
    setState(() => totalChickens = chickens.fold(0, (sum, row) => sum + (row['quantity'] as int)));

    // Eggs collected today
    String today = DateTime.now().toString().split(' ')[0];
    final eggs = await db.query('eggs', where: 'date = ?', whereArgs: [today]);
    setState(() => eggsToday = eggs.fold(0, (sum, row) => sum + (row['quantity'] as int)));

    // Feed stock (optional: sum of feed table)
    final feed = await db.query('feed');
    setState(() => feedStock = feed.fold(0.0, (sum, row) => sum + (row['quantity'] as double)));

    // Expenses today
    final expenses = await db.query('expenses', where: 'date = ?', whereArgs: [today]);
    setState(() => expensesToday = expenses.fold(0.0, (sum, row) => sum + (row['amount'] as double)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poultry Farm Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Core Metrics Top Grid
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: Column(
                        children: [
                          const Icon(Icons.pets, color: Colors.blue, size: 28),
                          const SizedBox(height: 8),
                          Text('$totalChickens',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Total Chickens',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: Column(
                        children: [
                          const Icon(Icons.egg, color: Colors.amber, size: 28),
                          const SizedBox(height: 8),
                          Text('$eggsToday',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Eggs Today',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: Column(
                        children: [
                          const Icon(Icons.grass, color: Colors.green, size: 28),
                          const SizedBox(height: 8),
                          Text('$feedStock kg',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Feed Stock',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Summary Banner
            Card(
              elevation: 3,
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.payments, color: Colors.green.shade700, size: 30),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's Expenses",
                            style: TextStyle(color: Colors.green.shade800, fontSize: 14)),
                        Text("Php $expensesToday",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Core Research Modules",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Buttons for all modules
            _buildModuleButton(context, "Chicken Inventory", Icons.pets, Colors.blue,
                const InventoryScreen()),
            _buildModuleButton(context, "Egg Tracker", Icons.egg, Colors.amber,
                const EggTrackerScreen()),
            _buildModuleButton(context, "Expenses", Icons.payments, Colors.green,
                const ExpensesScreen()),
            _buildModuleButton(context, "Feeding Schedule", Icons.grass, Colors.brown,
                const FeedingScreen()),
            _buildModuleButton(context, "Health Logs", Icons.health_and_safety, Colors.red,
                const HealthScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleButton(
      BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.white,
          foregroundColor: color,
          side: BorderSide(color: color.withAlpha(100), width: 1.5), // fixed deprecated withOpacity
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          _loadDashboardData(); // refresh after returning
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
