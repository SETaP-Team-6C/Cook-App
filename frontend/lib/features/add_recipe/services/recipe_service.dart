import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  Future<bool> addRecipe(
    String name,
    List ingredients,
    List steps,
    String time,
    String difficulty,
  ) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/add-recipe"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "recipe-title": name,
        "recipe-ingredients": ingredients,
        "recipe-steps": steps,
        "recipe-time": time,
        "recipe-difficulty": difficulty,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception("faile to add recipe");
    }
  }
}
