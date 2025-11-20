import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_service.dart';

class BookingPage extends StatefulWidget {
  final Lapangan lapangan;

  const BookingPage({super.key, required this.lapangan});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();
  
  DateTime? _selectedDate;
  int? _jamMulai;
  int? _jamSelesai;
  bool _isLoading = false;

  final List<int> _availableHours = List.generate(14, (index) => index + 7); // 7 AM to 8 PM

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  int _calculateDuration() {
    if (_jamMulai != null && _jamSelesai != null) {
      return _jamSelesai! - _jamMulai!;
    }
    return 0;
  }

  int _calculateTotalPrice() {
    final duration = _calculateDuration();
    return duration * widget.lapangan.hargaPerJam;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal booking'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_jamMulai == null || _jamSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jam mulai dan selesai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_jamMulai! >= _jamSelesai!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus lebih besar dari jam mulai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreateBookingRequest(
        lapanganId: widget.lapangan.id,
        tanggalBooking: _selectedDate!.toIso8601String().split('T')[0], // YYYY-MM-DD format
        jamMulai: _jamMulai!,
        jamSelesai: _jamSelesai!,
      );

      final booking = await _bookingService.createBooking(request);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Booking Berhasil!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kode Booking: ${booking.kodeBooking}'),
                  const SizedBox(height: 8),
                  Text('Lapangan: ${widget.lapangan.nama}'),
                  const SizedBox(height: 8),
                  Text('Total Harga: ${_formatRupiah(booking.totalHarga)}'),
                  const SizedBox(height: 8),
                  Text('Status: ${booking.statusPembayaran}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to lapangan list
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking gagal: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Booking Lapangan'),
        backgroundColor: const Color(0xFFC42F2F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lapangan Info Card
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.lapangan.nama,
                              style: const TextStyle(
                                fontSize: 20,
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
                              color: const Color(0xFFC42F2F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.lapangan.status.toUpperCase(),
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
                        widget.lapangan.deskripsi,
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
                            '${_formatRupiah(widget.lapangan.hargaPerJam)}/jam',
                            style: TextStyle(
                              fontSize: 16,
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
              const SizedBox(height: 20),

              // Booking Form
              const Text(
                'Detail Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal Booking'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Picker
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jam Mulai',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _jamMulai,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Pilih jam',
                          ),
                          items: _availableHours.map((hour) {
                            return DropdownMenuItem<int>(
                              value: hour,
                              child: Text('${hour.toString().padLeft(2, '0')}:00'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _jamMulai = value;
                              if (_jamSelesai != null && _jamSelesai! <= value!) {
                                _jamSelesai = null;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jam Selesai',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _jamSelesai,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Pilih jam',
                          ),
                          items: _availableHours.where((hour) {
                            return _jamMulai == null || hour > _jamMulai!;
                          }).map((hour) {
                            return DropdownMenuItem<int>(
                              value: hour,
                              child: Text('${hour.toString().padLeft(2, '0')}:00'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _jamSelesai = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Card
              if (_jamMulai != null && _jamSelesai != null) ...[
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC42F2F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Durasi:'),
                            Text('${_calculateDuration()} jam'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Harga per jam:'),
                            Text(_formatRupiah(widget.lapangan.hargaPerJam)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Harga:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatRupiah(_calculateTotalPrice()),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Booking Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC42F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Konfirmasi Booking',
                          style: TextStyle(
                            fontSize: 16,
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
  }
}