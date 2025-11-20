import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';

class AdminHistoryDetailPage extends StatelessWidget {
  final HistoryItem historyItem;

  const AdminHistoryDetailPage({
    super.key,
    required this.historyItem,
  });

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
        return Icons.add_circle_outline;
      case 'booking_updated':
        return Icons.edit_outlined;
      case 'booking_cancelled':
        return Icons.cancel_outlined;
      case 'payment_updated':
        return Icons.payment;
      default:
        return Icons.info_outline;
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

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    Color? color,
    IconData? icon,
  }) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null || title.isNotEmpty) ...[
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: color ?? const Color(0xFFC42F2F),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color ?? const Color(0xFFC42F2F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight? valueFontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFFC42F2F),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: valueFontWeight ?? FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = historyItem;
    final actionColor = _getActionColor(item.action ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail History Transaksi'),
        backgroundColor: const Color(0xFFC42F2F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Summary Card
            _buildInfoCard(
              title: _getActionDisplayName(item.action ?? ''),
              icon: _getActionIcon(item.action ?? ''),
              color: actionColor,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: actionColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.message ?? 'No message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: actionColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Waktu: ${_formatDate(item.createdAt ?? '')}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // User Information Card
            if (item.user != null) ...[
              _buildInfoCard(
                title: 'Informasi User',
                icon: Icons.person,
                children: [
                  if (item.user!.nama != null)
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: 'Nama',
                      value: item.user!.nama!,
                      valueFontWeight: FontWeight.bold,
                    ),
                  if (item.user!.noHp != null)
                    _buildDetailRow(
                      icon: Icons.phone,
                      label: 'No. HP',
                      value: item.user!.noHp!,
                    ),
                  if (item.user!.id != null)
                    _buildDetailRow(
                      icon: Icons.fingerprint,
                      label: 'User ID',
                      value: item.user!.id!,
                    ),
                ],
              ),
            ],

            // Booking Information Card
            if (item.booking != null) ...[
              _buildInfoCard(
                title: 'Informasi Booking',
                icon: Icons.event_note,
                children: [
                  if (item.booking!.kodeBooking != null)
                    _buildDetailRow(
                      icon: Icons.confirmation_number,
                      label: 'Kode Booking',
                      value: item.booking!.kodeBooking!,
                      valueFontWeight: FontWeight.bold,
                      valueColor: Colors.blue[700],
                    ),
                  if (item.booking!.tanggalBooking != null)
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal Booking',
                      value: _formatDate(item.booking!.tanggalBooking!),
                    ),
                  if (item.booking!.id != null)
                    _buildDetailRow(
                      icon: Icons.fingerprint,
                      label: 'Booking ID',
                      value: item.booking!.id!,
                    ),
                ],
              ),
            ],

            // Transaction Details Card
            if (item.meta != null) ...[
              _buildInfoCard(
                title: 'Detail Transaksi',
                icon: Icons.receipt_long,
                children: [
                  if (item.meta!.jamMulai != null && item.meta!.jamSelesai != null)
                    _buildDetailRow(
                      icon: Icons.schedule,
                      label: 'Jam Main',
                      value: '${item.meta!.jamMulai}:00 - ${item.meta!.jamSelesai}:00',
                      valueFontWeight: FontWeight.bold,
                    ),
                  if (item.meta!.jamMulai != null && item.meta!.jamSelesai != null)
                    _buildDetailRow(
                      icon: Icons.hourglass_empty,
                      label: 'Durasi',
                      value: '${item.meta!.jamSelesai! - item.meta!.jamMulai!} jam',
                    ),
                  if (item.meta!.totalHarga != null)
                    _buildDetailRow(
                      icon: Icons.attach_money,
                      label: 'Total Harga',
                      value: _formatRupiah(item.meta!.totalHarga!),
                      valueFontWeight: FontWeight.bold,
                      valueColor: Colors.green[700],
                    ),
                ],
              ),
            ],

            // Technical Information Card
            _buildInfoCard(
              title: 'Informasi Teknis',
              icon: Icons.info_outline,
              children: [
                if (item.id != null)
                  _buildDetailRow(
                    icon: Icons.fingerprint,
                    label: 'History ID',
                    value: item.id!,
                  ),
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'Tipe Aksi',
                  value: item.action ?? 'Unknown',
                ),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Waktu Dibuat',
                  value: _formatDate(item.createdAt ?? ''),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}