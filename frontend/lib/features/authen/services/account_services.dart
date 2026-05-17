import 'package:http/http.dart' as http;
import 'package:frontend/core/api_response.dart';

class AuthService {
  static String? _sessionCookie;

  static String? get sessionCookie => _sessionCookie;

  //set after login
  static void setSessionCookie(String cookie) {
    _sessionCookie = cookie;
  }

  //log out
  static void clearSession() {
    _sessionCookie = null;
  }

  // check if auth
  static bool isAuthenticated() {
    return _sessionCookie != null;
  }

  static Future<ApiResponse> authenticate(
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
    if (response.statusCode == 200) {
      final cookies = response.headers["set-cookie"];
      if (cookies != null) {
        _sessionCookie = cookies.split(';')[0];
      }
    }
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }

  static Future<ApiResponse> createAccount(
    String fname,
    String lname,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/create-account"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "user_fname": fname,
        "user_lname": lname,
        "user_email": email,
        "user_password": password,
      },
    );
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }
}
