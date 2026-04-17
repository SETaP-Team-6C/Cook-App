import 'package:flutter/material.dart';
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
        return ListTile(
          leading: const Icon(Icons.food_bank),
          title: Text(recipe["recipe_title"] ?? "no title"),
          subtitle: Text(recipe["recipe_ingredients"] ?? "no title"),
        );
      },
    );
  }
}
