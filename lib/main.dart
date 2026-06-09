import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Imports your custom cloud keys file
import 'screens/login_screen.dart';
import 'screens/dashboard.dart';
import 'screens/inventory.dart';
import 'screens/egg_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1. This connects your app to your online Firebase project at startup
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(), // 2. Changed from MainNavigationScreen to the security gate
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. This constantly listens to the cloud to see if a farmer is signed in
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // If logged in, let them access the app
          return const MainNavigationScreen();
        }
        // If not logged in, force them to see the login box
        return const LoginScreen();
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),  
    const InventoryScreen(),  
    const EggTrackerScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poultry Farm Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        actions: [
          // 4. Added a handy Logout button in the top bar
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Inventory"),
          BottomNavigationBarItem(icon: Icon(Icons.egg), label: "Eggs"),
        ],
      ),
    );
  }
}