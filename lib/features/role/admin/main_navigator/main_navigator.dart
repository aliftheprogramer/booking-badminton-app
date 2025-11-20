import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../lapangan/lapangan.dart';
import '../history_transaksi/history_transaksi.dart';
import '../profile/profile.dart';
import '../../../auth/services/auth_service.dart';

class AdminMainNavigator extends StatefulWidget {
  const AdminMainNavigator({super.key});

  @override
  State<AdminMainNavigator> createState() => _AdminMainNavigatorState();
}

class _AdminMainNavigatorState extends State<AdminMainNavigator> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      setState(() {
        userName = userData.nama;
      });
    }
  }

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminLapanganPage(),
    const AdminHistoryTransaksiPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFFC42F2F),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToProfile,
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: 'Lapangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Transaksi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFC42F2F),
        elevation: 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
