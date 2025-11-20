import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/logger.dart';
import 'booking_page.dart';

class UserLapanganPage extends StatefulWidget {
  const UserLapanganPage({super.key});

  @override
  State<UserLapanganPage> createState() => _UserLapanganPageState();
}

class _UserLapanganPageState extends State<UserLapanganPage> {
  final LapanganService _lapanganService = LapanganService();
  List<Lapangan> _lapanganList = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLapangan();
  }

  Future<void> _loadLapangan() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final lapanganList = await _lapanganService.getAllLapangan();
      
      // Debug logging
      AppLogger.i.i('Loaded ${lapanganList.length} lapangan');
      for (final lap in lapanganList) {
        AppLogger.i.i('Lapangan: ${lap.nama}, Foto count: ${lap.foto.length}');
        for (final foto in lap.foto) {
          AppLogger.i.i('  Foto URL: $foto');
        }
      }
      
      setState(() {
        _lapanganList = lapanganList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadLapangan();
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $_error',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLapangan,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _lapanganList.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_tennis,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada lapangan tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _lapanganList.length,
                        itemBuilder: (context, index) {
                          final lapangan = _lapanganList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: Colors.black.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingPage(lapangan: lapangan),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            lapangan.nama,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: lapangan.status == 'tersedia'
                                                ? Colors.green
                                                : (lapangan.status == 'dalam perbaikan'
                                                    ? Colors.orange
                                                    : Colors.red),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            lapangan.status.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      lapangan.deskripsi,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          size: 20,
                                          color: Color(0xFFC42F2F),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_formatRupiah(lapangan.hargaPerJam)}/jam',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFC42F2F),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (lapangan.foto.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 80,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: lapangan.foto.length,
                                          itemBuilder: (context, photoIndex) {
                                            final imageUrl = lapangan.foto[photoIndex];
                                            AppLogger.i.i('Loading image: $imageUrl');
                                            return Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              child: ImageService.buildNetworkImage(
                                                imageUrl: imageUrl,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: lapangan.status == 'tersedia'
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => BookingPage(lapangan: lapangan),
                                                  ),
                                                );
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFC42F2F),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.all(12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          lapangan.status == 'tersedia'
                                              ? 'Booking Sekarang'
                                              : (lapangan.status == 'dalam perbaikan'
                                                  ? 'Dalam Perbaikan'
                                                  : 'Tidak Tersedia'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
