import 'package:http/http.dart' as http;
import 'package:frontend/core/api_response.dart';

class LoginService {
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
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }
}

class CreateService {
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
