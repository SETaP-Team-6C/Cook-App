import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:frontend/features/authen/services/account_services.dart';

class RecipeService {
  static Future<bool> addRecipe(
    String name,
    List ingredients,
    List steps,
    String time,
    String difficulty,
    String? mainImage,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://localhost:5000/add-recipe"),
      );

      if (AuthService.sessionCookie != null) {
        request.headers["Cookie"] = AuthService.sessionCookie!;
      }

      // add fields
      request.fields['recipe-title'] = name;
      request.fields['recipe-ingredients'] = jsonEncode(ingredients);
      request.fields['recipe-steps'] = jsonEncode(steps);
      request.fields['recipe-time'] = time;
      request.fields['recipe-difficulty'] = difficulty;

      // add main image
      if (mainImage != null && mainImage.isNotEmpty) {
        File imageFile = File(mainImage);
        if (await imageFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath("recipe-main-image", mainImage),
          );
        }
      }

      // add step images
      for (var i = 0; i < steps.length; i++) {
        var step = steps[i];
        if (step['step-image'] != null && step['step-image'].isNotEmpty) {
          File stepImageFile = File(step['step-image']);
          if (await stepImageFile.exists()) {
            request.files.add(
              // uses step index to matcht on backend
              await http.MultipartFile.fromPath(
                'step-image-${step['step-index']}',
                step['step-image'],
              ),
            );
          }
        }
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          "Failed to add recipe: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("failed to add recipe : $e");
    }
  }
}
