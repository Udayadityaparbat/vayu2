// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // generated manually or by flutterfire

import 'src/ui/screens/auth_screen.dart';
import 'src/ui/screens/profile_screen.dart';
import 'src/ui/screens/report_screen.dart';
import 'src/ui/screens/insights_screen.dart';
import 'src/ui/screens/explore_screen.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Keep app running (useful for local dev fallback)
    // ignore: avoid_print
    print('Firebase init warning (continuing): $e');
  }

  runApp(const VayuApp());
}

class VayuApp extends StatelessWidget {
  const VayuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vayu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/home': (_) => const MainShell(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const <Widget>[
    ReportScreen(),
    InsightsScreen(),
    ExploreScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('World AQI', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text('72', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open search (TODO)')));
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search),
                      SizedBox(width: 8),
                      Expanded(child: Text('Search city or ZIP', style: TextStyle(color: Colors.grey))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: const CircleAvatar(radius: 20, child: Icon(Icons.person)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: SizedBox.expand(
                  key: ValueKey<int>(_selectedIndex),
                  child: _pages[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.indigo,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        ],
      ),
    );
  }
}
