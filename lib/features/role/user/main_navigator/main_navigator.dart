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
    const UserLapanganPage(),
    const UserHistoryTransaksiPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Badminton'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _navigateToProfile,
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: 'Lapangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
