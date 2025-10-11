import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import '../api_urls.dart';
import '../models/models.dart';
import '../../features/auth/services/auth_service.dart';
import '../logger.dart';

class LapanganService {
  final AuthService _authService = AuthService();

  // Upload image to backend (Cloudinary via backend) using raw bytes
  // Returns the hosted URL.
  Future<String> uploadImageBytes(Uint8List bytes, {required String filename, String mimeType = 'image/jpeg'}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final uri = Uri.parse('${ApiUrls.baseUrl}upload');
      AppLogger.i.i('[LapanganService] UPLOAD $uri (filename=$filename)');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      AppLogger.i.i('[LapanganService] upload status=${response.statusCode}');
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final url = body['url'] ?? body['secure_url'] ?? body['data']?['url'];
        if (url is String && url.isNotEmpty) return url;
        throw Exception('Upload succeeded but URL not found');
      } else {
        AppLogger.i.w('[LapanganService] upload error body=$body');
        throw Exception(body['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      AppLogger.i.e('[LapanganService] upload exception', error: e);
      rethrow;
    }
  }

  Future<List<Lapangan>> getAllLapangan() async {
    try {
      AppLogger.i.i('[LapanganService] GET ${ApiUrls.baseUrl}lapangan');
      final token = await _authService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        AppLogger.i.i('[LapanganService] attaching Authorization header (len=${token.length})');
      }
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}lapangan'),
        headers: headers,
      );

