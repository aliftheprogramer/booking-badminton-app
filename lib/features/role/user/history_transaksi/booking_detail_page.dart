import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

class BookingDetailPage extends StatefulWidget {
  final Booking booking;
  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  String _error = '';
  List<HistoryItem> _history = [];

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
      final items = await _bookingService.getHistoryByBooking(widget.booking.id);
      setState(() {
        _history = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.kodeBooking,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _row('Tanggal', _formatDate(b.tanggalBooking)),
                    const SizedBox(height: 6),
                    _row('Waktu', '${b.jamMulai.toString().padLeft(2, '0')}:00 - ${b.jamSelesai.toString().padLeft(2, '0')}:00'),
                    const SizedBox(height: 6),
                    _row('Durasi', '${b.durasi} jam'),
                    const SizedBox(height: 6),
                    _row('Total', 'Rp ${b.totalHarga}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Riwayat Perubahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ))
            else if (_error.isNotEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _loadHistory, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada riwayat.'),
              )
            else
              ..._history.map((h) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.timeline, color: Colors.green),
                      title: Text((h.action ?? '').replaceAll('_', ' ')),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.message ?? 'No message'),
                          const SizedBox(height: 4),
                          Text(_formatDate(h.createdAt ?? ''), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey[700])),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          )
        ],
      );
}
