import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/add_recipe/services/recipe_service.dart';

class Ingredient {
  final TextEditingController name = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController calories = TextEditingController();
  String? amountUnits;
}

class SubStep {
  final TextEditingController subStep = TextEditingController();

  final TextEditingController subMinutes = TextEditingController();
  final TextEditingController subHours = TextEditingController();
}

//gonna follow the same format as ingredients and make step into a class
class StepItem {
  final TextEditingController controller = TextEditingController();
  final List<SubStep> subSteps = [];

  final TextEditingController minutes = TextEditingController();
  final TextEditingController hours = TextEditingController();
}

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final TextEditingController _recipeNameController = TextEditingController();

  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final List<Ingredient> _ingredients = [];
  final List<StepItem> _steps = [];

  String? _difficultySelector;
  final List<String> _dietaryOptions = [
    'Vegan',
    'Vegetarian',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Halal',
    'Others',
  ];

  String? _selectedDietary;
  final TextEditingController _otherDietaryController = TextEditingController();

  // Allergy options
  final List<String> _allergyOptions = [
    'Peanuts',
    'Milk',
    'Eggs',
    'Wheat',
    'Soy',
    'Fish',
    'Others',
  ];

  String? _selectedAllergy;
  final TextEditingController _otherAllergyController = TextEditingController();

  @override
  void initState() {
    // intialise
    super.initState();

    for (int i = 0; i < 3; i++) {
      _ingredients.add(Ingredient());
      _steps.add(StepItem());
    }
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _otherDietaryController.dispose();
    _otherAllergyController.dispose();

    for (var cont in _ingredients) {
      cont.name.dispose();
      cont.amount.dispose();
      cont.calories.dispose();
    }

    for (var cont in _steps) {
      cont.controller.dispose();
      cont.hours.dispose();
      cont.minutes.dispose();

      for (var subCont in cont.subSteps) {
        subCont.subStep.dispose();
        subCont.subMinutes.dispose();
        subCont.subHours.dispose();
      }
    }

    super.dispose();
  }

  Widget buildDurationFields(
    TextEditingController hours,
    TextEditingController minutes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: hours,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "hours",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 20),

            Expanded(
              child: TextFormField(
                controller: minutes,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "minutes",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTextInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  String _durationToISO(int hours, int minutes) {
    String result = "PT";
    if (hours > 0) {
      result += "${hours}H";
    }
    if (minutes > 0) {
      result += "${minutes}M";
    }
    if (result == "PT") {
      result += "0M";
    }
    return result;
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final name = _recipeNameController.text.trim();

      int hour = int.tryParse(_hoursController.text.trim()) ?? 0;
      int minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

      final difficulty = _difficultySelector;

      final ingredients = _ingredients.map((ingredient) {
        return {
          "ingredient-name": ingredient.name.text.trim(),
          "ingredient-amount": int.tryParse(ingredient.amount.text.trim()),
          "ingredient-calories": int.tryParse(ingredient.calories.text.trim()),
          "ingredient-unit": ingredient.amountUnits,
        };
      }).toList();
      final List<Map<String, dynamic>> steps = [];

      for (var entry in _steps.asMap().entries) {
        int stepIndex = entry.key;
        var step = entry.value;

        int stepHours = int.tryParse(step.hours.text) ?? 0;
        int stepMinutes = int.tryParse(step.minutes.text) ?? 0;

        steps.add({
          "step-index": "${stepIndex + 1}",
          "step-description": step.controller.text.trim(),
          "step-duration": _durationToISO(stepHours, stepMinutes),
        });
        for (var subEntry in step.subSteps.asMap().entries) {
          int subIndex = subEntry.key;
          var subStep = subEntry.value;

          steps.add({
            "step-index": "${stepIndex + 1}.${subIndex + 1}",
            "step-description": subStep.subStep.text.trim(),
            "step-duration": _durationToISO(
              int.tryParse(subStep.subHours.text.trim()) ?? 0,
              int.tryParse(subStep.subMinutes.text.trim()) ?? 0,
            ),
          });
        }
      }

      final time = _durationToISO(hour, minutes);

      print("Name: $name");
      print("Ingredients: $ingredients");
      print("Steps: $steps");
      print("${time}");
      print("${difficulty}");
      print("/n");
      print("${steps}");

      try {
        // build dietary/allergy payloads (include 'Others' text if provided)
        final List<String> dietaryPayload = [];
        if (_selectedDietary != null) {
          if (_selectedDietary == 'Others') {
            final other = _otherDietaryController.text.trim();
            if (other.isNotEmpty) dietaryPayload.add(other);
          } else {
            dietaryPayload.add(_selectedDietary!);
          }
        }

        final List<String> allergyPayload = [];
        if (_selectedAllergy != null) {
          if (_selectedAllergy == 'Others') {
            final other = _otherAllergyController.text.trim();
            if (other.isNotEmpty) allergyPayload.add(other);
          } else {
            allergyPayload.add(_selectedAllergy!);
          }
        }

        bool success = await RecipeService.addRecipe(
          name,
          ingredients,
          steps,
          time,
          difficulty!,
          dietaryPayload,
          allergyPayload,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("recipe saved")));
        if (success) {
          Navigator.of(context).maybePop();
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("recipe failed to save")));
      }
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
              buildTextInputField(
                controller: _recipeNameController,
                label: "Recipe name:",
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

              buildDurationFields(_hoursController, _minutesController),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _difficultySelector,
                decoration: const InputDecoration(
                  labelText: "select difficulty",
                  border: OutlineInputBorder(),
                ),
                items: ["easy", "medium", "hard"]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _difficultySelector = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "please select a difficulty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDietary,
                decoration: const InputDecoration(
                  labelText: 'Dietary requirement',
                  border: OutlineInputBorder(),
                ),
                items: _dietaryOptions
                    .map(
                      (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedDietary = val),
                validator: (val) {
                  return null;
                },
              ),

              //dietary textbox
              if (_selectedDietary == 'Others') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otherDietaryController,
                  decoration: const InputDecoration(
                    labelText: 'Please specify dietary requirement',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedDietary == 'Others' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please specify dietary requirement';
                    }
                    return null;
                  },
                ),
              ],

              //Allergy dropdown
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAllergy,
                decoration: const InputDecoration(
                  labelText: 'Allergy requirement',
                  border: OutlineInputBorder(),
                ),
                items: _allergyOptions
                    .map(
                      (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedAllergy = val),
                validator: (val) {
                  return null;
                },
              ),

              //Allergy textbox
              if (_selectedAllergy == 'Others') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otherAllergyController,
                  decoration: const InputDecoration(
                    labelText: 'Please specify allergy',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedAllergy == 'Others' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please specify allergy';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 20),

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
                        child: buildTextInputField(
                          controller: controller.name,
                          label: "enter and ingredient:",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "enter a valid name";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        flex: 2,
                        child: buildTextInputField(
                          controller: controller.amount,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                          label: "enter a ingredient quantity",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "enter a valid quantity";
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
                          items: ["g", "KG", "ml", "L"]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              controller.amountUnits = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "please select a unit";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        flex: 2,
                        child: buildTextInputField(
                          controller: controller.calories,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          label: "ingredient calories",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
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
                      child: buildTextInputField(
                        controller: step.controller,
                        label: " Step ${stepIndex + 1}:",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "please enter a valid step";
                          }
                          return null;
                        },
                      ),
                    ),

                    buildDurationFields(step.hours, step.minutes),

                    const SizedBox(height: 20),

                    ...step.subSteps.asMap().entries.map((subEntry) {
                      int subIndex = subEntry.key;
                      SubStep subStep = subEntry.value;
                      return Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextInputField(
                              controller: subStep.subStep,
                              label:
                                  "Sub Step ${stepIndex + 1}.${subIndex + 1}:",
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "please enter a valid sub step";
                                }
                                if (value.trim().length < 3) {
                                  return "please enter a longer sub step";
                                }
                                return null;
                              },
                            ),

                            buildDurationFields(
                              subStep.subHours,
                              subStep.subMinutes,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          step.subSteps.add(SubStep());
                        });
                      },
                      child: const Text("add sub step"),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _steps.add(StepItem());
                  });
                },
                child: const Text("add Step"),
              ),
              const SizedBox(height: 20),

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
