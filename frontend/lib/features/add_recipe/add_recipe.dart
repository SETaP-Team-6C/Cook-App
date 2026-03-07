import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Ingredient {
  final TextEditingController name = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController calories = TextEditingController();
  String? amountUnits;
}
//gonna follow the same format as ingredients and make step into a class
class StepItem {
    final TextEditingController controller = TextEditingController();
    final List<TextEditingController> subSteps = [];
  
}

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _stepsController = [];
  final List<Ingredient> _ingredients = [];
  final List<StepItem> _steps = [];

  String? _difficultySelector;

  @override
  void initState() {
        // intialise 
    super.initState();

    for (int i = 0; i < 3; i++) {
      _stepsController.add(TextEditingController());
      _ingredients.add(Ingredient());
      _steps.add(StepItem());

    }
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _timeController.dispose();

    for (var cont in _ingredients) {
      cont.name.dispose();
      cont.amount.dispose();
      cont.calories.dispose();
    }

    for (var cont in _stepsController) {
      cont.dispose();
    }
    for (var cont in _steps){
        // TODo
    }

    super.dispose();
  }
Future<void> _sendRecipe(name, ingredients , steps, time, difficulty) async {
    try {
        final response = await http.post(
            Uri.parse("http://localhost:5000/add-recipe"),  
            headers: {
                "Content-Type": "application/json", 
            },
            body: jsonEncode({ 
                "recipe-title": name,
                "recipe-ingredients": ingredients,
                "recipe-steps": steps,
                "recipe-time": time,
                "recipe-difficulty": difficulty,
            }),
        );
            print("got in func");

        if (response.statusCode == 200) {
            print("hit backend ${response.body}");
        } else {
            print("fail ${response.statusCode}");
        }
    } catch (e) {
        print("error here =>: $e");
    }
}

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final name = _recipeNameController.text.trim();
      final time = _timeController.text.trim();
      final difficulty = _difficultySelector;

      final ingredients = _ingredients.map((ingredient) {
        return {
            "ingredient-name": ingredient.name.text.trim(),
            "ingredient-amount": int.parse(ingredient.amount.text.trim()),
            "ingredient-calories": int.parse(ingredient.calories.text.trim()),
            "ingredient-unit": ingredient.amountUnits
        };
      }).toList();

      final steps = _stepsController
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add at least one step"),
          ),
        );
        return;
      }
      await _sendRecipe(name, ingredients,steps,time,difficulty);

      print("Name: $name");
      print("Ingredients: $ingredients");
      print("Steps: $steps");
      print("${time}");
      print("${difficulty}");
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

              /// Recipe time
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: "Recipe expected time",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Recipe expected time is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                initialValue: _difficultySelector,
                decoration: const InputDecoration(
                    labelText: "select difficulty",
                    border: OutlineInputBorder(),
                ),
                items: ["easy", "medium","hard"].map((item)=>
                    DropdownMenuItem(
                                value:item, 
                                child:Text(item)
                  )
                ).toList(),
                onChanged: (value){
                        setState((){
                            _difficultySelector = value;
                        });
                    },
                validator: (value){
                        if (value == null || value.isEmpty){
                            return "please select a difficulty";
                        }
                        return null;
                    }
              ),

              /// Ingredients
              const Text(
                "Ingredients",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ..._ingredients.asMap().entries.map((entry) {
                Ingredient controller = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                        Expanded(
                            flex: 3,
                            child: TextFormField(
                                controller: controller.name,
                                decoration: const InputDecoration(
                                    labelText: "Ingredient name",
                                    border: OutlineInputBorder(),
                          ),
                            validator: (value){
                                if (value == null || value.trim().isEmpty){
                                    return "enter a valid name";
                                }
                                return null;
                            },
                        ),
                      ),

                       const SizedBox(width: 20),

                       Expanded(
                        flex: 2,
                        child: TextFormField(
                            controller: controller.amount,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Ingredient amount",
                                border: OutlineInputBorder(),
                          ),
                            validator: (value){
                                if (value == null || value.trim().isEmpty){
                                    return "enter a valid amount";
                                }
                                return null;
                            },
                        ),
                      ),

                       const SizedBox(width: 20),

                       Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                            initialValue: controller.amountUnits,
                            decoration: const InputDecoration(
                                labelText: "select Units",
                                border: OutlineInputBorder(),
                            ),
                        items: ["g","KG", "ml","L"].map((item)=>
                            DropdownMenuItem(
                                        value:item, 
                                        child:Text(item)
                          )
                        ).toList(),
                        onChanged: (value){
                                setState((){
                                    controller.amountUnits = value;
                                });
                            },
                        validator: (value){
                                if (value == null || value.isEmpty){
                                    return "please select a unit";
                                }
                                return null;
                            }
                          ),
                        ),

                       const SizedBox(width: 20),

                       Expanded(
                        flex: 2,
                        child: TextFormField(
                            controller: controller.calories,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                                labelText: "Ingredient calories",
                                border: OutlineInputBorder(),
                          ),
                            validator: (value){
                                if (value == null || value.trim().isEmpty){
                                    return "enter a valid amount";
                                }

                                return null;
                            },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                     _ingredients.add(Ingredient());
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

              ..._steps.asMap().entries.map((entry) {
                int stepIndex = entry.key;
                StepItem step = entry.value;

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: TextFormField(
                                controller: step.controller,
                                decoration: InputDecoration(
                                    labelText: "Step ${stepIndex + 1}:",
                                    border: const OutlineInputBorder()
                        ),
                           validator: (value){
                            if (value == null || value.isEmpty){
                                return "please enter a valid step";
                            }
                            return null;
                        },
                      ),
                    ),
                     ...step.subSteps.asMap().entries.map((subEntry){
                        int subIndex = subEntry.key;
                        TextEditingController subController = subEntry.value;
                        return Padding(
                            padding: const EdgeInsets.only(left: 20, bottom: 10),
                            child: TextFormField(
                                controller: subController,
                                decoration: InputDecoration(
                                    labelText: "Sub step ${stepIndex + 1}.${subIndex + 1}:",
                                    border: OutlineInputBorder()
                          ),
                              validator: (value){
                                if (value == null || value.isEmpty){
                                    return "please enter valid sub step";
                                }
                                return null;
                            },
                        ),
                      );
                    }), 
                    ElevatedButton(
                        onPressed: (){
                            setState((){
                            step.subSteps.add(TextEditingController());
                        }); 
                      },
                        child: const Text("add sub step"),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
        

              const SizedBox(height: 30),

              ElevatedButton(
                    onPressed: (){
                        setState(() {
                            _steps.add(StepItem());
                });
              },
                  child: const Text("add Step"),
            ),

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
