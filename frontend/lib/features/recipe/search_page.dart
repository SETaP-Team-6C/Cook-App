import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key}); 

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  
  String query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Recipes"),
      ),
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
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  if (query.isEmpty)
                    const Text("Type something to search recipes."),
                  if (query.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.food_bank),
                      title: Text("Search result for '$query'"),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}