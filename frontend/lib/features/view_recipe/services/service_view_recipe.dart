import 'dart:convert';

import 'package:frontend/core/api_response.dart';
import 'package:frontend/core/session.dart';
import 'package:http/http.dart' as http;

class ViewService {
  static Future<ApiResponse> viewRecipe(String recipeId) async {
    final response = await http.get(
      Uri.parse(
        "http://localhost:5000/view-recipe/$recipeId",
      ).replace(queryParameters: {"user_id": Session.userId.toString()}),
    );
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }

  static Future<ApiResponse> completeStep(int recipeStepId) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/complete-step"),
      headers: {"Content-Type": "application/Json"},
      body: jsonEncode({
        "recipe_step_id": recipeStepId,
        "user_id": Session.userId,
      }),
    );
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }

  static Future<ApiResponse> unCompleteStep(int recipeStepId) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/uncomplete-step"),
      headers: {"Content-Type": "application/Json"},
      body: jsonEncode({
        "recipe_step_id": recipeStepId,
        "user_id": Session.userId,
      }),
    );
    return ApiResponse(
      statusCode: response.statusCode,
      response: response.body,
    );
  }
}
