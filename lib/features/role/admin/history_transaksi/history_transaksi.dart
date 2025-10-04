import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/logger.dart';
import 'history_detail_page.dart';

class AdminHistoryTransaksiPage extends StatefulWidget {
  const AdminHistoryTransaksiPage({super.key});

  @override
  State<AdminHistoryTransaksiPage> createState() =>
      _AdminHistoryTransaksiPageState();
}

class _AdminHistoryTransaksiPageState extends State<AdminHistoryTransaksiPage> {
  final BookingService _bookingService = BookingService();
  List<HistoryItem> _historyList = [];
  bool _isLoading = true;
  String _error = '';
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _limit = 20;
  
  final TextEditingController _searchController = TextEditingController();
  final List<String> _actionFilters = [
    'Semua',
    'booking_created',
    'booking_updated',
    'booking_cancelled',
    'payment_updated'
  ];

  @override
  void initState() {
    super.initState();
    _loadAdminHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminHistory({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
      }
      
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response = await _bookingService.getAdminHistory(
        page: _currentPage,
        limit: _limit,
        action: _selectedFilter == 'Semua' ? null : _selectedFilter,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      setState(() {
        if (isRefresh || _currentPage == 1) {
          _historyList = response['items'] ?? [];
        } else {
          _historyList.addAll(response['items'] ?? []);
        }
        _totalItems = response['total'] ?? 0;
        _totalPages = response['pages'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.i.e('[AdminHistory] Load error', error: e);
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadAdminHistory(isRefresh: true);
  }

  Future<void> _loadMoreData() async {
    if (_currentPage < _totalPages && !_isLoading) {
      _currentPage++;
      await _loadAdminHistory();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _loadAdminHistory(isRefresh: true);
  }

  void _onFilterChanged(String? newFilter) {
    if (newFilter != null) {
      setState(() {
        _selectedFilter = newFilter;
      });
      _loadAdminHistory(isRefresh: true);
    }
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

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'booking_created':
        return Colors.blue;
      case 'booking_updated':
        return Colors.orange;
      case 'booking_cancelled':
        return Colors.red;
      case 'payment_updated':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'booking_created':
        return Icons.add_circle;
      case 'booking_updated':
        return Icons.edit;
      case 'booking_cancelled':
        return Icons.cancel;
      case 'payment_updated':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }

  int get _totalRevenue {
    return _historyList
        .where((item) => item.action == 'payment_updated' || item.action == 'booking_created')
        .map((item) => item.meta?.totalHarga ?? 0)
        .fold(0, (sum, amount) => sum + amount);
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'Semua':
        return 'Semua Aksi';
      case 'booking_created':
        return 'Booking Dibuat';
      case 'booking_updated':
        return 'Booking Diperbarui';
      case 'booking_cancelled':
        return 'Booking Dibatalkan';
      case 'payment_updated':
        return 'Pembayaran Diperbarui';
      default:
        return filter;
    }
  }

  String _getActionDisplayName(String action) {
    switch (action) {
      case 'booking_created':
        return 'Booking Dibuat';
      case 'booking_updated':
        return 'Booking Diperbarui';
      case 'booking_cancelled':
        return 'Booking Dibatalkan';
      case 'payment_updated':
        return 'Pembayaran Diperbarui';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama, no HP, atau kode booking...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _onSearchChanged,
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    onSubmitted: (_) => _onSearchChanged(),
                  ),
                  const SizedBox(height: 12),
                  
                  // Filter and Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilter,
                          decoration: const InputDecoration(
                            labelText: 'Filter Aksi',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          items: _actionFilters.map((String filter) {
                            return DropdownMenuItem<String>(
                              value: filter,
                              child: Text(_getFilterDisplayName(filter)),
                            );
                          }).toList(),
                          onChanged: _onFilterChanged,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total: $_totalItems',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatRupiah(_totalRevenue),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // History List
            Expanded(
              child: _isLoading && _historyList.isEmpty
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
                                onPressed: () => _loadAdminHistory(isRefresh: true),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _historyList.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada riwayat transaksi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (!_isLoading && 
                                    scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                                    _currentPage < _totalPages) {
                                  _loadMoreData();
                                }
                                return false;
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _historyList.length + (_currentPage < _totalPages ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _historyList.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  
                                  final item = _historyList[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AdminHistoryDetailPage(
                                              historyItem: item,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                _getActionIcon(item.action ?? ''),
                                                color: _getActionColor(item.action ?? ''),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _getActionDisplayName(item.action ?? ''),
                                                  style: const TextStyle(
                                                    fontSize: 16,
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
                                                  color: _getActionColor(item.action ?? ''),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  (item.action ?? '').replaceAll('_', ' ').toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          // Message
                                          Text(
                                            item.message ?? 'No message',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          // Booking Details
                                          if (item.booking?.kodeBooking?.isNotEmpty == true) ...[
                                            _buildDetailRow(
                                              Icons.confirmation_number,
                                              'Kode Booking',
                                              item.booking!.kodeBooking!,
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                          
                                          if (item.booking?.tanggalBooking?.isNotEmpty == true) ...[
                                            _buildDetailRow(
                                              Icons.calendar_today,
                                              'Tanggal',
                                              _formatDate(item.booking!.tanggalBooking!),
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                          

                                          
                                          if (item.meta?.totalHarga != null && item.meta!.totalHarga! > 0) ...[
                                            _buildDetailRow(
                                              Icons.attach_money,
                                              'Total Harga',
                                              _formatRupiah(item.meta!.totalHarga!),
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                          
                                          // User info
                                          if (item.user?.nama != null) ...[
                                            _buildDetailRow(
                                              Icons.person,
                                              'User',
                                              '${item.user!.nama} (${item.user!.noHp ?? 'N/A'})',
                                            ),
                                          ] else if (item.user?.id != null) ...[
                                            _buildDetailRow(
                                              Icons.person,
                                              'User ID',
                                              item.user!.id!,
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          
                                          Text(
                                            'Waktu: ${_formatDate(item.createdAt ?? '')}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
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
            ),
          ],
        ),
      ),
    );
  }
}
