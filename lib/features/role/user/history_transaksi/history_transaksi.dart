import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';
import 'booking_detail_page.dart';

class UserHistoryTransaksiPage extends StatefulWidget {
  const UserHistoryTransaksiPage({super.key});

  @override
  State<UserHistoryTransaksiPage> createState() => _UserHistoryTransaksiPageState();
}

class _UserHistoryTransaksiPageState extends State<UserHistoryTransaksiPage> {
  final BookingService _bookingService = BookingService();
  List<HistoryItem> _items = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final items = await _bookingService.getMyHistoryItems();
      setState(() {
        _items = items;
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
    await _loadHistory();
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
      case 'lunas':
        return Colors.green;
      case 'cancelled':
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
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
                          onPressed: _loadHistory,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _items.isEmpty
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
                              'Belum ada history booking',
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
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final booking = item.booking;
                          final meta = item.meta;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            child: InkWell(
                              onTap: booking == null
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookingDetailPage(
                                            booking: Booking(
                                              id: booking.id ?? '',
                                              kodeBooking: booking.kodeBooking ?? '',
                                              user: item.user?.id ?? '',
                                              lapangan: '',
                                              tanggalBooking: booking.tanggalBooking ?? item.createdAt ?? '',
                                              jamMulai: booking.jamMulai ?? meta?.jamMulai ?? 0,
                                              jamSelesai: booking.jamSelesai ?? meta?.jamSelesai ?? 0,
                                              durasi: ((booking.jamSelesai ?? meta?.jamSelesai ?? 0) - (booking.jamMulai ?? meta?.jamMulai ?? 0)).abs(),
                                              totalHarga: meta?.totalHarga ?? 0,
                                              statusPembayaran: item.action ?? '',
                                              createdAt: item.createdAt ?? '',
                                              updatedAt: item.createdAt ?? '',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          booking?.kodeBooking ?? '-',
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
                                          color: _getStatusColor(item.action ?? ''),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          (item.action ?? '').toUpperCase(),
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
                                  
                                  // Booking Details
                                  _buildDetailRow(
                                    Icons.calendar_today,
                                    'Tanggal',
                                    _formatDate(booking?.tanggalBooking ?? item.createdAt ?? ''),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    Icons.access_time,
                                    'Waktu',
                                    '${(booking?.jamMulai ?? meta?.jamMulai ?? 0).toString().padLeft(2, '0')}:00 - ${(booking?.jamSelesai ?? meta?.jamSelesai ?? 0).toString().padLeft(2, '0')}:00',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    Icons.timer,
                                    'Durasi',
                                    '${((booking?.jamSelesai ?? meta?.jamSelesai ?? 0) - (booking?.jamMulai ?? meta?.jamMulai ?? 0)).abs()} jam',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    Icons.attach_money,
                                    'Total Harga',
                                    _formatRupiah(meta?.totalHarga ?? 0),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Text(
                                    'Dibuat: ${_formatDate(item.createdAt ?? '')}',
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
    );
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
}
