import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import 'add_edit_lapangan_page.dart';

class DetailLapanganPage extends StatefulWidget {
  final Lapangan lapangan;
  
  const DetailLapanganPage({super.key, required this.lapangan});

  @override
  State<DetailLapanganPage> createState() => _DetailLapanganPageState();
}

class _DetailLapanganPageState extends State<DetailLapanganPage> {
  final LapanganService _lapanganService = LapanganService();
  late Lapangan _lapangan;
  bool _isLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _lapangan = widget.lapangan;
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditLapanganPage(lapangan: _lapangan),
      ),
    );
    
    if (result == true) {
      // Refresh data if lapangan was updated
      _refreshLapangan();
    }
  }

  Future<void> _refreshLapangan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedLapangan = await _lapanganService.getLapanganById(_lapangan.id);
      setState(() {
        _lapangan = updatedLapangan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLapangan() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus lapangan "${_lapangan.nama}"?\n\nTindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _lapanganService.deleteLapangan(_lapangan.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lapangan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen with success result
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus lapangan: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lapangan'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (!_isDeleting) ...[
            IconButton(
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Lapangan',
            ),
            IconButton(
              onPressed: _deleteLapangan,
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus Lapangan',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isDeleting
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Menghapus lapangan...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _lapangan.nama,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _lapangan.status == 'tersedia'
                                          ? Colors.green
                                          : (_lapangan.status == 'dalam perbaikan'
                                              ? Colors.orange
                                              : Colors.red),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _lapangan.status == 'tersedia'
                                          ? 'TERSEDIA'
                                          : (_lapangan.status == 'dalam perbaikan'
                                              ? 'DALAM PERBAIKAN'
                                              : 'TIDAK TERSEDIA'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _lapangan.deskripsi,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 24,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_formatRupiah(_lapangan.hargaPerJam)}/jam',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Photos Section
                      if (_lapangan.foto.isNotEmpty) ...[
                        const Text(
                          'Foto Lapangan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _lapangan.foto.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 300,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _lapangan.foto[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Gagal memuat gambar',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Information Card
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informasi Lapangan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'ID Lapangan',
                                _lapangan.id,
                                Icons.tag,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Nama',
                                _lapangan.nama,
                                Icons.sports_tennis,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Harga per Jam',
                                _formatRupiah(_lapangan.hargaPerJam),
                                Icons.attach_money,
                              ),
                              const SizedBox(height: 8),
                _buildInfoRow(
                'Status',
                _lapangan.status == 'tersedia'
                  ? 'Tersedia'
                  : (_lapangan.status == 'dalam perbaikan'
                    ? 'Dalam Perbaikan'
                    : 'Tidak Tersedia'),
                _lapangan.status == 'tersedia'
                  ? Icons.check_circle
                  : (_lapangan.status == 'dalam perbaikan'
                    ? Icons.build
                    : Icons.cancel),
                valueColor: _lapangan.status == 'tersedia'
                  ? Colors.green
                  : (_lapangan.status == 'dalam perbaikan'
                    ? Colors.orange
                    : Colors.red),
                ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Dibuat',
                                _formatDate(_lapangan.createdAt),
                                Icons.calendar_today,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Terakhir Diperbarui',
                                _formatDate(_lapangan.updatedAt),
                                Icons.update,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _navigateToEdit,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Lapangan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _deleteLapangan,
                              icon: const Icon(Icons.delete),
                              label: const Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
