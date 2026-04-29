import 'package:flutter/material.dart';

class RecipePage extends StatefulWidget {
  final int recipeId;
  const RecipePage({super.key, required this.recipeId});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  // test data
  final List<Map<String, dynamic>> steps = [
    {"id": 1, "text": "preheat oven"},
    {"id": 2, "text": "mix"},
    {"id": 3, "text": "fix"},
  ];
  Set<int> completedSteps = {};

  void toggleStep(int stepId) {
    setState(() {
      if (completedSteps.contains(stepId)) {
        completedSteps.remove(stepId);
      } else {
        completedSteps.add(stepId);
      }
    });
  }

  double get progress =>
      steps.isEmpty ? 0 : completedSteps.length / steps.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("recipe page test")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isDone = completedSteps.contains(step["id"]);

                  return ListTile(
                    title: Text(
                      step["text"], // needs changing for real dsat
                      style: TextStyle(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: Checkbox(
                      value: isDone,
                      onChanged: (_) => toggleStep(step["id"]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
