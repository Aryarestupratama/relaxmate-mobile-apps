import 'package:relaxmate/core/api/json_map.dart';

/// Ringkasan pengguna dari API (`user` pada register, login, dan `GET /me`).
/// Server sengaja tidak mengirim ID atau peran (Architecture-M bagian 5).
class UserSummary {
  const UserSummary({
    required this.name,
    required this.email,
    required this.emailVerified,
  });

  factory UserSummary.fromJson(JsonMap json) {
    return UserSummary(
      name: _text(json['name']),
      email: _text(json['email']),
      emailVerified: json['email_verified'] == true,
    );
  }

  final String name;
  final String email;
  final bool emailVerified;
}

String _text(Object? value) => value is String ? value : '';
