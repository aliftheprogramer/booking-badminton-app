class Lapangan {
  final String id;
  final String nama;
  final String deskripsi;
  final int hargaPerJam;
  final List<String> foto;
  final String status;
  final String createdAt;
  final String updatedAt;

  Lapangan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.hargaPerJam,
    required this.foto,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    return Lapangan(
      id: json['_id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      hargaPerJam: json['harga_per_jam'],
      foto: List<String>.from(json['foto'] ?? []),
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga_per_jam': hargaPerJam,
      'foto': foto,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CreateLapanganRequest {
  final String nama;
  final String deskripsi;
  final int hargaPerJam;
  final List<String> foto;
  final String status;

  CreateLapanganRequest({
    required this.nama,
    required this.deskripsi,
    required this.hargaPerJam,
    required this.foto,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'harga_per_jam': hargaPerJam,
      'foto': foto,
      'status': status,
    };
  }
}

class Booking {
  final String id;
  final String kodeBooking;
  final String user;
  final String lapangan;
  final String tanggalBooking;
  final int jamMulai;
  final int jamSelesai;
  final int durasi;
  final int totalHarga;
  final String statusPembayaran;
  final String createdAt;
  final String updatedAt;

  Booking({
    required this.id,
    required this.kodeBooking,
    required this.user,
    required this.lapangan,
    required this.tanggalBooking,
    required this.jamMulai,
    required this.jamSelesai,
    required this.durasi,
    required this.totalHarga,
    required this.statusPembayaran,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      kodeBooking: json['kode_booking'],
      user: json['user'],
      lapangan: json['lapangan'],
      tanggalBooking: json['tanggal_booking'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      durasi: json['durasi'],
      totalHarga: json['total_harga'],
      statusPembayaran: json['status_pembayaran'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class CreateBookingRequest {
  final String lapanganId;
  final String tanggalBooking;
  final int jamMulai;
  final int jamSelesai;

  CreateBookingRequest({
    required this.lapanganId,
    required this.tanggalBooking,
    required this.jamMulai,
    required this.jamSelesai,
  });

  Map<String, dynamic> toJson() {
    return {
      'lapanganId': lapanganId,
      'tanggal_booking': tanggalBooking,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    };
  }
}

class HistoryItem {
  final String? id;
  final HistoryBooking? booking;
  final HistoryUser? user;
  final String? action;
  final String? message;
  final HistoryMeta? meta;
  final String? createdAt;

  HistoryItem({
    this.id,
    this.booking,
    this.user,
    this.action,
    this.message,
    this.meta,
    this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['_id'],
      booking: json['booking'] != null ? HistoryBooking.fromJson(json['booking'] as Map<String, dynamic>) : null,
      user: json['user'] != null ? HistoryUser.fromJson(json['user'] as Map<String, dynamic>) : null,
      action: json['action'],
      message: json['message'],
      meta: json['meta'] != null ? HistoryMeta.fromJson(json['meta'] as Map<String, dynamic>) : null,
      createdAt: json['createdAt'],
    );
  }
}

class HistoryBooking {
  final String? id;
  final String? kodeBooking;
  final String? tanggalBooking;
  final int? jamMulai;
  final int? jamSelesai;

  HistoryBooking({
    this.id,
    this.kodeBooking,
    this.tanggalBooking,
    this.jamMulai,
    this.jamSelesai,
  });

  factory HistoryBooking.fromJson(Map<String, dynamic> json) {
    return HistoryBooking(
      id: json['_id'],
      kodeBooking: json['kode_booking'],
      tanggalBooking: json['tanggal_booking'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
    );
  }
}

class HistoryMeta {
  final int? jamMulai;
  final int? jamSelesai;
  final int? totalHarga;

  HistoryMeta({this.jamMulai, this.jamSelesai, this.totalHarga});

  factory HistoryMeta.fromJson(Map<String, dynamic> json) {
    return HistoryMeta(
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      totalHarga: json['total_harga'],
    );
  }
}

class HistoryUser {
  final String? id;
  final String? nama;
  final String? noHp;

  HistoryUser({this.id, this.nama, this.noHp});

  factory HistoryUser.fromJson(Map<String, dynamic> json) {
    return HistoryUser(
      id: json['_id'],
      nama: json['nama'],
      noHp: json['no_hp'],
    );
  }
}