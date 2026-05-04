import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/features/view_recipe/services/service_view_recipe.dart';

class RecipePage extends StatefulWidget {
  final int recipeId;
  const RecipePage({super.key, required this.recipeId});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  String recipeTitle = "";
  String? recipeTime;
  String? recipeDifficulty;

  List<Map<String, dynamic>> steps = [];
  Set<int> completedSteps = {};

  int? currentStepId;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecipe();
  }

  Future<void> loadRecipe() async {
    final response = await ViewService.viewRecipe(widget.recipeId.toString());

    if (response.statusCode != 200) {
      setState(() {
        isLoading = false;
      });
      // faile
      return;
    }

    final data = jsonDecode(response.response);

    recipeTitle = data["recipe-title"] ?? "";
    recipeTime = data["recipe-time"]?.toString();
    recipeDifficulty = data["recipe-difficulty"]?.toString();

    final fetchedSteps = data["recipe-steps"] ?? [];

    steps = [];

    for (final step in fetchedSteps) {
      steps.add({
        "id": int.parse(step["recipe-step-id"].toString()),
        "text": step["step-description"] ?? "",
        "duration": step["step-duration"],
        "completed": step["step-completion"] ?? false,
      });
    }
    completedSteps = {};

    for (final step in steps) {
      if (step["completed"] == true) {
        completedSteps.add(step["id"]);
      }
    }

    setState(() {
      final remaining = steps.where((s) => !completedSteps.contains(s["id"]));
      currentStepId = remaining.isEmpty ? null : remaining.first["id"];
      isLoading = false;
    });
  }

  Map<String, dynamic> get currentStep =>
      steps.firstWhere((s) => s["id"] == currentStepId);

  Future<void> completedStep() async {
    if (currentStepId == null) return;
    final stepToComplete = currentStepId;

    setState(() {
      completedSteps.add(currentStepId!);
      final next = steps.where((s) => !completedSteps.contains(s["id"]));
      currentStepId = next.isEmpty ? null : next.first["id"];
    });
    try {
      final response = await ViewService.completeStep(stepToComplete!);
      if (response.statusCode != 200) {
        debugPrint("good");
      }
    } catch (e) {
      // for error
      debugPrint("error $e");
    }
  }

  double get progress =>
      steps.isEmpty ? 0 : completedSteps.length / steps.length;

  Future<void> goBack() async {
    final completedList = completedSteps.toList();
    if (completedList.isEmpty) {
      return;
    }
    final stepToUncomplete = completedList.last;
    setState(() {
      currentStepId = completedList.last;
      completedSteps.remove(currentStepId);
    });

    try {
      final response = await ViewService.unCompleteStep(stepToUncomplete);
      if (response.statusCode != 200) {
        debugPrint("good");
      }
    } catch (e) {
      // could in future change to undo change to more accureatly show state of db id fails
      debugPrint("error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("loading")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentStepId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("test recipe")),
        body: const Center(child: Text("completed recipe")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeTitle),
        actions: [
          if (recipeTime != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(recipeTime!)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: progress),

            const SizedBox(height: 20),

            Text(
              "Step ${steps.indexWhere((s) => s["id"] == currentStepId) + 1} of ${steps.length}",
            ),

            if (recipeDifficulty != null) ...[
              const SizedBox(height: 10),
              Text("difficulty: $recipeDifficulty"),
            ],

            const SizedBox(height: 20),

            Text(
              currentStep["text"],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),

            if (currentStep["duration"] != null) ...[
              const SizedBox(height: 20),
              Text("${currentStep["duration"]}"),
            ],

            const Spacer(),

            ElevatedButton(
              onPressed: completedStep,
              child: const Text("complete step"),
            ),

            const SizedBox(height: 20),

            if (completedSteps.isNotEmpty)
              TextButton(onPressed: goBack, child: const Text("go back")),
          ],
        ),
      ),
    );
  }
}
