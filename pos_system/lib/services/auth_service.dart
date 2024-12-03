import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://localhost/pos_api/auth.php';

  Future<bool> register(String adminId, String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=register'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "admin_id": adminId,
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    final data = json.decode(response.body);
    return data['success'] ?? false;
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "password": password,
      }),
    );

    final data = json.decode(response.body);
    return data['success'] ?? false;
  }
}
