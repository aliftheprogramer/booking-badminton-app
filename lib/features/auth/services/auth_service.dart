import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_urls.dart';
import '../models/auth_models.dart';
import '../../../core/logger.dart';

class AuthService {
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
  // Log request (mask sensitive data)
  AppLogger.i.i('[AuthService] POST ${ApiUrls.baseUrl}auth/register for noHp=${request.noHp}');
      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

  // Log status code
  AppLogger.i.i('[AuthService] register status=${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        
        // Save token and user data to SharedPreferences
        await _saveAuthData(authResponse);
  AppLogger.i.i('[AuthService] register saved token(len)=${authResponse.token.length}, role=${authResponse.role}');
        
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
  AppLogger.i.w('[AuthService] register error body=$errorData');
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
  AppLogger.i.e('[AuthService] register exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
  AppLogger.i.i('[AuthService] POST ${ApiUrls.baseUrl}auth/login for noHp=${request.noHp}');
      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

  AppLogger.i.i('[AuthService] login status=${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        
        // Save token and user data to SharedPreferences
        await _saveAuthData(authResponse);
  AppLogger.i.i('[AuthService] login saved token(len)=${authResponse.token.length}, role=${authResponse.role}');
        
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
  AppLogger.i.w('[AuthService] login error body=$errorData');
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
  AppLogger.i.e('[AuthService] login exception', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, authResponse.token);
    await prefs.setString(userDataKey, jsonEncode(authResponse.toJson()));
    AppLogger.i.i('[AuthService] _saveAuthData complete (token/user stored)');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<AuthResponse?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(userDataKey);
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      return AuthResponse.fromJson(userData);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userDataKey);
  }
}