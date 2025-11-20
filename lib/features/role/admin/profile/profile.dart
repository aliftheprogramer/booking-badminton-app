import 'package:flutter/material.dart';
import '../../../auth/services/auth_service.dart';
import '../../../auth/models/auth_models.dart';
import '../../../auth/login/login.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final AuthService _authService = AuthService();
  AuthResponse? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: const Color(0xFFC42F2F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(
                  child: Text(
                    'Gagal memuat data profile',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFFC42F2F).withOpacity(0.1),
                                child: Text(
                                  _userData!.nama.isNotEmpty 
                                      ? _userData!.nama[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC42F2F),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _userData!.nama,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC42F2F),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _userData!.role.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Information
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProfileTile(
                              icon: Icons.person,
                              title: 'Nama Lengkap',
                              subtitle: _userData!.nama,
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _buildProfileTile(
                              icon: Icons.phone,
                              title: 'Nomor HP',
                              subtitle: _userData!.noHp,
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _buildProfileTile(
                              icon: Icons.verified_user,
                              title: 'Role',
                              subtitle: _userData!.role,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Admin Features
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProfileTile(
                              icon: Icons.sports_tennis,
                              title: 'Kelola Lapangan',
                              subtitle: 'Tambah dan edit lapangan',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gunakan tab Lapangan untuk mengelola'),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _buildProfileTile(
                              icon: Icons.analytics,
                              title: 'Laporan Transaksi',
                              subtitle: 'Lihat semua transaksi dan revenue',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gunakan tab Transaksi untuk melihat laporan'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // App Information
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProfileTile(
                              icon: Icons.info,
                              title: 'Tentang Aplikasi',
                              subtitle: 'Booking Badminton Admin v1.0.0',
                              showTrailing: false,
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _buildProfileTile(
                              icon: Icons.help,
                              title: 'Bantuan Admin',
                              subtitle: 'Panduan penggunaan admin panel',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur bantuan admin akan segera hadir'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool showTrailing = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFC42F2F),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: showTrailing && onTap != null
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }
}
