import 'package:flutter/material.dart';

class CookingTechnique {
  const CookingTechnique({
    required this.title,
    required this.description,
    required this.skillLevel,
    required this.bestFor,
    required this.timeRange,
    required this.steps,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String description;
  final String skillLevel;
  final String bestFor;
  final String timeRange;
  final List<String> steps;
  final IconData icon;
  final Color accent;
}

class CookingTechniquesPage extends StatelessWidget {
  const CookingTechniquesPage({super.key});

  static const List<CookingTechnique> _techniques = [
    CookingTechnique(
      title: 'Saute',
      description:
          'Cook quickly over medium-high heat with a small amount of fat.',
      skillLevel: 'Beginner',
      bestFor: 'Vegetables, shrimp, sliced chicken',
      timeRange: '5-12 min',
      steps: [
        'Heat pan first, then add oil.',
        'Keep ingredients moving for even browning.',
        'Do not crowd the pan to avoid steaming.',
      ],
      icon: Icons.local_fire_department,
      accent: Color(0xFFE26D5A),
    ),
    CookingTechnique(
      title: 'Braise',
      description:
          'Sear first, then cook covered with liquid for deep flavor and tenderness.',
      skillLevel: 'Intermediate',
      bestFor: 'Short ribs, chicken thighs, root vegetables',
      timeRange: '45-180 min',
      steps: [
        'Brown ingredients in batches for better fond.',
        'Add aromatics and deglaze with stock or wine.',
        'Cover and simmer low until fork-tender.',
      ],
      icon: Icons.soup_kitchen,
      accent: Color(0xFF6C584C),
    ),
    CookingTechnique(
      title: 'Roast',
      description:
          'Use dry oven heat to build caramelization and concentrated flavor.',
      skillLevel: 'Beginner',
      bestFor: 'Potatoes, squash, chicken, fish',
      timeRange: '20-90 min',
      steps: [
        'Preheat oven fully before loading tray.',
        'Use enough space between pieces for airflow.',
        'Turn once for balanced browning.',
      ],
      icon: Icons.outdoor_grill,
      accent: Color(0xFFBC6C25),
    ),
    CookingTechnique(
      title: 'Poach',
      description:
          'Gentle cooking in liquid below a simmer for delicate ingredients.',
      skillLevel: 'Intermediate',
      bestFor: 'Eggs, salmon, pears, chicken breast',
      timeRange: '6-25 min',
      steps: [
        'Keep liquid between 160-180 F (71-82 C).',
        'Flavor the poaching liquid with herbs and citrus.',
        'Rest briefly before serving to retain moisture.',
      ],
      icon: Icons.water_drop,
      accent: Color(0xFF4D908E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cooking Techniques')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E8), Color(0xFFF2F5F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _HeaderCard(techniqueCount: _techniques.length),
            const SizedBox(height: 16),
            ..._techniques.map((technique) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TechniqueCard(technique: technique),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.techniqueCount});

  final int techniqueCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3E46),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build better instincts in the kitchen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$techniqueCount core methods to help you cook with confidence.',
            style: const TextStyle(
              color: Color(0xFFD6E2E9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  const _TechniqueCard({required this.technique});

  final CookingTechnique technique;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: technique.accent.withValues(alpha: 0.25)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: technique.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(technique.icon, color: technique.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    technique.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(
                  backgroundColor: technique.accent.withValues(alpha: 0.15),
                  side: BorderSide.none,
                  label: Text(
                    technique.skillLevel,
                    style: TextStyle(
                      color: technique.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              technique.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Color(0xFF30353A),
              ),
            ),
            const SizedBox(height: 12),
            _MetaRow(label: 'Best for', value: technique.bestFor),
            const SizedBox(height: 6),
            _MetaRow(label: 'Typical time', value: technique.timeRange),
            const SizedBox(height: 12),
            const Text(
              'Quick method',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2933),
              ),
            ),
            const SizedBox(height: 8),
            ...technique.steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${entry.key + 1}. ${entry.value}',
                  style: const TextStyle(
                    color: Color(0xFF3E4C59),
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7B8794),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Color(0xFF323F4B))),
        ),
      ],
    );
  }
}