      AppLogger.i.i('[LapanganService] status=${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Lapangan.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        AppLogger.i.w('[LapanganService] error body=$errorData');
        throw Exception(errorData['message'] ?? 'Failed to get lapangan data');
      }
    } catch (e) {
      AppLogger.i.e('[LapanganService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  // Create Lapangan using multipart/form-data as per backend (Cloudinary inside API)
  Future<Lapangan> createLapanganFormData({
    required String nama,
    required String deskripsi,
    required int hargaPerJam,
    required String status,
    Uint8List? fotoBytes,
    String? filename,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final uri = Uri.parse('${ApiUrls.baseUrl}lapangan');
      AppLogger.i.i('[LapanganService] POST (multipart) $uri');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nama'] = nama;
      request.fields['deskripsi'] = deskripsi;
      request.fields['status'] = status;
      request.fields['harga_per_jam'] = hargaPerJam.toString();

      if (fotoBytes != null && fotoBytes.isNotEmpty) {
        final fname = (filename == null || filename.isEmpty) ? 'foto.jpg' : filename;
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            fotoBytes,
            filename: fname,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      AppLogger.i.i('[LapanganService] create multipart status=${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return Lapangan.fromJson(data);
        } catch (e) {
          final head = response.body.substring(0, response.body.length > 200 ? 200 : response.body.length);
          throw Exception('Invalid JSON from create lapangan: $head');
        }
      } else {
        final head = response.body.substring(0, response.body.length > 200 ? 200 : response.body.length);
        throw Exception('Failed to create lapangan (HTTP ${response.statusCode}): $head');
      }
    } catch (e) {
      AppLogger.i.e('[LapanganService] create multipart exception', error: e);
      rethrow;
    }
  }

  // Update Lapangan using multipart/form-data; foto optional
  Future<Lapangan> updateLapanganFormData({
    required String id,
    required String nama,
    required String deskripsi,
    required int hargaPerJam,
    required String status,
    Uint8List? fotoBytes,
    String? filename,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final uri = Uri.parse('${ApiUrls.baseUrl}lapangan/$id');
      AppLogger.i.i('[LapanganService] PUT (multipart) $uri');

      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nama'] = nama;
      request.fields['deskripsi'] = deskripsi;
      request.fields['status'] = status;
      request.fields['harga_per_jam'] = hargaPerJam.toString();

      if (fotoBytes != null && fotoBytes.isNotEmpty) {
        final fname = (filename == null || filename.isEmpty) ? 'foto.jpg' : filename;
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            fotoBytes,
            filename: fname,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      AppLogger.i.i('[LapanganService] update multipart status=${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return Lapangan.fromJson(data);
        } catch (e) {
          final head = response.body.substring(0, response.body.length > 200 ? 200 : response.body.length);
          throw Exception('Invalid JSON from update lapangan: $head');
        }
      } else {
        final head = response.body.substring(0, response.body.length > 200 ? 200 : response.body.length);
        throw Exception('Failed to update lapangan (HTTP ${response.statusCode}): $head');
      }
    } catch (e) {
      AppLogger.i.e('[LapanganService] update multipart exception', error: e);
      rethrow;
    }
  }

  Future<Lapangan> getLapanganById(String id) async {
    try {
      AppLogger.i.i('[LapanganService] GET ${ApiUrls.baseUrl}lapangan/$id');
      final token = await _authService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        AppLogger.i.i('[LapanganService] attaching Authorization header (len=${token.length})');
      }
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}lapangan/$id'),
        headers: headers,
      );

      AppLogger.i.i('[LapanganService] status=${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Lapangan.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        AppLogger.i.w('[LapanganService] error body=$errorData');
        throw Exception(errorData['message'] ?? 'Failed to get lapangan data');
      }
    } catch (e) {
      AppLogger.i.e('[LapanganService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<Lapangan> createLapangan(CreateLapanganRequest request) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      AppLogger.i.i('[LapanganService] POST ${ApiUrls.baseUrl}lapangan (auth bearer len=${token.length})');
      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}lapangan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      AppLogger.i.i('[LapanganService] status=${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Lapangan.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        AppLogger.i.w('[LapanganService] error body=$errorData');
        throw Exception(errorData['message'] ?? 'Failed to create lapangan');
      }
    } catch (e) {
      AppLogger.i.e('[LapanganService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<Lapangan> updateLapangan(String id, CreateLapanganRequest request) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      AppLogger.i.i('[LapanganService] PUT ${ApiUrls.baseUrl}lapangan/$id (auth bearer len=${token.length})');
      final response = await http.put(
        Uri.parse('${ApiUrls.baseUrl}lapangan/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      AppLogger.i.i('[LapanganService] status=${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Lapangan.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        AppLogger.i.w('[LapanganService] error body=$errorData');
        throw Exception(errorData['message'] ?? 'Failed to update lapangan');
      }
    } catch (e) {
      AppLogger.i.e('[LapanganService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<void> deleteLapangan(String id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      AppLogger.i.i('[LapanganService] DELETE ${ApiUrls.baseUrl}lapangan/$id (auth bearer len=${token.length})');
      final response = await http.delete(
        Uri.parse('${ApiUrls.baseUrl}lapangan/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.i.i('[LapanganService] status=${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        AppLogger.i.w('[LapanganService] error body=$errorData');
        throw Exception(errorData['message'] ?? 'Failed to delete lapangan');
      }
    } catch (e) {
      AppLogger.i.e('[LapanganService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }
}

class BookingService {
  final AuthService _authService = AuthService();

  // Helper function to safely parse integer values from JSON
  int _safeParseInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Future<Booking> createBooking(CreateBookingRequest request) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      AppLogger.i.i('[BookingService] POST ${ApiUrls.baseUrl}bookings (auth bearer len=${token.length})');
      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      AppLogger.i.i('[BookingService] status=${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Booking.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        AppLogger.i.w('[BookingService] error body=$errorData');
        throw Exception(errorData['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      AppLogger.i.e('[BookingService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<List<Booking>> getUserBookings() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      // Updated to new history endpoint
      AppLogger.i.i('[BookingService] GET ${ApiUrls.baseUrl}history/my (auth bearer len=${token.length})');
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}history/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.i.i('[BookingService] status=${response.statusCode}');
      if (response.statusCode == 200) {
        final body = response.body;
        try {
          final List<dynamic> data = jsonDecode(body);
          return data.map((e) {
            final Map<String, dynamic> item = e as Map<String, dynamic>;
            final Map<String, dynamic> booking = (item['booking'] ?? {}) as Map<String, dynamic>;
            final Map<String, dynamic> meta = (item['meta'] ?? {}) as Map<String, dynamic>;
            return Booking(
              id: booking['_id'] ?? item['_id'] ?? '',
              kodeBooking: booking['kode_booking'] ?? '',
              user: item['user'] ?? '',
              lapangan: '',
              tanggalBooking: booking['tanggal_booking'] ?? item['createdAt'] ?? '',
              jamMulai: (booking['jam_mulai'] ?? meta['jam_mulai'] ?? 0) as int,
              jamSelesai: (booking['jam_selesai'] ?? meta['jam_selesai'] ?? 0) as int,
              durasi: ((booking['jam_selesai'] ?? meta['jam_selesai'] ?? 0) - (booking['jam_mulai'] ?? meta['jam_mulai'] ?? 0)).abs(),
              totalHarga: (meta['total_harga'] ?? 0) as int,
              statusPembayaran: (item['action'] ?? '').toString(),
              createdAt: item['createdAt'] ?? '',
              updatedAt: item['createdAt'] ?? '',
            );
          }).toList();
        } catch (e) {
          AppLogger.i.e('[BookingService] JSON parse error for history/my', error: e);
          throw Exception('Invalid response format from history');
        }
      } else {
        // If backend returned HTML (like 404 page), avoid jsonDecode
        final body = response.body;
        final head = body.substring(0, body.length > 200 ? 200 : body.length);
        AppLogger.i.w('[BookingService] history/my non-200 (status=${response.statusCode}), body(head)=$head');
        throw Exception('Failed to get booking history (HTTP ${response.statusCode})');
      }
    } catch (e) {
      AppLogger.i.e('[BookingService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<List<Booking>> getAllBookings() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      AppLogger.i.i('[BookingService] GET ${ApiUrls.baseUrl}bookings (auth bearer len=${token.length})');
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.i.i('[BookingService] status=${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        AppLogger.i.w('[BookingService] error body=$errorData');
        throw Exception(errorData['message'] ?? 'Failed to get all bookings');
      }
    } catch (e) {
      AppLogger.i.e('[BookingService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<List<HistoryItem>> getHistoryByBooking(String bookingId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final url = '${ApiUrls.baseUrl}history/booking/$bookingId';
      AppLogger.i.i('[BookingService] GET $url (auth bearer len=${token.length})');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      AppLogger.i.i('[BookingService] status=${response.statusCode}');
      if (response.statusCode == 200) {
        final body = response.body;
        try {
          final decoded = jsonDecode(body);
          if (decoded is List) {
            return decoded.map<HistoryItem>((e) => HistoryItem.fromJson(e as Map<String, dynamic>)).toList();
          } else if (decoded is Map<String, dynamic>) {
            // Some APIs return single item
            return [HistoryItem.fromJson(decoded)];
          } else {
            throw Exception('Unexpected response format');
          }
        } catch (e) {
          AppLogger.i.e('[BookingService] JSON parse error for history/booking/:id', error: e);
          throw Exception('Invalid response format from history detail');
        }
      } else {
        final head = response.body.substring(0, response.body.length > 200 ? 200 : response.body.length);
        AppLogger.i.w('[BookingService] history/booking non-200 (status=${response.statusCode}), body(head)=$head');
        throw Exception('Failed to get booking history detail (HTTP ${response.statusCode})');
      }
    } catch (e) {
      AppLogger.i.e('[BookingService] exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<Map<String, dynamic>> getAdminHistory({
    int page = 1,
    int limit = 20,
    String? action,
    String? search,
    String? userId,
    String? userName,
    String? no_hp,
    String? bookingCode,
    String? start,
    String? end,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (action != null) queryParams['action'] = action;
      if (search != null) queryParams['search'] = search;
      if (userId != null) queryParams['userId'] = userId;
      if (userName != null) queryParams['userName'] = userName;
      if (no_hp != null) queryParams['no_hp'] = no_hp;
      if (bookingCode != null) queryParams['bookingCode'] = bookingCode;
      if (start != null) queryParams['start'] = start;
      if (end != null) queryParams['end'] = end;

      final uri = Uri.parse('${ApiUrls.baseUrl}history/admin/all').replace(
        queryParameters: queryParams,
      );

      AppLogger.i.i('[BookingService] GET admin history (page=$page, limit=$limit, action=$action, search=$search, start=$start, end=$end)');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          AppLogger.i.i('[BookingService] admin history raw response: $decoded');
          
          // Handle different possible response structures
          Map<String, dynamic> data;
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('data') && decoded['data'] != null) {
              data = decoded['data'] as Map<String, dynamic>;
            } else {
              // Direct response without 'data' wrapper
              data = decoded;
            }
          } else {
            throw Exception('Response is not a Map');
          }
          
          AppLogger.i.i('[BookingService] admin history data structure: $data');
          
          final items = (data['items'] as List<dynamic>? ?? [])
              .map<HistoryItem>((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
              .toList();

          AppLogger.i.i('[BookingService] admin history success (items=${items.length})');

          return {
            'items': items,
            'total': _safeParseInt(data['total'], 0),
            'page': _safeParseInt(data['page'], page),
            'pages': _safeParseInt(data['pages'], 1),
          };
        } catch (e) {
          AppLogger.i.e('[BookingService] JSON parse error for admin history', error: e);
          AppLogger.i.i('[BookingService] Raw response body: ${response.body}');
          throw Exception('Invalid response format from admin history: ${e.toString()}');
        }
      } else {
        final head = response.body.substring(0, response.body.length > 200 ? 200 : response.body.length);
        AppLogger.i.w('[BookingService] admin history non-200 (status=${response.statusCode}), body(head)=$head');
        throw Exception('Failed to get admin history (HTTP ${response.statusCode})');
      }
    } catch (e) {
      AppLogger.i.e('[BookingService] admin history exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<Map<String, dynamic>> getAdminHistoryByUser(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token found');

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('${ApiUrls.baseUrl}history/admin/by-user/$userId').replace(
        queryParameters: queryParams,
      );

      AppLogger.i.i('[BookingService] GET admin history by user (userId=$userId, page=$page, limit=$limit)');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          AppLogger.i.i('[BookingService] admin history by user raw response: $decoded');
          
          // Handle different possible response structures
          Map<String, dynamic> data;
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('data') && decoded['data'] != null) {
              data = decoded['data'] as Map<String, dynamic>;
            } else {
              // Direct response without 'data' wrapper
              data = decoded;
            }
          } else {
            throw Exception('Response is not a Map');
          }
          
          AppLogger.i.i('[BookingService] admin history by user data structure: $data');
          
          final items = (data['items'] as List<dynamic>? ?? [])
              .map<HistoryItem>((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
              .toList();

          AppLogger.i.i('[BookingService] admin history by user success (items=${items.length})');

          return {
            'items': items,
            'total': _safeParseInt(data['total'], 0),
            'page': _safeParseInt(data['page'], page),
            'pages': _safeParseInt(data['pages'], 1),
          };
        } catch (e) {
          AppLogger.i.e('[BookingService] JSON parse error for admin history by user', error: e);
          AppLogger.i.i('[BookingService] Raw response body: ${response.body}');
          throw Exception('Invalid response format from admin history by user: ${e.toString()}');
        }
      } else {
        final head = response.body.substring(0, response.body.length > 200 ? 200 : response.body.length);
        AppLogger.i.w('[BookingService] admin history by user non-200 (status=${response.statusCode}), body(head)=$head');
        throw Exception('Failed to get admin history by user (HTTP ${response.statusCode})');
      }
    } catch (e) {
      AppLogger.i.e('[BookingService] admin history by user exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }
}