# Booking Badminton Mobile App - Authentication System

Aplikasi Flutter untuk booking lapangan badminton dengan sistem autentikasi.

## Fitur yang Telah Dibuat

### 1. Halaman Login (`/lib/features/auth/login/login.dart`)
- Input nomor HP dan password
- Validasi form input
- Integrasi dengan API login
- Navigasi ke halaman register
- Loading state saat proses login

**API Endpoint Login:**
- URL: `{{BASE_URL}}/auth/login`
- Method: POST
- Body Request:
```json
{
  "no_hp": "08123456789",
  "password": "password123"
}
```

### 2. Halaman Register (`/lib/features/auth/register/register.dart`)
- Input nama lengkap, nomor HP, password, dan konfirmasi password
- Validasi form input dengan konfirmasi password
- Integrasi dengan API register
- Navigasi kembali ke halaman login
- Loading state saat proses register

**API Endpoint Register:**
- URL: `{{BASE_URL}}/auth/register`
- Method: POST
- Body Request:
```json
{
  "nama": "Nama Lengkap",
  "password": "password123",
  "no_hp": "08123456789"
}
```

### 3. Model Data (`/lib/features/auth/models/auth_models.dart`)
- `AuthResponse`: Model untuk response login/register
- `LoginRequest`: Model untuk request login
- `RegisterRequest`: Model untuk request register

### 4. Service API (`/lib/features/auth/services/auth_service.dart`)
- `AuthService`: Class untuk menangani komunikasi dengan API
- Auto-save token dan data user ke SharedPreferences
- Method untuk cek status login
- Method untuk logout

### 5. Halaman Home (`/lib/features/home/home_page.dart`)
- Halaman utama setelah login berhasil
- Menampilkan nama user yang login
- Grid fitur-fitur aplikasi (placeholder)
- Tombol logout

### 6. Splash Screen (`/lib/main.dart`)
- Auto-check status login saat aplikasi dibuka
- Redirect ke home jika sudah login
- Redirect ke login jika belum login

## Konfigurasi API

Base URL API dikonfigurasi di `/lib/core/api_urls.dart`:
```dart
class ApiUrls {
  static const String baseUrl = "http://localhost:5000/api/";
}
```

## Response Format yang Didukung

Kedua endpoint (login dan register) mengembalikan response dengan format:
```json
{
  "_id": "68e1505527ec0a47883c18ae",
  "nama": "Nama Lengkap",
  "no_hp": "08123456789",
  "role": "user",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Dependencies yang Digunakan

- `http: ^1.1.0` - untuk HTTP requests
- `shared_preferences: ^2.2.2` - untuk local storage

## Cara Menjalankan

1. Pastikan Flutter sudah terinstall
2. Clone project ini
3. Jalankan `flutter pub get` untuk install dependencies
4. Jalankan `flutter run` untuk menjalankan aplikasi
5. Pastikan API backend sudah berjalan di `http://localhost:5000`

## Validasi Form

### Login:
- Nomor HP: Harus format 08xxxxxxxxx (8-11 digit setelah 08)
- Password: Minimal 6 karakter

### Register:
- Nama: Minimal 2 karakter
- Nomor HP: Harus format 08xxxxxxxxx (8-11 digit setelah 08)
- Password: Minimal 6 karakter
- Konfirmasi Password: Harus sama dengan password

## Fitur Keamanan

- Token disimpan secara lokal menggunakan SharedPreferences
- Auto-logout saat token dihapus
- Validasi input di sisi client
- Error handling untuk network requests

## Struktur Folder

```
lib/
├── main.dart                          # Entry point aplikasi
├── core/
│   └── api_urls.dart                 # Konfigurasi API URLs
└── features/
    ├── auth/
    │   ├── login/
    │   │   └── login.dart            # Halaman login
    │   ├── register/
    │   │   └── register.dart         # Halaman register
    │   ├── models/
    │   │   └── auth_models.dart      # Model data auth
    │   └── services/
    │       └── auth_service.dart     # Service API auth
    └── home/
        └── home_page.dart            # Halaman home setelah login
```