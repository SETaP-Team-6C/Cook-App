import 'package:frontend/core/api_response.dart';
import 'package:frontend/core/session.dart';
import 'package:http/http.dart' as http;

class ViewService {
  static Future<ApiResponse> viewRecipe(String recipeId) async {
    print("got in func");
    final response = await http.get(
      Uri.parse("http://localhost:5000/view-recipe").replace(
        queryParameters: {
          "recipe_id": recipeId,
          "user_id": Session.userId.toString(),
        },
      ),
    );
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }
}
