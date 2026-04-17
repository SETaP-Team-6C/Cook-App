import 'package:http/http.dart' as http;

class ApiResponse {
  final int statusCode;
  final String response;

  ApiResponse({required this.statusCode, required this.response});
}

class SearchService {
  Future<ApiResponse> searchRecipe(String name) async {
    final response = await http.get(
      Uri.parse(
        "http://localhost:5000/search-recipe",
      ).replace(queryParameters: {"q": name}),
    );
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }
}
