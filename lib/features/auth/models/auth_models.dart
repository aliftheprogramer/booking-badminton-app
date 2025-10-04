class AuthResponse {
  final String id;
  final String nama;
  final String noHp;
  final String role;
  final String token;

  AuthResponse({
    required this.id,
    required this.nama,
    required this.noHp,
    required this.role,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['_id'],
      nama: json['nama'],
      noHp: json['no_hp'],
      role: json['role'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nama': nama,
      'no_hp': noHp,
      'role': role,
      'token': token,
    };
  }
}

class RegisterRequest {
  final String nama;
  final String password;
  final String noHp;

  RegisterRequest({
    required this.nama,
    required this.password,
    required this.noHp,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'password': password,
      'no_hp': noHp,
    };
  }
}

class LoginRequest {
  final String noHp;
  final String password;

  LoginRequest({
    required this.noHp,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'no_hp': noHp,
      'password': password,
    };
  }
}