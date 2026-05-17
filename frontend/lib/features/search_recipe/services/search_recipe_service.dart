import 'package:frontend/features/authen/services/account_services.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/api_response.dart';

class SearchService {
  static Future<ApiResponse> searchRecipe(String name) async {
    final response = await http.get(
      Uri.parse(
        "http://localhost:5000/search-recipe",
      ).replace(queryParameters: {"q": name}),
      headers: {
        if (AuthService.sessionCookie != null)
          'Cookie': AuthService.sessionCookie!,
      },
    );
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }
}
