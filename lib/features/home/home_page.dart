import 'package:flutter/material.dart';
import '../auth/services/auth_service.dart';
import '../auth/login/login.dart';
import '../role/user/main_navigator/main_navigator.dart';
import '../role/admin/main_navigator/main_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  String userName = '';
  String userRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndRedirect();
  }

  Future<void> _loadUserDataAndRedirect() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      setState(() {
        userName = userData.nama;
        userRole = userData.role;
        isLoading = false;
      });
      
      // Redirect based on role
      if (mounted) {
        if (userData.role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminMainNavigator()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const UserMainNavigator()),
          );
        }
      }
    } else {
      // No user data, redirect to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.green,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_tennis,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Redirecting...',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Badminton'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Redirecting based on role...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}