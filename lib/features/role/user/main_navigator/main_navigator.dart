import 'package:flutter/material.dart';
import '../lapangan/lapangan.dart';
import '../history_transaksi/history_transaksi.dart';
import '../profile/profile.dart';
import '../../../auth/services/auth_service.dart';

class UserMainNavigator extends StatefulWidget {
  const UserMainNavigator({super.key});

  @override
  State<UserMainNavigator> createState() => _UserMainNavigatorState();
}

class _UserMainNavigatorState extends State<UserMainNavigator> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  String userName = '';
  // Keep pages but allow refreshing History tab by replacing widget
  final List<Widget> _pages = [
    const UserLapanganPage(),
    const UserHistoryTransaksiPage(),
  ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // When switching to History tab, replace it with a new key to trigger reload
      if (index == 1) {
        _pages[1] = UserHistoryTransaksiPage(key: UniqueKey());
      }
    });
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Badminton'),
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
            icon: Icon(Icons.sports_tennis),
            label: 'Lapangan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFC42F2F),
        elevation: 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
