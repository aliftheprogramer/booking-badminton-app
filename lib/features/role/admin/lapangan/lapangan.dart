import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import 'add_edit_lapangan_page.dart';
import 'detail_lapangan.dart';

class AdminLapanganPage extends StatefulWidget {
  const AdminLapanganPage({super.key});

  @override
  State<AdminLapanganPage> createState() => _AdminLapanganPageState();
}

class _AdminLapanganPageState extends State<AdminLapanganPage> {
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

  Future<void> _navigateToAddLapangan() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditLapanganPage(),
      ),
    );
    
    if (result == true) {
      _loadLapangan(); // Refresh data if lapangan was added
    }
  }

  Future<void> _navigateToDetailLapangan(Lapangan lapangan) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailLapanganPage(lapangan: lapangan),
      ),
    );
    
    if (result == true) {
      _loadLapangan(); // Refresh data if lapangan was updated/deleted
    }
  }

  Future<void> _navigateToEditLapangan(Lapangan lapangan) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditLapanganPage(lapangan: lapangan),
      ),
    );
    
    if (result == true) {
      _loadLapangan(); // Refresh data if lapangan was updated
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                : Column(
                    children: [
                      // Header with Add Button
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kelola Lapangan (${_lapanganList.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _navigateToAddLapangan,
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Lapangan List
                      Expanded(
                        child: _lapanganList.isEmpty
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
                                      'Belum ada lapangan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _lapanganList.length,
                                itemBuilder: (context, index) {
                                  final lapangan = _lapanganList[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () => _navigateToDetailLapangan(lapangan),
                                      borderRadius: BorderRadius.circular(4),
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
                                                      fontSize: 10,
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
                                                Icon(
                                                  Icons.attach_money,
                                                  size: 20,
                                                  color: Colors.green[700],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${_formatRupiah(lapangan.hargaPerJam)}/jam',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[700],
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
                                                    return Container(
                                                      margin: const EdgeInsets.only(right: 8),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.network(
                                                          lapangan.foto[photoIndex],
                                                          width: 80,
                                                          height: 80,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Container(
                                                              width: 80,
                                                              height: 80,
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey[300],
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: const Icon(
                                                                Icons.image_not_supported,
                                                                color: Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 16),
                                            // Action Buttons
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () => _navigateToEditLapangan(lapangan),
                                                    icon: const Icon(Icons.edit, size: 16),
                                                    label: const Text('Edit'),
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: Colors.blue,
                                                      side: const BorderSide(color: Colors.blue),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => _navigateToDetailLapangan(lapangan),
                                                    icon: const Icon(Icons.visibility, size: 16),
                                                    label: const Text('Detail'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.orange,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLapangan,
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
