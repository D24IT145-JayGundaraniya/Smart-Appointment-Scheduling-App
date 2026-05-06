import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'providers/appointment_provider.dart';
import 'screens/user/booking_screen.dart';
import 'screens/user/queue_status_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppointmentProvider()..loadAppointments()),
      ],
      child: const SmartAppointmentApp(),
    ),
  );
}

class SmartAppointmentApp extends StatelessWidget {
  const SmartAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoWash Scheduler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern Indigo
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF4F46E5),
          surface: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Inter',
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BookingScreen(),
    const QueueStatusScreen(),
    const SearchScreen(),
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF6366F1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundColor: Colors.white, radius: 30, child: Icon(Icons.directions_car, color: Color(0xFF6366F1))),
                  SizedBox(height: 10),
                  Text('AutoWash Pro', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Smart Queue Management', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            _DrawerItem(icon: Icons.calendar_today, label: 'Book a Wash', index: 0, selectedIndex: _selectedIndex, onTap: _onItemTapped),
            _DrawerItem(icon: Icons.line_weight, label: 'Live Queue', index: 1, selectedIndex: _selectedIndex, onTap: _onItemTapped),
            _DrawerItem(icon: Icons.search, label: 'Search Bookings', index: 2, selectedIndex: _selectedIndex, onTap: _onItemTapped),
            const Divider(),
            _DrawerItem(icon: Icons.admin_panel_settings, label: 'Admin Dashboard', index: 3, selectedIndex: _selectedIndex, onTap: _onItemTapped),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Book'),
          NavigationDestination(icon: Icon(Icons.queue), label: 'Queue'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _DrawerItem({required this.icon, required this.label, required this.index, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selectedIndex == index ? const Color(0xFF6366F1) : null),
      title: Text(label, style: TextStyle(color: selectedIndex == index ? const Color(0xFF6366F1) : null, fontWeight: selectedIndex == index ? FontWeight.bold : null)),
      onTap: () => onTap(index),
      selected: selectedIndex == index,
    );
  }
}
