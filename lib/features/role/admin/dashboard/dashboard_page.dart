import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final BookingService _bookingService = BookingService();
  final LapanganService _lapanganService = LapanganService();

  bool _isLoading = true;
  String _error = '';

  // Stats data
  int _totalBookings = 0;
  int _totalRevenue = 0;
  int _totalLapangan = 0;
  int _activeLapangan = 0;
  int _maintenanceLapangan = 0;
  List<Lapangan> _lapanganInMaintenance = [];
  List<HistoryItem> _recentBookings = [];
  Map<String, int> _bookingsByDay = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Load all data in parallel
      final results = await Future.wait([
        _bookingService.getAdminHistory(limit: 100),
        _lapanganService.getAllLapangan(),
      ]);

      final historyData = results[0] as Map<String, dynamic>;
      final lapanganList = results[1] as List<Lapangan>;

      final items = historyData['items'] as List<HistoryItem>;

      // Calculate total bookings (count only booking_created actions)
      final bookingCreatedItems = items
          .where((item) => item.action == 'booking_created')
          .toList();

      // Calculate total revenue
      int revenue = 0;
      for (var item in bookingCreatedItems) {
        revenue += item.meta?.totalHarga ?? 0;
      }

      // Count lapangan by status
      int active = 0;
      int maintenance = 0;
      List<Lapangan> maintenanceList = [];

      for (var lapangan in lapanganList) {
        if (lapangan.status.toLowerCase() == 'tersedia' ||
            lapangan.status.toLowerCase() == 'available') {
          active++;
        } else if (lapangan.status.toLowerCase() == 'maintenance' ||
            lapangan.status.toLowerCase() == 'perbaikan') {
          maintenance++;
          maintenanceList.add(lapangan);
        }
      }

      // Get bookings by day (last 7 days)
      Map<String, int> bookingsByDay = {};
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayKey = '${day.day}/${day.month}';
        bookingsByDay[dayKey] = 0;
      }

      for (var item in bookingCreatedItems) {
        if (item.createdAt != null) {
          try {
            final date = DateTime.parse(item.createdAt!);
            final dayKey = '${date.day}/${date.month}';
            if (bookingsByDay.containsKey(dayKey)) {
              bookingsByDay[dayKey] = (bookingsByDay[dayKey] ?? 0) + 1;
            }
          } catch (_) {}
        }
      }

      setState(() {
        _totalBookings = bookingCreatedItems.length;
        _totalRevenue = revenue;
        _totalLapangan = lapanganList.length;
        _activeLapangan = active;
        _maintenanceLapangan = maintenance;
        _lapanganInMaintenance = maintenanceList;
        _recentBookings = bookingCreatedItems.take(5).toList();
        _bookingsByDay = bookingsByDay;
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
    await _loadDashboardData();
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
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome Card
                  Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.dashboard,
                            size: 40,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dashboard Admin',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ringkasan data booking badminton',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[700],
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

                  // Statistics Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        'Total Booking',
                        _totalBookings.toString(),
                        Icons.event_available,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Total Pendapatan',
                        _formatRupiah(_totalRevenue),
                        Icons.attach_money,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Total Lapangan',
                        _totalLapangan.toString(),
                        Icons.sports_tennis,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Lapangan Aktif',
                        _activeLapangan.toString(),
                        Icons.check_circle,
                        Colors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Chart Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking 7 Hari Terakhir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _bookingsByDay.isEmpty
                                ? const Center(child: Text('Tidak ada data'))
                                : CustomPaint(
                                    painter: BarChartPainter(_bookingsByDay),
                                    size: const Size(double.infinity, 200),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Maintenance Alert
                  if (_maintenanceLapangan > 0) ...[
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red[700],
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Lapangan dalam Perbaikan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[700],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$_maintenanceLapangan',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._lapanganInMaintenance.map((lapangan) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sports_tennis,
                                      size: 16,
                                      color: Colors.red[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        lapangan.nama,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red[900],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red[300]!,
                                        ),
                                      ),
                                      child: Text(
                                        lapangan.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Recent Bookings
                  const Text(
                    'Booking Terbaru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_recentBookings.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Belum ada booking',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._recentBookings.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child: Icon(
                              Icons.person,
                              color: Colors.orange[700],
                            ),
                          ),
                          title: Text(
                            item.user?.nama ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                item.message ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(item.createdAt ?? ''),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            _formatRupiah(item.meta?.totalHarga ?? 0),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const Spacer(),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: title.contains('Pendapatan') ? 14 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final Map<String, int> data;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;

    final maxValue = data.values.reduce(math.max).toDouble();
    final barWidth = (size.width - (data.length + 1) * 8) / data.length;
    final chartHeight = size.height - 40;

    int index = 0;
    data.forEach((day, count) {
      final barHeight = maxValue > 0 ? (count / maxValue) * chartHeight : 0.0;
      final left = 8.0 + index * (barWidth + 8);
      final top = size.height - 30 - barHeight;

      // Draw bar with gradient
      final rect = Rect.fromLTWH(left, top, barWidth, barHeight.toDouble());
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.orange[400]!, Colors.orange[700]!],
      ).createShader(rect);

      final roundedRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(4),
      );
      canvas.drawRRect(roundedRect, paint);

      // Draw value on top of bar
      if (count > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: count.toString(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(left + (barWidth - textPainter.width) / 2, top - 15),
        );
      }

      // Draw day label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: day,
          style: TextStyle(color: Colors.grey[600], fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(left + (barWidth - labelPainter.width) / 2, size.height - 20),
      );

      index++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
