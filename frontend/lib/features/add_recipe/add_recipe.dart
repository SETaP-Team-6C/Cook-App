import 'package:flutter/material.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final TextEditingController _recipeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _ingredientsController = [];
  final List<TextEditingController> _stepsController = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 3; i++) {
      _ingredientsController.add(TextEditingController());
      _stepsController.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _recipeNameController.dispose();

    for (var cont in _ingredientsController) {
      cont.dispose();
    }

    for (var cont in _stepsController) {
      cont.dispose();
    }

    super.dispose();
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final name = _recipeNameController.text.trim();

      final ingredients = _ingredientsController
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final steps = _stepsController
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add at least one ingredient"),
          ),
        );
        return;
      }

      if (steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add at least one step"),
          ),
        );
        return;
      }

      print("Name: $name");
      print("Ingredients: $ingredients");
      print("Steps: $steps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Add Recipe"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Recipe Name
              TextFormField(
                controller: _recipeNameController,
                decoration: const InputDecoration(
                  labelText: "Recipe Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Recipe name is required";
                  }
                  if (value.trim().length < 3) {
                    return "Recipe name must be at least 3 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              /// Ingredients
              const Text(
                "Ingredients",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ..._ingredientsController.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Ingredient ${index + 1}",
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Ingredient cannot be empty";
                      }
                      return null;
                    },
                  ),
                );
              }),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _ingredientsController.add(TextEditingController());
                  });
                },
                child: const Text("Add Ingredient"),
              ),

              const SizedBox(height: 20),

              /// Steps
              const Text(
                "Enter Steps (in order)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ..._stepsController.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Step ${index + 1}",
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Step cannot be empty";
                      }
                      if (value.trim().length < 5) {
                        return "Step must be more descriptive";
                      }
                      return null;
                    },
                  ),
                );
              }),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _stepsController.add(TextEditingController());
                  });
                },
                child: const Text("Add Step"),
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  child: const Text("Save Recipe"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}