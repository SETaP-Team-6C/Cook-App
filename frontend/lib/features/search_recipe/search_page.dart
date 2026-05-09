import 'package:flutter/material.dart';
import 'package:frontend/core/routes.dart';
import 'dart:convert';
import 'services/search_recipe_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = "";
  List<dynamic> results = [];
  String? error;
  bool isLoading = false;

  Future<void> _search(String name) async {
    if (name.isEmpty) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    final apiResponse = await SearchService.searchRecipe(name);

    if (apiResponse.statusCode == 200) {
      final data = jsonDecode(apiResponse.response);

      setState(() {
        results = data["recipes"];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Recipes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Search recipes",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
                _search(value);
              },
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (query.isEmpty) {
      return const Text("type to search something");
    }
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.isEmpty) {
      return const Center(child: Text("not results found"));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final recipe = results[index];
        final ingredients = recipe["ingredients"] as List;
        final ingredientNames = ingredients
            .map((i) => i["recipe_ingredient_name"])
            .join(", ");
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: _buildRecipeImage(recipe["recipe_id"]),
            title: Text(recipe["recipe_title"] ?? "no title"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ingredients: $ingredientNames"),
                Text("Time: ${recipe["recipe_time"]}"),
                Text("Difficulty: ${recipe["recipe_difficulty"]}"),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.viewRecipe,
                arguments: {"recipeId": recipe["recipe_id"]},
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecipeImage(int? recipeId) {
    if (recipeId == null) {
      return _buildPlaceholder();
    }
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(8),
      child: Image.network(
        "http://localhost:5000/recipe-image/$recipeId",
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, LoadingProgress) {
          if (LoadingProgress == null) return child;
          return SizedBox(
            width: 60,
            height: 60,
            child: Center(
              child: CircularProgressIndicator(
                value: LoadingProgress.expectedTotalBytes != null
                    ? LoadingProgress.cumulativeBytesLoaded /
                          LoadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      child: const Icon(Icons.food_bank, color: Colors.grey, size: 30),
    );
  }
}
