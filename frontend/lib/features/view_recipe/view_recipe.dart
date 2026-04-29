import 'package:flutter/material.dart';

class RecipePage extends StatefulWidget {
  final int recipeId;
  const RecipePage({super.key, required this.recipeId});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  // test data
  List<Map<String, dynamic>> steps = [];
  Set<int> completedSteps = {};

  int? currentStepId;

  @override
  void initState() {
    super.initState();
    loadRecipe();
  }

  Future<void> loadRecipe() async {
    // todo make fetch req i will need to make api response gonna put that class in core and use it ther
    // flake data
    steps = [
      {"id": 1, "text": "preheat onven"},
      {"id": 2, "text": "preheat onven2"},
      {"id": 3, "text": "preheat onven3"},
    ];
    completedSteps = {1};

    setState(() {
      currentStepId = steps.firstWhere(
        (s) => !completedSteps.contains(s["id"]),
      )["id"];
    });
  }

  Map<String, dynamic> get currentStep =>
      steps.firstWhere((s) => s["id"] == currentStepId);

  void completedstep() {
    setState(() {
      completedSteps.add(currentStepId!);
      //todo
      //change db
      final next = steps.where((s) => !completedSteps.contains(s["id"]));
      if (next.isEmpty) {
        currentStepId = null; //complete
      } else {
        currentStepId = next.first["id"];
      }
    });
  }

  double get progress =>
      steps.isEmpty ? 0 : completedSteps.length / steps.length;

  void goBack() {
    final completedList = completedSteps.toList();
    if (completedList.isEmpty) {
      return;
    }
    setState(() {
      currentStepId = completedList.last;
      completedSteps.remove(currentStepId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentStepId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("test recipe")),
        body: const Center(child: Text("completed recipe")),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("recipe page test")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: progress),

            const SizedBox(height: 20),

            Text("Step ${currentStep["id"]}"),

            const SizedBox(height: 20),

            Text(
              currentStep["text"],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: completedstep,
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
