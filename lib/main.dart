import 'package:flutter/material.dart';
import 'features/auth/login/login.dart';
import 'features/auth/services/auth_service.dart';
import 'features/home/home_page.dart';
import 'features/role/user/main_navigator/main_navigator.dart';
import 'features/role/admin/main_navigator/main_navigator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking Badminton',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    final isLoggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    // User is logged in, check role
    final user = await _authService.getUserData();

    if (!mounted) return;

    if (user == null) {
      // Fallback to login if user data missing
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final role = (user.role).toLowerCase();
    if (role == 'admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminMainNavigator()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserMainNavigator()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Booking Badminton',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
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
}
