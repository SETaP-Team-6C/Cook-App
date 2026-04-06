import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  Future<Map<String, dynamic>> authenticate(
    String fname,
    String lname,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/authenticate"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "user_fname": fname,
        "user_lname": lname,
        "user_password": password,
      },
    );
    return jsonDecode(response.body);
  }
}
